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

/// The PATH a run gets: [extraPath] first, then the login shell's, then the
/// inherited one, each folder once.
Map<String, String> runEnvironment({
  List<String> extraPath = const [],
  Map<String, String>? inherited,
  String? loginShellPath,
}) {
  final base = inherited ?? Platform.environment;
  final separator = Platform.isWindows ? ';' : ':';
  final key = base.keys.firstWhere(
    (name) => name.toUpperCase() == 'PATH',
    orElse: () => 'PATH',
  );
  final folders = <String>{
    for (final folder in extraPath)
      if (folder.trim().isNotEmpty) folder.trim(),
    if (!Platform.isWindows)
      for (final folder in (loginShellPath ?? _loginShellPath ?? '').split(
        separator,
      ))
        if (folder.isNotEmpty) folder,
    for (final folder in (base[key] ?? '').split(separator))
      if (folder.isNotEmpty) folder,
  };
  return {key: folders.join(separator)};
}
