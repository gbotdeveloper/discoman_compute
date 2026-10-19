import 'dart:convert';
import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

import 'python/imports.dart';
import 'python/interpreter_check.dart';
import 'scripts/script_store.dart';
import 'settings/worker_settings.dart';

typedef RunProcess =
    Future<ProcessResult> Function(String executable, List<String> arguments);

/// Checks this machine's Python and scripts without running any script.
///
/// Every project in [expectedScripts] or on disk is reported: whether its
/// script is here, whether it matches the one last linked, and which of its
/// imports this Python cannot find.
Future<MachineCheckResult> runMachineCheck({
  required String pythonPath,
  required ScriptStore scriptStore,
  required WorkerSettings settings,
  required Map<String, String?> expectedScripts,
  RunProcess? runProcess,
}) async {
  final interpreter = await checkInterpreter(
    pythonPath,
    runProcess: runProcess,
  );

  final projectIds = {
    ...expectedScripts.keys,
    ...scriptStore.linkedProjectIds(),
  }.toList()..sort();
  final sources = <String, String>{};
  for (final projectId in projectIds) {
    final file = scriptStore.fileFor(projectId);
    if (file.existsSync()) sources[projectId] = file.readAsStringSync();
  }

  final modulesByProject = {
    for (final entry in sources.entries)
      entry.key: importedModules(entry.value),
  };
  final missing = interpreter.isUsable
      ? await _missingModules(pythonPath, {
          for (final modules in modulesByProject.values) ...modules,
        }, runProcess ?? (exe, args) => Process.run(exe, args))
      : const <String>{};

  return MachineCheckResult(
    pythonPath: pythonPath,
    pythonVersion: interpreter.version,
    pythonUsable: interpreter.isUsable,
    pythonProblem: interpreter.isUsable ? null : interpreter.message,
    scripts: [
      for (final projectId in projectIds)
        MachineCheckScript(
          projectId: projectId,
          present: sources.containsKey(projectId),
          paused: settings.pausedProjectIds.contains(projectId),
          fingerprint: sources.containsKey(projectId)
              ? fingerprintScript(sources[projectId]!)
              : null,
          expectedFingerprint: expectedScripts[projectId],
          missingModules: [
            for (final module
                in modulesByProject[projectId] ?? const <String>[])
              if (missing.contains(module)) module,
          ],
        ),
    ],
  );
}

/// Which of [modules] the interpreter at [pythonPath] cannot import. Only
/// looks them up, so no module code runs.
Future<Set<String>> _missingModules(
  String pythonPath,
  Set<String> modules,
  RunProcess run,
) async {
  if (modules.isEmpty) return const {};
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
