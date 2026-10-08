import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/src/execution_processor.dart';
import 'package:discoman_worker/src/heartbeat.dart';
import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:test/test.dart';

void main() {
  final workerId = UuidValue.fromString('0190d0c4-0000-7000-8000-000000000001');
  final executionId = UuidValue.fromString(
    '0190d0c4-0000-7000-8000-000000000002',
  );

  ClaimedExecution claimed() => ClaimedExecution(
    executionId: executionId,
    kind: ExecutionKind.publishedApp,
    computeMode: ComputeMode.cloud,
    projectId: 'project-1',
    source: 'def main():\n  return {}\n',
    entrypointName: 'main',
    inputsJson: '{}',
    timeoutSeconds: 60,
    attempt: 1,
  );

  late _FakeComputeWorker computeWorker;
  late _FakeHeartbeat heartbeat;
  late ExecutionProcessor processor;

  setUp(() {
    final client = _FakeClient();
    computeWorker = _FakeComputeWorker(client);
    client.fake = computeWorker;
    heartbeat = _FakeHeartbeat(client, workerId);
    processor = ExecutionProcessor(
      client: client,
      workerId: workerId,
      pythonRunner: _FakePythonRunner({
        'chart': {
          'kind': 'image',
          'name': 'chart',
          'extension': 'png',
          'mimeType': 'image/png',
          'sizeBytes': 3,
          'base64': 'AAAA',
        },
      }),
      heartbeat: heartbeat,
    );
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
  void Function()? onUpload;
  void Function()? onReport;
  final reports = <ExecutionOutcome>[];

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
    onReport?.call();
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

  @override
  Future<PythonRunResult> run({
    required String source,
    required String entrypointName,
    required Map<String, dynamic> inputs,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
  }) async => PythonRunResult(
    success: true,
    canceled: false,
    timedOut: false,
    outputs: outputs,
    durationMs: 5,
    logs: const [],
    errorMessage: null,
  );
}
