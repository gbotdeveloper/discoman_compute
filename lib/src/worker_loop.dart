import 'dart:async';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

import 'auth/cloud_auth.dart';
import 'auth/remote_auth.dart';
import 'auth/session.dart';
import 'execution_processor.dart';
import 'heartbeat.dart';
import 'python/python_runner.dart';
import 'remote_worker.dart';
import 'worker_config.dart';

/// Runs the worker in the mode selected by [config], returning the process exit
/// code (0 normal, 1 on a fatal auth/bus error).
Future<int> runWorker(WorkerConfig config) async {
  switch (config.mode) {
    case WorkerMode.cloud:
      return _runCloudWorker(config);
    case WorkerMode.remote:
      return _runRemoteWorker(config);
  }
}

/// Cloud (Container App Job) mode: authenticate with the shared secret, drain
/// the queue, and exit 0 as soon as it is empty — or when the replica is close
/// enough to its platform timeout that a new claim might not finish in time.
Future<int> _runCloudWorker(WorkerConfig config) async {
  final session = buildWorkerSession(config.serverUrl);
  try {
    await cloudLogin(session, config.workerSecret);
  } catch (error) {
    stderr.writeln('Cloud authentication failed: $error');
    return 1;
  }

  final WorkerRegistration registration;
  try {
    registration = await session.client.computeWorker.register(
      config.hostname,
      workerVersion,
    );
  } catch (error) {
    stderr.writeln('Worker registration failed: $error');
    return 1;
  }

  final workerId = registration.workerId;
  final processor = _buildProcessor(session, registration, config);

  final startedAt = DateTime.now();
  // Reserve enough headroom for one in-flight job below the replica timeout.
  // Grows as jobs with larger timeouts are observed so the check stays honest.
  var reservedSeconds = 900;

  var exitCode = 0;
  try {
    while (true) {
      final elapsed = DateTime.now().difference(startedAt).inSeconds;
      if (elapsed + reservedSeconds + 60 > config.maxRuntimeSeconds) {
        stdout.writeln('Approaching the replica timeout; stopping claims.');
        break;
      }

      // Cloud replicas run whatever the row carries, so the served-project
      // list a self-hosted machine sends means nothing here.
      final claimed = await session.client.computeWorker.claimNext(
        workerId,
        const [],
      );
      if (claimed == null) {
        stdout.writeln('Queue empty; drain complete.');
        break;
      }
      if (claimed.timeoutSeconds > reservedSeconds) {
        reservedSeconds = claimed.timeoutSeconds;
      }
      await processor.process(claimed);
    }
  } catch (error) {
    stderr.writeln('Fatal error in the cloud worker loop: $error');
    exitCode = 1;
  }

  await _safeDeregister(session.client, workerId);
  session.client.close();
  return exitCode;
}

/// Remote (self-hosted) mode: run [RemoteWorker] until Ctrl+C, printing its
/// log to stdout. The loop itself lives in that class so the desktop app can
/// run the same worker in a window.
Future<int> _runRemoteWorker(WorkerConfig config) async {
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

  final failed = worker.state
      .firstWhere((state) => state == RemoteWorkerState.failed)
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

ExecutionProcessor _buildProcessor(
  WorkerSession session,
  WorkerRegistration registration,
  WorkerConfig config,
) {
  final heartbeat = ExecutionHeartbeat(
    session.client,
    registration.workerId,
    registration.heartbeatIntervalSeconds,
  );
  return ExecutionProcessor(
    client: session.client,
    workerId: registration.workerId,
    pythonRunner: PythonRunner(config.pythonPath),
    heartbeat: heartbeat,
  );
}

Future<void> _safeDeregister(Client client, UuidValue workerId) async {
  try {
    await client.computeWorker.deregister(workerId);
  } catch (_) {
    // The lease sweeper reclaims anything left running if deregister fails.
  }
}
