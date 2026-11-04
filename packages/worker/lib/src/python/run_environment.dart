import 'dart:async';
import 'dart:convert';
import 'dart:io';

String? _loginShellPath;

const _marker = '__DISCOMAN_PATH__';

/// Reads PATH from the creator's login shell, once, so runs find the programs
/// their terminal finds. An app opened from the Finder only gets
/// /usr/bin:/bin:/usr/sbin:/sbin. Does nothing on Windows, where programs
/// inherit the PATH the creator set. Never throws.
Future<void> loadLoginShellPath({
  Duration timeout = const Duration(seconds: 5),
}) async {
  if (Platform.isWindows || _loginShellPath != null) return;
  final shell = Platform.environment['SHELL']?.trim() ?? '';
  for (final candidate in {if (shell.isNotEmpty) shell, '/bin/zsh'}) {
    final path = await _readPath(candidate, timeout);
    if (path != null) {
      _loginShellPath = path;
      return;
    }
  }
}

Future<String?> _readPath(String shell, Duration timeout) async {
  try {
    final process = await Process.start(shell, [
      '-lic',
      'printf "$_marker%s$_marker" "\$PATH"',
    ]);
    unawaited(process.stdin.close());
    unawaited(process.stderr.drain<void>());
    final output = process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .join();
    final exited = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        process.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
    if (exited == -1) return null;
    final text = await output.timeout(timeout, onTimeout: () => '');
    final match = RegExp(
      '$_marker(.*?)$_marker',
      dotAll: true,
    ).firstMatch(text);
    final path = match?.group(1)?.trim() ?? '';
    return path.isEmpty ? null : path;
  } catch (_) {
    return null;
  }
}

/// The PATH a run gets: the folders of the environment [pythonPath] lives in,
/// then the login shell's, then the inherited one, each folder once.
///
/// A conda environment or a venv is set up the way `conda activate` or
/// `activate` would, so its packages find the libraries they ship.
Map<String, String> runEnvironment({
  Map<String, String>? inherited,
  String? loginShellPath,
  String? pythonPath,
  bool? isWindows,
}) {
  final base = inherited ?? Platform.environment;
  final windows = isWindows ?? Platform.isWindows;
  final separator = windows ? ';' : ':';
  final key = base.keys.firstWhere(
    (name) => name.toUpperCase() == 'PATH',
    orElse: () => 'PATH',
  );
  final activated = pythonPath == null
      ? null
      : _activatedEnvironment(pythonPath, windows);
  final folders = <String>{
    ...?activated?.folders,
    if (!windows)
      for (final folder in (loginShellPath ?? _loginShellPath ?? '').split(
        separator,
      ))
        if (folder.isNotEmpty) folder,
    for (final folder in (base[key] ?? '').split(separator))
      if (folder.isNotEmpty) folder,
  };
  return {...?activated?.variables, key: folders.join(separator)};
}

typedef _Activated = ({List<String> folders, Map<String, String> variables});

_Activated? _activatedEnvironment(String pythonPath, bool windows) {
  final sep = windows ? r'\' : '/';
  String parent(String path) {
    final index = path.lastIndexOf(windows ? RegExp(r'[\\/]') : '/');
    return index <= 0 ? path : path.substring(0, index);
  }

  String name(String path) => path.substring(parent(path).length + 1);

  final dir = parent(pythonPath);
  final last = name(dir).toLowerCase();
  final prefix = (windows ? last == 'scripts' : last == 'bin')
      ? parent(dir)
      : dir;
  String join(List<String> parts) => [prefix, ...parts].join(sep);

  if (Directory(join(['conda-meta'])).existsSync()) {
    final envsParent = parent(prefix);
    final isEnv = name(envsParent).toLowerCase() == 'envs';
    return (
      folders: windows
          ? [
              prefix,
              join(['Library', 'mingw-w64', 'bin']),
              join(['Library', 'usr', 'bin']),
              join(['Library', 'bin']),
              join(['Scripts']),
              join(['bin']),
            ]
          : [
              join(['bin']),
            ],
      variables: {
        'CONDA_PREFIX': prefix,
        'CONDA_DEFAULT_ENV': isEnv ? name(prefix) : 'base',
        'CONDA_SHLVL': '1',
      },
    );
  }
  if (File(join(['pyvenv.cfg'])).existsSync()) {
    return (
      folders: [
        join([windows ? 'Scripts' : 'bin']),
      ],
      variables: {'VIRTUAL_ENV': prefix},
    );
  }
  return null;
}
