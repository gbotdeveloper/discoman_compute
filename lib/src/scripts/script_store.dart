import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

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

  /// The default location: `~/.discoman/scripts/`, beside the machine token.
  factory ScriptStore.defaultLocation() {
    final env = Platform.environment;
    final home = env['HOME'] ?? env['USERPROFILE'];
    if (home == null || home.trim().isEmpty) {
      throw StateError(
        'Cannot determine the home directory (HOME/USERPROFILE unset).',
      );
    }
    final sep = Platform.pathSeparator;
    return ScriptStore(Directory('$home$sep.discoman${sep}scripts'));
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
