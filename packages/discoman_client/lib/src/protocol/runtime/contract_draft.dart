/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:discoman_client/src/protocol/protocol.dart' as _iy9hkqa4;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../runtime/contract_input_field.dart' as _i8w5nnxk;
import '../runtime/contract_output_field.dart' as _io5zd92x;

/// The contract draft extracted by statically inspecting a Python script.
/// Returned to the client, which persists it (e.g. to Firestore). Mirrors
/// `ExtractionDraft` from the legacy `inspectPythonScript` Cloud Function.
abstract class ContractDraft
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ContractDraft._({
    required this.entrypointName,
    required this.inputFields,
    required this.outputFields,
    required this.notes,
    required this.summaryMessage,
  });

  factory ContractDraft({
    required String entrypointName,
    required List<_i8w5nnxk.ContractInputField> inputFields,
    required List<_io5zd92x.ContractOutputField> outputFields,
    required List<String> notes,
    required String summaryMessage,
  }) = _ContractDraftImpl;

  factory ContractDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContractDraft(
      entrypointName: jsonSerialization['entrypointName'] as String,
      inputFields: _iy9hkqa4.Protocol()
          .deserialize<List<_i8w5nnxk.ContractInputField>>(
            jsonSerialization['inputFields'],
          ),
      outputFields: _iy9hkqa4.Protocol()
          .deserialize<List<_io5zd92x.ContractOutputField>>(
            jsonSerialization['outputFields'],
          ),
      notes: _iy9hkqa4.Protocol().deserialize<List<String>>(
        jsonSerialization['notes'],
      ),
      summaryMessage: jsonSerialization['summaryMessage'] as String,
    );
  }

  /// The detected entrypoint function name (e.g. "run", "main").
  String entrypointName;

  /// Inferred input parameters.
  List<_i8w5nnxk.ContractInputField> inputFields;

  /// Inferred output fields.
  List<_io5zd92x.ContractOutputField> outputFields;

  /// Diagnostic notes about how the extraction was performed.
  List<String> notes;

  /// Short human-readable summary of the extraction result.
  String summaryMessage;

  /// Returns a shallow copy of this [ContractDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ContractDraft copyWith({
    String? entrypointName,
    List<_i8w5nnxk.ContractInputField>? inputFields,
    List<_io5zd92x.ContractOutputField>? outputFields,
    List<String>? notes,
    String? summaryMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContractDraft',
      'entrypointName': entrypointName,
      'inputFields': inputFields.toJson(valueToJson: (v) => v.toJson()),
      'outputFields': outputFields.toJson(valueToJson: (v) => v.toJson()),
      'notes': notes.toJson(),
      'summaryMessage': summaryMessage,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ContractDraft',
      'entrypointName': entrypointName,
      'inputFields': inputFields.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'outputFields': outputFields.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'notes': notes.toJson(),
      'summaryMessage': summaryMessage,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ContractDraftImpl extends ContractDraft {
  _ContractDraftImpl({
    required String entrypointName,
    required List<_i8w5nnxk.ContractInputField> inputFields,
    required List<_io5zd92x.ContractOutputField> outputFields,
    required List<String> notes,
    required String summaryMessage,
  }) : super._(
         entrypointName: entrypointName,
         inputFields: inputFields,
         outputFields: outputFields,
         notes: notes,
         summaryMessage: summaryMessage,
       );

  /// Returns a shallow copy of this [ContractDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ContractDraft copyWith({
    String? entrypointName,
    List<_i8w5nnxk.ContractInputField>? inputFields,
    List<_io5zd92x.ContractOutputField>? outputFields,
    List<String>? notes,
    String? summaryMessage,
  }) {
    return ContractDraft(
      entrypointName: entrypointName ?? this.entrypointName,
      inputFields:
          inputFields ?? this.inputFields.map((e0) => e0.copyWith()).toList(),
      outputFields:
          outputFields ?? this.outputFields.map((e0) => e0.copyWith()).toList(),
      notes: notes ?? this.notes.map((e0) => e0).toList(),
      summaryMessage: summaryMessage ?? this.summaryMessage,
    );
  }
}
