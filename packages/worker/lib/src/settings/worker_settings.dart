import 'dart:convert';
import 'dart:io';

import '../external_code.dart';
import '../home_path.dart';

/// Preferences a creator sets once and both front ends honour.
class WorkerSettings {
  const WorkerSettings({
    this.pythonPath,
    this.pausedProjectIds = const {},
    this.externalCode = const {},
    this.parallelRuns = 1,
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

  /// Code outside Discoman that each project's script uses on this machine,
  /// so the dashboard can show which version every computer has.
  final Map<String, List<ExternalCodeSource>> externalCode;

  /// How many runs this computer takes at once.
  final int parallelRuns;

  WorkerSettings copyWith({
    String? pythonPath,
    Set<String>? pausedProjectIds,
    Map<String, List<ExternalCodeSource>>? externalCode,
    int? parallelRuns,
  }) {
    return WorkerSettings(
      pythonPath: pythonPath ?? this.pythonPath,
      pausedProjectIds: pausedProjectIds ?? this.pausedProjectIds,
      externalCode: externalCode ?? this.externalCode,
      parallelRuns: parallelRuns ?? this.parallelRuns,
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
      final external = decoded['externalCode'];
      final parallel = decoded['parallelRuns'];
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
        externalCode: external is Map
            ? {
                for (final entry in external.entries)
                  if (entry.key is String && entry.value is List)
                    entry.key as String: [
                      for (final item in entry.value as List)
                        ?ExternalCodeSource.tryFromJson(item),
                    ],
              }
            : const {},
        parallelRuns: parallel is int && parallel > 1 ? parallel : 1,
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
        if (settings.externalCode.values.any((list) => list.isNotEmpty))
          'externalCode': {
            for (final entry in settings.externalCode.entries)
              if (entry.value.isNotEmpty)
                entry.key: [for (final code in entry.value) code.toJson()],
          },
        if (settings.parallelRuns > 1) 'parallelRuns': settings.parallelRuns,
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
