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

/// A pending browser sign-in as the approval page shows it.
abstract class DeviceSignInRequest implements _i1.SerializableModel {
  DeviceSignInRequest._({
    required this.userCode,
    required this.deviceName,
    required this.expiresAt,
  });

  factory DeviceSignInRequest({
    required String userCode,
    required String deviceName,
    required DateTime expiresAt,
  }) = _DeviceSignInRequestImpl;

  factory DeviceSignInRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceSignInRequest(
      userCode: jsonSerialization['userCode'] as String,
      deviceName: jsonSerialization['deviceName'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String userCode;

  String deviceName;

  DateTime expiresAt;

  /// Returns a shallow copy of this [DeviceSignInRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeviceSignInRequest copyWith({
    String? userCode,
    String? deviceName,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceSignInRequest',
      'userCode': userCode,
      'deviceName': deviceName,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DeviceSignInRequestImpl extends DeviceSignInRequest {
  _DeviceSignInRequestImpl({
    required String userCode,
    required String deviceName,
    required DateTime expiresAt,
  }) : super._(
         userCode: userCode,
         deviceName: deviceName,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [DeviceSignInRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeviceSignInRequest copyWith({
    String? userCode,
    String? deviceName,
    DateTime? expiresAt,
  }) {
    return DeviceSignInRequest(
      userCode: userCode ?? this.userCode,
      deviceName: deviceName ?? this.deviceName,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
