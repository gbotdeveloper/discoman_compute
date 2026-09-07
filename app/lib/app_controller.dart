import 'dart:async';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
// The engine's own `signIn` would be shadowed by this class's method, so it
// comes in under a prefix while the types stay unprefixed.
import 'package:discoman_compute/discoman_compute.dart' hide signIn;
import 'package:discoman_compute/discoman_compute.dart' as engine show signIn;
import 'package:flutter/foundation.dart';

/// A script the creator picked, together with the contract read from it here.
///
/// Held between picking the file and confirming the link so the creator sees
/// exactly what will be sent before anything leaves this machine.
class ScriptCandidate {
  ScriptCandidate({
    required this.path,
    required this.source,
    required this.draft,
  });

  final String path;
  final String source;
  final ContractDraft draft;

  String get fileName => path.split(Platform.pathSeparator).last;
}

/// Everything the window shows and does, in one place.
///
/// The app is small enough that a single [ChangeNotifier] beats pulling in a
/// state-management package — and this binary is one creators download and
/// audit, so every dependency it does not have is a dependency they do not
/// have to trust.
class AppController extends ChangeNotifier {
  AppController({WorkerConfig? config})
    : config = config ?? WorkerConfig.resolve(modeArg: 'remote');

  /// Rebuilt when a setting that feeds it changes, so the panel shows what the
  /// next run will actually use.
  WorkerConfig config;

  WorkerSession? _session;
  RemoteWorker? _worker;
  StreamSubscription<String>? _logSubscription;
  StreamSubscription<RemoteWorkerState>? _stateSubscription;

  /// The signed-in creator's email, or null while signed out.
  String? signedInAs;

  bool isBusy = false;

  /// The last thing that went wrong, shown until the next action clears it.
  String? errorMessage;

  List<CreatorProjectSummary> projects = const [];

  ScriptCandidate? candidate;

  RemoteWorkerState workerState = RemoteWorkerState.stopped;

  /// The most recent worker log lines, oldest first.
  final List<String> log = [];

  bool _isDisposed = false;

  /// Older lines are dropped: this window can be left running for days and
  /// nobody scrolls back through a week of runs.
  static const _maxLogLines = 500;

  bool get isSignedIn => _session != null;

  bool get isWorkerBusy =>
      workerState == RemoteWorkerState.connecting ||
      workerState == RemoteWorkerState.online;

  /// Signs in, enrols this machine, and loads the creator's projects.
  ///
  /// Enrolling here means a creator who opens the app once can later start the
  /// worker without signing in again — the machine token outlives the session.
  Future<void> signIn(String email, String password) async {
    await _run(() async {
      final session = await engine.signIn(
        config,
        email: email,
        password: password,
      );
      _session = session;
      signedInAs = email.trim();
      await enrolMachine(session, config);
      await _loadProjects();
    });
  }

  Future<void> refreshProjects() => _run(_loadProjects);

  Future<void> _loadProjects() async {
    final session = _session;
    if (session == null) return;
    projects = await session.client.creatorScript.listProjects();
  }

  /// Reads [path] and extracts its contract, without sending anything.
  Future<void> pickScript(String path) async {
    await _run(() async {
      final source = await File(path).readAsString();
      candidate = ScriptCandidate(
        path: path,
        source: source,
        draft: extractContractDraft(source),
      );
    });
  }

  void clearCandidate() {
    candidate = null;
    _notify();
  }

  /// Stores the picked script on this machine and sends its contract to the
  /// project, so the creator can build screens against it in GBot.
  Future<void> linkTo(String projectId) async {
    final session = _session;
    final picked = candidate;
    if (session == null || picked == null) return;

    await _run(() async {
      // Stored first: a contract published against a script this machine does
      // not have would leave the project pointing at nothing.
      ScriptStore.defaultLocation().store(projectId, picked.source);
      await session.client.creatorScript.publishContract(
        projectId,
        picked.draft,
        fingerprintScript(picked.source),
      );
      candidate = null;
      await _loadProjects();
    });
  }

  /// Saves the Python interpreter the creator picked.
  ///
  /// Takes effect on the next start: [RemoteWorker] builds its runner from the
  /// config it was handed, so a worker already running keeps the interpreter
  /// it started with. The panel disables this while it runs rather than
  /// pretending otherwise.
  Future<void> setPythonPath(String path) async {
    await _run(() async {
      WorkerSettingsStore.defaultLocation().save(
        WorkerSettings(pythonPath: path),
      );
      config = WorkerConfig.resolve(modeArg: 'remote');
    });
  }

  Future<void> startWorker() async {
    if (_worker != null) return;
    final worker = RemoteWorker(config);
    _worker = worker;
    _logSubscription = worker.log.listen(_appendLog);
    _stateSubscription = worker.state.listen((state) {
      workerState = state;
      _notify();
    });

    await _run(worker.start);
  }

  Future<void> stopWorker() async {
    final worker = _worker;
    if (worker == null) return;
    await _run(worker.stop);
    await _disposeWorker();
  }

  void _appendLog(String line) {
    log.add(line);
    if (log.length > _maxLogLines) {
      log.removeRange(0, log.length - _maxLogLines);
    }
    _notify();
  }

  /// Runs [action] with the busy flag set and any failure turned into
  /// [errorMessage], so no callers have to repeat that.
  Future<void> _run(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    _notify();
    try {
      await action();
    } on RemoteAuthException catch (error) {
      errorMessage = error.message;
    } on ScriptRunException catch (error) {
      errorMessage = error.message;
    } catch (error) {
      errorMessage = '$error';
    } finally {
      isBusy = false;
      _notify();
    }
  }

  /// Notifies unless the controller is gone.
  ///
  /// Tearing the worker down is asynchronous, so its last state change and log
  /// line can arrive after [dispose] — which would otherwise throw.
  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> _disposeWorker() async {
    await _logSubscription?.cancel();
    await _stateSubscription?.cancel();
    _logSubscription = null;
    _stateSubscription = null;
    await _worker?.dispose();
    _worker = null;
    workerState = RemoteWorkerState.stopped;
    _notify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_disposeWorker());
    _session?.client.close();
    super.dispose();
  }
}
