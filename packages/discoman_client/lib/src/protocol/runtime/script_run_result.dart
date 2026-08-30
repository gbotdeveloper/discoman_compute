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
import 'package:discoman_client/src/protocol/protocol.dart' as _i2;

abstract class ScriptRunResult implements _i1.SerializableModel {
  ScriptRunResult._({
    required this.outputsJson,
    this.durationMs,
    required this.warnings,
    required this.logs,
  });

  factory ScriptRunResult({
    required String outputsJson,
    int? durationMs,
    required List<String> warnings,
    required List<String> logs,
  }) = _ScriptRunResultImpl;

  factory ScriptRunResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScriptRunResult(
      outputsJson: jsonSerialization['outputsJson'] as String,
      durationMs: jsonSerialization['durationMs'] as int?,
      warnings: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
      logs: _i2.Protocol().deserialize<List<String>>(jsonSerialization['logs']),
    );
  }

  String outputsJson;

  int? durationMs;

  List<String> warnings;

  List<String> logs;

  @_i1.useResult
  ScriptRunResult copyWith({
    String? outputsJson,
    int? durationMs,
    List<String>? warnings,
    List<String>? logs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScriptRunResult',
      'outputsJson': outputsJson,
      if (durationMs != null) 'durationMs': durationMs,
      'warnings': warnings.toJson(),
      'logs': logs.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ScriptRunResultImpl extends ScriptRunResult {
  _ScriptRunResultImpl({
    required String outputsJson,
    int? durationMs,
    required List<String> warnings,
    required List<String> logs,
  }) : super._(
         outputsJson: outputsJson,
         durationMs: durationMs,
         warnings: warnings,
         logs: logs,
       );

  @_i1.useResult
  @override
  ScriptRunResult copyWith({
    String? outputsJson,
    Object? durationMs = _Undefined,
    List<String>? warnings,
    List<String>? logs,
  }) {
    return ScriptRunResult(
      outputsJson: outputsJson ?? this.outputsJson,
      durationMs: durationMs is int? ? durationMs : this.durationMs,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
      logs: logs ?? this.logs.map((e0) => e0).toList(),
    );
  }
}
