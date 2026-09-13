import 'dart:convert';
import 'dart:io';

import '../home_path.dart';

/// Preferences a creator sets once and both front ends honour.
class WorkerSettings {
  const WorkerSettings({
    this.pythonPath,
    this.pausedProjectIds = const {},
  });

  /// The Python interpreter to run scripts with, or null when the creator has
  /// expressed no preference and the platform default should apply.
  final String? pythonPath;

  /// Projects this machine will not take work for, even though it holds their
  /// script.
  ///
  /// Stored rather than held in memory: a creator who switches a project off
  /// and closes the window has said something about this machine, not about
  /// this session. Coming back to find it switched on again — and a day of
  /// held-back runs starting at once — is not what they asked for.
  final Set<String> pausedProjectIds;

  WorkerSettings copyWith({
    String? pythonPath,
    Set<String>? pausedProjectIds,
  }) {
    return WorkerSettings(
      pythonPath: pythonPath ?? this.pythonPath,
      pausedProjectIds: pausedProjectIds ?? this.pausedProjectIds,
    );
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
    final home = discomanHomeDirectory();
    return WorkerSettingsStore(
      File('${home.path}${Platform.pathSeparator}settings.json'),
    );
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
      final paused = decoded['pausedProjectIds'];
      return WorkerSettings(
        pythonPath: (python is String && python.trim().isNotEmpty)
            ? python.trim()
            : null,
        pausedProjectIds: paused is List
            ? {
                for (final id in paused)
                  if (id is String && id.trim().isNotEmpty) id.trim(),
              }
            : const {},
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
        if (settings.pausedProjectIds.isNotEmpty)
          'pausedProjectIds': settings.pausedProjectIds.toList()..sort(),
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
