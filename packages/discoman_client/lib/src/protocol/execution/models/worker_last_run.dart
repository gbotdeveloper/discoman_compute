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
import '../../execution/models/execution_status.dart' as _i3;

/// The last run a worker finished, shown on its dashboard card.
abstract class WorkerLastRun implements _i1.SerializableModel {
  WorkerLastRun._({
    required this.executionId,
    required this.kind,
    required this.status,
    required this.projectId,
    this.appTitle,
    this.finishedAt,
    this.errorReason,
    this.errorMessage,
  });

  factory WorkerLastRun({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ExecutionStatus status,
    required String projectId,
    String? appTitle,
    DateTime? finishedAt,
    String? errorReason,
    String? errorMessage,
  }) = _WorkerLastRunImpl;

  factory WorkerLastRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkerLastRun(
      executionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['executionId'],
      ),
      kind: _i2.ExecutionKind.fromJson((jsonSerialization['kind'] as String)),
      status: _i3.ExecutionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      projectId: jsonSerialization['projectId'] as String,
      appTitle: jsonSerialization['appTitle'] as String?,
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      errorReason: jsonSerialization['errorReason'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  _i1.UuidValue executionId;

  _i2.ExecutionKind kind;

  _i3.ExecutionStatus status;

  String projectId;

  String? appTitle;

  DateTime? finishedAt;

  String? errorReason;

  String? errorMessage;

  /// Returns a shallow copy of this [WorkerLastRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WorkerLastRun copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ExecutionStatus? status,
    String? projectId,
    String? appTitle,
    DateTime? finishedAt,
    String? errorReason,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkerLastRun',
      'executionId': executionId.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      'projectId': projectId,
      if (appTitle != null) 'appTitle': appTitle,
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      if (errorReason != null) 'errorReason': errorReason,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkerLastRunImpl extends WorkerLastRun {
  _WorkerLastRunImpl({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ExecutionStatus status,
    required String projectId,
    String? appTitle,
    DateTime? finishedAt,
    String? errorReason,
    String? errorMessage,
  }) : super._(
         executionId: executionId,
         kind: kind,
         status: status,
         projectId: projectId,
         appTitle: appTitle,
         finishedAt: finishedAt,
         errorReason: errorReason,
         errorMessage: errorMessage,
       );

  /// Returns a shallow copy of this [WorkerLastRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WorkerLastRun copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ExecutionStatus? status,
    String? projectId,
    Object? appTitle = _Undefined,
    Object? finishedAt = _Undefined,
    Object? errorReason = _Undefined,
    Object? errorMessage = _Undefined,
  }) {
    return WorkerLastRun(
      executionId: executionId ?? this.executionId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      appTitle: appTitle is String? ? appTitle : this.appTitle,
      finishedAt: finishedAt is DateTime? ? finishedAt : this.finishedAt,
      errorReason: errorReason is String? ? errorReason : this.errorReason,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}
