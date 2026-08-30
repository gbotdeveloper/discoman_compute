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

abstract class CreatorUsageRollup implements _i1.SerializableModel {
  CreatorUsageRollup._({
    this.id,
    required this.creatorFirebaseUid,
    required this.periodYearMonth,
    required this.executionCount,
    required this.publishedAppExecutionCount,
    required this.previewExecutionCount,
    required this.cloudExecutionCount,
    required this.selfHostedExecutionCount,
    required this.cloudComputeMs,
    required this.failedCount,
    required this.platformFailedCount,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CreatorUsageRollup({
    _i1.UuidValue? id,
    required String creatorFirebaseUid,
    required String periodYearMonth,
    required int executionCount,
    required int publishedAppExecutionCount,
    required int previewExecutionCount,
    required int cloudExecutionCount,
    required int selfHostedExecutionCount,
    required int cloudComputeMs,
    required int failedCount,
    required int platformFailedCount,
    DateTime? updatedAt,
  }) = _CreatorUsageRollupImpl;

  factory CreatorUsageRollup.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreatorUsageRollup(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String,
      periodYearMonth: jsonSerialization['periodYearMonth'] as String,
      executionCount: jsonSerialization['executionCount'] as int,
      publishedAppExecutionCount:
          jsonSerialization['publishedAppExecutionCount'] as int,
      previewExecutionCount: jsonSerialization['previewExecutionCount'] as int,
      cloudExecutionCount: jsonSerialization['cloudExecutionCount'] as int,
      selfHostedExecutionCount:
          jsonSerialization['selfHostedExecutionCount'] as int,
      cloudComputeMs: jsonSerialization['cloudComputeMs'] as int,
      failedCount: jsonSerialization['failedCount'] as int,
      platformFailedCount: jsonSerialization['platformFailedCount'] as int,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  _i1.UuidValue? id;

  String creatorFirebaseUid;

  String periodYearMonth;

  int executionCount;

  int publishedAppExecutionCount;

  int previewExecutionCount;

  int cloudExecutionCount;

  int selfHostedExecutionCount;

  int cloudComputeMs;

  int failedCount;

  int platformFailedCount;

  DateTime updatedAt;

  @_i1.useResult
  CreatorUsageRollup copyWith({
    _i1.UuidValue? id,
    String? creatorFirebaseUid,
    String? periodYearMonth,
    int? executionCount,
    int? publishedAppExecutionCount,
    int? previewExecutionCount,
    int? cloudExecutionCount,
    int? selfHostedExecutionCount,
    int? cloudComputeMs,
    int? failedCount,
    int? platformFailedCount,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatorUsageRollup',
      if (id != null) 'id': id?.toJson(),
      'creatorFirebaseUid': creatorFirebaseUid,
      'periodYearMonth': periodYearMonth,
      'executionCount': executionCount,
      'publishedAppExecutionCount': publishedAppExecutionCount,
      'previewExecutionCount': previewExecutionCount,
      'cloudExecutionCount': cloudExecutionCount,
      'selfHostedExecutionCount': selfHostedExecutionCount,
      'cloudComputeMs': cloudComputeMs,
      'failedCount': failedCount,
      'platformFailedCount': platformFailedCount,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatorUsageRollupImpl extends CreatorUsageRollup {
  _CreatorUsageRollupImpl({
    _i1.UuidValue? id,
    required String creatorFirebaseUid,
    required String periodYearMonth,
    required int executionCount,
    required int publishedAppExecutionCount,
    required int previewExecutionCount,
    required int cloudExecutionCount,
    required int selfHostedExecutionCount,
    required int cloudComputeMs,
    required int failedCount,
    required int platformFailedCount,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         creatorFirebaseUid: creatorFirebaseUid,
         periodYearMonth: periodYearMonth,
         executionCount: executionCount,
         publishedAppExecutionCount: publishedAppExecutionCount,
         previewExecutionCount: previewExecutionCount,
         cloudExecutionCount: cloudExecutionCount,
         selfHostedExecutionCount: selfHostedExecutionCount,
         cloudComputeMs: cloudComputeMs,
         failedCount: failedCount,
         platformFailedCount: platformFailedCount,
         updatedAt: updatedAt,
       );

  @_i1.useResult
  @override
  CreatorUsageRollup copyWith({
    Object? id = _Undefined,
    String? creatorFirebaseUid,
    String? periodYearMonth,
    int? executionCount,
    int? publishedAppExecutionCount,
    int? previewExecutionCount,
    int? cloudExecutionCount,
    int? selfHostedExecutionCount,
    int? cloudComputeMs,
    int? failedCount,
    int? platformFailedCount,
    DateTime? updatedAt,
  }) {
    return CreatorUsageRollup(
      id: id is _i1.UuidValue? ? id : this.id,
      creatorFirebaseUid: creatorFirebaseUid ?? this.creatorFirebaseUid,
      periodYearMonth: periodYearMonth ?? this.periodYearMonth,
      executionCount: executionCount ?? this.executionCount,
      publishedAppExecutionCount:
          publishedAppExecutionCount ?? this.publishedAppExecutionCount,
      previewExecutionCount:
          previewExecutionCount ?? this.previewExecutionCount,
      cloudExecutionCount: cloudExecutionCount ?? this.cloudExecutionCount,
      selfHostedExecutionCount:
          selfHostedExecutionCount ?? this.selfHostedExecutionCount,
      cloudComputeMs: cloudComputeMs ?? this.cloudComputeMs,
      failedCount: failedCount ?? this.failedCount,
      platformFailedCount: platformFailedCount ?? this.platformFailedCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
