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
import '../../execution/models/execution_kind.dart' as _i2;
import '../../execution/models/compute_mode.dart' as _i3;

/// Everything a worker needs to run a claimed execution. The source comes
/// from the row snapshot — workers never receive storage credentials.
abstract class ClaimedExecution implements _i1.SerializableModel {
  ClaimedExecution._({
    required this.executionId,
    required this.kind,
    required this.computeMode,
    required this.projectId,
    this.source,
    required this.entrypointName,
    required this.inputsJson,
    required this.timeoutSeconds,
    required this.attempt,
    this.historyRunId,
  });

  factory ClaimedExecution({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ComputeMode computeMode,
    required String projectId,
    String? source,
    required String entrypointName,
    required String inputsJson,
    required int timeoutSeconds,
    required int attempt,
    String? historyRunId,
  }) = _ClaimedExecutionImpl;

  factory ClaimedExecution.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClaimedExecution(
      executionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['executionId'],
      ),
      kind: _i2.ExecutionKind.fromJson((jsonSerialization['kind'] as String)),
      computeMode: _i3.ComputeMode.fromJson(
        (jsonSerialization['computeMode'] as String),
      ),
      projectId: jsonSerialization['projectId'] as String,
      source: jsonSerialization['source'] as String?,
      entrypointName: jsonSerialization['entrypointName'] as String,
      inputsJson: jsonSerialization['inputsJson'] as String,
      timeoutSeconds: jsonSerialization['timeoutSeconds'] as int,
      attempt: jsonSerialization['attempt'] as int,
      historyRunId: jsonSerialization['historyRunId'] as String?,
    );
  }

  _i1.UuidValue executionId;

  _i2.ExecutionKind kind;

  _i3.ComputeMode computeMode;

  /// The project this run belongs to. A self-hosted worker uses it to find the
  /// script on its own disk when [source] is null.
  String projectId;

  /// The script text to run, or null when the project's script lives on the
  /// creator's machine and was therefore never uploaded to us.
  String? source;

  String entrypointName;

  String inputsJson;

  int timeoutSeconds;

  int attempt;

  /// Present for published-app runs: the pre-allocated Firestore history doc
  /// id whose path output assets are uploaded under.
  String? historyRunId;

  /// Returns a shallow copy of this [ClaimedExecution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClaimedExecution copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ComputeMode? computeMode,
    String? projectId,
    String? source,
    String? entrypointName,
    String? inputsJson,
    int? timeoutSeconds,
    int? attempt,
    String? historyRunId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClaimedExecution',
      'executionId': executionId.toJson(),
      'kind': kind.toJson(),
      'computeMode': computeMode.toJson(),
      'projectId': projectId,
      if (source != null) 'source': source,
      'entrypointName': entrypointName,
      'inputsJson': inputsJson,
      'timeoutSeconds': timeoutSeconds,
      'attempt': attempt,
      if (historyRunId != null) 'historyRunId': historyRunId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ClaimedExecutionImpl extends ClaimedExecution {
  _ClaimedExecutionImpl({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ComputeMode computeMode,
    required String projectId,
    String? source,
    required String entrypointName,
    required String inputsJson,
    required int timeoutSeconds,
    required int attempt,
    String? historyRunId,
  }) : super._(
         executionId: executionId,
         kind: kind,
         computeMode: computeMode,
         projectId: projectId,
         source: source,
         entrypointName: entrypointName,
         inputsJson: inputsJson,
         timeoutSeconds: timeoutSeconds,
         attempt: attempt,
         historyRunId: historyRunId,
       );

  /// Returns a shallow copy of this [ClaimedExecution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClaimedExecution copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ComputeMode? computeMode,
    String? projectId,
    Object? source = _Undefined,
    String? entrypointName,
    String? inputsJson,
    int? timeoutSeconds,
    int? attempt,
    Object? historyRunId = _Undefined,
  }) {
    return ClaimedExecution(
      executionId: executionId ?? this.executionId,
      kind: kind ?? this.kind,
      computeMode: computeMode ?? this.computeMode,
      projectId: projectId ?? this.projectId,
      source: source is String? ? source : this.source,
      entrypointName: entrypointName ?? this.entrypointName,
      inputsJson: inputsJson ?? this.inputsJson,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      attempt: attempt ?? this.attempt,
      historyRunId: historyRunId is String? ? historyRunId : this.historyRunId,
    );
  }
}
