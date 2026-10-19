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
import '../../execution/models/compute_mode.dart' as _i2;
import '../../execution/models/worker_last_run.dart' as _i3;
import 'package:discoman_client/src/protocol/protocol.dart' as _i4;

/// Client-safe view of a worker for the dashboard and the creator's
/// self-hosting UI.
abstract class ComputeWorkerInfo implements _i1.SerializableModel {
  ComputeWorkerInfo._({
    required this.workerId,
    required this.mode,
    this.creatorFirebaseUid,
    this.hostname,
    this.version,
    required this.online,
    required this.startedAt,
    required this.lastSeenAt,
    this.currentExecutionId,
    this.servedProjectIds,
    this.servedProjectNames,
    this.lastRun,
  });

  factory ComputeWorkerInfo({
    required _i1.UuidValue workerId,
    required _i2.ComputeMode mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    required bool online,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    _i1.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
    Map<String, String>? servedProjectNames,
    _i3.WorkerLastRun? lastRun,
  }) = _ComputeWorkerInfoImpl;

  factory ComputeWorkerInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeWorkerInfo(
      workerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['workerId'],
      ),
      mode: _i2.ComputeMode.fromJson((jsonSerialization['mode'] as String)),
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String?,
      hostname: jsonSerialization['hostname'] as String?,
      version: jsonSerialization['version'] as String?,
      online: _i1.BoolJsonExtension.fromJson(jsonSerialization['online']),
      startedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      lastSeenAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeenAt'],
      ),
      currentExecutionId: jsonSerialization['currentExecutionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentExecutionId'],
            ),
      servedProjectIds: jsonSerialization['servedProjectIds'] == null
          ? null
          : _i4.Protocol().deserialize<List<String>>(
              jsonSerialization['servedProjectIds'],
            ),
      servedProjectNames: jsonSerialization['servedProjectNames'] == null
          ? null
          : _i4.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['servedProjectNames'],
            ),
      lastRun: jsonSerialization['lastRun'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.WorkerLastRun>(
              jsonSerialization['lastRun'],
            ),
    );
  }

  _i1.UuidValue workerId;

  _i2.ComputeMode mode;

  String? creatorFirebaseUid;

  String? hostname;

  String? version;

  bool online;

  DateTime startedAt;

  DateTime lastSeenAt;

  _i1.UuidValue? currentExecutionId;

  /// Which of the creator's projects this machine is standing behind. Null
  /// where the machine has not said yet.
  List<String>? servedProjectIds;

  /// Names of the projects in [servedProjectIds], where they could be looked
  /// up.
  Map<String, String>? servedProjectNames;

  /// The last run this machine finished. Null when it has finished none.
  _i3.WorkerLastRun? lastRun;

  /// Returns a shallow copy of this [ComputeWorkerInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ComputeWorkerInfo copyWith({
    _i1.UuidValue? workerId,
    _i2.ComputeMode? mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    bool? online,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    _i1.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
    Map<String, String>? servedProjectNames,
    _i3.WorkerLastRun? lastRun,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeWorkerInfo',
      'workerId': workerId.toJson(),
      'mode': mode.toJson(),
      if (creatorFirebaseUid != null) 'creatorFirebaseUid': creatorFirebaseUid,
      if (hostname != null) 'hostname': hostname,
      if (version != null) 'version': version,
      'online': online,
      'startedAt': startedAt.toJson(),
      'lastSeenAt': lastSeenAt.toJson(),
      if (currentExecutionId != null)
        'currentExecutionId': currentExecutionId?.toJson(),
      if (servedProjectIds != null)
        'servedProjectIds': servedProjectIds?.toJson(),
      if (servedProjectNames != null)
        'servedProjectNames': servedProjectNames?.toJson(),
      if (lastRun != null) 'lastRun': lastRun?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ComputeWorkerInfoImpl extends ComputeWorkerInfo {
  _ComputeWorkerInfoImpl({
    required _i1.UuidValue workerId,
    required _i2.ComputeMode mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    required bool online,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    _i1.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
    Map<String, String>? servedProjectNames,
    _i3.WorkerLastRun? lastRun,
  }) : super._(
         workerId: workerId,
         mode: mode,
         creatorFirebaseUid: creatorFirebaseUid,
         hostname: hostname,
         version: version,
         online: online,
         startedAt: startedAt,
         lastSeenAt: lastSeenAt,
         currentExecutionId: currentExecutionId,
         servedProjectIds: servedProjectIds,
         servedProjectNames: servedProjectNames,
         lastRun: lastRun,
       );

  /// Returns a shallow copy of this [ComputeWorkerInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ComputeWorkerInfo copyWith({
    _i1.UuidValue? workerId,
    _i2.ComputeMode? mode,
    Object? creatorFirebaseUid = _Undefined,
    Object? hostname = _Undefined,
    Object? version = _Undefined,
    bool? online,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    Object? currentExecutionId = _Undefined,
    Object? servedProjectIds = _Undefined,
    Object? servedProjectNames = _Undefined,
    Object? lastRun = _Undefined,
  }) {
    return ComputeWorkerInfo(
      workerId: workerId ?? this.workerId,
      mode: mode ?? this.mode,
      creatorFirebaseUid: creatorFirebaseUid is String?
          ? creatorFirebaseUid
          : this.creatorFirebaseUid,
      hostname: hostname is String? ? hostname : this.hostname,
      version: version is String? ? version : this.version,
      online: online ?? this.online,
      startedAt: startedAt ?? this.startedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      currentExecutionId: currentExecutionId is _i1.UuidValue?
          ? currentExecutionId
          : this.currentExecutionId,
      servedProjectIds: servedProjectIds is List<String>?
          ? servedProjectIds
          : this.servedProjectIds?.map((e0) => e0).toList(),
      servedProjectNames: servedProjectNames is Map<String, String>?
          ? servedProjectNames
          : this.servedProjectNames?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      lastRun: lastRun is _i3.WorkerLastRun?
          ? lastRun
          : this.lastRun?.copyWith(),
    );
  }
}
