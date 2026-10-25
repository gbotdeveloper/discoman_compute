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

/// What a self-hosted worker says about the computer it runs on.
abstract class MachineReport implements _i1.SerializableModel {
  MachineReport._({
    required this.machineId,
    required this.linkedProjectIds,
    required this.pausedProjectIds,
  });

  factory MachineReport({
    required String machineId,
    required List<String> linkedProjectIds,
    required List<String> pausedProjectIds,
  }) = _MachineReportImpl;

  factory MachineReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return MachineReport(
      machineId: jsonSerialization['machineId'] as String,
      linkedProjectIds: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['linkedProjectIds'],
      ),
      pausedProjectIds: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['pausedProjectIds'],
      ),
    );
  }

  String machineId;

  List<String> linkedProjectIds;

  List<String> pausedProjectIds;

  /// Returns a shallow copy of this [MachineReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MachineReport copyWith({
    String? machineId,
    List<String>? linkedProjectIds,
    List<String>? pausedProjectIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MachineReport',
      'machineId': machineId,
      'linkedProjectIds': linkedProjectIds.toJson(),
      'pausedProjectIds': pausedProjectIds.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MachineReportImpl extends MachineReport {
  _MachineReportImpl({
    required String machineId,
    required List<String> linkedProjectIds,
    required List<String> pausedProjectIds,
  }) : super._(
         machineId: machineId,
         linkedProjectIds: linkedProjectIds,
         pausedProjectIds: pausedProjectIds,
       );

  /// Returns a shallow copy of this [MachineReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MachineReport copyWith({
    String? machineId,
    List<String>? linkedProjectIds,
    List<String>? pausedProjectIds,
  }) {
    return MachineReport(
      machineId: machineId ?? this.machineId,
      linkedProjectIds:
          linkedProjectIds ?? this.linkedProjectIds.map((e0) => e0).toList(),
      pausedProjectIds:
          pausedProjectIds ?? this.pausedProjectIds.map((e0) => e0).toList(),
    );
  }
}
