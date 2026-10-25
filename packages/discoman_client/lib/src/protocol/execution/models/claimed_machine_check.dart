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

/// Handed to a worker that picks up a machine check: which scripts it should
/// hold, and what each should hash to.
abstract class ClaimedMachineCheck implements _i1.SerializableModel {
  ClaimedMachineCheck._({
    required this.checkId,
    required this.expectedScripts,
  });

  factory ClaimedMachineCheck({
    required _i1.UuidValue checkId,
    required Map<String, String?> expectedScripts,
  }) = _ClaimedMachineCheckImpl;

  factory ClaimedMachineCheck.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClaimedMachineCheck(
      checkId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['checkId'],
      ),
      expectedScripts: _i2.Protocol().deserialize<Map<String, String?>>(
        jsonSerialization['expectedScripts'],
      ),
    );
  }

  _i1.UuidValue checkId;

  /// Project id to the fingerprint last linked to it, for every project of
  /// the creator that keeps its script on a machine. A null fingerprint means
  /// the project was never linked.
  Map<String, String?> expectedScripts;

  /// Returns a shallow copy of this [ClaimedMachineCheck]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClaimedMachineCheck copyWith({
    _i1.UuidValue? checkId,
    Map<String, String?>? expectedScripts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClaimedMachineCheck',
      'checkId': checkId.toJson(),
      'expectedScripts': expectedScripts.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ClaimedMachineCheckImpl extends ClaimedMachineCheck {
  _ClaimedMachineCheckImpl({
    required _i1.UuidValue checkId,
    required Map<String, String?> expectedScripts,
  }) : super._(
         checkId: checkId,
         expectedScripts: expectedScripts,
       );

  /// Returns a shallow copy of this [ClaimedMachineCheck]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClaimedMachineCheck copyWith({
    _i1.UuidValue? checkId,
    Map<String, String?>? expectedScripts,
  }) {
    return ClaimedMachineCheck(
      checkId: checkId ?? this.checkId,
      expectedScripts:
          expectedScripts ??
          this.expectedScripts.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
    );
  }
}
