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
import '../../execution/models/execution_status.dart' as _i4;

abstract class ExecutionStatusView implements _i1.SerializableModel {
  ExecutionStatusView._({
    required this.executionId,
    required this.kind,
    required this.computeMode,
    required this.status,
    required this.projectId,
    this.slug,
    this.appTitle,
    required this.creatorFirebaseUid,
    required this.callerIsAnonymous,
    this.queuePosition,
    this.waitingReason,
    required this.attempt,
    required this.maxAttempts,
    required this.cancelRequested,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.durationMs,
    this.errorReason,
    this.errorMessage,
  });

  factory ExecutionStatusView({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ComputeMode computeMode,
    required _i4.ExecutionStatus status,
    required String projectId,
    String? slug,
    String? appTitle,
    required String creatorFirebaseUid,
    required bool callerIsAnonymous,
    int? queuePosition,
    String? waitingReason,
    required int attempt,
    required int maxAttempts,
    required bool cancelRequested,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
  }) = _ExecutionStatusViewImpl;

  factory ExecutionStatusView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionStatusView(
      executionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['executionId'],
      ),
      kind: _i2.ExecutionKind.fromJson((jsonSerialization['kind'] as String)),
      computeMode: _i3.ComputeMode.fromJson(
        (jsonSerialization['computeMode'] as String),
      ),
      status: _i4.ExecutionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      projectId: jsonSerialization['projectId'] as String,
      slug: jsonSerialization['slug'] as String?,
      appTitle: jsonSerialization['appTitle'] as String?,
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String,
      callerIsAnonymous: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['callerIsAnonymous'],
      ),
      queuePosition: jsonSerialization['queuePosition'] as int?,
      waitingReason: jsonSerialization['waitingReason'] as String?,
      attempt: jsonSerialization['attempt'] as int,
      maxAttempts: jsonSerialization['maxAttempts'] as int,
      cancelRequested: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['cancelRequested'],
      ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      durationMs: jsonSerialization['durationMs'] as int?,
      errorReason: jsonSerialization['errorReason'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  _i1.UuidValue executionId;

  _i2.ExecutionKind kind;

  _i3.ComputeMode computeMode;

  _i4.ExecutionStatus status;

  String projectId;

  String? slug;

  String? appTitle;

  String creatorFirebaseUid;

  bool callerIsAnonymous;

  int? queuePosition;

  String? waitingReason;

  int attempt;

  int maxAttempts;

  bool cancelRequested;

  DateTime createdAt;

  DateTime? startedAt;

  DateTime? finishedAt;

  int? durationMs;

  String? errorReason;

  String? errorMessage;

  @_i1.useResult
  ExecutionStatusView copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ComputeMode? computeMode,
    _i4.ExecutionStatus? status,
    String? projectId,
    String? slug,
    String? appTitle,
    String? creatorFirebaseUid,
    bool? callerIsAnonymous,
    int? queuePosition,
    String? waitingReason,
    int? attempt,
    int? maxAttempts,
    bool? cancelRequested,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionStatusView',
      'executionId': executionId.toJson(),
      'kind': kind.toJson(),
      'computeMode': computeMode.toJson(),
      'status': status.toJson(),
      'projectId': projectId,
      if (slug != null) 'slug': slug,
      if (appTitle != null) 'appTitle': appTitle,
      'creatorFirebaseUid': creatorFirebaseUid,
      'callerIsAnonymous': callerIsAnonymous,
      if (queuePosition != null) 'queuePosition': queuePosition,
      if (waitingReason != null) 'waitingReason': waitingReason,
      'attempt': attempt,
      'maxAttempts': maxAttempts,
      'cancelRequested': cancelRequested,
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      if (durationMs != null) 'durationMs': durationMs,
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

class _ExecutionStatusViewImpl extends ExecutionStatusView {
  _ExecutionStatusViewImpl({
    required _i1.UuidValue executionId,
    required _i2.ExecutionKind kind,
    required _i3.ComputeMode computeMode,
    required _i4.ExecutionStatus status,
    required String projectId,
    String? slug,
    String? appTitle,
    required String creatorFirebaseUid,
    required bool callerIsAnonymous,
    int? queuePosition,
    String? waitingReason,
    required int attempt,
    required int maxAttempts,
    required bool cancelRequested,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? durationMs,
    String? errorReason,
    String? errorMessage,
  }) : super._(
         executionId: executionId,
         kind: kind,
         computeMode: computeMode,
         status: status,
         projectId: projectId,
         slug: slug,
         appTitle: appTitle,
         creatorFirebaseUid: creatorFirebaseUid,
         callerIsAnonymous: callerIsAnonymous,
         queuePosition: queuePosition,
         waitingReason: waitingReason,
         attempt: attempt,
         maxAttempts: maxAttempts,
         cancelRequested: cancelRequested,
         createdAt: createdAt,
         startedAt: startedAt,
         finishedAt: finishedAt,
         durationMs: durationMs,
         errorReason: errorReason,
         errorMessage: errorMessage,
       );

  @_i1.useResult
  @override
  ExecutionStatusView copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionKind? kind,
    _i3.ComputeMode? computeMode,
    _i4.ExecutionStatus? status,
    String? projectId,
    Object? slug = _Undefined,
    Object? appTitle = _Undefined,
    String? creatorFirebaseUid,
    bool? callerIsAnonymous,
    Object? queuePosition = _Undefined,
    Object? waitingReason = _Undefined,
    int? attempt,
    int? maxAttempts,
    bool? cancelRequested,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    Object? finishedAt = _Undefined,
    Object? durationMs = _Undefined,
    Object? errorReason = _Undefined,
    Object? errorMessage = _Undefined,
  }) {
    return ExecutionStatusView(
      executionId: executionId ?? this.executionId,
      kind: kind ?? this.kind,
      computeMode: computeMode ?? this.computeMode,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      slug: slug is String? ? slug : this.slug,
      appTitle: appTitle is String? ? appTitle : this.appTitle,
      creatorFirebaseUid: creatorFirebaseUid ?? this.creatorFirebaseUid,
      callerIsAnonymous: callerIsAnonymous ?? this.callerIsAnonymous,
      queuePosition: queuePosition is int? ? queuePosition : this.queuePosition,
      waitingReason: waitingReason is String?
          ? waitingReason
          : this.waitingReason,
      attempt: attempt ?? this.attempt,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      finishedAt: finishedAt is DateTime? ? finishedAt : this.finishedAt,
      durationMs: durationMs is int? ? durationMs : this.durationMs,
      errorReason: errorReason is String? ? errorReason : this.errorReason,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}
