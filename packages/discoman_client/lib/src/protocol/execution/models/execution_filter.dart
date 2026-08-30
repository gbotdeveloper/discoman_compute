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
import '../../execution/models/execution_kind.dart' as _i3;
import '../../execution/models/compute_mode.dart' as _i4;
import 'package:discoman_client/src/protocol/protocol.dart' as _i5;

abstract class ExecutionFilter implements _i1.SerializableModel {
  ExecutionFilter._({
    this.statuses,
    this.errorReasons,
    this.kind,
    this.computeMode,
    this.slug,
    this.projectId,
    this.creatorFirebaseUid,
    this.since,
  });

  factory ExecutionFilter({
    List<_i2.ExecutionStatus>? statuses,
    List<String>? errorReasons,
    _i3.ExecutionKind? kind,
    _i4.ComputeMode? computeMode,
    String? slug,
    String? projectId,
    String? creatorFirebaseUid,
    DateTime? since,
  }) = _ExecutionFilterImpl;

  factory ExecutionFilter.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionFilter(
      statuses: jsonSerialization['statuses'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i2.ExecutionStatus>>(
              jsonSerialization['statuses'],
            ),
      errorReasons: jsonSerialization['errorReasons'] == null
          ? null
          : _i5.Protocol().deserialize<List<String>>(
              jsonSerialization['errorReasons'],
            ),
      kind: jsonSerialization['kind'] == null
          ? null
          : _i3.ExecutionKind.fromJson((jsonSerialization['kind'] as String)),
      computeMode: jsonSerialization['computeMode'] == null
          ? null
          : _i4.ComputeMode.fromJson(
              (jsonSerialization['computeMode'] as String),
            ),
      slug: jsonSerialization['slug'] as String?,
      projectId: jsonSerialization['projectId'] as String?,
      creatorFirebaseUid: jsonSerialization['creatorFirebaseUid'] as String?,
      since: jsonSerialization['since'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['since']),
    );
  }

  List<_i2.ExecutionStatus>? statuses;

  List<String>? errorReasons;

  _i3.ExecutionKind? kind;

  _i4.ComputeMode? computeMode;

  String? slug;

  String? projectId;

  String? creatorFirebaseUid;

  DateTime? since;

  @_i1.useResult
  ExecutionFilter copyWith({
    List<_i2.ExecutionStatus>? statuses,
    List<String>? errorReasons,
    _i3.ExecutionKind? kind,
    _i4.ComputeMode? computeMode,
    String? slug,
    String? projectId,
    String? creatorFirebaseUid,
    DateTime? since,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionFilter',
      if (statuses != null)
        'statuses': statuses?.toJson(valueToJson: (v) => v.toJson()),
      if (errorReasons != null) 'errorReasons': errorReasons?.toJson(),
      if (kind != null) 'kind': kind?.toJson(),
      if (computeMode != null) 'computeMode': computeMode?.toJson(),
      if (slug != null) 'slug': slug,
      if (projectId != null) 'projectId': projectId,
      if (creatorFirebaseUid != null) 'creatorFirebaseUid': creatorFirebaseUid,
      if (since != null) 'since': since?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExecutionFilterImpl extends ExecutionFilter {
  _ExecutionFilterImpl({
    List<_i2.ExecutionStatus>? statuses,
    List<String>? errorReasons,
    _i3.ExecutionKind? kind,
    _i4.ComputeMode? computeMode,
    String? slug,
    String? projectId,
    String? creatorFirebaseUid,
    DateTime? since,
  }) : super._(
         statuses: statuses,
         errorReasons: errorReasons,
         kind: kind,
         computeMode: computeMode,
         slug: slug,
         projectId: projectId,
         creatorFirebaseUid: creatorFirebaseUid,
         since: since,
       );

  @_i1.useResult
  @override
  ExecutionFilter copyWith({
    Object? statuses = _Undefined,
    Object? errorReasons = _Undefined,
    Object? kind = _Undefined,
    Object? computeMode = _Undefined,
    Object? slug = _Undefined,
    Object? projectId = _Undefined,
    Object? creatorFirebaseUid = _Undefined,
    Object? since = _Undefined,
  }) {
    return ExecutionFilter(
      statuses: statuses is List<_i2.ExecutionStatus>?
          ? statuses
          : this.statuses?.map((e0) => e0).toList(),
      errorReasons: errorReasons is List<String>?
          ? errorReasons
          : this.errorReasons?.map((e0) => e0).toList(),
      kind: kind is _i3.ExecutionKind? ? kind : this.kind,
      computeMode: computeMode is _i4.ComputeMode?
          ? computeMode
          : this.computeMode,
      slug: slug is String? ? slug : this.slug,
      projectId: projectId is String? ? projectId : this.projectId,
      creatorFirebaseUid: creatorFirebaseUid is String?
          ? creatorFirebaseUid
          : this.creatorFirebaseUid,
      since: since is DateTime? ? since : this.since,
    );
  }
}
