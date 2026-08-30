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

abstract class ComputeClientCredentialInfo implements _i1.SerializableModel {
  ComputeClientCredentialInfo._({
    required this.credentialId,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    required this.revoked,
  });

  factory ComputeClientCredentialInfo({
    required _i1.UuidValue credentialId,
    required String name,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    required bool revoked,
  }) = _ComputeClientCredentialInfoImpl;

  factory ComputeClientCredentialInfo.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ComputeClientCredentialInfo(
      credentialId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['credentialId'],
      ),
      name: jsonSerialization['name'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      revoked: _i1.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
    );
  }

  _i1.UuidValue credentialId;

  String name;

  DateTime createdAt;

  DateTime? lastUsedAt;

  bool revoked;

  @_i1.useResult
  ComputeClientCredentialInfo copyWith({
    _i1.UuidValue? credentialId,
    String? name,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? revoked,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeClientCredentialInfo',
      'credentialId': credentialId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      'revoked': revoked,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ComputeClientCredentialInfoImpl extends ComputeClientCredentialInfo {
  _ComputeClientCredentialInfoImpl({
    required _i1.UuidValue credentialId,
    required String name,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    required bool revoked,
  }) : super._(
         credentialId: credentialId,
         name: name,
         createdAt: createdAt,
         lastUsedAt: lastUsedAt,
         revoked: revoked,
       );

  @_i1.useResult
  @override
  ComputeClientCredentialInfo copyWith({
    _i1.UuidValue? credentialId,
    String? name,
    DateTime? createdAt,
    Object? lastUsedAt = _Undefined,
    bool? revoked,
  }) {
    return ComputeClientCredentialInfo(
      credentialId: credentialId ?? this.credentialId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      revoked: revoked ?? this.revoked,
    );
  }
}
