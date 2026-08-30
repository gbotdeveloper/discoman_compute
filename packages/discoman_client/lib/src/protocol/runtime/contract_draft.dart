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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../runtime/contract_input_field.dart' as _i2;
import '../runtime/contract_output_field.dart' as _i3;
import 'package:discoman_client/src/protocol/protocol.dart' as _i4;

abstract class ContractDraft implements _i1.SerializableModel {
  ContractDraft._({
    required this.entrypointName,
    required this.inputFields,
    required this.outputFields,
    required this.notes,
    required this.summaryMessage,
  });

  factory ContractDraft({
    required String entrypointName,
    required List<_i2.ContractInputField> inputFields,
    required List<_i3.ContractOutputField> outputFields,
    required List<String> notes,
    required String summaryMessage,
  }) = _ContractDraftImpl;

  factory ContractDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContractDraft(
      entrypointName: jsonSerialization['entrypointName'] as String,
      inputFields: _i4.Protocol().deserialize<List<_i2.ContractInputField>>(
        jsonSerialization['inputFields'],
      ),
      outputFields: _i4.Protocol().deserialize<List<_i3.ContractOutputField>>(
        jsonSerialization['outputFields'],
      ),
      notes: _i4.Protocol().deserialize<List<String>>(
        jsonSerialization['notes'],
      ),
      summaryMessage: jsonSerialization['summaryMessage'] as String,
    );
  }

  String entrypointName;

  List<_i2.ContractInputField> inputFields;

  List<_i3.ContractOutputField> outputFields;

  List<String> notes;

  String summaryMessage;

  @_i1.useResult
  ContractDraft copyWith({
    String? entrypointName,
    List<_i2.ContractInputField>? inputFields,
    List<_i3.ContractOutputField>? outputFields,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ContractDraftImpl extends ContractDraft {
  _ContractDraftImpl({
    required String entrypointName,
    required List<_i2.ContractInputField> inputFields,
    required List<_i3.ContractOutputField> outputFields,
    required List<String> notes,
    required String summaryMessage,
  }) : super._(
         entrypointName: entrypointName,
         inputFields: inputFields,
         outputFields: outputFields,
         notes: notes,
         summaryMessage: summaryMessage,
       );

  @_i1.useResult
  @override
  ContractDraft copyWith({
    String? entrypointName,
    List<_i2.ContractInputField>? inputFields,
    List<_i3.ContractOutputField>? outputFields,
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
