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

abstract class CreatorComputeSettings implements _i1.SerializableModel {
  CreatorComputeSettings._({
    this.id,
    required this.creatorFirebaseUid,
    required this.computeMode,
    required this.selfHostedTimeoutSeconds,
    required this.selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CreatorComputeSettings({
    _i1.UuidValue? id,
    required String creatorFirebaseUid,
    required _i2.ComputeMode computeMode,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String,
      computeMode: _i2.ComputeMode.fromJson(
        (jsonSerialization['computeMode'] as String),
      ),
      selfHostedTimeoutSeconds:
          jsonSerialization['selfHostedTimeoutSeconds'] as int,
      selfHostedQueueDeadlineHours:
          jsonSerialization['selfHostedQueueDeadlineHours'] as int,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  _i1.UuidValue? id;

  String creatorFirebaseUid;

  _i2.ComputeMode computeMode;

  int selfHostedTimeoutSeconds;

  int selfHostedQueueDeadlineHours;

  DateTime updatedAt;

  @_i1.useResult
  CreatorComputeSettings copyWith({
    _i1.UuidValue? id,
    String? creatorFirebaseUid,
    _i2.ComputeMode? computeMode,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatorComputeSettingsImpl extends CreatorComputeSettings {
  _CreatorComputeSettingsImpl({
    _i1.UuidValue? id,
    required String creatorFirebaseUid,
    required _i2.ComputeMode computeMode,
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

  @_i1.useResult
  @override
  CreatorComputeSettings copyWith({
    Object? id = _Undefined,
    String? creatorFirebaseUid,
    _i2.ComputeMode? computeMode,
    int? selfHostedTimeoutSeconds,
    int? selfHostedQueueDeadlineHours,
    DateTime? updatedAt,
  }) {
    return CreatorComputeSettings(
      id: id is _i1.UuidValue? ? id : this.id,
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
