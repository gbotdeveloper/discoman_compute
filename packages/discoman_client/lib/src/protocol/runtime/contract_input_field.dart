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
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

/// A single input parameter inferred from a Python script's entrypoint.
/// Mirrors `ExtractedInputField` from the legacy contract extraction.
abstract class ContractInputField implements _i1.SerializableModel {
  ContractInputField._({
    required this.id,
    required this.parameterName,
    required this.label,
    required this.type,
    required this.isRequired,
    required this.controlHint,
    required this.validationHint,
    required this.options,
  });

  factory ContractInputField({
    required String id,
    required String parameterName,
    required String label,
    required _i2.PythonFieldType type,
    required bool isRequired,
    required String controlHint,
    required String validationHint,
    required List<String> options,
  }) = _ContractInputFieldImpl;

  factory ContractInputField.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContractInputField(
      id: jsonSerialization['id'] as String,
      parameterName: jsonSerialization['parameterName'] as String,
      label: jsonSerialization['label'] as String,
      type: _i2.PythonFieldType.fromJson((jsonSerialization['type'] as String)),
      isRequired: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isRequired'],
      ),
      controlHint: jsonSerialization['controlHint'] as String,
      validationHint: jsonSerialization['validationHint'] as String,
      options: _i3.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
    );
  }

  /// Stable draft identifier, e.g. "draft-input-1".
  String id;

  /// The Python parameter name.
  String parameterName;

  /// Human-friendly label derived from the parameter name.
  String label;

  /// Inferred field type.
  _i2.PythonFieldType type;

  /// Whether the parameter has no default value (i.e. is required).
  bool isRequired;

  /// Hint describing the suggested UI control for this input.
  String controlHint;

  /// Optional validation guidance for this input.
  String validationHint;

  /// Category/dropdown options when the type is `category`.
  List<String> options;

  /// Returns a shallow copy of this [ContractInputField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ContractInputField copyWith({
    String? id,
    String? parameterName,
    String? label,
    _i2.PythonFieldType? type,
    bool? isRequired,
    String? controlHint,
    String? validationHint,
    List<String>? options,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContractInputField',
      'id': id,
      'parameterName': parameterName,
      'label': label,
      'type': type.toJson(),
      'isRequired': isRequired,
      'controlHint': controlHint,
      'validationHint': validationHint,
      'options': options.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ContractInputFieldImpl extends ContractInputField {
  _ContractInputFieldImpl({
    required String id,
    required String parameterName,
    required String label,
    required _i2.PythonFieldType type,
    required bool isRequired,
    required String controlHint,
    required String validationHint,
    required List<String> options,
  }) : super._(
         id: id,
         parameterName: parameterName,
         label: label,
         type: type,
         isRequired: isRequired,
         controlHint: controlHint,
         validationHint: validationHint,
         options: options,
       );

  /// Returns a shallow copy of this [ContractInputField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ContractInputField copyWith({
    String? id,
    String? parameterName,
    String? label,
    _i2.PythonFieldType? type,
    bool? isRequired,
    String? controlHint,
    String? validationHint,
    List<String>? options,
  }) {
    return ContractInputField(
      id: id ?? this.id,
      parameterName: parameterName ?? this.parameterName,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      controlHint: controlHint ?? this.controlHint,
      validationHint: validationHint ?? this.validationHint,
      options: options ?? this.options.map((e0) => e0).toList(),
    );
  }
}
