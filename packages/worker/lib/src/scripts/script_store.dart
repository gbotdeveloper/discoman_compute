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
  /// one, and returns the stored file.
  ///
  /// Written through a temp file and renamed, so an interrupted copy cannot
  /// leave a truncated script that would fail at run time rather than here.
  File store(String projectId, String source) {
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
    return target;
  }

  File _originFileFor(String projectId) {
    return File(
      '${directory.path}${Platform.pathSeparator}$projectId.origin.json',
    );
  }

  /// Where the script for [projectId] was linked from, or null for a script
  /// linked before that was recorded, or copied here from Discoman.
  ScriptOrigin? originFor(String projectId) {
    try {
      final file = _originFileFor(projectId);
      if (!file.existsSync()) return null;
      final json = jsonDecode(file.readAsStringSync());
      if (json is! Map) return null;
      final path = json['path'];
      final fingerprint = json['fingerprint'];
      if (path is! String || fingerprint is! String) return null;
      return ScriptOrigin(path: path, fingerprint: fingerprint);
    } catch (_) {
      return null;
    }
  }

  /// Records where the script for [projectId] lives, and the fingerprint of
  /// the version last checked against the linked contract.
  void storeOrigin(String projectId, ScriptOrigin origin) {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final target = _originFileFor(projectId);
    final tmp = File('${target.path}.tmp');
    tmp.writeAsStringSync(
      jsonEncode({'path': origin.path, 'fingerprint': origin.fingerprint}),
      flush: true,
    );
    _chmod(tmp.path, '600');
    tmp.renameSync(target.path);
  }

  /// Forgets where the script for [projectId] came from.
  void clearOrigin(String projectId) {
    final file = _originFileFor(projectId);
    if (file.existsSync()) file.deleteSync();
  }

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

/// The script a project was linked from on this computer. Runs use it, as it
/// is now, from its own folder.
class ScriptOrigin {
  const ScriptOrigin({required this.path, required this.fingerprint});

  final String path;

  /// The version last known to match the linked contract.
  final String fingerprint;
}
