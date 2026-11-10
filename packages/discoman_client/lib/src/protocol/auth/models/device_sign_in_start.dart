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

/// What an app gets back when it asks to be signed in through the browser.
abstract class DeviceSignInStart implements _i1.SerializableModel {
  DeviceSignInStart._({
    required this.deviceCode,
    required this.userCode,
    required this.approvalUrl,
    required this.expiresAt,
    required this.pollSeconds,
  });

  factory DeviceSignInStart({
    required String deviceCode,
    required String userCode,
    required String approvalUrl,
    required DateTime expiresAt,
    required int pollSeconds,
  }) = _DeviceSignInStartImpl;

  factory DeviceSignInStart.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceSignInStart(
      deviceCode: jsonSerialization['deviceCode'] as String,
      userCode: jsonSerialization['userCode'] as String,
      approvalUrl: jsonSerialization['approvalUrl'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      pollSeconds: jsonSerialization['pollSeconds'] as int,
    );
  }

  /// The secret to collect the session with. Never shown or sent anywhere
  /// but back to `deviceSignIn.claim`.
  String deviceCode;

  /// The short code to show the person, e.g. `K7QM-3XPD`.
  String userCode;

  /// The web app page where the person approves, with the code filled in.
  String approvalUrl;

  DateTime expiresAt;

  /// How long to wait between two `claim` calls.
  int pollSeconds;

  /// Returns a shallow copy of this [DeviceSignInStart]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeviceSignInStart copyWith({
    String? deviceCode,
    String? userCode,
    String? approvalUrl,
    DateTime? expiresAt,
    int? pollSeconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceSignInStart',
      'deviceCode': deviceCode,
      'userCode': userCode,
      'approvalUrl': approvalUrl,
      'expiresAt': expiresAt.toJson(),
      'pollSeconds': pollSeconds,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DeviceSignInStartImpl extends DeviceSignInStart {
  _DeviceSignInStartImpl({
    required String deviceCode,
    required String userCode,
    required String approvalUrl,
    required DateTime expiresAt,
    required int pollSeconds,
  }) : super._(
         deviceCode: deviceCode,
         userCode: userCode,
         approvalUrl: approvalUrl,
         expiresAt: expiresAt,
         pollSeconds: pollSeconds,
       );

  /// Returns a shallow copy of this [DeviceSignInStart]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeviceSignInStart copyWith({
    String? deviceCode,
    String? userCode,
    String? approvalUrl,
    DateTime? expiresAt,
    int? pollSeconds,
  }) {
    return DeviceSignInStart(
      deviceCode: deviceCode ?? this.deviceCode,
      userCode: userCode ?? this.userCode,
      approvalUrl: approvalUrl ?? this.approvalUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      pollSeconds: pollSeconds ?? this.pollSeconds,
    );
  }
}
