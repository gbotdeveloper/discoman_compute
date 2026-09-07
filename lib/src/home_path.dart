import 'dart:io';

/// Expands a leading `~` to the user's home directory.
///
/// Shells expand `~` before a program ever sees it, so a path typed into a
/// terminal works. A path typed into a text field or read from a settings file
/// does not go through a shell — `Process.start` looks for a directory
/// literally named `~` and fails. Anything a creator can type by hand goes
/// through here first.
///
/// Returns [path] unchanged when it has no leading `~`, or when there is no
/// home directory to expand to.
///
/// [environment] is injectable because the Windows branch reads `USERPROFILE`
/// rather than `HOME`, and that branch cannot be exercised from a Mac any
/// other way.
String expandHomePath(String path, {Map<String, String>? environment}) {
  final trimmed = path.trim();
  if (trimmed != '~' &&
      !trimmed.startsWith('~/') &&
      !trimmed.startsWith(r'~\')) {
    return trimmed;
  }

  final env = environment ?? Platform.environment;
  final home = env['HOME'] ?? env['USERPROFILE'];
  if (home == null || home.trim().isEmpty) return trimmed;

  if (trimmed == '~') return home;
  return '$home${trimmed.substring(1)}';
}
