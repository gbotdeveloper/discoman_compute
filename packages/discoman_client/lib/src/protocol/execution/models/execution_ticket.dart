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
import '../../execution/models/execution_status.dart' as _i2;

abstract class ExecutionTicket implements _i1.SerializableModel {
  ExecutionTicket._({
    required this.executionId,
    required this.status,
    required this.queuePosition,
    required this.workerOnline,
  });

  factory ExecutionTicket({
    required _i1.UuidValue executionId,
    required _i2.ExecutionStatus status,
    required int queuePosition,
    required bool workerOnline,
  }) = _ExecutionTicketImpl;

  factory ExecutionTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionTicket(
      executionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['executionId'],
      ),
      status: _i2.ExecutionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      queuePosition: jsonSerialization['queuePosition'] as int,
      workerOnline: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['workerOnline'],
      ),
    );
  }

  _i1.UuidValue executionId;

  _i2.ExecutionStatus status;

  int queuePosition;

  bool workerOnline;

  @_i1.useResult
  ExecutionTicket copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionStatus? status,
    int? queuePosition,
    bool? workerOnline,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionTicket',
      'executionId': executionId.toJson(),
      'status': status.toJson(),
      'queuePosition': queuePosition,
      'workerOnline': workerOnline,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionTicketImpl extends ExecutionTicket {
  _ExecutionTicketImpl({
    required _i1.UuidValue executionId,
    required _i2.ExecutionStatus status,
    required int queuePosition,
    required bool workerOnline,
  }) : super._(
         executionId: executionId,
         status: status,
         queuePosition: queuePosition,
         workerOnline: workerOnline,
       );

  @_i1.useResult
  @override
  ExecutionTicket copyWith({
    _i1.UuidValue? executionId,
    _i2.ExecutionStatus? status,
    int? queuePosition,
    bool? workerOnline,
  }) {
    return ExecutionTicket(
      executionId: executionId ?? this.executionId,
      status: status ?? this.status,
      queuePosition: queuePosition ?? this.queuePosition,
      workerOnline: workerOnline ?? this.workerOnline,
    );
  }
}
