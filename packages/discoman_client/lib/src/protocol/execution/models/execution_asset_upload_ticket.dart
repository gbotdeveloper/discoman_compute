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
import '../../execution/models/execution_asset_ref.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

/// Where a worker uploads one output file, and the reference to report for it.
abstract class ExecutionAssetUploadTicket implements _i1.SerializableModel {
  ExecutionAssetUploadTicket._({
    required this.asset,
    required this.uploadUrl,
  });

  factory ExecutionAssetUploadTicket({
    required _i2.ExecutionAssetRef asset,
    required String uploadUrl,
  }) = _ExecutionAssetUploadTicketImpl;

  factory ExecutionAssetUploadTicket.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ExecutionAssetUploadTicket(
      asset: _i3.Protocol().deserialize<_i2.ExecutionAssetRef>(
        jsonSerialization['asset'],
      ),
      uploadUrl: jsonSerialization['uploadUrl'] as String,
    );
  }

  _i2.ExecutionAssetRef asset;

  /// Short-lived, create-only link for a PUT of the file's bytes.
  String uploadUrl;

  /// Returns a shallow copy of this [ExecutionAssetUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ExecutionAssetUploadTicket copyWith({
    _i2.ExecutionAssetRef? asset,
    String? uploadUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionAssetUploadTicket',
      'asset': asset.toJson(),
      'uploadUrl': uploadUrl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionAssetUploadTicketImpl extends ExecutionAssetUploadTicket {
  _ExecutionAssetUploadTicketImpl({
    required _i2.ExecutionAssetRef asset,
    required String uploadUrl,
  }) : super._(
         asset: asset,
         uploadUrl: uploadUrl,
       );

  /// Returns a shallow copy of this [ExecutionAssetUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ExecutionAssetUploadTicket copyWith({
    _i2.ExecutionAssetRef? asset,
    String? uploadUrl,
  }) {
    return ExecutionAssetUploadTicket(
      asset: asset ?? this.asset.copyWith(),
      uploadUrl: uploadUrl ?? this.uploadUrl,
    );
  }
}
