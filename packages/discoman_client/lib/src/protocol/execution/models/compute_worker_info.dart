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
import 'package:discoman_client/src/protocol/protocol.dart' as _iy9hkqa4;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../../execution/models/compute_mode.dart' as _ij2201jp;

/// Client-safe view of a worker for the dashboard and the creator's
/// self-hosting UI.
abstract class ComputeWorkerInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
  });

  factory ComputeWorkerInfo({
    required _isc.UuidValue workerId,
    required _ij2201jp.ComputeMode mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    required bool online,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    _isc.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
  }) = _ComputeWorkerInfoImpl;

  factory ComputeWorkerInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeWorkerInfo(
      workerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['workerId'],
      ),
      mode: _ij2201jp.ComputeMode.fromJson(
        (jsonSerialization['mode'] as String),
      ),
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String?,
      hostname: jsonSerialization['hostname'] as String?,
      version: jsonSerialization['version'] as String?,
      online: _isc.BoolJsonExtension.fromJson(jsonSerialization['online']),
      startedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      lastSeenAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeenAt'],
      ),
      currentExecutionId: jsonSerialization['currentExecutionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentExecutionId'],
            ),
      servedProjectIds: jsonSerialization['servedProjectIds'] == null
          ? null
          : _iy9hkqa4.Protocol().deserialize<List<String>>(
              jsonSerialization['servedProjectIds'],
            ),
    );
  }

  _isc.UuidValue workerId;

  _ij2201jp.ComputeMode mode;

  String? creatorFirebaseUid;

  String? hostname;

  String? version;

  bool online;

  DateTime startedAt;

  DateTime lastSeenAt;

  _isc.UuidValue? currentExecutionId;

  /// Which of the creator's projects this machine is standing behind. Null
  /// where the machine has not said yet.
  List<String>? servedProjectIds;

  /// Returns a shallow copy of this [ComputeWorkerInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ComputeWorkerInfo copyWith({
    _isc.UuidValue? workerId,
    _ij2201jp.ComputeMode? mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    bool? online,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    _isc.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
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
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
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
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ComputeWorkerInfoImpl extends ComputeWorkerInfo {
  _ComputeWorkerInfoImpl({
    required _isc.UuidValue workerId,
    required _ij2201jp.ComputeMode mode,
    String? creatorFirebaseUid,
    String? hostname,
    String? version,
    required bool online,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    _isc.UuidValue? currentExecutionId,
    List<String>? servedProjectIds,
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
       );

  /// Returns a shallow copy of this [ComputeWorkerInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ComputeWorkerInfo copyWith({
    _isc.UuidValue? workerId,
    _ij2201jp.ComputeMode? mode,
    Object? creatorFirebaseUid = _Undefined,
    Object? hostname = _Undefined,
    Object? version = _Undefined,
    bool? online,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    Object? currentExecutionId = _Undefined,
    Object? servedProjectIds = _Undefined,
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
      currentExecutionId: currentExecutionId is _isc.UuidValue?
          ? currentExecutionId
          : this.currentExecutionId,
      servedProjectIds: servedProjectIds is List<String>?
          ? servedProjectIds
          : this.servedProjectIds?.map((e0) => e0).toList(),
    );
  }
}
