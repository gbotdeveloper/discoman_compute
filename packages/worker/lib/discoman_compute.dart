/// The compute engine: everything the desktop app and the CLI both need to
/// sign a machine in, link a script to a project, and run queued executions.
///
/// The two front ends live on top of this — `bin/discoman_compute.dart` for the
/// terminal, `app/` for the desktop window. Keeping the engine here is what
/// lets the cloud worker stay a plain Dart package with no Flutter dependency.
library;

export 'src/auth/file_auth_storage.dart' show MachineTokenStore;
export 'src/auth/remote_auth.dart'
    show RemoteAuthException, enrolMachine, signIn;
export 'src/auth/session.dart' show WorkerSession, buildWorkerSession;
export 'src/home_path.dart' show expandHomePath;
export 'src/python/contract_extractor.dart' show extractContractDraft;
export 'src/python/interpreter_check.dart'
    show InterpreterCheck, checkInterpreter;
export 'src/remote_worker.dart' show RemoteWorker, RemoteWorkerState;
export 'src/scripts/script_store.dart' show ScriptStore, fingerprintScript;
export 'src/settings/worker_settings.dart'
    show WorkerSettings, WorkerSettingsStore, loadWorkerSettingsOrEmpty;
export 'src/worker_config.dart' show WorkerConfig, WorkerMode, workerVersion;
