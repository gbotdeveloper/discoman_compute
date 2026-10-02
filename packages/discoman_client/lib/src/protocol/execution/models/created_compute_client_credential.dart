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
import 'package:discoman_client/src/protocol/protocol.dart' as _iy9hkqa4;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../execution/models/compute_client_credential_info.dart'
    as _ih9mej3u;

/// Returned once from createComputeClientCredential: the only time the
/// plaintext token is ever visible.
abstract class CreatedComputeClientCredential
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreatedComputeClientCredential._({
    required this.info,
    required this.token,
  });

  factory CreatedComputeClientCredential({
    required _ih9mej3u.ComputeClientCredentialInfo info,
    required String token,
  }) = _CreatedComputeClientCredentialImpl;

  factory CreatedComputeClientCredential.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CreatedComputeClientCredential(
      info: _iy9hkqa4.Protocol()
          .deserialize<_ih9mej3u.ComputeClientCredentialInfo>(
            jsonSerialization['info'],
          ),
      token: jsonSerialization['token'] as String,
    );
  }

  _ih9mej3u.ComputeClientCredentialInfo info;

  /// Plaintext machine token — store it on the client machine; the server
  /// keeps only its hash.
  String token;

  /// Returns a shallow copy of this [CreatedComputeClientCredential]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreatedComputeClientCredential copyWith({
    _ih9mej3u.ComputeClientCredentialInfo? info,
    String? token,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatedComputeClientCredential',
      'info': info.toJson(),
      'token': token,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreatedComputeClientCredential',
      'info': info.toJsonForProtocol(),
      'token': token,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CreatedComputeClientCredentialImpl
    extends CreatedComputeClientCredential {
  _CreatedComputeClientCredentialImpl({
    required _ih9mej3u.ComputeClientCredentialInfo info,
    required String token,
  }) : super._(
         info: info,
         token: token,
       );

  /// Returns a shallow copy of this [CreatedComputeClientCredential]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreatedComputeClientCredential copyWith({
    _ih9mej3u.ComputeClientCredentialInfo? info,
    String? token,
  }) {
    return CreatedComputeClientCredential(
      info: info ?? this.info.copyWith(),
      token: token ?? this.token,
    );
  }
}
