import 'dart:convert';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/src/execution_processor.dart';
import 'package:discoman_worker/src/heartbeat.dart';
import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  final workerId = UuidValue.fromString('0190d0c4-0000-7000-8000-000000000001');
  final executionId = UuidValue.fromString(
    '0190d0c4-0000-7000-8000-000000000002',
  );

  ClaimedExecution claimed({String inputsJson = '{}'}) => ClaimedExecution(
    executionId: executionId,
    kind: ExecutionKind.publishedApp,
    computeMode: ComputeMode.cloud,
    projectId: 'project-1',
    source: 'def main():\n  return {}\n',
    entrypointName: 'main',
    inputsJson: inputsJson,
    timeoutSeconds: 60,
    attempt: 1,
  );

  late _FakeComputeWorker computeWorker;
  late _FakeHeartbeat heartbeat;
  late _FakePythonRunner pythonRunner;
  late ExecutionProcessor processor;
  final requests = <http.Request>[];
  var storageResponse = (http.Request request) async => http.Response('', 201);

  setUp(() {
    requests.clear();
    storageResponse = (request) async => http.Response('', 201);
    final client = _FakeClient();
    computeWorker = _FakeComputeWorker(client);
    client.fake = computeWorker;
    heartbeat = _FakeHeartbeat(client, workerId);
    pythonRunner = _FakePythonRunner({
      'chart': {
        'kind': 'image',
        'name': 'chart',
        'extension': 'png',
        'mimeType': 'image/png',
        'sizeBytes': 3,
        'base64': 'AAAA',
      },
    });
    processor = ExecutionProcessor(
      client: client,
      workerId: workerId,
      pythonRunner: pythonRunner,
      heartbeat: heartbeat,
      reportRetryDelay: Duration.zero,
      httpClient: MockClient((request) {
        requests.add(request);
        return storageResponse(request);
      }),
    );
  });

  test(
    'uploads an output straight to storage when the server offers it',
    () async {
      computeWorker.directUploads = true;

      await processor.process(claimed());

      expect(requests.single.method, 'PUT');
      expect(requests.single.url.toString(), 'https://blob.test/upload?sp=c');
      expect(requests.single.headers['x-ms-blob-type'], 'BlockBlob');
      expect(requests.single.bodyBytes, base64Decode('AAAA'));
      final outputs =
          jsonDecode(computeWorker.reports.single.outputsJson!) as Map;
      expect(outputs['chart']['storagePath'], 'outputs/published/x/chart.png');
    },
  );

  test('reports a failed direct upload as a failed run', () async {
    computeWorker.directUploads = true;
    storageResponse = (request) async => http.Response('', 403);

    await processor.process(claimed());

    expect(computeWorker.reports.single.errorReason, 'outputUploadFailed');
  });

  test('hands Python the input files it downloads', () async {
    storageResponse = (request) async => http.Response.bytes([1, 2, 3], 200);

    await processor.process(
      claimed(
        inputsJson: jsonEncode({
          'photo': {
            'kind': 'image',
            'name': 'cat.png',
            'extension': 'png',
            'mimeType': 'image/png',
            'sizeBytes': 3,
            'storagePath': 'inputs/published/x/photo.png',
            'downloadUrl': 'https://blob.test/inputs/published/x/photo.png',
          },
          'count': 2,
        }),
      ),
    );

    expect(requests.first.method, 'GET');
    expect(pythonRunner.lastInputs, {
      'photo': {
        'kind': 'image',
        'name': 'cat.png',
        'extension': 'png',
        'mimeType': 'image/png',
        'sizeBytes': 3,
        'base64': base64Encode([1, 2, 3]),
      },
      'count': 2,
    });
  });

  test('fails the run when an input file cannot be downloaded', () async {
    storageResponse = (request) async => http.Response('', 404);

    await processor.process(
      claimed(
        inputsJson: jsonEncode({
          'photo': {
            'kind': 'image',
            'name': 'cat.png',
            'downloadUrl': 'https://blob.test/inputs/missing.png',
          },
        }),
      ),
    );

    expect(pythonRunner.lastInputs, isNull);
    expect(computeWorker.reports.single.errorReason, 'inputDownloadFailed');
  });

  test('reports a rejected output upload as a failed run', () async {
    computeWorker.uploadError = ScriptRunException(
      message: 'The asset size does not match or exceeds the limit.',
      reason: 'invalidInputs',
    );

    await processor.process(claimed());

    final outcome = computeWorker.reports.single;
    expect(outcome.success, isFalse);
    expect(outcome.errorReason, 'outputUploadFailed');
    expect(
      outcome.errorMessage,
      'The asset size does not match or exceeds the limit.',
    );
  });

  test('reports an unreachable storage as a failed run', () async {
    computeWorker.uploadError = Exception('connection reset');

    await processor.process(claimed());

    final outcome = computeWorker.reports.single;
    expect(outcome.success, isFalse);
    expect(outcome.errorReason, 'outputUploadFailed');
  });

  test('keeps the lease alive until the result is reported', () async {
    final activeDuring = <String, bool>{};
    computeWorker
      ..onUpload = (() => activeDuring['upload'] = heartbeat.active)
      ..onReport = (() => activeDuring['report'] = heartbeat.active);

    await processor.process(claimed());

    expect(activeDuring, {'upload': true, 'report': true});
    expect(heartbeat.active, isFalse);
  });

  test('retries a report that fails in transit', () async {
    computeWorker.reportErrors.addAll([
      Exception('connection reset'),
      Exception('connection reset'),
    ]);

    await processor.process(claimed());

    expect(computeWorker.reportCalls, 3);
    expect(computeWorker.reports.single.success, isTrue);
  });

  test('gives up after three failed reports', () async {
    computeWorker.reportErrors.addAll(
      List.generate(5, (_) => Exception('connection reset')),
    );

    await processor.process(claimed());

    expect(computeWorker.reportCalls, 3);
    expect(computeWorker.reports, isEmpty);
  });

  test('does not retry a report the server rejected', () async {
    computeWorker.reportErrors.add(
      ScriptRunException(
        message: 'This execution is not claimed by the calling worker.',
        reason: 'forbidden',
      ),
    );

    await processor.process(claimed());

    expect(computeWorker.reportCalls, 1);
  });
}

class _FakeClient extends Client {
  _FakeClient() : super('http://localhost:1/');

  late EndpointComputeWorker fake;

  @override
  EndpointComputeWorker get computeWorker => fake;
}

class _FakeComputeWorker extends EndpointComputeWorker {
  _FakeComputeWorker(super.caller);

  Object? uploadError;
  var directUploads = false;
  void Function()? onUpload;
  void Function()? onReport;
  final reportErrors = <Object>[];
  var reportCalls = 0;
  final reports = <ExecutionOutcome>[];

  @override
  Future<ExecutionAssetUploadTicket> createOutputUpload(
    UuidValue workerId,
    UuidValue executionId,
    ExecutionAssetUploadRequest asset,
  ) async {
    if (!directUploads) {
      throw ScriptRunException(
        message: 'Direct uploads are not configured on this server.',
        reason: 'blobNotConfigured',
      );
    }
    onUpload?.call();
    return ExecutionAssetUploadTicket(
      asset: ExecutionAssetRef(
        outputKey: asset.outputKey,
        kind: asset.kind,
        name: asset.name,
        fileExtension: asset.fileExtension,
        mimeType: asset.mimeType,
        sizeBytes: asset.sizeBytes,
        storagePath: 'outputs/published/x/${asset.outputKey}.png',
        downloadUrl: 'https://blob.test/outputs/published/x/chart.png',
      ),
      uploadUrl: 'https://blob.test/upload?sp=c',
    );
  }

  @override
  Future<ExecutionAssetRef> uploadExecutionAsset(
    UuidValue workerId,
    UuidValue executionId,
    ExecutionAssetUpload asset,
  ) async {
    onUpload?.call();
    final error = uploadError;
    if (error != null) throw error;
    return ExecutionAssetRef(
      outputKey: asset.outputKey,
      kind: asset.kind,
      name: asset.name,
      fileExtension: asset.fileExtension,
      mimeType: asset.mimeType,
      sizeBytes: asset.sizeBytes,
      storagePath: 'executionAssets/$executionId/${asset.outputKey}',
      downloadUrl: 'https://example.test/${asset.outputKey}',
    );
  }

  @override
  Future<void> reportResult(
    UuidValue workerId,
    UuidValue executionId,
    ExecutionOutcome outcome,
  ) async {
    reportCalls++;
    onReport?.call();
    if (reportErrors.isNotEmpty) throw reportErrors.removeAt(0);
    reports.add(outcome);
  }
}

class _FakeHeartbeat extends ExecutionHeartbeat {
  _FakeHeartbeat(Client client, UuidValue workerId)
    : super(client, workerId, 20);

  bool active = false;

  @override
  void start(UuidValue executionId) => active = true;

  @override
  void stop() => active = false;
}

class _FakePythonRunner extends PythonRunner {
  _FakePythonRunner(this.outputs) : super('python3');

  final Map<String, dynamic> outputs;
  Map<String, dynamic>? lastInputs;

  @override
  Future<PythonRunResult> run({
    required String source,
    required String entrypointName,
    required Map<String, dynamic> inputs,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
  }) async {
    lastInputs = inputs;
    return PythonRunResult(
      success: true,
      canceled: false,
      timedOut: false,
      outputs: outputs,
      durationMs: 5,
      logs: const [],
      errorMessage: null,
    );
  }
}
