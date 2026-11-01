/// The compute engine: everything the desktop app and the CLI both need to
/// sign a machine in, link a script to a project, and run queued executions.
///
/// The two front ends live on top of this — `bin/discoman_compute.dart` for the
/// terminal, `app/` for the desktop window. Keeping the engine here is what
/// lets other workers build on it as a plain Dart package with no Flutter
/// dependency.
library;

export 'src/auth/file_auth_storage.dart' show MachineTokenStore;
export 'src/auth/remote_auth.dart'
    show RemoteAuthException, enrolMachine, signIn;
export 'src/auth/session.dart' show WorkerSession, buildWorkerSession;
export 'src/execution_processor.dart' show ExecutionProcessor;
export 'src/external_code.dart'
    show ExternalCodeSource, readExternalCode, readExternalCodeVersion;
export 'src/heartbeat.dart' show ExecutionHeartbeat;
export 'src/home_path.dart' show expandHomePath;
export 'src/python/contract_extractor.dart' show extractContractDraft;
export 'src/python/imports.dart' show importedModules;
export 'src/python/interpreter_check.dart'
    show InterpreterCheck, InterpreterProblem, checkInterpreter;
export 'src/python/python_installer.dart'
    show
        PythonInstallException,
        PythonInstallProgress,
        PythonInstallResult,
        PythonInstallStep,
        PythonInstaller,
        managedPythonVersion;
export 'src/python/packages.dart'
    show PackageInstallResult, installPackages, missingPackagesFor;
export 'src/python/python_runner.dart' show PythonRunner;
export 'src/remote_worker.dart' show RemoteWorker, RemoteWorkerState;
export 'src/scripts/script_store.dart' show ScriptStore, fingerprintScript;
export 'src/scripts/script_sync.dart'
    show
        ScriptSyncResult,
        SyncedScriptsApi,
        keepInDiscomanIfChosen,
        syncScripts;
export 'src/settings/worker_settings.dart'
    show WorkerSettings, WorkerSettingsStore, loadWorkerSettingsOrEmpty;
export 'src/worker_config.dart' show WorkerConfig, workerVersion;
