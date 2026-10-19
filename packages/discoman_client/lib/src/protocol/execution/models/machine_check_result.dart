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
import '../../execution/models/machine_check_script.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

/// What a worker found when it checked itself.
abstract class MachineCheckResult implements _i1.SerializableModel {
  MachineCheckResult._({
    required this.pythonPath,
    this.pythonVersion,
    required this.pythonUsable,
    this.pythonProblem,
    required this.scripts,
  });

  factory MachineCheckResult({
    required String pythonPath,
    String? pythonVersion,
    required bool pythonUsable,
    String? pythonProblem,
    required List<_i2.MachineCheckScript> scripts,
  }) = _MachineCheckResultImpl;

  factory MachineCheckResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return MachineCheckResult(
      pythonPath: jsonSerialization['pythonPath'] as String,
      pythonVersion: jsonSerialization['pythonVersion'] as String?,
      pythonUsable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['pythonUsable'],
      ),
      pythonProblem: jsonSerialization['pythonProblem'] as String?,
      scripts: _i3.Protocol().deserialize<List<_i2.MachineCheckScript>>(
        jsonSerialization['scripts'],
      ),
    );
  }

  String pythonPath;

  String? pythonVersion;

  bool pythonUsable;

  /// Why the interpreter could not be used, when it could not.
  String? pythonProblem;

  List<_i2.MachineCheckScript> scripts;

  /// Returns a shallow copy of this [MachineCheckResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MachineCheckResult copyWith({
    String? pythonPath,
    String? pythonVersion,
    bool? pythonUsable,
    String? pythonProblem,
    List<_i2.MachineCheckScript>? scripts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MachineCheckResult',
      'pythonPath': pythonPath,
      if (pythonVersion != null) 'pythonVersion': pythonVersion,
      'pythonUsable': pythonUsable,
      if (pythonProblem != null) 'pythonProblem': pythonProblem,
      'scripts': scripts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MachineCheckResultImpl extends MachineCheckResult {
  _MachineCheckResultImpl({
    required String pythonPath,
    String? pythonVersion,
    required bool pythonUsable,
    String? pythonProblem,
    required List<_i2.MachineCheckScript> scripts,
  }) : super._(
         pythonPath: pythonPath,
         pythonVersion: pythonVersion,
         pythonUsable: pythonUsable,
         pythonProblem: pythonProblem,
         scripts: scripts,
       );

  /// Returns a shallow copy of this [MachineCheckResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MachineCheckResult copyWith({
    String? pythonPath,
    Object? pythonVersion = _Undefined,
    bool? pythonUsable,
    Object? pythonProblem = _Undefined,
    List<_i2.MachineCheckScript>? scripts,
  }) {
    return MachineCheckResult(
      pythonPath: pythonPath ?? this.pythonPath,
      pythonVersion: pythonVersion is String?
          ? pythonVersion
          : this.pythonVersion,
      pythonUsable: pythonUsable ?? this.pythonUsable,
      pythonProblem: pythonProblem is String?
          ? pythonProblem
          : this.pythonProblem,
      scripts: scripts ?? this.scripts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
