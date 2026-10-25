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

/// One script a creator keeps in Discoman, as their computers see it.
abstract class SyncedScriptInfo implements _i1.SerializableModel {
  SyncedScriptInfo._({
    required this.projectId,
    this.fingerprint,
  });

  factory SyncedScriptInfo({
    required String projectId,
    String? fingerprint,
  }) = _SyncedScriptInfoImpl;

  factory SyncedScriptInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncedScriptInfo(
      projectId: jsonSerialization['projectId'] as String,
      fingerprint: jsonSerialization['fingerprint'] as String?,
    );
  }

  String projectId;

  /// Null until one of the creator's computers has sent the script.
  String? fingerprint;

  /// Returns a shallow copy of this [SyncedScriptInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncedScriptInfo copyWith({
    String? projectId,
    String? fingerprint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncedScriptInfo',
      'projectId': projectId,
      if (fingerprint != null) 'fingerprint': fingerprint,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncedScriptInfoImpl extends SyncedScriptInfo {
  _SyncedScriptInfoImpl({
    required String projectId,
    String? fingerprint,
  }) : super._(
         projectId: projectId,
         fingerprint: fingerprint,
       );

  /// Returns a shallow copy of this [SyncedScriptInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncedScriptInfo copyWith({
    String? projectId,
    Object? fingerprint = _Undefined,
  }) {
    return SyncedScriptInfo(
      projectId: projectId ?? this.projectId,
      fingerprint: fingerprint is String? ? fingerprint : this.fingerprint,
    );
  }
}
