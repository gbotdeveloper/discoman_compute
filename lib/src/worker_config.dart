import 'dart:io';

import 'settings/worker_settings.dart';

/// The worker build/version string reported to the server on `register`.
const String workerVersion = '0.1.0';

/// Which lane this worker drains.
enum WorkerMode {
  /// Azure Container App Job replica: authenticate with the shared cloud
  /// secret, drain the queue, exit when it is empty.
  cloud,

  /// A creator's self-hosted machine: authenticate with a per-machine token,
  /// long-poll forever, run Python with the local interpreter.
  remote,
}

/// All configuration the worker resolves from CLI arguments and the
/// environment. Arguments win over environment variables, which win over the
/// built-in defaults.
class WorkerConfig {
  WorkerConfig({
    required this.serverUrl,
    required this.mode,
    required this.workerSecret,
    required this.pythonPath,
    required this.firebaseApiKey,
    required this.maxRuntimeSeconds,
    required this.hostname,
  });

  /// Serverpod server URL, always with a trailing slash (what `Client`
  /// expects).
  final String serverUrl;

  /// The lane this process drains.
  final WorkerMode mode;

  /// Shared cloud worker secret (cloud mode only). Empty in remote mode.
  final String workerSecret;

  /// Local Python interpreter used to run executions (remote mode). The cloud
  /// image ships its own interpreter on `PATH`.
  final String pythonPath;

  /// Firebase Web API key used only by the `login` flow to exchange the
  /// creator's email + password for an ID token. Empty unless configured.
  final String firebaseApiKey;

  /// Safety bound (seconds) a cloud replica keeps below the Container App Job
  /// `replica_timeout`, so it never claims a job it cannot finish before the
  /// platform kills the replica.
  final int maxRuntimeSeconds;

  /// Machine name reported on `register` and used as the default credential
  /// name at `login`.
  final String hostname;

  /// The interpreter to try when nothing names one.
  ///
  /// Windows installs Python as `python`; `python3` usually resolves to the
  /// Store stub that opens a download page instead of running anything.
  static String get _defaultPythonCommand =>
      Platform.isWindows ? 'python' : 'python3';

  static String _env(String key) => Platform.environment[key]?.trim() ?? '';

  /// The Firebase Web API key of the `no-code-ui-kosgeb` project, used only by
  /// `discoman-compute login` to exchange the creator's email/password for a
  /// Firebase ID token. This is a PUBLIC key (it ships in the web apps), so it
  /// is safe to embed as the default; `FIREBASE_API_KEY` overrides it if the
  /// project ever changes.
  /// Where a worker looks for the backend when nothing says otherwise.
  ///
  /// Production, deliberately: this binary is installed by creators, and the
  /// common case is a machine that should reach the live backend. Point it
  /// somewhere else with `--server-url` or `DISCOMAN_API_URL` — cloud replicas
  /// are given theirs by Terraform, and local development passes
  /// `http://localhost:8080/`.
  static const _defaultServerUrl =
      'https://ca-dscm-prod-api.kindtree-c083f0e1.northeurope.azurecontainerapps.io/';

  static const _defaultFirebaseApiKey =
      'AIzaSyCop5feBwwPAeo7ElOZj1rEHcMY5klz6J4';

  static String _normalizeUrl(String url) => url.endsWith('/') ? url : '$url/';

  /// Resolves configuration for the `start` command.
  factory WorkerConfig.resolve({
    String? modeArg,
    String? serverUrlArg,
    String? pythonArg,
    String? nameArg,
  }) {
    final serverUrlRaw = (serverUrlArg?.trim().isNotEmpty ?? false)
        ? serverUrlArg!.trim()
        : (_env('DISCOMAN_API_URL').isNotEmpty
              ? _env('DISCOMAN_API_URL')
              : _defaultServerUrl);

    final modeRaw = (modeArg?.trim().isNotEmpty ?? false)
        ? modeArg!.trim()
        : (_env('WORKER_MODE').isNotEmpty ? _env('WORKER_MODE') : 'remote');
    final mode = switch (modeRaw.toLowerCase()) {
      'cloud' => WorkerMode.cloud,
      'remote' => WorkerMode.remote,
      _ => throw FormatException('Unknown --mode "$modeRaw".'),
    };

    // Most specific wins: the flag for this one run, then the environment,
    // then what the creator chose in the desktop app, then the platform
    // default. The saved setting sits below the environment so a container or
    // a CI job can still override what a developer picked on their laptop.
    final python = (pythonArg?.trim().isNotEmpty ?? false)
        ? pythonArg!.trim()
        : (_env('DISCOMAN_PYTHON').isNotEmpty
              ? _env('DISCOMAN_PYTHON')
              : (loadWorkerSettingsOrEmpty().pythonPath ??
                    _defaultPythonCommand));

    final maxRuntimeRaw = _env('EXECUTION_MAX_RUNTIME_SECONDS');
    final maxRuntime = int.tryParse(maxRuntimeRaw) ?? 3300;

    final hostname = (nameArg?.trim().isNotEmpty ?? false)
        ? nameArg!.trim()
        : _hostname();

    return WorkerConfig(
      serverUrl: _normalizeUrl(serverUrlRaw),
      mode: mode,
      workerSecret: _env('WORKER_AUTH_SECRET'),
      pythonPath: python,
      firebaseApiKey: _env('FIREBASE_API_KEY').isNotEmpty
          ? _env('FIREBASE_API_KEY')
          : _defaultFirebaseApiKey,
      maxRuntimeSeconds: maxRuntime,
      hostname: hostname,
    );
  }

  static String _hostname() {
    try {
      final name = Platform.localHostname.trim();
      if (name.isNotEmpty) return name;
    } catch (_) {
      // Fall through to the environment-based fallbacks.
    }
    final env = Platform.environment;
    return (env['HOSTNAME'] ?? env['COMPUTERNAME'] ?? 'discoman-compute')
        .trim();
  }
}
