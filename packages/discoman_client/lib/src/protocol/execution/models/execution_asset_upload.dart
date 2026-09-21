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

/// One output asset sent by a worker. Base64 payload; the server validates
/// size caps and decoded length before uploading to Firebase Storage.
abstract class ExecutionAssetUpload implements _i1.SerializableModel {
  ExecutionAssetUpload._({
    required this.outputKey,
    required this.kind,
    required this.name,
    required this.fileExtension,
    required this.mimeType,
    required this.sizeBytes,
    required this.base64,
  });

  factory ExecutionAssetUpload({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
    required String base64,
  }) = _ExecutionAssetUploadImpl;

  factory ExecutionAssetUpload.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ExecutionAssetUpload(
      outputKey: jsonSerialization['outputKey'] as String,
      kind: jsonSerialization['kind'] as String,
      name: jsonSerialization['name'] as String,
      fileExtension: jsonSerialization['fileExtension'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      base64: jsonSerialization['base64'] as String,
    );
  }

  String outputKey;

  /// image | file
  String kind;

  String name;

  /// File extension without the dot ('extension' is reserved in model fields).
  String fileExtension;

  String mimeType;

  int sizeBytes;

  String base64;

  /// Returns a shallow copy of this [ExecutionAssetUpload]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ExecutionAssetUpload copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
    String? base64,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionAssetUpload',
      'outputKey': outputKey,
      'kind': kind,
      'name': name,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'base64': base64,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionAssetUploadImpl extends ExecutionAssetUpload {
  _ExecutionAssetUploadImpl({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
    required String base64,
  }) : super._(
         outputKey: outputKey,
         kind: kind,
         name: name,
         fileExtension: fileExtension,
         mimeType: mimeType,
         sizeBytes: sizeBytes,
         base64: base64,
       );

  /// Returns a shallow copy of this [ExecutionAssetUpload]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ExecutionAssetUpload copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
    String? base64,
  }) {
    return ExecutionAssetUpload(
      outputKey: outputKey ?? this.outputKey,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      base64: base64 ?? this.base64,
    );
  }
}
