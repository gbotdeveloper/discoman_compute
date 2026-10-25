import 'dart:async';

import 'package:discoman_client/discoman_client.dart';

import 'auth/remote_auth.dart';
import 'auth/session.dart';
import 'execution_processor.dart';
import 'external_code.dart';
import 'heartbeat.dart';
import 'machine_check.dart';
import 'machine_id.dart';
import 'python/python_runner.dart';
import 'scripts/script_store.dart';
import 'scripts/script_sync.dart';
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

/// How often an idle worker repeats what it reported about its computer, so
/// scripts linked or switched off while it runs show up on the dashboard.
const _machineReportInterval = Duration(minutes: 1);

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
    MachineIdStore? machineIdStore,
  }) : _scriptStore = scriptStore,
       _settingsStore = settingsStore,
       _machineIdStore = machineIdStore;

  final WorkerConfig _config;
  final ScriptStore? _scriptStore;
  final WorkerSettingsStore? _settingsStore;
  final MachineIdStore? _machineIdStore;

  /// Where linked scripts live. Resolved on first use rather than in the
  /// constructor, so a machine with no home directory can still construct one.
  late final ScriptStore scriptStore =
      _scriptStore ?? ScriptStore.defaultLocation();

  late final MachineIdStore machineIdStore =
      _machineIdStore ?? MachineIdStore.defaultLocation();

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
      externalCodeFor: (projectId) => readExternalCode({
        projectId: settingsStore.load().externalCode[projectId] ?? const [],
      }),
    );

    var reportedAt = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      while (!_stopRequested) {
        if (DateTime.now().difference(reportedAt) > _machineReportInterval) {
          reportedAt = DateTime.now();
          await _syncScripts(session);
          await _reportMachine(session, workerId);
        }
        final claimed = await session.client.computeWorker.claimNext(
          workerId,
          servedProjectIds(),
        );
        if (claimed == null) {
          // Idle: heartbeat (no execution) to stay marked online, then back
          // off before asking again.
          try {
            final beat = await session.client.computeWorker.heartbeat(
              workerId,
              null,
            );
            if (beat.machineCheckRequested ?? false) {
              await _answerMachineCheck(session, workerId);
            }
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

  /// Brings the scripts the creator keeps in Discoman onto this computer.
  /// Best effort, like [_reportMachine].
  Future<void> _syncScripts(WorkerSession session) async {
    try {
      final result = await syncScripts(
        SyncedScriptsApi.of(session.client),
        scriptStore,
      );
      if (result.downloaded.isNotEmpty) {
        _log.add(
          'Copied ${result.downloaded.length} script(s) kept in Discoman to '
          'this computer.',
        );
      }
    } catch (_) {
      // Retried on the next report.
    }
  }

  /// Tells the server which computer this is and every script linked on it.
  /// Best effort: a server too old to take it still runs everything else.
  Future<void> _reportMachine(WorkerSession session, UuidValue workerId) async {
    try {
      final linked = scriptStore.linkedProjectIds();
      final settings = settingsStore.load();
      final paused = settings.pausedProjectIds;
      await session.client.computeWorker.reportMachine(
        workerId,
        MachineReport(
          machineId: machineIdStore.read(),
          linkedProjectIds: linked,
          pausedProjectIds: [
            for (final id in linked)
              if (paused.contains(id)) id,
          ],
          externalCode: await readExternalCode({
            for (final id in linked) id: ?settings.externalCode[id],
          }),
        ),
      );
    } catch (_) {
      // Retried on the next report.
    }
  }

  /// Checks this machine for the dashboard and reports what it found.
  Future<void> _answerMachineCheck(
    WorkerSession session,
    UuidValue workerId,
  ) async {
    final claimed = await session.client.computeWorker.claimMachineCheck(
      workerId,
    );
    if (claimed == null) return;
    _log.add('Checking this machine for the dashboard.');
    final result = await runMachineCheck(
      pythonPath: _config.pythonPath,
      scriptStore: scriptStore,
      settings: settingsStore.load(),
      expectedScripts: claimed.expectedScripts,
    );
    await session.client.computeWorker.reportMachineCheck(
      workerId,
      claimed.checkId,
      result,
    );
    _log.add('Machine check sent.');
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
