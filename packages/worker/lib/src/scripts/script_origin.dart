import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

import '../python/contract_extractor.dart';
import 'script_store.dart';

/// How the script a project was linked from compares with what was linked.
enum ScriptOriginState {
  /// The same version that was linked or last checked.
  unchanged,

  /// Edited, with the same inputs and outputs, so it still runs.
  updated,

  /// No longer at its path.
  missing,

  /// Its inputs or outputs changed, or they cannot be read any more.
  contractChanged,
}

class ScriptOriginCheck {
  const ScriptOriginCheck(this.state, {this.source, this.message});

  final ScriptOriginState state;

  /// The script as it is now, when it can run.
  final String? source;

  /// Why it cannot run, when it cannot.
  final String? message;

  bool get canRun =>
      state == ScriptOriginState.unchanged ||
      state == ScriptOriginState.updated;
}

/// Compares the script at [origin] with [linkedSource], the copy its contract
/// was read from. Only the inputs, outputs and entrypoint matter: an edit
/// that keeps them runs as it is.
ScriptOriginCheck checkScriptOrigin(
  ScriptOrigin origin, {
  required String? linkedSource,
}) {
  final file = File(origin.path);
  if (!file.existsSync()) {
    return ScriptOriginCheck(
      ScriptOriginState.missing,
      message:
          'The script linked to this project is no longer at ${origin.path}. '
          'Link it again in Discoman Compute.',
    );
  }
  final String source;
  try {
    source = file.readAsStringSync();
  } on IOException catch (error) {
    return ScriptOriginCheck(
      ScriptOriginState.missing,
      message: 'Could not read the linked script at ${origin.path}: $error',
    );
  }
  if (fingerprintScript(source) == origin.fingerprint) {
    return ScriptOriginCheck(ScriptOriginState.unchanged, source: source);
  }
  if (linkedSource == null) {
    return ScriptOriginCheck(ScriptOriginState.updated, source: source);
  }

  final ContractDraft now;
  try {
    now = extractContractDraft(source);
  } on ScriptRunException catch (error) {
    return ScriptOriginCheck(
      ScriptOriginState.contractChanged,
      message:
          'The script at ${origin.path} no longer reads as a contract '
          '(${error.message}). Fix it, or link it again in Discoman Compute.',
    );
  }
  final ContractDraft linked;
  try {
    linked = extractContractDraft(linkedSource);
  } on ScriptRunException {
    return ScriptOriginCheck(ScriptOriginState.updated, source: source);
  }
  if (!sameInputsAndOutputs(linked, now)) {
    return const ScriptOriginCheck(
      ScriptOriginState.contractChanged,
      message:
          "The script's inputs or outputs changed — link it again in "
          'Discoman Compute.',
    );
  }
  return ScriptOriginCheck(ScriptOriginState.updated, source: source);
}

/// Whether [a] and [b] take and return the same things: the entrypoint, and
/// each input and output by name, type and whether it is a list.
bool sameInputsAndOutputs(ContractDraft a, ContractDraft b) {
  Map<String, String> inputs(ContractDraft draft) => {
    for (final field in draft.inputFields)
      field.parameterName: '${field.type.name}/${field.multiple}',
  };
  Map<String, String> outputs(ContractDraft draft) => {
    for (final field in draft.outputFields)
      field.outputKey: '${field.type.name}/${field.multiple}',
  };
  bool same(Map<String, String> x, Map<String, String> y) =>
      x.length == y.length &&
      x.entries.every((entry) => y[entry.key] == entry.value);
  return a.entrypointName == b.entrypointName &&
      same(inputs(a), inputs(b)) &&
      same(outputs(a), outputs(b));
}
