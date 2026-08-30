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
import '../../execution/models/compute_client_credential_info.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

abstract class CreatedComputeClientCredential implements _i1.SerializableModel {
  CreatedComputeClientCredential._({
    required this.info,
    required this.token,
  });

  factory CreatedComputeClientCredential({
    required _i2.ComputeClientCredentialInfo info,
    required String token,
  }) = _CreatedComputeClientCredentialImpl;

  factory CreatedComputeClientCredential.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CreatedComputeClientCredential(
      info: _i3.Protocol().deserialize<_i2.ComputeClientCredentialInfo>(
        jsonSerialization['info'],
      ),
      token: jsonSerialization['token'] as String,
    );
  }

  _i2.ComputeClientCredentialInfo info;

  String token;

  @_i1.useResult
  CreatedComputeClientCredential copyWith({
    _i2.ComputeClientCredentialInfo? info,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CreatedComputeClientCredentialImpl
    extends CreatedComputeClientCredential {
  _CreatedComputeClientCredentialImpl({
    required _i2.ComputeClientCredentialInfo info,
    required String token,
  }) : super._(
         info: info,
         token: token,
       );

  @_i1.useResult
  @override
  CreatedComputeClientCredential copyWith({
    _i2.ComputeClientCredentialInfo? info,
    String? token,
  }) {
    return CreatedComputeClientCredential(
      info: info ?? this.info.copyWith(),
      token: token ?? this.token,
    );
  }
}
