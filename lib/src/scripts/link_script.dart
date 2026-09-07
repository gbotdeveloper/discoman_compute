import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

import '../auth/remote_auth.dart';
import '../home_path.dart';
import '../auth/session.dart';
import '../python/contract_extractor.dart';
import '../worker_config.dart';
import 'script_store.dart';

/// The `link` flow: attaches a Python script on this machine to one of the
/// creator's projects.
///
/// The script is read, parsed, and stored here. Only the contract it describes
/// and a fingerprint of the file are sent to the server, so the creator's code
/// stays on this computer — that is the whole point of the command.
///
/// [scriptPathArg] and [projectIdArg] skip the corresponding prompt when given.
Future<int> runLink(
  WorkerConfig config, {
  String? scriptPathArg,
  String? projectIdArg,
}) async {
  final String source;
  final File scriptFile;
  try {
    scriptFile = await _resolveScriptFile(scriptPathArg);
    source = scriptFile.readAsStringSync();
  } on _LinkAborted catch (error) {
    stderr.writeln(error.message);
    return 1;
  }

  // Parsed before signing in: a script this command cannot read is the
  // creator's to fix, and there is no reason to ask for a password first.
  final ContractDraft draft;
  try {
    draft = extractContractDraft(source);
  } on ScriptRunException catch (error) {
    stderr.writeln('Could not read a contract from ${scriptFile.path}:');
    stderr.writeln('  ${error.message}');
    return 1;
  }

  _printDraft(draft);

  final WorkerSession session;
  try {
    session = await signInInteractively(config);
  } on RemoteAuthException catch (error) {
    stderr.writeln(error.message);
    return 1;
  }

  try {
    final projectId = await _resolveProject(session, projectIdArg);
    if (projectId == null) return 1;

    if (!_confirm('Link this contract to the project?')) {
      stdout.writeln('Nothing was changed.');
      return 0;
    }

    final fingerprint = fingerprintScript(source);

    // Stored before publishing: if the call fails the creator can retry, but a
    // published contract with no script behind it would leave the project
    // pointing at a file this machine does not have.
    final stored = ScriptStore.defaultLocation().store(projectId, source);

    await session.client.creatorScript.publishContract(
      projectId,
      draft,
      fingerprint,
    );

    stdout.writeln('Linked. The script is kept at ${stored.path}.');
    stdout.writeln(
      'Open the project in GBot to design its screens, then run '
      "'discoman-compute start' to serve it from this machine.",
    );
    return 0;
  } on ScriptRunException catch (error) {
    stderr.writeln('The server rejected the contract: ${error.message}');
    return 1;
  } catch (error) {
    stderr.writeln('Linking failed: $error');
    return 1;
  } finally {
    session.client.close();
  }
}

/// Raised for a script path the creator gave that cannot be used.
class _LinkAborted implements Exception {
  _LinkAborted(this.message);

  final String message;
}

Future<File> _resolveScriptFile(String? pathArg) async {
  var path = pathArg?.trim() ?? '';
  if (path.isEmpty) {
    stdout.write('Path to your Python script: ');
    path = stdin.readLineSync()?.trim() ?? '';
  }
  if (path.isEmpty) {
    throw _LinkAborted('No script path given.');
  }

  path = expandHomePath(path);

  final file = File(path);
  if (!file.existsSync()) {
    throw _LinkAborted('No file at $path.');
  }
  return file;
}

/// Lists the creator's projects and returns the id they picked, or null if
/// there is nothing to pick.
Future<String?> _resolveProject(
  WorkerSession session,
  String? projectIdArg,
) async {
  final given = projectIdArg?.trim() ?? '';
  if (given.isNotEmpty) return given;

  final projects = await session.client.creatorScript.listProjects();
  if (projects.isEmpty) {
    stderr.writeln(
      'You have no projects yet. Create one in GBot first, then run this '
      'command again.',
    );
    return null;
  }

  stdout.writeln('\nYour projects:');
  for (var i = 0; i < projects.length; i++) {
    final project = projects[i];
    final linked = project.scriptLocation == ScriptLocation.creatorMachine
        ? ' (already runs on your machine)'
        : '';
    stdout.writeln('  ${i + 1}. ${project.name}$linked');
  }

  stdout.write('Which one? [1-${projects.length}] ');
  final answer = int.tryParse(stdin.readLineSync()?.trim() ?? '');
  if (answer == null || answer < 1 || answer > projects.length) {
    stderr.writeln('That is not one of the listed numbers.');
    return null;
  }
  return projects[answer - 1].projectId;
}

void _printDraft(ContractDraft draft) {
  stdout.writeln('\nEntrypoint: ${draft.entrypointName}');

  stdout.writeln('Inputs:');
  if (draft.inputFields.isEmpty) {
    stdout.writeln('  (none)');
  }
  for (final field in draft.inputFields) {
    final required = field.isRequired ? 'required' : 'optional';
    stdout.writeln(
      '  ${field.parameterName} — ${field.type.name}, $required',
    );
  }

  stdout.writeln('Outputs:');
  if (draft.outputFields.isEmpty) {
    stdout.writeln('  (none)');
  }
  for (final field in draft.outputFields) {
    stdout.writeln('  ${field.outputKey} — ${field.type.name}');
  }

  if (draft.notes.isNotEmpty) {
    stdout.writeln('Notes:');
    for (final note in draft.notes) {
      stdout.writeln('  $note');
    }
  }
}

bool _confirm(String question) {
  stdout.write('\n$question [y/N] ');
  final answer = stdin.readLineSync()?.trim().toLowerCase() ?? '';
  return answer == 'y' || answer == 'yes';
}
