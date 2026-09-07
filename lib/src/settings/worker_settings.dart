import 'dart:convert';
import 'dart:io';

/// Preferences a creator sets once and both front ends honour.
class WorkerSettings {
  const WorkerSettings({this.pythonPath});

  /// The Python interpreter to run scripts with, or null when the creator has
  /// expressed no preference and the platform default should apply.
  final String? pythonPath;

  WorkerSettings copyWith({String? pythonPath}) {
    return WorkerSettings(pythonPath: pythonPath ?? this.pythonPath);
  }
}

/// Reads and writes [WorkerSettings] at `~/.discoman/settings.json`, beside the
/// machine token and the linked scripts.
///
/// Shared between the desktop app and the CLI on purpose: someone who picks an
/// interpreter in the app and later runs `discoman-compute start` in a terminal
/// means the same interpreter both times.
class WorkerSettingsStore {
  WorkerSettingsStore(this.file);

  final File file;

  /// The default location, beside the other per-machine state.
  factory WorkerSettingsStore.defaultLocation() {
    final env = Platform.environment;
    final home = env['HOME'] ?? env['USERPROFILE'];
    if (home == null || home.trim().isEmpty) {
      throw StateError(
        'Cannot determine the home directory (HOME/USERPROFILE unset).',
      );
    }
    final sep = Platform.pathSeparator;
    return WorkerSettingsStore(File('$home$sep.discoman${sep}settings.json'));
  }

  /// The stored settings, or empty settings when there is nothing to read.
  ///
  /// Never throws. A missing file and a corrupt one mean the same thing to
  /// every caller: no preference has been expressed.
  WorkerSettings load() {
    try {
      if (!file.existsSync()) return const WorkerSettings();
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) return const WorkerSettings();
      final python = decoded['pythonPath'];
      return WorkerSettings(
        pythonPath: (python is String && python.trim().isNotEmpty)
            ? python.trim()
            : null,
      );
    } catch (_) {
      return const WorkerSettings();
    }
  }

  /// Writes [settings], creating `~/.discoman` if needed.
  ///
  /// Written through a temp file and renamed, as with the machine token: an
  /// interrupted write must not leave a half-parsed file that silently reads
  /// as "no preference" the next time the worker starts.
  void save(WorkerSettings settings) {
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final tmp = File('${file.path}.tmp');
    tmp.writeAsStringSync(
      jsonEncode({
        if (settings.pythonPath != null) 'pythonPath': settings.pythonPath,
      }),
      flush: true,
    );
    tmp.renameSync(file.path);
  }
}

/// The stored settings, or empty settings when they cannot be reached at all.
///
/// Used where a missing home directory is a normal condition rather than a
/// fault — the cloud worker runs in a container that has neither a home nor
/// any use for these settings.
WorkerSettings loadWorkerSettingsOrEmpty() {
  try {
    return WorkerSettingsStore.defaultLocation().load();
  } catch (_) {
    return const WorkerSettings();
  }
}
