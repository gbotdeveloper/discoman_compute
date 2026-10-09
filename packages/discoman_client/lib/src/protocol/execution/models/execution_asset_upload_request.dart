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

/// An output file a worker is about to upload itself: everything but the bytes.
abstract class ExecutionAssetUploadRequest implements _i1.SerializableModel {
  ExecutionAssetUploadRequest._({
    required this.outputKey,
    required this.kind,
    required this.name,
    required this.fileExtension,
    required this.mimeType,
    required this.sizeBytes,
  });

  factory ExecutionAssetUploadRequest({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
  }) = _ExecutionAssetUploadRequestImpl;

  factory ExecutionAssetUploadRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ExecutionAssetUploadRequest(
      outputKey: jsonSerialization['outputKey'] as String,
      kind: jsonSerialization['kind'] as String,
      name: jsonSerialization['name'] as String,
      fileExtension: jsonSerialization['fileExtension'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
    );
  }

  String outputKey;

  /// image | file
  String kind;

  String name;

  String fileExtension;

  String mimeType;

  int sizeBytes;

  /// Returns a shallow copy of this [ExecutionAssetUploadRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ExecutionAssetUploadRequest copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionAssetUploadRequest',
      'outputKey': outputKey,
      'kind': kind,
      'name': name,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionAssetUploadRequestImpl extends ExecutionAssetUploadRequest {
  _ExecutionAssetUploadRequestImpl({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
  }) : super._(
         outputKey: outputKey,
         kind: kind,
         name: name,
         fileExtension: fileExtension,
         mimeType: mimeType,
         sizeBytes: sizeBytes,
       );

  /// Returns a shallow copy of this [ExecutionAssetUploadRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ExecutionAssetUploadRequest copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
  }) {
    return ExecutionAssetUploadRequest(
      outputKey: outputKey ?? this.outputKey,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}
