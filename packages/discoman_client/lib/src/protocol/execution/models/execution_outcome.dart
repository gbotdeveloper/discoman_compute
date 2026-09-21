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
import 'package:discoman_client/src/protocol/protocol.dart' as _i2;

/// Final result a worker reports for a claimed execution. For asset outputs
/// the values in [outputsJson] must already be storage references produced by
/// uploadExecutionAsset.
abstract class ExecutionOutcome implements _i1.SerializableModel {
  ExecutionOutcome._({
    required this.success,
    this.outputsJson,
    this.durationMs,
    this.errorReason,
    this.errorMessage,
    required this.warnings,
    required this.logs,
  });

  factory ExecutionOutcome({
    required bool success,
    String? outputsJson,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
    required List<String> warnings,
    required List<String> logs,
  }) = _ExecutionOutcomeImpl;

  factory ExecutionOutcome.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionOutcome(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      outputsJson: jsonSerialization['outputsJson'] as String?,
      durationMs: jsonSerialization['durationMs'] as int?,
      errorReason: jsonSerialization['errorReason'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      warnings: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
      logs: _i2.Protocol().deserialize<List<String>>(jsonSerialization['logs']),
    );
  }

  bool success;

  String? outputsJson;

  /// Pure Python wall time measured by the runner.
  int? durationMs;

  String? errorReason;

  String? errorMessage;

  List<String> warnings;

  List<String> logs;

  /// Returns a shallow copy of this [ExecutionOutcome]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ExecutionOutcome copyWith({
    bool? success,
    String? outputsJson,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
    List<String>? warnings,
    List<String>? logs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionOutcome',
      'success': success,
      if (outputsJson != null) 'outputsJson': outputsJson,
      if (durationMs != null) 'durationMs': durationMs,
      if (errorReason != null) 'errorReason': errorReason,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'warnings': warnings.toJson(),
      'logs': logs.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExecutionOutcomeImpl extends ExecutionOutcome {
  _ExecutionOutcomeImpl({
    required bool success,
    String? outputsJson,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
    required List<String> warnings,
    required List<String> logs,
  }) : super._(
         success: success,
         outputsJson: outputsJson,
         durationMs: durationMs,
         errorReason: errorReason,
         errorMessage: errorMessage,
         warnings: warnings,
         logs: logs,
       );

  /// Returns a shallow copy of this [ExecutionOutcome]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ExecutionOutcome copyWith({
    bool? success,
    Object? outputsJson = _Undefined,
    Object? durationMs = _Undefined,
    Object? errorReason = _Undefined,
    Object? errorMessage = _Undefined,
    List<String>? warnings,
    List<String>? logs,
  }) {
    return ExecutionOutcome(
      success: success ?? this.success,
      outputsJson: outputsJson is String? ? outputsJson : this.outputsJson,
      durationMs: durationMs is int? ? durationMs : this.durationMs,
      errorReason: errorReason is String? ? errorReason : this.errorReason,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
      logs: logs ?? this.logs.map((e0) => e0).toList(),
    );
  }
}
