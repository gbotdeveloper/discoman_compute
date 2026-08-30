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
import '../runtime/python_field_type.dart' as _i2;

abstract class ContractOutputField implements _i1.SerializableModel {
  ContractOutputField._({
    required this.id,
    required this.outputKey,
    required this.displayLabel,
    required this.type,
    required this.presentationHint,
  });

  factory ContractOutputField({
    required String id,
    required String outputKey,
    required String displayLabel,
    required _i2.PythonFieldType type,
    required String presentationHint,
  }) = _ContractOutputFieldImpl;

  factory ContractOutputField.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContractOutputField(
      id: jsonSerialization['id'] as String,
      outputKey: jsonSerialization['outputKey'] as String,
      displayLabel: jsonSerialization['displayLabel'] as String,
      type: _i2.PythonFieldType.fromJson((jsonSerialization['type'] as String)),
      presentationHint: jsonSerialization['presentationHint'] as String,
    );
  }

  String id;

  String outputKey;

  String displayLabel;

  _i2.PythonFieldType type;

  String presentationHint;

  @_i1.useResult
  ContractOutputField copyWith({
    String? id,
    String? outputKey,
    String? displayLabel,
    _i2.PythonFieldType? type,
    String? presentationHint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContractOutputField',
      'id': id,
      'outputKey': outputKey,
      'displayLabel': displayLabel,
      'type': type.toJson(),
      'presentationHint': presentationHint,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ContractOutputFieldImpl extends ContractOutputField {
  _ContractOutputFieldImpl({
    required String id,
    required String outputKey,
    required String displayLabel,
    required _i2.PythonFieldType type,
    required String presentationHint,
  }) : super._(
         id: id,
         outputKey: outputKey,
         displayLabel: displayLabel,
         type: type,
         presentationHint: presentationHint,
       );

  @_i1.useResult
  @override
  ContractOutputField copyWith({
    String? id,
    String? outputKey,
    String? displayLabel,
    _i2.PythonFieldType? type,
    String? presentationHint,
  }) {
    return ContractOutputField(
      id: id ?? this.id,
      outputKey: outputKey ?? this.outputKey,
      displayLabel: displayLabel ?? this.displayLabel,
      type: type ?? this.type,
      presentationHint: presentationHint ?? this.presentationHint,
    );
  }
}
