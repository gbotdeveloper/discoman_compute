import 'dart:async';

import 'package:discoman_client/discoman_client.dart';

import 'auth/remote_auth.dart';
import 'auth/session.dart';
import 'execution_processor.dart';
import 'heartbeat.dart';
import 'python/python_runner.dart';
import 'scripts/script_store.dart';
import 'settings/worker_settings.dart';
import 'worker_config.dart';

/// How far along the worker is, for anything that shows the creator a status.
enum RemoteWorkerState {
  stopped,

  /// Signing in and registering; not yet claiming runs.
  connecting,

  /// Registered and claiming runs.
  online,

  /// Stopped by an error rather than by the creator.
  failed,
}

/// The self-hosted worker as a controllable object: start it, stop it, and
/// watch what it is doing.
///
/// The engine used to live inside a CLI function that wrote to stdout and
/// exited the process on Ctrl+C. Both front ends need the same loop but
/// neither of those behaviours: the desktop app has to show the log in a window
/// and stop the worker without killing itself, and the CLI wraps this with the
/// stdout and signal handling it wants.
class RemoteWorker {
  RemoteWorker(
    this._config, {
    ScriptStore? scriptStore,
    WorkerSettingsStore? settingsStore,
  }) : _scriptStore = scriptStore,
       _settingsStore = settingsStore;

  final WorkerConfig _config;
  final ScriptStore? _scriptStore;
  final WorkerSettingsStore? _settingsStore;

  /// Where linked scripts live. Resolved on first use rather than in the
  /// constructor, so a machine with no home directory can still construct one.
  late final ScriptStore scriptStore =
      _scriptStore ?? ScriptStore.defaultLocation();

  /// Where the creator's switched-off projects are recorded. Resolved on first
  /// use for the same reason as [scriptStore].
  late final WorkerSettingsStore settingsStore =
      _settingsStore ?? WorkerSettingsStore.defaultLocation();

  final _log = StreamController<String>.broadcast();
  final _state = StreamController<RemoteWorkerState>.broadcast();

  var _currentState = RemoteWorkerState.stopped;
  WorkerSession? _session;
  UuidValue? _workerId;
  bool _stopRequested = false;
  Future<void>? _loop;

  /// Every line the worker would have printed.
  Stream<String> get log => _log.stream;

  /// State changes. [currentState] carries the value a late listener missed.
  Stream<RemoteWorkerState> get state => _state.stream;

  RemoteWorkerState get currentState => _currentState;

  /// The projects this machine is currently willing to run.
  ///
  /// Read from disk on every call, so a script linked while the worker runs is
  /// picked up on the next poll — which is exactly how a creator sets up a
  /// second computer.
  List<String> servedProjectIds() {
    final paused = settingsStore.load().pausedProjectIds;
    return [
      for (final id in scriptStore.linkedProjectIds())
        if (!paused.contains(id)) id,
    ];
  }

  /// Signs in with the stored machine token, registers this machine, and starts
  /// claiming runs. Returns once the worker is online (or has failed); the loop
  /// keeps running in the background until [stop].
  ///
  /// Throws [RemoteAuthException] when there is no usable machine token — the
  /// only failure the caller can act on, by signing in again.
  Future<void> start() async {
    if (_currentState != RemoteWorkerState.stopped &&
        _currentState != RemoteWorkerState.failed) {
      return;
    }
    _stopRequested = false;
    _emitState(RemoteWorkerState.connecting);

    final session = buildWorkerSession(_config.serverUrl);
    _session = session;

    try {
      await remoteRuntimeLogin(session);
    } catch (error) {
      await _shutDown(RemoteWorkerState.failed);
      if (error is RemoteAuthException) rethrow;
      throw RemoteAuthException('Could not sign in this machine: $error');
    }

    final WorkerRegistration registration;
    try {
      registration = await session.client.computeWorker.register(
        _config.hostname,
        workerVersion,
      );
    } catch (error) {
      _log.add('Could not register this machine: $error');
      await _shutDown(RemoteWorkerState.failed);
      rethrow;
    }

    _workerId = registration.workerId;
    _emitState(RemoteWorkerState.online);
    _log.add(
      'Compute client "${_config.hostname}" is online. Waiting for runs.',
    );

    _loop = _claimLoop(session, registration);
  }

  /// Stops claiming, deregisters this machine, and closes the connection.
  Future<void> stop() async {
    if (_currentState == RemoteWorkerState.stopped) return;
    _stopRequested = true;
    _log.add('Stopping; deregistering this machine.');
    await _loop;
    await _shutDown(RemoteWorkerState.stopped);
  }

  /// Releases the streams. The worker cannot be started again afterwards.
  Future<void> dispose() async {
    await stop();
    await _log.close();
    await _state.close();
  }

  Future<void> _claimLoop(
    WorkerSession session,
    WorkerRegistration registration,
  ) async {
    final workerId = registration.workerId;
    final processor = ExecutionProcessor(
      client: session.client,
      workerId: workerId,
      pythonRunner: PythonRunner(_config.pythonPath),
      heartbeat: ExecutionHeartbeat(
        session.client,
        workerId,
        registration.heartbeatIntervalSeconds,
      ),
    );

    try {
      while (!_stopRequested) {
        final claimed = await session.client.computeWorker.claimNext(
          workerId,
          servedProjectIds(),
        );
        if (claimed == null) {
          // Idle: heartbeat (no execution) to stay marked online, then back
          // off before asking again.
          try {
            await session.client.computeWorker.heartbeat(workerId, null);
          } catch (_) {
            // Transient; retry on the next tick.
          }
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }

        _log.add('Running ${claimed.kind.name} ${claimed.executionId}.');
        await processor.process(claimed);
        _log.add('Finished ${claimed.executionId}.');
      }
    } catch (error) {
      _log.add('The worker stopped with an error: $error');
      await _shutDown(RemoteWorkerState.failed);
    }
  }

  /// Deregisters and closes, best effort — a machine that cannot say goodbye
  /// is marked offline by the server's lease expiry anyway.
  Future<void> _shutDown(RemoteWorkerState nextState) async {
    final session = _session;
    final workerId = _workerId;
    _session = null;
    _workerId = null;
    _loop = null;

    if (session != null) {
      if (workerId != null) {
        try {
          await session.client.computeWorker.deregister(workerId);
        } catch (_) {
          // Nothing to do about it, and nothing depends on it succeeding.
        }
      }
      session.client.close();
    }
    _emitState(nextState);
  }

  void _emitState(RemoteWorkerState next) {
    _currentState = next;
    if (!_state.isClosed) _state.add(next);
  }
}
