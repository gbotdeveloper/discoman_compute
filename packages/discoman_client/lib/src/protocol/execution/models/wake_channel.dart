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

/// Where a self-hosted worker waits to be told there is something to do,
/// instead of asking every few seconds: a queue of its own that it may
/// only read. A request to [receiveUrl] with [authorization] answers when
/// a wake-up arrives, or empty after its timeout.
abstract class WakeChannel implements _i1.SerializableModel {
  WakeChannel._({
    required this.receiveUrl,
    required this.authorization,
    required this.expiresAt,
  });

  factory WakeChannel({
    required String receiveUrl,
    required String authorization,
    required DateTime expiresAt,
  }) = _WakeChannelImpl;

  factory WakeChannel.fromJson(Map<String, dynamic> jsonSerialization) {
    return WakeChannel(
      receiveUrl: jsonSerialization['receiveUrl'] as String,
      authorization: jsonSerialization['authorization'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// `DELETE` this URL (it already carries the wait timeout) to take the
  /// next wake-up.
  String receiveUrl;

  /// The `Authorization` header that goes with it.
  String authorization;

  /// When [authorization] stops working; open a new channel before then.
  DateTime expiresAt;

  /// Returns a shallow copy of this [WakeChannel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WakeChannel copyWith({
    String? receiveUrl,
    String? authorization,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WakeChannel',
      'receiveUrl': receiveUrl,
      'authorization': authorization,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _WakeChannelImpl extends WakeChannel {
  _WakeChannelImpl({
    required String receiveUrl,
    required String authorization,
    required DateTime expiresAt,
  }) : super._(
         receiveUrl: receiveUrl,
         authorization: authorization,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [WakeChannel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WakeChannel copyWith({
    String? receiveUrl,
    String? authorization,
    DateTime? expiresAt,
  }) {
    return WakeChannel(
      receiveUrl: receiveUrl ?? this.receiveUrl,
      authorization: authorization ?? this.authorization,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
