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

enum ExecutionStatus implements _i1.SerializableModel {
  queued,
  running,
  succeeded,
  failed,
  canceled
  ;

  static ExecutionStatus fromJson(String name) {
    switch (name) {
      case 'queued':
        return ExecutionStatus.queued;
      case 'running':
        return ExecutionStatus.running;
      case 'succeeded':
        return ExecutionStatus.succeeded;
      case 'failed':
        return ExecutionStatus.failed;
      case 'canceled':
        return ExecutionStatus.canceled;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ExecutionStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
