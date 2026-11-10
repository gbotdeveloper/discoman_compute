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

/// Who the session belongs to: what the app needs to know after restoring
/// a stored session.
abstract class AccountInfo implements _i1.SerializableModel {
  AccountInfo._({
    required this.userId,
    this.email,
  });

  factory AccountInfo({
    required String userId,
    String? email,
  }) = _AccountInfoImpl;

  factory AccountInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountInfo(
      userId: jsonSerialization['userId'] as String,
      email: jsonSerialization['email'] as String?,
    );
  }

  String userId;

  /// Null for the anonymous session of a public app visitor.
  String? email;

  /// Returns a shallow copy of this [AccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountInfo copyWith({
    String? userId,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountInfo',
      'userId': userId,
      if (email != null) 'email': email,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountInfoImpl extends AccountInfo {
  _AccountInfoImpl({
    required String userId,
    String? email,
  }) : super._(
         userId: userId,
         email: email,
       );

  /// Returns a shallow copy of this [AccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountInfo copyWith({
    String? userId,
    Object? email = _Undefined,
  }) {
    return AccountInfo(
      userId: userId ?? this.userId,
      email: email is String? ? email : this.email,
    );
  }
}
