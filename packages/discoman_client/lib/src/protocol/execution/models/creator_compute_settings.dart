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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../execution/models/compute_mode.dart' as _ij2201jp;

/// Per-creator execution routing. Lives in Postgres (not the publicly-gettable
/// Firestore publish config) so it is server-trusted, flips without
/// re-publishing, and is read atomically with the execution insert.
abstract class CreatorComputeSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreatorComputeSettings._({
    this.id,
    required this.creatorFirebaseUid,
    required this.computeMode,
    required this.selfHostedTimeoutSeconds,
    required this.selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CreatorComputeSettings({
    _isc.UuidValue? id,
    required String creatorFirebaseUid,
    required _ij2201jp.ComputeMode computeMode,
    required int selfHostedTimeoutSeconds,
    required int selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) = _CreatorComputeSettingsImpl;

  factory CreatorComputeSettings.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CreatorComputeSettings(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String,
      computeMode: _ij2201jp.ComputeMode.fromJson(
        (jsonSerialization['computeMode'] as String),
      ),
      selfHostedTimeoutSeconds:
          jsonSerialization['selfHostedTimeoutSeconds'] as int,
      selfHostedQueueDeadlineHours:
          jsonSerialization['selfHostedQueueDeadlineHours'] as int,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String creatorFirebaseUid;

  _ij2201jp.ComputeMode computeMode;

  /// Hard wall-clock limit for a self-hosted run.
  int selfHostedTimeoutSeconds;

  /// How long a queued run waits for the creator's machine to come online
  /// before failing with computeOffline. Distinct from the run timeout.
  int selfHostedQueueDeadlineHours;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CreatorComputeSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreatorComputeSettings copyWith({
    _isc.UuidValue? id,
    String? creatorFirebaseUid,
    _ij2201jp.ComputeMode? computeMode,
    int? selfHostedTimeoutSeconds,
    int? selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatorComputeSettings',
      if (id != null) 'id': id?.toJson(),
      'creatorFirebaseUid': creatorFirebaseUid,
      'computeMode': computeMode.toJson(),
      'selfHostedTimeoutSeconds': selfHostedTimeoutSeconds,
      'selfHostedQueueDeadlineHours': selfHostedQueueDeadlineHours,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreatorComputeSettings',
      if (id != null) 'id': id?.toJson(),
      'creatorFirebaseUid': creatorFirebaseUid,
      'computeMode': computeMode.toJson(),
      'selfHostedTimeoutSeconds': selfHostedTimeoutSeconds,
      'selfHostedQueueDeadlineHours': selfHostedQueueDeadlineHours,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatorComputeSettingsImpl extends CreatorComputeSettings {
  _CreatorComputeSettingsImpl({
    _isc.UuidValue? id,
    required String creatorFirebaseUid,
    required _ij2201jp.ComputeMode computeMode,
    required int selfHostedTimeoutSeconds,
    required int selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         creatorFirebaseUid: creatorFirebaseUid,
         computeMode: computeMode,
         selfHostedTimeoutSeconds: selfHostedTimeoutSeconds,
         selfHostedQueueDeadlineHours: selfHostedQueueDeadlineHours,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CreatorComputeSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreatorComputeSettings copyWith({
    Object? id = _Undefined,
    String? creatorFirebaseUid,
    _ij2201jp.ComputeMode? computeMode,
    int? selfHostedTimeoutSeconds,
    int? selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) {
    return CreatorComputeSettings(
      id: id is _isc.UuidValue? ? id : this.id,
      creatorFirebaseUid: creatorFirebaseUid ?? this.creatorFirebaseUid,
      computeMode: computeMode ?? this.computeMode,
      selfHostedTimeoutSeconds:
          selfHostedTimeoutSeconds ?? this.selfHostedTimeoutSeconds,
      selfHostedQueueDeadlineHours:
          selfHostedQueueDeadlineHours ?? this.selfHostedQueueDeadlineHours,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
