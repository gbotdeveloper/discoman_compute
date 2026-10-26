import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'imports.dart';
import 'pip_names.dart';

typedef RunProcess =
    Future<ProcessResult> Function(String executable, List<String> arguments);

typedef StartProcess =
    Future<Process> Function(String executable, List<String> arguments);

/// Which of [modules] the interpreter at [pythonPath] cannot import. Only
/// looks them up, so no module code runs. Empty when the lookup itself fails.
Future<Set<String>> findMissingModules(
  String pythonPath,
  Iterable<String> modules, {
  RunProcess? runProcess,
}) async {
  if (modules.isEmpty) return const {};
  final run = runProcess ?? (exe, args) => Process.run(exe, args);
  const lookup =
      'import importlib.util, json, sys\n'
      'print(json.dumps([m for m in sys.argv[1:] '
      'if importlib.util.find_spec(m) is None]))';
  try {
    final result = await run(pythonPath, ['-c', lookup, ...modules]);
    if (result.exitCode != 0) return const {};
    final lines = '${result.stdout}'.trim().split('\n');
    return {...(jsonDecode(lines.last) as List).cast<String>()};
  } catch (_) {
    return const {};
  }
}

/// The pip packages [source] needs that the interpreter at [pythonPath]
/// does not have.
Future<List<String>> missingPackagesFor(
  String pythonPath,
  String source, {
  RunProcess? runProcess,
}) async {
  final modules = importedModules(source);
  final missing = await findMissingModules(
    pythonPath,
    modules,
    runProcess: runProcess,
  );
  return pipPackagesFor(modules.where(missing.contains));
}

/// How a pip install went.
class PackageInstallResult {
  const PackageInstallResult({
    required this.success,
    this.externallyManaged = false,
  });

  final bool success;

  /// The interpreter refuses pip installs (PEP 668), as Homebrew's and many
  /// Linux system Pythons do.
  final bool externallyManaged;
}

/// Installs [packages] into the interpreter at [pythonPath] with pip,
/// handing every line pip prints to [onOutput].
Future<PackageInstallResult> installPackages(
  String pythonPath,
  List<String> packages, {
  required void Function(String line) onOutput,
  StartProcess? startProcess,
}) async {
  final start = startProcess ?? (exe, args) => Process.start(exe, args);
  final Process process;
  try {
    process = await start(pythonPath, [
      '-m',
      'pip',
      'install',
      '--disable-pip-version-check',
      ...packages,
    ]);
  } catch (error) {
    onOutput('Could not run $pythonPath: $error');
    return const PackageInstallResult(success: false);
  }

  var externallyManaged = false;
  void read(String line) {
    if (line.contains('externally-managed-environment')) {
      externallyManaged = true;
    }
    if (line.trim().isNotEmpty) onOutput(line);
  }

  await Future.wait([
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(read),
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(read),
  ]);
  final exitCode = await process.exitCode;
  return PackageInstallResult(
    success: exitCode == 0,
    externallyManaged: externallyManaged,
  );
}
