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
import 'python/run_environment.dart';
import 'scripts/script_store.dart';
import 'scripts/script_sync.dart';
import 'settings/usage_store.dart';
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

/// The longest a worker waits between tries while it cannot reach Discoman.
const _maxRetryDelay = Duration(seconds: 30);

/// The projects in [served] that may take one more run, given how many of
/// each are [running] and the creator's [limits].
List<String> claimableProjectIds(
  List<String> served,
  Map<String, int> limits,
  Map<String, int> running,
) => [
  for (final id in served)
    if ((running[id] ?? 0) < (limits[id] ?? double.maxFinite)) id,
];

/// The self-hosted worker as a controllable object: start it, stop it, and
/// watch what it is doing.
///
/// Takes as many runs at once as the creator chose for this computer. Each
/// one registers as its own worker sharing this computer's machine id, so the
/// server needs nothing new to hand them out and the dashboard still shows one
/// computer.
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
    UsageStore? usageStore,
    int? parallelRuns,
    this.keepInDiscoman,
  }) : _scriptStore = scriptStore,
       _settingsStore = settingsStore,
       _machineIdStore = machineIdStore,
       _usageStore = usageStore,
       _parallelRuns = parallelRuns;

  final WorkerConfig _config;
  final ScriptStore? _scriptStore;
  final WorkerSettingsStore? _settingsStore;
  final MachineIdStore? _machineIdStore;
  final UsageStore? _usageStore;

  /// Overrides the saved setting, for the CLI's `--parallel`.
  final int? _parallelRuns;

  /// Sends a script edited since it was linked to Discoman, when its project
  /// keeps it there. Given by the desktop app, which is signed in as the
  /// creator.
  final Future<bool> Function(
    String projectId,
    String source,
    String fingerprint,
  )?
  keepInDiscoman;

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

  /// What each project's runs used on this computer.
  late final UsageStore usageStore =
      _usageStore ?? UsageStore.defaultLocation();

  final _log = StreamController<String>.broadcast();
  final _state = StreamController<RemoteWorkerState>.broadcast();
  final _measured = StreamController<String>.broadcast();
  final _scriptChecked = StreamController<String>.broadcast();

  /// Projects whose runs had to use the script's own folder, so they take
  /// one run at a time here.
  final _sharedFolderProjects = <String>{};

  var _currentState = RemoteWorkerState.stopped;
  WorkerSession? _session;
  final _workerIds = <UuidValue>[];
  bool _stopRequested = false;
  bool _failed = false;
  Future<void>? _loop;

  /// Runs in progress here, by project, so a project's limit holds across
  /// every worker on this computer.
  final _running = <String, int>{};

  /// Claims go one at a time, so two workers cannot both take the last run
  /// a project's limit allows.
  Future<void> _claimTurn = Future.value();

  bool _lostContact = false;

  /// Every line the worker would have printed.
  Stream<String> get log => _log.stream;

  /// State changes. [currentState] carries the value a late listener missed.
  Stream<RemoteWorkerState> get state => _state.stream;

  RemoteWorkerState get currentState => _currentState;

  /// The project of each run whose usage was just recorded in [usageStore].
  Stream<String> get measured => _measured.stream;

  /// The project of each run that found its script edited since linking.
  Stream<String> get scriptChecked => _scriptChecked.stream;

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
    _failed = false;
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

    await loadLoginShellPath();
    final parallelRuns = _parallelRuns ?? settingsStore.load().parallelRuns;
    final registrations = <WorkerRegistration>[];
    try {
      for (var i = 0; i < parallelRuns; i++) {
        final registration = await session.client.computeWorker.register(
          _config.hostname,
          workerVersion,
        );
        registrations.add(registration);
        _workerIds.add(registration.workerId);
      }
    } catch (error) {
      _log.add('Could not register this machine: $error');
      await _shutDown(RemoteWorkerState.failed);
      rethrow;
    }

    _emitState(RemoteWorkerState.online);
    _log.add(
      parallelRuns == 1
          ? 'Compute client "${_config.hostname}" is online. Waiting for runs.'
          : 'Compute client "${_config.hostname}" is online, taking up to '
                '$parallelRuns runs at once. Waiting for runs.',
    );

    _loop = _runAll(session, registrations);
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
    await _measured.close();
    await _scriptChecked.close();
  }

  Future<void> _runAll(
    WorkerSession session,
    List<WorkerRegistration> registrations,
  ) async {
    await Future.wait([
      for (final (i, registration) in registrations.indexed)
        _claimLoop(session, registration, syncsScripts: i == 0),
    ]);
    if (_failed) await _shutDown(RemoteWorkerState.failed);
  }

  /// One run at a time for one registration. Only the first copies down the
  /// scripts kept in Discoman, so they are not fetched once per run slot.
  Future<void> _claimLoop(
    WorkerSession session,
    WorkerRegistration registration, {
    required bool syncsScripts,
  }) async {
    final workerId = registration.workerId;
    final processor = ExecutionProcessor(
      client: session.client,
      workerId: workerId,
      pythonRunner: PythonRunner(_config.pythonPath, measureUsage: true),
      heartbeat: ExecutionHeartbeat(
        session.client,
        workerId,
        registration.heartbeatIntervalSeconds,
      ),
      externalCodeFor: (projectId) => readExternalCode({
        projectId: settingsStore.load().externalCode[projectId] ?? const [],
      }),
      onUsage: (projectId, usage) {
        usageStore.record(projectId, usage);
        if (!_measured.isClosed) _measured.add(projectId);
      },
      keepInDiscoman: keepInDiscoman,
      onScriptChecked: (projectId) {
        if (!_scriptChecked.isClosed) _scriptChecked.add(projectId);
      },
      onScriptFolderShared: (projectId) {
        if (_sharedFolderProjects.add(projectId)) {
          _log.add(
            'Runs of $projectId use its script folder itself, so they go one '
            'at a time. See the run log for why.',
          );
        }
      },
    );

    var reportedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var retryDelay = const Duration(seconds: 3);
    while (!_stopRequested) {
      try {
        if (DateTime.now().difference(reportedAt) > _machineReportInterval) {
          reportedAt = DateTime.now();
          if (syncsScripts) await _syncScripts(session);
          await _reportMachine(session, workerId);
        }
        final claimed = await _claim(session, workerId);
        _backInContact();
        retryDelay = const Duration(seconds: 3);
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
        try {
          await processor.process(claimed);
        } finally {
          _running.update(claimed.projectId, (count) => count - 1);
        }
        _log.add('Finished ${claimed.executionId}.');
      } catch (error) {
        if (_isRefusal(error)) {
          _log.add('The worker stopped with an error: $error');
          _failed = true;
          _stopRequested = true;
          return;
        }
        // A dropped connection or a slow reply: whatever was claimed comes
        // back to the queue when its lease runs out, so trying again later
        // loses nothing.
        if (!_lostContact) {
          _lostContact = true;
          _log.add('Lost contact with Discoman ($error). Trying again…');
        }
        await _pauseUnlessStopped(retryDelay);
        retryDelay = retryDelay * 2 > _maxRetryDelay
            ? _maxRetryDelay
            : retryDelay * 2;
      }
    }
  }

  /// The next run for this worker, or null when nothing it may take waits.
  Future<ClaimedExecution?> _claim(WorkerSession session, UuidValue workerId) {
    final claim = _claimTurn.then((_) async {
      final claimable = claimableProjectIds(servedProjectIds(), {
        ...settingsStore.load().projectRunLimits,
        for (final id in _sharedFolderProjects) id: 1,
      }, _running);
      if (claimable.isEmpty) return null;
      final claimed = await session.client.computeWorker.claimNext(
        workerId,
        claimable,
      );
      if (claimed != null) {
        _running.update(claimed.projectId, (n) => n + 1, ifAbsent: () => 1);
      }
      return claimed;
    });
    _claimTurn = claim.then((_) {}, onError: (_) {});
    return claim;
  }

  /// Waits [delay], cut short by [stop] so stopping never waits out a retry.
  Future<void> _pauseUnlessStopped(Duration delay) async {
    final until = DateTime.now().add(delay);
    while (!_stopRequested && DateTime.now().isBefore(until)) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  void _backInContact() {
    if (!_lostContact) return;
    _lostContact = false;
    _log.add('Back in contact with Discoman.');
  }

  /// Whether Discoman turned this worker away, rather than not answering.
  /// Asking again would only be turned away again.
  static bool _isRefusal(Object error) =>
      error is ServerpodClientUnauthorized ||
      error is ServerpodClientForbidden ||
      error is ScriptRunException;

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
    final workerIds = [..._workerIds];
    _session = null;
    _workerIds.clear();
    _loop = null;

    if (session != null) {
      for (final workerId in workerIds) {
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
