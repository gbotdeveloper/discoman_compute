import 'package:discoman_client/discoman_client.dart';

import 'python/imports.dart';
import 'python/interpreter_check.dart';
import 'python/packages.dart';
import 'python/pip_names.dart';
import 'scripts/script_store.dart';
import 'settings/worker_settings.dart';

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
      ? await findMissingModules(pythonPath, {
          for (final modules in modulesByProject.values) ...modules,
        }, runProcess: runProcess)
      : const <String>{};

  return MachineCheckResult(
    pythonPath: pythonPath,
    pythonVersion: interpreter.version,
    pythonUsable: interpreter.isUsable,
    pythonProblem: interpreter.isUsable ? null : interpreter.message,
    pythonProblemCode: interpreter.problem?.name,
    missingPackages: pipPackagesFor(missing.toList()..sort()),
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
