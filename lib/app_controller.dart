import 'dart:async';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
// The engine's own `signIn` would be shadowed by this class's method, so it
// comes in under a prefix while the types stay unprefixed.
import 'package:discoman_worker/discoman_compute.dart' hide signIn;
import 'package:discoman_worker/discoman_compute.dart' as engine show signIn;
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
    this.missingPackages = const [],
  });

  final String path;
  final String source;
  final ContractDraft draft;

  /// Pip packages the script imports that this computer's Python lacks.
  final List<String> missingPackages;

  String get fileName => path.split(Platform.pathSeparator).last;
}

/// Everything the window shows and does, in one place.
///
/// The app is small enough that a single [ChangeNotifier] beats pulling in a
/// state-management package — and this binary is one creators download and
/// audit, so every dependency it does not have is a dependency they do not
/// have to trust.
class AppController extends ChangeNotifier {
  AppController({
    WorkerConfig? config,
    WorkerSettingsStore? settingsStore,
    UsageStore? usageStore,
    Future<MachineResources> Function()? readMachine,
  }) : config = config ?? WorkerConfig.resolve(modeArg: 'remote'),
       _settingsStore = settingsStore,
       _usageStore = usageStore,
       _readMachine = readMachine ?? MachineResources.read;

  /// Injectable so a test never writes to the creator's real home directory.
  final WorkerSettingsStore? _settingsStore;
  final UsageStore? _usageStore;
  final Future<MachineResources> Function() _readMachine;

  late final WorkerSettingsStore settingsStore =
      _settingsStore ?? WorkerSettingsStore.defaultLocation();

  late final UsageStore usageStore =
      _usageStore ?? UsageStore.defaultLocation();

  /// What this computer has, read once.
  MachineResources? machine;

  /// The latest measured runs of each project on this computer.
  Map<String, List<RunUsage>> usageByProject = const {};

  /// Rebuilt when a setting that feeds it changes, so the panel shows what the
  /// next run will actually use.
  WorkerConfig config;

  WorkerSession? _session;
  RemoteWorker? _worker;
  StreamSubscription<String>? _logSubscription;
  StreamSubscription<RemoteWorkerState>? _stateSubscription;
  StreamSubscription<String>? _measuredSubscription;

  /// The signed-in creator's email, or null while signed out.
  String? signedInAs;

  bool isBusy = false;

  /// The last thing that went wrong, shown until the next action clears it.
  String? errorMessage;

  List<CreatorProjectSummary> projects = const [];

  ScriptCandidate? candidate;

  RemoteWorkerState workerState = RemoteWorkerState.stopped;

  /// Projects whose script is on this machine, so it can serve them.
  Set<String> linkedProjectIds = {};

  /// Projects the creator has switched off for this machine.
  ///
  /// Mirrors what is on disk so the list can render without reading a file on
  /// every frame; [setProjectServed] writes through.
  late Set<String> pausedProjectIds = _loadPaused();

  Set<String> _loadPaused() {
    try {
      return settingsStore.load().pausedProjectIds;
    } catch (_) {
      // No home directory to read from is a normal condition, not a fault.
      return const {};
    }
  }

  /// Pip packages each linked script needs that this computer's Python
  /// lacks. Projects missing nothing are left out.
  Map<String, List<String>> missingPackagesByProject = const {};

  /// Whether a pip install is running.
  bool isInstalling = false;

  /// What the running or last pip install printed.
  final List<String> installLog = [];

  /// The most recent worker log lines, oldest first.
  final List<String> log = [];

  bool _isDisposed = false;

  /// Older lines are dropped: this window can be left running for days and
  /// nobody scrolls back through a week of runs.
  static const _maxLogLines = 500;

  bool get isSignedIn => _session != null;

  /// Whether this machine can serve anything at all.
  ///
  /// Starting with nothing linked would register a worker that claims nothing,
  /// which looks online but never runs — worse than refusing to start.
  bool get canServeAnything =>
      linkedProjectIds.any((id) => !pausedProjectIds.contains(id));

  /// How many runs this computer takes at once.
  int get parallelRuns {
    try {
      return settingsStore.load().parallelRuns;
    } catch (_) {
      return 1;
    }
  }

  /// How many runs at once suit this computer, judged by what the scripts it
  /// serves used. Null until one of them has run here.
  int? get suggestedRuns {
    final machine = this.machine;
    if (machine == null) return null;
    return suggestedParallelRuns(machine, [
      for (final entry in usageByProject.entries)
        if (linkedProjectIds.contains(entry.key) &&
            !pausedProjectIds.contains(entry.key))
          ...entry.value,
    ]);
  }

  /// Takes effect on the next start, like the interpreter.
  void setParallelRuns(int runs) {
    final store = settingsStore;
    store.save(store.load().copyWith(parallelRuns: runs));
    _notify();
  }

  /// Re-reads what the runs here used, and what this computer has.
  Future<void> refreshUsage() async {
    try {
      machine ??= await _readMachine();
    } catch (_) {
      // Leaves the suggestion out.
    }
    usageByProject = usageStore.load();
    _notify();
  }

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
    await _syncScripts(session);
    _refreshLinkedProjects();
    await refreshMissingPackages();
    await refreshUsage();
  }

  /// Copies the scripts the creator keeps in Discoman onto this computer.
  /// Best effort: linking by hand still works when it fails.
  Future<void> _syncScripts(WorkerSession session) async {
    try {
      await syncScripts(
        SyncedScriptsApi.of(session.client),
        ScriptStore.defaultLocation(),
      );
    } catch (_) {}
  }

  /// Re-reads which packages the linked scripts need and Python lacks.
  Future<void> refreshMissingPackages() async {
    final store = ScriptStore.defaultLocation();
    final missing = <String, List<String>>{};
    for (final projectId in linkedProjectIds) {
      final file = store.fileFor(projectId);
      if (!file.existsSync()) continue;
      final packages = await missingPackagesFor(
        config.pythonPath,
        file.readAsStringSync(),
      );
      if (packages.isNotEmpty) missing[projectId] = packages;
    }
    missingPackagesByProject = missing;
    _notify();
  }

  /// Installs [packages] into this computer's Python with pip.
  Future<PackageInstallResult> installMissingPackages(
    List<String> packages,
  ) async {
    isInstalling = true;
    installLog.clear();
    _notify();
    try {
      return await installPackages(
        config.pythonPath,
        packages,
        onOutput: (line) {
          installLog.add(line);
          _notify();
        },
      );
    } finally {
      isInstalling = false;
      await refreshMissingPackages();
    }
  }

  /// Re-reads which projects have a script on this machine.
  void _refreshLinkedProjects() {
    linkedProjectIds = ScriptStore.defaultLocation().linkedProjectIds().toSet();
  }

  /// Stops or resumes taking work for one project on this machine.
  ///
  /// Takes effect on the worker's next poll; the served list is read fresh
  /// each time rather than fixed when it started.
  void setProjectServed(String projectId, {required bool served}) {
    final store = settingsStore;
    final paused = {...pausedProjectIds};
    if (served) {
      paused.remove(projectId);
    } else {
      paused.add(projectId);
    }
    // Written before the worker can read it: the loop re-reads this file on
    // every poll, so saving is the whole of telling it.
    store.save(store.load().copyWith(pausedProjectIds: paused));
    pausedProjectIds = paused;
    _notify();
  }

  /// Code outside Discoman each project's script uses on this computer.
  Map<String, List<ExternalCodeSource>> get externalCode {
    try {
      return settingsStore.load().externalCode;
    } catch (_) {
      return const {};
    }
  }

  /// Replaces the code outside Discoman that [projectId] uses here. The
  /// worker reports it on its next report and stamps every run with it.
  void setExternalCode(String projectId, List<ExternalCodeSource> code) {
    final store = settingsStore;
    final settings = store.load();
    store.save(
      settings.copyWith(
        externalCode: {...settings.externalCode, projectId: code},
      ),
    );
    _notify();
  }

  /// Reads [path] and extracts its contract, without sending anything.
  Future<void> pickScript(String path) async {
    await _run(() async {
      final source = await File(path).readAsString();
      candidate = ScriptCandidate(
        path: path,
        source: source,
        draft: extractContractDraft(source),
        missingPackages: await missingPackagesFor(config.pythonPath, source),
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
      final fingerprint = fingerprintScript(picked.source);
      // Sent to Discoman before it is stored here, so a sync cannot bring
      // the older copy Discoman held back over it.
      await keepInDiscomanIfChosen(
        session.client,
        projectId: projectId,
        source: picked.source,
        fingerprint: fingerprint,
      );
      // Stored before publishing: a contract published against a script this
      // machine does not have would leave the project pointing at nothing.
      ScriptStore.defaultLocation().store(projectId, picked.source);
      _refreshLinkedProjects();
      await session.client.creatorScript.publishContract(
        projectId,
        picked.draft,
        fingerprint,
      );
      candidate = null;
      await _loadProjects();
    });
  }

  /// Downloads Discoman's own Python with the packages the linked scripts
  /// need, and switches this computer to it. Throws a
  /// [PythonInstallException] when it fails.
  Future<PythonInstallResult> installPython(
    void Function(PythonInstallProgress progress) onProgress, {
    Future<List<String>> Function(List<String> packages)? confirmGuessed,
    PythonInstaller? installer,
  }) async {
    final store = ScriptStore.defaultLocation();
    final modules = {
      for (final projectId in linkedProjectIds)
        if (store.fileFor(projectId).existsSync())
          ...importedModules(store.fileFor(projectId).readAsStringSync()),
    }.toList();
    final result = await (installer ?? PythonInstaller()).install(
      modules: modules,
      confirmGuessed: confirmGuessed,
      onProgress: onProgress,
    );
    await setPythonPath(result.path);
    return result;
  }

  /// Saves the Python interpreter the creator picked.
  ///
  /// Takes effect on the next start: [RemoteWorker] builds its runner from the
  /// config it was handed, so a worker already running keeps the interpreter
  /// it started with. The panel disables this while it runs rather than
  /// pretending otherwise.
  Future<void> setPythonPath(String path) async {
    await _run(() async {
      // Merged into what is already there: writing a fresh WorkerSettings
      // would silently clear the projects switched off on this machine.
      final store = settingsStore;
      store.save(store.load().copyWith(pythonPath: path));
      config = WorkerConfig.resolve(modeArg: 'remote');
      await refreshMissingPackages();
    });
  }

  Future<void> startWorker() async {
    if (_worker != null) return;
    final worker = RemoteWorker(
      config,
      settingsStore: _settingsStore,
      usageStore: _usageStore,
    );
    _worker = worker;
    _logSubscription = worker.log.listen(_appendLog);
    _stateSubscription = worker.state.listen((state) {
      workerState = state;
      _notify();
    });
    _measuredSubscription = worker.measured.listen(
      (_) => unawaited(refreshUsage()),
    );

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
    await _measuredSubscription?.cancel();
    _logSubscription = null;
    _stateSubscription = null;
    _measuredSubscription = null;
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
