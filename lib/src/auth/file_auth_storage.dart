import 'dart:convert';
import 'dart:io';

/// Persists the remote worker's per-machine token at `~/.discoman/credentials.json`.
///
/// This is NOT a Serverpod session store. Remote mode never persists a
/// Serverpod [AuthSuccess]; it persists only the long-lived machine token
/// (a plain string) and re-exchanges it via `workerAuth.loginRemote` on every
/// run. The file therefore holds exactly `{"machineToken": "..."}`.
///
/// Writes are atomic (temp file + rename) so a crash mid-write can never leave
/// a half-written credentials file, and the file is locked down to `0600`.
class MachineTokenStore {
  MachineTokenStore(this._file);

  final File _file;

  /// The default location: `~/.discoman/credentials.json`.
  factory MachineTokenStore.defaultLocation() {
    final home = _homeDirectory();
    return MachineTokenStore(
      File(
        '${home.path}${Platform.pathSeparator}.discoman'
        '${Platform.pathSeparator}credentials.json',
      ),
    );
  }

  /// The credentials file path (for user-facing messages).
  String get path => _file.path;

  static Directory _homeDirectory() {
    final env = Platform.environment;
    final home = env['HOME'] ?? env['USERPROFILE'];
    if (home == null || home.trim().isEmpty) {
      throw StateError(
        'Cannot determine the home directory (HOME/USERPROFILE unset).',
      );
    }
    return Directory(home);
  }

  /// Returns the stored machine token, or null if none is stored / the file is
  /// missing or unreadable.
  String? read() {
    if (!_file.existsSync()) return null;
    try {
      final decoded = jsonDecode(_file.readAsStringSync());
      if (decoded is Map && decoded['machineToken'] is String) {
        final token = (decoded['machineToken'] as String).trim();
        return token.isEmpty ? null : token;
      }
    } catch (_) {
      // A corrupt file is treated as "no credential"; the user re-runs login.
    }
    return null;
  }

  /// Atomically writes [machineToken], creating `~/.discoman` if needed and
  /// restricting permissions to the owner.
  void write(String machineToken) {
    final dir = _file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _chmod(dir.path, '700');

    final tmp = File('${_file.path}.tmp');
    tmp.writeAsStringSync(
      jsonEncode({'machineToken': machineToken}),
      flush: true,
    );
    _chmod(tmp.path, '600');
    // rename is atomic within the same directory on POSIX and Windows.
    tmp.renameSync(_file.path);
    _chmod(_file.path, '600');
  }

  /// Removes the stored credential (used when it is revoked/invalid).
  void clear() {
    if (_file.existsSync()) {
      _file.deleteSync();
    }
  }

  static void _chmod(String path, String mode) {
    if (Platform.isWindows) return;
    try {
      Process.runSync('chmod', [mode, path]);
    } catch (_) {
      // Best effort: on platforms without chmod the token is still written.
    }
  }
}
