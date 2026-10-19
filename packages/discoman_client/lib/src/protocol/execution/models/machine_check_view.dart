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
import '../../execution/models/machine_check_status.dart' as _i2;
import '../../execution/models/machine_check_result.dart' as _i3;
import 'package:discoman_client/src/protocol/protocol.dart' as _i4;

/// The latest machine check of a worker, as the dashboard shows it.
abstract class MachineCheckView implements _i1.SerializableModel {
  MachineCheckView._({
    required this.checkId,
    required this.status,
    required this.requestedAt,
    this.finishedAt,
    required this.unanswered,
    this.result,
  });

  factory MachineCheckView({
    required _i1.UuidValue checkId,
    required _i2.MachineCheckStatus status,
    required DateTime requestedAt,
    DateTime? finishedAt,
    required bool unanswered,
    _i3.MachineCheckResult? result,
  }) = _MachineCheckViewImpl;

  factory MachineCheckView.fromJson(Map<String, dynamic> jsonSerialization) {
    return MachineCheckView(
      checkId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['checkId'],
      ),
      status: _i2.MachineCheckStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      requestedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['requestedAt'],
      ),
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      unanswered: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['unanswered'],
      ),
      result: jsonSerialization['result'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.MachineCheckResult>(
              jsonSerialization['result'],
            ),
    );
  }

  _i1.UuidValue checkId;

  _i2.MachineCheckStatus status;

  DateTime requestedAt;

  DateTime? finishedAt;

  /// True when the check went unanswered for too long, most likely because
  /// the machine runs a Discoman Compute too old to answer checks.
  bool unanswered;

  _i3.MachineCheckResult? result;

  /// Returns a shallow copy of this [MachineCheckView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MachineCheckView copyWith({
    _i1.UuidValue? checkId,
    _i2.MachineCheckStatus? status,
    DateTime? requestedAt,
    DateTime? finishedAt,
    bool? unanswered,
    _i3.MachineCheckResult? result,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MachineCheckView',
      'checkId': checkId.toJson(),
      'status': status.toJson(),
      'requestedAt': requestedAt.toJson(),
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      'unanswered': unanswered,
      if (result != null) 'result': result?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MachineCheckViewImpl extends MachineCheckView {
  _MachineCheckViewImpl({
    required _i1.UuidValue checkId,
    required _i2.MachineCheckStatus status,
    required DateTime requestedAt,
    DateTime? finishedAt,
    required bool unanswered,
    _i3.MachineCheckResult? result,
  }) : super._(
         checkId: checkId,
         status: status,
         requestedAt: requestedAt,
         finishedAt: finishedAt,
         unanswered: unanswered,
         result: result,
       );

  /// Returns a shallow copy of this [MachineCheckView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MachineCheckView copyWith({
    _i1.UuidValue? checkId,
    _i2.MachineCheckStatus? status,
    DateTime? requestedAt,
    Object? finishedAt = _Undefined,
    bool? unanswered,
    Object? result = _Undefined,
  }) {
    return MachineCheckView(
      checkId: checkId ?? this.checkId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      finishedAt: finishedAt is DateTime? ? finishedAt : this.finishedAt,
      unanswered: unanswered ?? this.unanswered,
      result: result is _i3.MachineCheckResult?
          ? result
          : this.result?.copyWith(),
    );
  }
}
