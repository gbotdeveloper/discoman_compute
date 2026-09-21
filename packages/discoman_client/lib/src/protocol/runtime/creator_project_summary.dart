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
import '../runtime/script_location.dart' as _i2;

/// One of the creator's projects, as listed by their compute client so they can
/// pick which one a script belongs to.
///
/// Deliberately thin: the client only needs enough to show a chooser and say
/// what state each project is in.
abstract class CreatorProjectSummary implements _i1.SerializableModel {
  CreatorProjectSummary._({
    required this.projectId,
    required this.name,
    required this.scriptLocation,
    required this.hasContract,
    this.scriptFingerprint,
  });

  factory CreatorProjectSummary({
    required String projectId,
    required String name,
    required _i2.ScriptLocation scriptLocation,
    required bool hasContract,
    String? scriptFingerprint,
  }) = _CreatorProjectSummaryImpl;

  factory CreatorProjectSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CreatorProjectSummary(
      projectId: jsonSerialization['projectId'] as String,
      name: jsonSerialization['name'] as String,
      scriptLocation: _i2.ScriptLocation.fromJson(
        (jsonSerialization['scriptLocation'] as String),
      ),
      hasContract: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasContract'],
      ),
      scriptFingerprint: jsonSerialization['scriptFingerprint'] as String?,
    );
  }

  String projectId;

  /// Project name as the creator typed it in the web app.
  String name;

  _i2.ScriptLocation scriptLocation;

  /// False until a contract has been published for this project.
  bool hasContract;

  /// Fingerprint of the script the current contract came from, when it was
  /// published from a compute client.
  String? scriptFingerprint;

  /// Returns a shallow copy of this [CreatorProjectSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreatorProjectSummary copyWith({
    String? projectId,
    String? name,
    _i2.ScriptLocation? scriptLocation,
    bool? hasContract,
    String? scriptFingerprint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatorProjectSummary',
      'projectId': projectId,
      'name': name,
      'scriptLocation': scriptLocation.toJson(),
      'hasContract': hasContract,
      if (scriptFingerprint != null) 'scriptFingerprint': scriptFingerprint,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatorProjectSummaryImpl extends CreatorProjectSummary {
  _CreatorProjectSummaryImpl({
    required String projectId,
    required String name,
    required _i2.ScriptLocation scriptLocation,
    required bool hasContract,
    String? scriptFingerprint,
  }) : super._(
         projectId: projectId,
         name: name,
         scriptLocation: scriptLocation,
         hasContract: hasContract,
         scriptFingerprint: scriptFingerprint,
       );

  /// Returns a shallow copy of this [CreatorProjectSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreatorProjectSummary copyWith({
    String? projectId,
    String? name,
    _i2.ScriptLocation? scriptLocation,
    bool? hasContract,
    Object? scriptFingerprint = _Undefined,
  }) {
    return CreatorProjectSummary(
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      scriptLocation: scriptLocation ?? this.scriptLocation,
      hasContract: hasContract ?? this.hasContract,
      scriptFingerprint: scriptFingerprint is String?
          ? scriptFingerprint
          : this.scriptFingerprint,
    );
  }
}
