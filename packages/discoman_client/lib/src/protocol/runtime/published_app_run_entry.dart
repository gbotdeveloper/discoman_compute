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
import '../runtime/history_field_descriptor.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

abstract class PublishedAppRunEntry implements _i1.SerializableModel {
  PublishedAppRunEntry._({
    required this.id,
    required this.slug,
    required this.appTitle,
    required this.createdAt,
    this.durationMs,
    required this.warnings,
    required this.inputFields,
    required this.outputFields,
    required this.inputSummaryJson,
    required this.outputSummaryJson,
  });

  factory PublishedAppRunEntry({
    required String id,
    required String slug,
    required String appTitle,
    required DateTime createdAt,
    int? durationMs,
    required List<String> warnings,
    required List<_i2.HistoryFieldDescriptor> inputFields,
    required List<_i2.HistoryFieldDescriptor> outputFields,
    required String inputSummaryJson,
    required String outputSummaryJson,
  }) = _PublishedAppRunEntryImpl;

  factory PublishedAppRunEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PublishedAppRunEntry(
      id: jsonSerialization['id'] as String,
      slug: jsonSerialization['slug'] as String,
      appTitle: jsonSerialization['appTitle'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      durationMs: jsonSerialization['durationMs'] as int?,
      warnings: _i3.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
      inputFields: _i3.Protocol().deserialize<List<_i2.HistoryFieldDescriptor>>(
        jsonSerialization['inputFields'],
      ),
      outputFields: _i3.Protocol()
          .deserialize<List<_i2.HistoryFieldDescriptor>>(
            jsonSerialization['outputFields'],
          ),
      inputSummaryJson: jsonSerialization['inputSummaryJson'] as String,
      outputSummaryJson: jsonSerialization['outputSummaryJson'] as String,
    );
  }

  String id;

  String slug;

  String appTitle;

  DateTime createdAt;

  int? durationMs;

  List<String> warnings;

  List<_i2.HistoryFieldDescriptor> inputFields;

  List<_i2.HistoryFieldDescriptor> outputFields;

  String inputSummaryJson;

  String outputSummaryJson;

  @_i1.useResult
  PublishedAppRunEntry copyWith({
    String? id,
    String? slug,
    String? appTitle,
    DateTime? createdAt,
    int? durationMs,
    List<String>? warnings,
    List<_i2.HistoryFieldDescriptor>? inputFields,
    List<_i2.HistoryFieldDescriptor>? outputFields,
    String? inputSummaryJson,
    String? outputSummaryJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublishedAppRunEntry',
      'id': id,
      'slug': slug,
      'appTitle': appTitle,
      'createdAt': createdAt.toJson(),
      if (durationMs != null) 'durationMs': durationMs,
      'warnings': warnings.toJson(),
      'inputFields': inputFields.toJson(valueToJson: (v) => v.toJson()),
      'outputFields': outputFields.toJson(valueToJson: (v) => v.toJson()),
      'inputSummaryJson': inputSummaryJson,
      'outputSummaryJson': outputSummaryJson,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublishedAppRunEntryImpl extends PublishedAppRunEntry {
  _PublishedAppRunEntryImpl({
    required String id,
    required String slug,
    required String appTitle,
    required DateTime createdAt,
    int? durationMs,
    required List<String> warnings,
    required List<_i2.HistoryFieldDescriptor> inputFields,
    required List<_i2.HistoryFieldDescriptor> outputFields,
    required String inputSummaryJson,
    required String outputSummaryJson,
  }) : super._(
         id: id,
         slug: slug,
         appTitle: appTitle,
         createdAt: createdAt,
         durationMs: durationMs,
         warnings: warnings,
         inputFields: inputFields,
         outputFields: outputFields,
         inputSummaryJson: inputSummaryJson,
         outputSummaryJson: outputSummaryJson,
       );

  @_i1.useResult
  @override
  PublishedAppRunEntry copyWith({
    String? id,
    String? slug,
    String? appTitle,
    DateTime? createdAt,
    Object? durationMs = _Undefined,
    List<String>? warnings,
    List<_i2.HistoryFieldDescriptor>? inputFields,
    List<_i2.HistoryFieldDescriptor>? outputFields,
    String? inputSummaryJson,
    String? outputSummaryJson,
  }) {
    return PublishedAppRunEntry(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      appTitle: appTitle ?? this.appTitle,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs is int? ? durationMs : this.durationMs,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
      inputFields:
          inputFields ?? this.inputFields.map((e0) => e0.copyWith()).toList(),
      outputFields:
          outputFields ?? this.outputFields.map((e0) => e0.copyWith()).toList(),
      inputSummaryJson: inputSummaryJson ?? this.inputSummaryJson,
      outputSummaryJson: outputSummaryJson ?? this.outputSummaryJson,
    );
  }
}
