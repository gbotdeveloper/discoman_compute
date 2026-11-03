import 'dart:io';

import '../home_path.dart';

/// A Python found where a tool installs it by default.
class FoundPython {
  const FoundPython({required this.path, required this.label});

  /// The interpreter to run.
  final String path;

  /// What put it there, such as "Anaconda · base" or "pyenv 3.12.4".
  final String label;
}

/// The Pythons on this computer that a researcher is likely to use: Discoman's
/// own, conda environments (Anaconda, Miniconda, Miniforge, including the ones
/// conda lists in `~/.conda/environments.txt`), Spyder's, pyenv versions,
/// virtual environments kept in the usual folders, and the system ones.
///
/// Only looks for files, so it is quick and runs nothing; each is checked when
/// the creator picks it. Each interpreter is listed once.
List<FoundPython> findPythons({
  Map<String, String>? environment,
  bool? isWindows,
  bool includeSystem = true,
}) {
  final env = environment ?? Platform.environment;
  final windows = isWindows ?? Platform.isWindows;
  final sep = windows ? r'\' : '/';
  final home = (env['HOME'] ?? env['USERPROFILE'] ?? '').trim();
  String join(List<String> parts) => parts.join(sep);
  String bin(String prefix) =>
      windows ? join([prefix, 'python.exe']) : join([prefix, 'bin', 'python']);

  final found = <FoundPython>[];
  final seen = <String>{};
  void add(String path, String label) {
    final file = File(path);
    if (!file.existsSync()) return;
    var key = path;
    try {
      key = file.resolveSymbolicLinksSync();
    } catch (_) {}
    if (seen.add(windows ? key.toLowerCase() : key)) {
      found.add(FoundPython(path: path, label: label));
    }
  }

  List<Directory> children(String path) {
    try {
      return Directory(
          path,
        ).listSync(followLinks: false).whereType<Directory>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    } catch (_) {
      return const [];
    }
  }

  String name(String path) =>
      path.split(RegExp(r'[\\/]')).lastWhere((p) => p.isNotEmpty);

  try {
    final managed = discomanHomeDirectory(environment: env);
    add(
      windows
          ? join([managed.path, 'python', 'python.exe'])
          : join([managed.path, 'python', 'bin', 'python3']),
      "Discoman's Python",
    );
  } catch (_) {}

  // Conda: each install's base, its environments, and any environment conda
  // made elsewhere, which it records in environments.txt.
  final localAppData = env['LOCALAPPDATA'] ?? '';
  final programData = env['ProgramData'] ?? env['PROGRAMDATA'] ?? '';
  const condaNames = ['anaconda3', 'miniconda3', 'miniforge3', 'mambaforge'];
  final condaRoots = <String>[
    for (final n in condaNames) ...[
      if (home.isNotEmpty) join([home, n]),
      if (windows && localAppData.isNotEmpty) join([localAppData, n]),
      if (windows && programData.isNotEmpty) join([programData, n]),
      if (!windows && includeSystem) ...['/opt/$n', '/usr/local/$n'],
    ],
    if (!windows && includeSystem) ...[
      '/opt/homebrew/anaconda3',
      '/opt/homebrew/Caskroom/miniconda/base',
      '/opt/homebrew/Caskroom/miniforge/base',
      '/usr/local/Caskroom/miniconda/base',
    ],
  ];
  String condaLabel(String root) {
    final lower = root.toLowerCase();
    if (lower.contains('anaconda')) return 'Anaconda';
    if (lower.contains('miniforge') || lower.contains('mambaforge')) {
      return 'Miniforge';
    }
    return 'Miniconda';
  }

  for (final root in condaRoots) {
    add(bin(root), '${condaLabel(root)} · base');
    for (final envDir in children(join([root, 'envs']))) {
      add(bin(envDir.path), '${condaLabel(root)} · ${name(envDir.path)}');
    }
  }
  if (home.isNotEmpty) {
    try {
      final listed = File(join([home, '.conda', 'environments.txt']));
      for (final line in listed.readAsLinesSync()) {
        final prefix = line.trim();
        if (prefix.isNotEmpty) add(bin(prefix), 'conda · ${name(prefix)}');
      }
    } catch (_) {}
  }

  // Spyder's standalone installer brings a Python of its own.
  if (windows && localAppData.isNotEmpty) {
    for (final dir in children(localAppData)) {
      if (name(dir.path).toLowerCase().startsWith('spyder')) {
        add(bin(join([dir.path, 'envs', 'spyder-runtime'])), 'Spyder');
      }
    }
  } else if (!windows && home.isNotEmpty) {
    for (final dir in children(join([home, 'Library']))) {
      if (name(dir.path).toLowerCase().startsWith('spyder')) {
        add(bin(join([dir.path, 'envs', 'spyder-runtime'])), 'Spyder');
      }
    }
  }

  if (home.isNotEmpty) {
    final pyenv = windows
        ? join([home, '.pyenv', 'pyenv-win', 'versions'])
        : join([home, '.pyenv', 'versions']);
    for (final version in children(pyenv)) {
      add(bin(version.path), 'pyenv ${name(version.path)}');
    }
    for (final folder in ['.virtualenvs', '.venvs', 'venvs']) {
      for (final venv in children(join([home, folder]))) {
        add(
          windows
              ? join([venv.path, 'Scripts', 'python.exe'])
              : join([venv.path, 'bin', 'python']),
          'venv · ${name(venv.path)}',
        );
      }
    }
  }

  if (!includeSystem) return found;
  if (windows) {
    if (localAppData.isNotEmpty) {
      for (final dir in children(join([localAppData, 'Programs', 'Python']))) {
        add(join([dir.path, 'python.exe']), 'Python ${name(dir.path)}');
      }
    }
    final programFiles = env['ProgramFiles'] ?? env['PROGRAMFILES'] ?? '';
    for (final root in [if (programFiles.isNotEmpty) programFiles, r'C:\']) {
      for (final dir in children(root)) {
        if (RegExp(
          r'^Python\d',
          caseSensitive: false,
        ).hasMatch(name(dir.path))) {
          add(join([dir.path, 'python.exe']), 'Python ${name(dir.path)}');
        }
      }
    }
  } else {
    for (final dir in children(
      '/Library/Frameworks/Python.framework/Versions',
    )) {
      add(join([dir.path, 'bin', 'python3']), 'python.org ${name(dir.path)}');
    }
    add('/opt/homebrew/bin/python3', 'Homebrew');
    add('/usr/local/bin/python3', '/usr/local');
    add('/usr/bin/python3', 'System');
  }
  return found;
}
