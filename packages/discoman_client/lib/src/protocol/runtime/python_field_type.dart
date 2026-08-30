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

enum PythonFieldType implements _i1.SerializableModel {
  text,
  integer,
  decimal,
  boolean,
  list,
  table,
  category,
  image,
  file
  ;

  static PythonFieldType fromJson(String name) {
    switch (name) {
      case 'text':
        return PythonFieldType.text;
      case 'integer':
        return PythonFieldType.integer;
      case 'decimal':
        return PythonFieldType.decimal;
      case 'boolean':
        return PythonFieldType.boolean;
      case 'list':
        return PythonFieldType.list;
      case 'table':
        return PythonFieldType.table;
      case 'category':
        return PythonFieldType.category;
      case 'image':
        return PythonFieldType.image;
      case 'file':
        return PythonFieldType.file;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "PythonFieldType"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
