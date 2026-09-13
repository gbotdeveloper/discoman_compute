import 'dart:io';

import '../home_path.dart';

/// What running `<interpreter> --version` told us.
class InterpreterCheck {
  const InterpreterCheck._({
    required this.isUsable,
    required this.message,
    this.version,
  });

  /// Whether the path names a Python that actually runs.
  final bool isUsable;

  /// A sentence to show the creator, whichever way it went.
  final String message;

  /// The reported version, when there was one.
  final String? version;
}

/// Runs `<path> --version` and reports whether it is a usable interpreter.
///
/// A creator who mistypes a path or points at a Python without their packages
/// would otherwise only find out when a visitor's run fails. Checking costs
/// one process and answers it now.
///
/// [runProcess] exists so tests can supply a result instead of launching a
/// real interpreter.
Future<InterpreterCheck> checkInterpreter(
  String path, {
  Future<ProcessResult> Function(String executable, List<String> arguments)?
  runProcess,
}) async {
  final trimmed = expandHomePath(path);
  if (trimmed.isEmpty) {
    return const InterpreterCheck._(
      isUsable: false,
      message: 'Enter the path to a Python interpreter.',
    );
  }

  final run = runProcess ?? (exe, args) => Process.run(exe, args);

  final ProcessResult result;
  try {
    result = await run(trimmed, const ['--version']);
  } on ProcessException {
    return InterpreterCheck._(
      isUsable: false,
      message: 'Nothing runnable at $trimmed.',
    );
  } catch (error) {
    return InterpreterCheck._(
      isUsable: false,
      message: 'Could not run $trimmed: $error',
    );
  }

  if (result.exitCode != 0) {
    return InterpreterCheck._(
      isUsable: false,
      message: '$trimmed exited with code ${result.exitCode}.',
    );
  }

  // Python 3.4 and later print the version on stdout; older ones used stderr,
  // and some wrappers still do, so both are worth reading.
  final reported = [
    '${result.stdout}'.trim(),
    '${result.stderr}'.trim(),
  ].firstWhere((line) => line.isNotEmpty, orElse: () => '');

  if (!reported.toLowerCase().startsWith('python')) {
    return InterpreterCheck._(
      isUsable: false,
      message: reported.isEmpty
          ? '$trimmed ran but did not report a Python version.'
          : '$trimmed does not look like Python — it reported "$reported".',
    );
  }

  return InterpreterCheck._(
    isUsable: true,
    message: '$reported — ready to run your scripts.',
    version: reported,
  );
}
