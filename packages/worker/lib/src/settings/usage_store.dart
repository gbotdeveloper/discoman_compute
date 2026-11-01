import 'dart:convert';
import 'dart:io';

import '../home_path.dart';
import '../python/run_usage.dart';

/// The last few measured runs of each project, at `~/.discoman/usage.json`.
class UsageStore {
  UsageStore(this.file);

  final File file;

  static const keptPerProject = 5;

  factory UsageStore.defaultLocation() {
    final home = discomanHomeDirectory();
    return UsageStore(File('${home.path}${Platform.pathSeparator}usage.json'));
  }

  /// Never throws; a missing or corrupt file reads as nothing measured.
  Map<String, List<RunUsage>> load() {
    try {
      if (!file.existsSync()) return const {};
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is List)
            entry.key as String: [
              for (final item in entry.value as List)
                ?RunUsage.tryFromJson(item),
            ],
      };
    } catch (_) {
      return const {};
    }
  }

  /// Adds [usage] to [projectId]'s runs, dropping the oldest beyond
  /// [keptPerProject].
  void record(String projectId, RunUsage usage) {
    final all = {...load()};
    final runs = [...?all[projectId], usage];
    all[projectId] = runs.length > keptPerProject
        ? runs.sublist(runs.length - keptPerProject)
        : runs;

    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final tmp = File('${file.path}.tmp');
    tmp.writeAsStringSync(
      jsonEncode({
        for (final entry in all.entries)
          entry.key: [for (final run in entry.value) run.toJson()],
      }),
      flush: true,
    );
    tmp.renameSync(file.path);
  }
}
