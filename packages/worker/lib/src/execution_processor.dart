import 'dart:convert';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
import 'package:http/http.dart' as http;

import 'heartbeat.dart';
import 'python/contract_extractor.dart';
import 'python/pip_names.dart';
import 'python/python_runner.dart';
import 'python/run_usage.dart';
import 'scripts/script_store.dart';

/// Runs one claimed execution end to end: Python execution (honoring cancel and
/// timeout), output-asset upload, and the final `reportResult` call.
class ExecutionProcessor {
  ExecutionProcessor({
    required this.client,
    required this.workerId,
    required this.pythonRunner,
    required this.heartbeat,
    ScriptStore? scriptStore,
    this.reportRetryDelay = const Duration(seconds: 1),
    this.externalCodeFor,
    this.onUsage,
    this.onFailed,
    http.Client? httpClient,
  }) : _injectedScriptStore = scriptStore,
       _http = httpClient ?? http.Client();

  final Client client;
  final UuidValue workerId;
  final PythonRunner pythonRunner;
  final ExecutionHeartbeat heartbeat;
  final Duration reportRetryDelay;

  /// The code outside Discoman a project uses on this machine. Given only on
  /// a creator's own computer, where each run is stamped with it.
  final Future<List<ExternalCodeVersion>> Function(String projectId)?
  externalCodeFor;

  /// Told what each measured run used, by project.
  final void Function(String projectId, RunUsage usage)? onUsage;

  /// Told why each run that did not succeed failed.
  final void Function(UuidValue executionId, String message)? onFailed;

  final http.Client _http;
  bool _directUploads = true;

  final ScriptStore? _injectedScriptStore;

  /// Where scripts linked with `discoman-compute link` are kept. Only read for
  /// runs whose script never reached the server.
  ///
  /// Resolved on first use rather than in the constructor: a cloud replica
  /// never reads a local script, and its container has no home directory to
  /// resolve one from.
  late final ScriptStore scriptStore =
      _injectedScriptStore ?? ScriptStore.defaultLocation();

  Future<void> process(ClaimedExecution claimed) async {
    final String source;
    try {
      source = _resolveSource(claimed);
    } on _MissingLocalScript catch (error) {
      // The run is finished here rather than left to time out: the person
      // waiting on the app should be told, and a lease that expires would
      // just be retried into the same missing file.
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'scriptMissing',
          errorMessage: error.message,
          warnings: const [],
          logs: const [],
        ),
      );
      return;
    }

    final inputs = _decodeInputs(claimed.inputsJson);

    // Input files are downloaded into the run folder and outputs read from it,
    // so it lives as long as the whole run.
    final runDir = Directory.systemTemp.createTempSync('discoman_compute_');
    heartbeat.start(claimed.executionId);
    try {
      await _runAndReport(claimed, source, inputs, runDir);
    } finally {
      heartbeat.stop();
      try {
        runDir.deleteSync(recursive: true);
      } catch (_) {
        // Best effort cleanup.
      }
    }
  }

  Future<void> _runAndReport(
    ClaimedExecution claimed,
    String source,
    Map<String, dynamic> inputs,
    Directory runDir,
  ) async {
    try {
      inputs = await _downloadInputFiles(inputs, runDir);
    } catch (error) {
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'inputDownloadFailed',
          errorMessage: 'An input file could not be read: $error',
          warnings: const [],
          logs: const [],
        ),
      );
      return;
    }

    await _stampExternalCode(claimed);

    final result = await pythonRunner.run(
      source: source,
      entrypointName: claimed.entrypointName,
      inputs: inputs,
      timeoutSeconds: claimed.timeoutSeconds,
      cancelRequested: () => heartbeat.cancelRequested,
      outputTypes: _declaredOutputTypes(source),
      runDirectory: runDir,
    );
    final usage = result.usage;
    if (usage != null) {
      try {
        onUsage?.call(claimed.projectId, usage);
      } catch (_) {
        // A measurement that cannot be kept must not fail the run.
      }
    }

    if (result.canceled) {
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'canceled',
          errorMessage: 'Execution canceled.',
          durationMs: result.durationMs,
          warnings: const [],
          logs: result.logs,
        ),
      );
      return;
    }

    final missingModule = result.missingModule;
    if (!result.success && missingModule != null) {
      final package = pipPackageFor(missingModule);
      final note = manualInstallNote(package);
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'missingPackage',
          errorMessage:
              'The script imports "$missingModule", but the Python running '
              'it does not have it. '
              '${note ?? 'Install it with: python -m pip install $package'}',
          durationMs: result.durationMs,
          warnings: const [],
          logs: result.logs,
        ),
      );
      return;
    }

    if (!result.success) {
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'executorError',
          errorMessage: result.errorMessage,
          durationMs: result.durationMs,
          warnings: const [],
          logs: result.logs,
        ),
      );
      return;
    }

    final Map<String, dynamic> outputs;
    try {
      outputs = await _uploadAssets(
        claimed.executionId,
        result.outputs ?? const {},
      );
    } catch (error) {
      await _report(
        claimed.executionId,
        ExecutionOutcome(
          success: false,
          errorReason: 'outputUploadFailed',
          errorMessage: error is ScriptRunException
              ? error.message
              : 'The run finished but its output files could not be saved.',
          durationMs: result.durationMs,
          warnings: const [],
          logs: result.logs,
        ),
      );
      return;
    }
    await _report(
      claimed.executionId,
      ExecutionOutcome(
        success: true,
        outputsJson: jsonEncode(outputs),
        durationMs: result.durationMs,
        warnings: const [],
        logs: result.logs,
      ),
    );
  }

  /// Best effort: a run is not held back because its stamp could not be
  /// written.
  Future<void> _stampExternalCode(ClaimedExecution claimed) async {
    final read = externalCodeFor;
    if (read == null) return;
    try {
      final code = await read(claimed.projectId);
      if (code.isEmpty) return;
      await client.computeWorker.stampExternalCode(
        workerId,
        claimed.executionId,
        code,
      );
    } catch (_) {}
  }

  Map<String, String>? _declaredOutputTypes(String source) {
    try {
      return declaredOutputTypes(source);
    } catch (_) {
      // The runner then reads the returned values as they are.
      return null;
    }
  }

  /// Uploads every asset-shaped output value and replaces it with the storage
  /// reference descriptor the history writer expects. A list of files is
  /// uploaded file by file, each named after the key and its position.
  /// Non-asset values pass through unchanged.
  Future<Map<String, dynamic>> _uploadAssets(
    UuidValue executionId,
    Map<String, dynamic> outputs,
  ) async {
    final result = <String, dynamic>{};
    for (final entry in outputs.entries) {
      final value = entry.value;
      if (_isAssetOutput(value)) {
        result[entry.key] = await _uploadedDescriptor(
          executionId,
          entry.key,
          value as Map<dynamic, dynamic>,
        );
      } else if (value is List &&
          value.isNotEmpty &&
          value.every(_isAssetOutput)) {
        result[entry.key] = [
          for (var i = 0; i < value.length; i++)
            await _uploadedDescriptor(
              executionId,
              '${entry.key}_${i + 1}',
              value[i] as Map<dynamic, dynamic>,
            ),
        ];
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _uploadedDescriptor(
    UuidValue executionId,
    String outputKey,
    Map<dynamic, dynamic> asset,
  ) async {
    final ref = await _uploadAsset(executionId, outputKey, asset);
    // The history writer reads 'extension' (not 'fileExtension') from the
    // outputs map, so emit the descriptor with that key.
    return {
      'kind': ref.kind,
      'name': ref.name,
      'extension': ref.fileExtension,
      'mimeType': ref.mimeType,
      'sizeBytes': ref.sizeBytes,
      'storagePath': ref.storagePath,
      'downloadUrl': ref.downloadUrl,
    };
  }

  /// Uploads one output file straight to storage, or through the server when
  /// it does not offer direct uploads.
  Future<ExecutionAssetRef> _uploadAsset(
    UuidValue executionId,
    String outputKey,
    Map<dynamic, dynamic> asset,
  ) async {
    if (_directUploads) {
      try {
        final ticket = await client.computeWorker.createOutputUpload(
          workerId,
          executionId,
          ExecutionAssetUploadRequest(
            outputKey: outputKey,
            kind: asset['kind'] as String,
            name: asset['name'] as String,
            fileExtension: asset['extension'] as String,
            mimeType: asset['mimeType'] as String,
            sizeBytes: asset['sizeBytes'] as int,
          ),
        );
        final response = await _http
            .put(
              Uri.parse(ticket.uploadUrl),
              headers: {
                'x-ms-blob-type': 'BlockBlob',
                'Content-Type': asset['mimeType'] as String,
              },
              body: await File(asset['path'] as String).readAsBytes(),
            )
            .timeout(const Duration(minutes: 2));
        if (response.statusCode != 201) {
          throw StateError(
            'Output upload failed (HTTP ${response.statusCode}).',
          );
        }
        return ticket.asset;
      } on ScriptRunException catch (error) {
        if (error.reason != 'blobNotConfigured') rethrow;
        _directUploads = false;
      }
    }

    return client.computeWorker.uploadExecutionAsset(
      workerId,
      executionId,
      ExecutionAssetUpload(
        outputKey: outputKey,
        kind: asset['kind'] as String,
        name: asset['name'] as String,
        // The runner emits 'extension'; the upload DTO calls it fileExtension.
        fileExtension: asset['extension'] as String,
        mimeType: asset['mimeType'] as String,
        sizeBytes: asset['sizeBytes'] as int,
        base64: base64Encode(await File(asset['path'] as String).readAsBytes()),
      ),
    );
  }

  /// Input files arrive as links to storage. Each is downloaded into
  /// [runDir] under its own name, and Python is given its path; a list of
  /// files becomes a list of paths.
  Future<Map<String, dynamic>> _downloadInputFiles(
    Map<String, dynamic> inputs,
    Directory runDir,
  ) async {
    var count = 0;
    Future<String> save(String key, Map<dynamic, dynamic> value) =>
        _saveInputFile(key, value, runDir, ++count);

    final result = <String, dynamic>{};
    for (final entry in inputs.entries) {
      final value = entry.value;
      if (_isInputFile(value)) {
        result[entry.key] = await save(
          entry.key,
          value as Map<dynamic, dynamic>,
        );
      } else if (value is List &&
          value.isNotEmpty &&
          value.every(_isInputFile)) {
        result[entry.key] = [
          for (final item in value)
            await save(entry.key, item as Map<dynamic, dynamic>),
        ];
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  bool _isInputFile(dynamic value) =>
      value is Map &&
      (value['kind'] == 'image' || value['kind'] == 'file') &&
      (value['downloadUrl'] is String || value['base64'] is String);

  Future<String> _saveInputFile(
    String key,
    Map<dynamic, dynamic> value,
    Directory runDir,
    int position,
  ) async {
    final List<int> bytes;
    if (value['base64'] case final String inline) {
      bytes = base64Decode(inline);
    } else {
      final response = await _http
          .get(Uri.parse(value['downloadUrl'] as String))
          .timeout(const Duration(minutes: 2));
      if (response.statusCode != 200) {
        throw StateError('"$key" (HTTP ${response.statusCode})');
      }
      bytes = response.bodyBytes;
    }
    final sep = Platform.pathSeparator;
    final dir = Directory('${runDir.path}${sep}inputs$sep$position')
      ..createSync(recursive: true);
    final file = File('${dir.path}$sep${inputFileName(value)}');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  bool _isAssetOutput(dynamic value) {
    return value is Map &&
        (value['kind'] == 'image' || value['kind'] == 'file') &&
        value['path'] is String &&
        value['name'] is String &&
        value['extension'] is String &&
        value['mimeType'] is String &&
        value['sizeBytes'] is int;
  }

  /// The Python to run: the server's snapshot when it has one, otherwise this
  /// machine's own copy of the project's script.
  ///
  /// A null snapshot means the creator linked the script with
  /// `discoman-compute link` and it was never uploaded, so we are the only
  /// place it exists.
  String _resolveSource(ClaimedExecution claimed) {
    final snapshot = claimed.source;
    if (snapshot != null) return snapshot;

    final file = scriptStore.fileFor(claimed.projectId);
    if (!file.existsSync()) {
      throw _MissingLocalScript(
        'No script is linked to this project on this machine. Run '
        "'discoman-compute link' here to attach it.",
      );
    }
    try {
      return file.readAsStringSync();
    } on IOException catch (error) {
      throw _MissingLocalScript(
        'Could not read the linked script at ${file.path}: $error',
      );
    }
  }

  Map<String, dynamic> _decodeInputs(String inputsJson) {
    if (inputsJson.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(inputsJson);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // Server validated inputs at submit time; treat anything odd as empty.
    }
    return {};
  }

  Future<void> _report(UuidValue executionId, ExecutionOutcome outcome) async {
    if (!outcome.success && outcome.errorReason != 'canceled') {
      onFailed?.call(executionId, outcome.errorMessage ?? 'The run failed.');
    }
    const attempts = 3;
    for (var attempt = 1; ; attempt++) {
      try {
        await client.computeWorker.reportResult(workerId, executionId, outcome);
        return;
      } on ScriptRunException catch (error) {
        stderr.writeln('Result for $executionId rejected: ${error.message}');
        return;
      } catch (error) {
        if (attempt == attempts) {
          stderr.writeln('Failed to report result for $executionId: $error');
          return;
        }
        await Future<void>.delayed(reportRetryDelay * attempt);
      }
    }
  }
}

/// Raised when a run needs this machine's copy of a script and it is not there.
class _MissingLocalScript implements Exception {
  _MissingLocalScript(this.message);

  final String message;
}

/// The name an input file is saved under: the one it was uploaded with, minus
/// anything a file name cannot hold on Windows or macOS.
String inputFileName(Map<dynamic, dynamic> value) {
  final extension = '${value['extension'] ?? ''}'.replaceAll(
    RegExp(r'[^A-Za-z0-9]'),
    '',
  );
  var name = '${value['name'] ?? ''}'
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .trim()
      .replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
  if (RegExp(
    r'^(con|prn|aux|nul|com\d|lpt\d)(\.|$)',
    caseSensitive: false,
  ).hasMatch(name)) {
    name = '_$name';
  }
  if (name.isEmpty) name = 'input';
  if (extension.isNotEmpty &&
      !name.toLowerCase().endsWith('.${extension.toLowerCase()}')) {
    name = '$name.$extension';
  }
  return name;
}
