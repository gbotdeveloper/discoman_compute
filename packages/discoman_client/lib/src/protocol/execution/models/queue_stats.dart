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

abstract class QueueStats implements _i1.SerializableModel {
  QueueStats._({
    required this.queuedCloud,
    required this.runningCloud,
    required this.queuedSelfHosted,
    required this.runningSelfHosted,
    required this.succeededLastHour,
    required this.failedLastHour,
    this.oldestQueuedAt,
    this.lastSweepAt,
    required this.cloudConcurrencyLimit,
    required this.onlineWorkerCount,
  });

  factory QueueStats({
    required int queuedCloud,
    required int runningCloud,
    required int queuedSelfHosted,
    required int runningSelfHosted,
    required int succeededLastHour,
    required int failedLastHour,
    DateTime? oldestQueuedAt,
    DateTime? lastSweepAt,
    required int cloudConcurrencyLimit,
    required int onlineWorkerCount,
  }) = _QueueStatsImpl;

  factory QueueStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return QueueStats(
      queuedCloud: jsonSerialization['queuedCloud'] as int,
      runningCloud: jsonSerialization['runningCloud'] as int,
      queuedSelfHosted: jsonSerialization['queuedSelfHosted'] as int,
      runningSelfHosted: jsonSerialization['runningSelfHosted'] as int,
      succeededLastHour: jsonSerialization['succeededLastHour'] as int,
      failedLastHour: jsonSerialization['failedLastHour'] as int,
      oldestQueuedAt: jsonSerialization['oldestQueuedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['oldestQueuedAt'],
            ),
      lastSweepAt: jsonSerialization['lastSweepAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSweepAt'],
            ),
      cloudConcurrencyLimit: jsonSerialization['cloudConcurrencyLimit'] as int,
      onlineWorkerCount: jsonSerialization['onlineWorkerCount'] as int,
    );
  }

  int queuedCloud;

  int runningCloud;

  int queuedSelfHosted;

  int runningSelfHosted;

  int succeededLastHour;

  int failedLastHour;

  DateTime? oldestQueuedAt;

  DateTime? lastSweepAt;

  int cloudConcurrencyLimit;

  int onlineWorkerCount;

  @_i1.useResult
  QueueStats copyWith({
    int? queuedCloud,
    int? runningCloud,
    int? queuedSelfHosted,
    int? runningSelfHosted,
    int? succeededLastHour,
    int? failedLastHour,
    DateTime? oldestQueuedAt,
    DateTime? lastSweepAt,
    int? cloudConcurrencyLimit,
    int? onlineWorkerCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QueueStats',
      'queuedCloud': queuedCloud,
      'runningCloud': runningCloud,
      'queuedSelfHosted': queuedSelfHosted,
      'runningSelfHosted': runningSelfHosted,
      'succeededLastHour': succeededLastHour,
      'failedLastHour': failedLastHour,
      if (oldestQueuedAt != null) 'oldestQueuedAt': oldestQueuedAt?.toJson(),
      if (lastSweepAt != null) 'lastSweepAt': lastSweepAt?.toJson(),
      'cloudConcurrencyLimit': cloudConcurrencyLimit,
      'onlineWorkerCount': onlineWorkerCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QueueStatsImpl extends QueueStats {
  _QueueStatsImpl({
    required int queuedCloud,
    required int runningCloud,
    required int queuedSelfHosted,
    required int runningSelfHosted,
    required int succeededLastHour,
    required int failedLastHour,
    DateTime? oldestQueuedAt,
    DateTime? lastSweepAt,
    required int cloudConcurrencyLimit,
    required int onlineWorkerCount,
  }) : super._(
         queuedCloud: queuedCloud,
         runningCloud: runningCloud,
         queuedSelfHosted: queuedSelfHosted,
         runningSelfHosted: runningSelfHosted,
         succeededLastHour: succeededLastHour,
         failedLastHour: failedLastHour,
         oldestQueuedAt: oldestQueuedAt,
         lastSweepAt: lastSweepAt,
         cloudConcurrencyLimit: cloudConcurrencyLimit,
         onlineWorkerCount: onlineWorkerCount,
       );

  @_i1.useResult
  @override
  QueueStats copyWith({
    int? queuedCloud,
    int? runningCloud,
    int? queuedSelfHosted,
    int? runningSelfHosted,
    int? succeededLastHour,
    int? failedLastHour,
    Object? oldestQueuedAt = _Undefined,
    Object? lastSweepAt = _Undefined,
    int? cloudConcurrencyLimit,
    int? onlineWorkerCount,
  }) {
    return QueueStats(
      queuedCloud: queuedCloud ?? this.queuedCloud,
      runningCloud: runningCloud ?? this.runningCloud,
      queuedSelfHosted: queuedSelfHosted ?? this.queuedSelfHosted,
      runningSelfHosted: runningSelfHosted ?? this.runningSelfHosted,
      succeededLastHour: succeededLastHour ?? this.succeededLastHour,
      failedLastHour: failedLastHour ?? this.failedLastHour,
      oldestQueuedAt: oldestQueuedAt is DateTime?
          ? oldestQueuedAt
          : this.oldestQueuedAt,
      lastSweepAt: lastSweepAt is DateTime? ? lastSweepAt : this.lastSweepAt,
      cloudConcurrencyLimit:
          cloudConcurrencyLimit ?? this.cloudConcurrencyLimit,
      onlineWorkerCount: onlineWorkerCount ?? this.onlineWorkerCount,
    );
  }
}
