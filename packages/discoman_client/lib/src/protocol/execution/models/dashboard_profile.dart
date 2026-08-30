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

abstract class DashboardProfile implements _i1.SerializableModel {
  DashboardProfile._({
    required this.firebaseUid,
    this.email,
    required this.isAdmin,
  });

  factory DashboardProfile({
    required String firebaseUid,
    String? email,
    required bool isAdmin,
  }) = _DashboardProfileImpl;

  factory DashboardProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return DashboardProfile(
      firebaseUid: jsonSerialization['firebaseUid'] as String,
      email: jsonSerialization['email'] as String?,
      isAdmin: _i1.BoolJsonExtension.fromJson(jsonSerialization['isAdmin']),
    );
  }

  String firebaseUid;

  String? email;

  bool isAdmin;

  @_i1.useResult
  DashboardProfile copyWith({
    String? firebaseUid,
    String? email,
    bool? isAdmin,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DashboardProfile',
      'firebaseUid': firebaseUid,
      if (email != null) 'email': email,
      'isAdmin': isAdmin,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DashboardProfileImpl extends DashboardProfile {
  _DashboardProfileImpl({
    required String firebaseUid,
    String? email,
    required bool isAdmin,
  }) : super._(
         firebaseUid: firebaseUid,
         email: email,
         isAdmin: isAdmin,
       );

  @_i1.useResult
  @override
  DashboardProfile copyWith({
    String? firebaseUid,
    Object? email = _Undefined,
    bool? isAdmin,
  }) {
    return DashboardProfile(
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email is String? ? email : this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
