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

/// Returned by computeWorker.register: the worker's id plus the cadence the
/// server expects (heartbeat interval and lease length are server-owned so
/// they can be tuned without shipping new workers).
abstract class WorkerRegistration implements _i1.SerializableModel {
  WorkerRegistration._({
    required this.workerId,
    required this.heartbeatIntervalSeconds,
    required this.leaseSeconds,
  });

  factory WorkerRegistration({
    required _i1.UuidValue workerId,
    required int heartbeatIntervalSeconds,
    required int leaseSeconds,
  }) = _WorkerRegistrationImpl;

  factory WorkerRegistration.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkerRegistration(
      workerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['workerId'],
      ),
      heartbeatIntervalSeconds:
          jsonSerialization['heartbeatIntervalSeconds'] as int,
      leaseSeconds: jsonSerialization['leaseSeconds'] as int,
    );
  }

  _i1.UuidValue workerId;

  int heartbeatIntervalSeconds;

  int leaseSeconds;

  /// Returns a shallow copy of this [WorkerRegistration]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WorkerRegistration copyWith({
    _i1.UuidValue? workerId,
    int? heartbeatIntervalSeconds,
    int? leaseSeconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkerRegistration',
      'workerId': workerId.toJson(),
      'heartbeatIntervalSeconds': heartbeatIntervalSeconds,
      'leaseSeconds': leaseSeconds,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _WorkerRegistrationImpl extends WorkerRegistration {
  _WorkerRegistrationImpl({
    required _i1.UuidValue workerId,
    required int heartbeatIntervalSeconds,
    required int leaseSeconds,
  }) : super._(
         workerId: workerId,
         heartbeatIntervalSeconds: heartbeatIntervalSeconds,
         leaseSeconds: leaseSeconds,
       );

  /// Returns a shallow copy of this [WorkerRegistration]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WorkerRegistration copyWith({
    _i1.UuidValue? workerId,
    int? heartbeatIntervalSeconds,
    int? leaseSeconds,
  }) {
    return WorkerRegistration(
      workerId: workerId ?? this.workerId,
      heartbeatIntervalSeconds:
          heartbeatIntervalSeconds ?? this.heartbeatIntervalSeconds,
      leaseSeconds: leaseSeconds ?? this.leaseSeconds,
    );
  }
}
