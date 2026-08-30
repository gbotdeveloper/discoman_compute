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

abstract class HistoryFieldDescriptor implements _i1.SerializableModel {
  HistoryFieldDescriptor._({
    required this.key,
    required this.label,
    required this.type,
  });

  factory HistoryFieldDescriptor({
    required String key,
    required String label,
    required _i2.PythonFieldType type,
  }) = _HistoryFieldDescriptorImpl;

  factory HistoryFieldDescriptor.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HistoryFieldDescriptor(
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      type: _i2.PythonFieldType.fromJson((jsonSerialization['type'] as String)),
    );
  }

  String key;

  String label;

  _i2.PythonFieldType type;

  @_i1.useResult
  HistoryFieldDescriptor copyWith({
    String? key,
    String? label,
    _i2.PythonFieldType? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HistoryFieldDescriptor',
      'key': key,
      'label': label,
      'type': type.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _HistoryFieldDescriptorImpl extends HistoryFieldDescriptor {
  _HistoryFieldDescriptorImpl({
    required String key,
    required String label,
    required _i2.PythonFieldType type,
  }) : super._(
         key: key,
         label: label,
         type: type,
       );

  @_i1.useResult
  @override
  HistoryFieldDescriptor copyWith({
    String? key,
    String? label,
    _i2.PythonFieldType? type,
  }) {
    return HistoryFieldDescriptor(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
    );
  }
}
