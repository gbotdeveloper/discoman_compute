import 'dart:async';
import 'dart:io';

import 'auth/remote_auth.dart';
import 'remote_worker.dart';
import 'worker_config.dart';

/// Runs [RemoteWorker] until Ctrl+C, printing its log to stdout, and returns
/// the process exit code (0 normal, 1 when it fails). The loop itself lives in
/// that class so the desktop app can run the same worker in a window.
Future<int> runWorker(WorkerConfig config) async {
  final worker = RemoteWorker(config);
  final logSubscription = worker.log.listen(stdout.writeln);

  try {
    await worker.start();
  } on RemoteAuthException catch (error) {
    stderr.writeln(error.message);
    await logSubscription.cancel();
    return 1;
  } catch (error) {
    stderr.writeln('Remote worker failed to start: $error');
    await logSubscription.cancel();
    return 1;
  }

  stdout.writeln('Press Ctrl+C to stop.');

  // Ctrl+C stops the worker cleanly rather than killing the process mid-run,
  // so the machine deregisters instead of waiting out its lease.
  final stopped = Completer<void>();
  final sigint = ProcessSignal.sigint.watch().listen((_) {
    if (!stopped.isCompleted) stopped.complete();
  });

  // The stream closes on a clean stop without ever failing.
  final failed = worker.state
      .firstWhere(
        (state) => state == RemoteWorkerState.failed,
        orElse: () => RemoteWorkerState.stopped,
      )
      .then((_) {
        if (!stopped.isCompleted) stopped.complete();
      });
  unawaited(failed);

  await stopped.future;
  await sigint.cancel();

  final exitCode = worker.currentState == RemoteWorkerState.failed ? 1 : 0;
  await worker.dispose();
  await logSubscription.cancel();
  return exitCode;
}
