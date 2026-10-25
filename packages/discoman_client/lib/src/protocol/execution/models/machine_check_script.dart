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

/// One project's script as a worker found it during a machine check.
abstract class MachineCheckScript implements _i1.SerializableModel {
  MachineCheckScript._({
    required this.projectId,
    required this.present,
    required this.paused,
    this.fingerprint,
    this.expectedFingerprint,
    required this.missingModules,
  });

  factory MachineCheckScript({
    required String projectId,
    required bool present,
    required bool paused,
    String? fingerprint,
    String? expectedFingerprint,
    required List<String> missingModules,
  }) = _MachineCheckScriptImpl;

  factory MachineCheckScript.fromJson(Map<String, dynamic> jsonSerialization) {
    return MachineCheckScript(
      projectId: jsonSerialization['projectId'] as String,
      present: _i1.BoolJsonExtension.fromJson(jsonSerialization['present']),
      paused: _i1.BoolJsonExtension.fromJson(jsonSerialization['paused']),
      fingerprint: jsonSerialization['fingerprint'] as String?,
      expectedFingerprint: jsonSerialization['expectedFingerprint'] as String?,
      missingModules: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['missingModules'],
      ),
    );
  }

  String projectId;

  /// False when the project keeps its script on the creator's machine but
  /// this machine has no copy.
  bool present;

  /// The creator turned this project off on this machine.
  bool paused;

  String? fingerprint;

  /// The fingerprint of the script last linked to the project, from any
  /// machine. Null when the project has none.
  String? expectedFingerprint;

  /// Modules the script imports that this machine's Python cannot find.
  List<String> missingModules;

  /// Returns a shallow copy of this [MachineCheckScript]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MachineCheckScript copyWith({
    String? projectId,
    bool? present,
    bool? paused,
    String? fingerprint,
    String? expectedFingerprint,
    List<String>? missingModules,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MachineCheckScript',
      'projectId': projectId,
      'present': present,
      'paused': paused,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (expectedFingerprint != null)
        'expectedFingerprint': expectedFingerprint,
      'missingModules': missingModules.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MachineCheckScriptImpl extends MachineCheckScript {
  _MachineCheckScriptImpl({
    required String projectId,
    required bool present,
    required bool paused,
    String? fingerprint,
    String? expectedFingerprint,
    required List<String> missingModules,
  }) : super._(
         projectId: projectId,
         present: present,
         paused: paused,
         fingerprint: fingerprint,
         expectedFingerprint: expectedFingerprint,
         missingModules: missingModules,
       );

  /// Returns a shallow copy of this [MachineCheckScript]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MachineCheckScript copyWith({
    String? projectId,
    bool? present,
    bool? paused,
    Object? fingerprint = _Undefined,
    Object? expectedFingerprint = _Undefined,
    List<String>? missingModules,
  }) {
    return MachineCheckScript(
      projectId: projectId ?? this.projectId,
      present: present ?? this.present,
      paused: paused ?? this.paused,
      fingerprint: fingerprint is String? ? fingerprint : this.fingerprint,
      expectedFingerprint: expectedFingerprint is String?
          ? expectedFingerprint
          : this.expectedFingerprint,
      missingModules:
          missingModules ?? this.missingModules.map((e0) => e0).toList(),
    );
  }
}
