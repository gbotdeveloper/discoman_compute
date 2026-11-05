import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../home_path.dart';

/// Holds the Python scripts a creator has linked to their projects, one file
/// per project, under `~/.discoman/scripts/`.
///
/// The script is copied here rather than run from wherever the creator picked
/// it, so a moved or renamed source file cannot break a published app halfway
/// through its life. It also gives the worker one predictable path to read at
/// run time.
///
/// Nothing in here is ever uploaded. This directory is the only copy of a
/// creator's code the system knows about.
class ScriptStore {
  ScriptStore(this.directory);

  final Directory directory;

  /// The default location: `scripts/` under [discomanHomeDirectory], beside the
  /// machine token.
  factory ScriptStore.defaultLocation() {
    final home = discomanHomeDirectory();
    return ScriptStore(
      Directory('${home.path}${Platform.pathSeparator}scripts'),
    );
  }

  /// Where the script for [projectId] lives, whether or not it exists yet.
  File fileFor(String projectId) {
    return File('${directory.path}${Platform.pathSeparator}$projectId.py');
  }

  /// Copies [source] in as the script for [projectId], replacing any previous
  /// one, and returns the stored file. [sourcePath], the file it was read
  /// from, is remembered beside it so runs can import the modules kept next
  /// to the original.
  ///
  /// Written through a temp file and renamed, so an interrupted copy cannot
  /// leave a truncated script that would fail at run time rather than here.
  File store(String projectId, String source, {String? sourcePath}) {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    _chmod(directory.path, '700');

    final target = fileFor(projectId);
    final tmp = File('${target.path}.tmp');
    tmp.writeAsStringSync(source, flush: true);
    _chmod(tmp.path, '600');
    tmp.renameSync(target.path);
    _chmod(target.path, '600');
    if (sourcePath != null) {
      _sourcePathFileFor(projectId).writeAsStringSync(sourcePath, flush: true);
    }
    return target;
  }

  /// The folder the script for [projectId] was linked from, when it was
  /// linked on this machine and that folder still exists. Runs put it on
  /// PYTHONPATH, so `import helper` finds a helper.py kept next to the script.
  Directory? sourceDirectoryFor(String projectId) {
    final file = _sourcePathFileFor(projectId);
    if (!file.existsSync()) return null;
    final path = file.readAsStringSync().trim();
    if (path.isEmpty) return null;
    final folder = File(path).parent;
    return folder.existsSync() ? folder : null;
  }

  File _sourcePathFileFor(String projectId) =>
      File('${directory.path}${Platform.pathSeparator}$projectId.source');

  /// The project ids this machine holds a script for.
  ///
  /// Read from disk on demand rather than cached: a creator setting up a second
  /// computer links scripts while the worker is already running, and the next
  /// poll should pick them up without a restart.
  List<String> linkedProjectIds() {
    if (!directory.existsSync()) return const [];
    return [
      for (final entry in directory.listSync())
        if (entry is File && entry.path.endsWith('.py'))
          entry.uri.pathSegments.last.replaceAll(RegExp(r'\.py$'), ''),
    ]..sort();
  }

  static void _chmod(String path, String mode) {
    if (Platform.isWindows) return;
    try {
      Process.runSync('chmod', [mode, path]);
    } catch (_) {
      // Best effort, matching MachineTokenStore: the file is still written.
    }
  }
}

/// Identifies the exact script a contract was read from.
///
/// Computed over the source with line endings normalised, rather than over the
/// file's bytes, so a creator's own copy of the same script on another computer
/// counts as the same script.
String fingerprintScript(String source) {
  final normalised = source.replaceAll('\r\n', '\n');
  return 'sha256:${sha256.convert(utf8.encode(normalised))}';
}
