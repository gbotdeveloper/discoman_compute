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

/// Raised when running or inspecting a user Python script fails in a way the
/// client should be able to display (validation errors, disallowed imports,
/// executor errors, timeouts). The message is safe to show to the user.
abstract class ScriptRunException
    implements _i1.SerializableException, _i1.SerializableModel {
  ScriptRunException._({
    required this.message,
    required this.reason,
  });

  factory ScriptRunException({
    required String message,
    required String reason,
  }) = _ScriptRunExceptionImpl;

  factory ScriptRunException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScriptRunException(
      message: jsonSerialization['message'] as String,
      reason: jsonSerialization['reason'] as String,
    );
  }

  /// Human-readable error message safe to surface to the client.
  String message;

  /// Machine-readable failure category (e.g. "disallowedImport", "timeout",
  /// "executorError", "invalidScriptPath", "extractionFailed").
  String reason;

  /// Returns a shallow copy of this [ScriptRunException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ScriptRunException copyWith({
    String? message,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScriptRunException',
      'message': message,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'ScriptRunException(message: $message, reason: $reason)';
  }
}

class _ScriptRunExceptionImpl extends ScriptRunException {
  _ScriptRunExceptionImpl({
    required String message,
    required String reason,
  }) : super._(
         message: message,
         reason: reason,
       );

  /// Returns a shallow copy of this [ScriptRunException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ScriptRunException copyWith({
    String? message,
    String? reason,
  }) {
    return ScriptRunException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
    );
  }
}
