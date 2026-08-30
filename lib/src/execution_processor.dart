import 'dart:convert';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

import 'heartbeat.dart';
import 'python/python_runner.dart';

/// Runs one claimed execution end to end: Python execution (honoring cancel and
/// timeout), output-asset upload, and the final `reportResult` call.
class ExecutionProcessor {
  ExecutionProcessor({
    required this.client,
    required this.workerId,
    required this.pythonRunner,
    required this.heartbeat,
  });

  final Client client;
  final UuidValue workerId;
  final PythonRunner pythonRunner;
  final ExecutionHeartbeat heartbeat;

  Future<void> process(ClaimedExecution claimed) async {
    final inputs = _decodeInputs(claimed.inputsJson);

    heartbeat.start(claimed.executionId);
    PythonRunResult result;
    try {
      result = await pythonRunner.run(
        source: claimed.source,
        entrypointName: claimed.entrypointName,
        inputs: inputs,
        timeoutSeconds: claimed.timeoutSeconds,
        cancelRequested: () => heartbeat.cancelRequested,
      );
    } finally {
      heartbeat.stop();
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

    final outputs = await _uploadAssets(
      claimed.executionId,
      result.outputs ?? const {},
    );
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

  /// Uploads every asset-shaped output value and replaces it with the storage
  /// reference descriptor the history writer expects. Non-asset values pass
  /// through unchanged.
  Future<Map<String, dynamic>> _uploadAssets(
    UuidValue executionId,
    Map<String, dynamic> outputs,
  ) async {
    final result = <String, dynamic>{};
    for (final entry in outputs.entries) {
      final value = entry.value;
      if (!_isAssetOutput(value)) {
        result[entry.key] = value;
        continue;
      }
      final asset = value as Map;
      final ref = await client.computeWorker.uploadExecutionAsset(
        workerId,
        executionId,
        ExecutionAssetUpload(
          outputKey: entry.key,
          kind: asset['kind'] as String,
          name: asset['name'] as String,
          // The runner emits 'extension'; the upload DTO calls it fileExtension.
          fileExtension: asset['extension'] as String,
          mimeType: asset['mimeType'] as String,
          sizeBytes: asset['sizeBytes'] as int,
          base64: asset['base64'] as String,
        ),
      );
      // The history writer reads 'extension' (not 'fileExtension') from the
      // outputs map, so emit the descriptor with that key.
      result[entry.key] = {
        'kind': ref.kind,
        'name': ref.name,
        'extension': ref.fileExtension,
        'mimeType': ref.mimeType,
        'sizeBytes': ref.sizeBytes,
        'storagePath': ref.storagePath,
        'downloadUrl': ref.downloadUrl,
      };
    }
    return result;
  }

  bool _isAssetOutput(dynamic value) {
    return value is Map &&
        (value['kind'] == 'image' || value['kind'] == 'file') &&
        value['base64'] is String &&
        value['name'] is String &&
        value['extension'] is String &&
        value['mimeType'] is String &&
        value['sizeBytes'] is int;
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
    try {
      await client.computeWorker.reportResult(workerId, executionId, outcome);
    } catch (error) {
      // reportResult is exactly-once and idempotent server-side; if it fails
      // (transient), the lease sweeper reclaims the run. Log and move on rather
      // than crash the worker.
      stderr.writeln('Failed to report result for $executionId: $error');
    }
  }
}
