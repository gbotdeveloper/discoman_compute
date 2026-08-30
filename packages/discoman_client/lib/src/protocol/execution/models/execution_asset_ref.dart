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

abstract class ExecutionAssetRef implements _i1.SerializableModel {
  ExecutionAssetRef._({
    required this.outputKey,
    required this.kind,
    required this.name,
    required this.fileExtension,
    required this.mimeType,
    required this.sizeBytes,
    required this.storagePath,
    required this.downloadUrl,
  });

  factory ExecutionAssetRef({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
    required String storagePath,
    required String downloadUrl,
  }) = _ExecutionAssetRefImpl;

  factory ExecutionAssetRef.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionAssetRef(
      outputKey: jsonSerialization['outputKey'] as String,
      kind: jsonSerialization['kind'] as String,
      name: jsonSerialization['name'] as String,
      fileExtension: jsonSerialization['fileExtension'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      downloadUrl: jsonSerialization['downloadUrl'] as String,
    );
  }

  String outputKey;

  String kind;

  String name;

  String fileExtension;

  String mimeType;

  int sizeBytes;

  String storagePath;

  String downloadUrl;

  @_i1.useResult
  ExecutionAssetRef copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
    String? storagePath,
    String? downloadUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionAssetRef',
      'outputKey': outputKey,
      'kind': kind,
      'name': name,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionAssetRefImpl extends ExecutionAssetRef {
  _ExecutionAssetRefImpl({
    required String outputKey,
    required String kind,
    required String name,
    required String fileExtension,
    required String mimeType,
    required int sizeBytes,
    required String storagePath,
    required String downloadUrl,
  }) : super._(
         outputKey: outputKey,
         kind: kind,
         name: name,
         fileExtension: fileExtension,
         mimeType: mimeType,
         sizeBytes: sizeBytes,
         storagePath: storagePath,
         downloadUrl: downloadUrl,
       );

  @_i1.useResult
  @override
  ExecutionAssetRef copyWith({
    String? outputKey,
    String? kind,
    String? name,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
    String? storagePath,
    String? downloadUrl,
  }) {
    return ExecutionAssetRef(
      outputKey: outputKey ?? this.outputKey,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }
}
