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
import '../../execution/models/execution_status_view.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

abstract class ExecutionDetailView implements _i1.SerializableModel {
  ExecutionDetailView._({
    required this.summary,
    this.outputsJson,
    required this.warnings,
    required this.logs,
    this.inputSummaryJson,
    this.claimedByWorkerId,
    this.claimedAt,
    this.leaseExpiresAt,
    required this.queueDeadlineAt,
    this.computeMsBilled,
    required this.timeoutSeconds,
    required this.relaxImportPolicy,
  });

  factory ExecutionDetailView({
    required _i2.ExecutionStatusView summary,
    String? outputsJson,
    required List<String> warnings,
    required List<String> logs,
    String? inputSummaryJson,
    _i1.UuidValue? claimedByWorkerId,
    DateTime? claimedAt,
    DateTime? leaseExpiresAt,
    required DateTime queueDeadlineAt,
    int? computeMsBilled,
    required int timeoutSeconds,
    required bool relaxImportPolicy,
  }) = _ExecutionDetailViewImpl;

  factory ExecutionDetailView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionDetailView(
      summary: _i3.Protocol().deserialize<_i2.ExecutionStatusView>(
        jsonSerialization['summary'],
      ),
      outputsJson: jsonSerialization['outputsJson'] as String?,
      warnings: _i3.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
      logs: _i3.Protocol().deserialize<List<String>>(jsonSerialization['logs']),
      inputSummaryJson: jsonSerialization['inputSummaryJson'] as String?,
      claimedByWorkerId: jsonSerialization['claimedByWorkerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['claimedByWorkerId'],
            ),
      claimedAt: jsonSerialization['claimedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['claimedAt']),
      leaseExpiresAt: jsonSerialization['leaseExpiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['leaseExpiresAt'],
            ),
      queueDeadlineAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['queueDeadlineAt'],
      ),
      computeMsBilled: jsonSerialization['computeMsBilled'] as int?,
      timeoutSeconds: jsonSerialization['timeoutSeconds'] as int,
      relaxImportPolicy: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['relaxImportPolicy'],
      ),
    );
  }

  _i2.ExecutionStatusView summary;

  String? outputsJson;

  List<String> warnings;

  List<String> logs;

  String? inputSummaryJson;

  _i1.UuidValue? claimedByWorkerId;

  DateTime? claimedAt;

  DateTime? leaseExpiresAt;

  DateTime queueDeadlineAt;

  int? computeMsBilled;

  int timeoutSeconds;

  bool relaxImportPolicy;

  @_i1.useResult
  ExecutionDetailView copyWith({
    _i2.ExecutionStatusView? summary,
    String? outputsJson,
    List<String>? warnings,
    List<String>? logs,
    String? inputSummaryJson,
    _i1.UuidValue? claimedByWorkerId,
    DateTime? claimedAt,
    DateTime? leaseExpiresAt,
    DateTime? queueDeadlineAt,
    int? computeMsBilled,
    int? timeoutSeconds,
    bool? relaxImportPolicy,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionDetailView',
      'summary': summary.toJson(),
      if (outputsJson != null) 'outputsJson': outputsJson,
      'warnings': warnings.toJson(),
      'logs': logs.toJson(),
      if (inputSummaryJson != null) 'inputSummaryJson': inputSummaryJson,
      if (claimedByWorkerId != null)
        'claimedByWorkerId': claimedByWorkerId?.toJson(),
      if (claimedAt != null) 'claimedAt': claimedAt?.toJson(),
      if (leaseExpiresAt != null) 'leaseExpiresAt': leaseExpiresAt?.toJson(),
      'queueDeadlineAt': queueDeadlineAt.toJson(),
      if (computeMsBilled != null) 'computeMsBilled': computeMsBilled,
      'timeoutSeconds': timeoutSeconds,
      'relaxImportPolicy': relaxImportPolicy,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExecutionDetailViewImpl extends ExecutionDetailView {
  _ExecutionDetailViewImpl({
    required _i2.ExecutionStatusView summary,
    String? outputsJson,
    required List<String> warnings,
    required List<String> logs,
    String? inputSummaryJson,
    _i1.UuidValue? claimedByWorkerId,
    DateTime? claimedAt,
    DateTime? leaseExpiresAt,
    required DateTime queueDeadlineAt,
    int? computeMsBilled,
    required int timeoutSeconds,
    required bool relaxImportPolicy,
  }) : super._(
         summary: summary,
         outputsJson: outputsJson,
         warnings: warnings,
         logs: logs,
         inputSummaryJson: inputSummaryJson,
         claimedByWorkerId: claimedByWorkerId,
         claimedAt: claimedAt,
         leaseExpiresAt: leaseExpiresAt,
         queueDeadlineAt: queueDeadlineAt,
         computeMsBilled: computeMsBilled,
         timeoutSeconds: timeoutSeconds,
         relaxImportPolicy: relaxImportPolicy,
       );

  @_i1.useResult
  @override
  ExecutionDetailView copyWith({
    _i2.ExecutionStatusView? summary,
    Object? outputsJson = _Undefined,
    List<String>? warnings,
    List<String>? logs,
    Object? inputSummaryJson = _Undefined,
    Object? claimedByWorkerId = _Undefined,
    Object? claimedAt = _Undefined,
    Object? leaseExpiresAt = _Undefined,
    DateTime? queueDeadlineAt,
    Object? computeMsBilled = _Undefined,
    int? timeoutSeconds,
    bool? relaxImportPolicy,
  }) {
    return ExecutionDetailView(
      summary: summary ?? this.summary.copyWith(),
      outputsJson: outputsJson is String? ? outputsJson : this.outputsJson,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
      logs: logs ?? this.logs.map((e0) => e0).toList(),
      inputSummaryJson: inputSummaryJson is String?
          ? inputSummaryJson
          : this.inputSummaryJson,
      claimedByWorkerId: claimedByWorkerId is _i1.UuidValue?
          ? claimedByWorkerId
          : this.claimedByWorkerId,
      claimedAt: claimedAt is DateTime? ? claimedAt : this.claimedAt,
      leaseExpiresAt: leaseExpiresAt is DateTime?
          ? leaseExpiresAt
          : this.leaseExpiresAt,
      queueDeadlineAt: queueDeadlineAt ?? this.queueDeadlineAt,
      computeMsBilled: computeMsBilled is int?
          ? computeMsBilled
          : this.computeMsBilled,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      relaxImportPolicy: relaxImportPolicy ?? this.relaxImportPolicy,
    );
  }
}
