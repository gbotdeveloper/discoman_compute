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

/// Where a project's Python script lives, which also decides where it runs.
///
/// The two are one choice: a script we hold runs in our cloud, a script that
/// never leaves the creator's machine can only run there.
enum ScriptLocation implements _i1.SerializableModel {
  /// Uploaded through the web app; stored in Firebase Storage and run in the
  /// cloud pool.
  uploaded,

  /// Loaded into the creator's compute client; stays on their disk and runs
  /// there. We only ever see the contract it exposes.
  creatorMachine
  ;

  static ScriptLocation fromJson(String name) {
    switch (name) {
      case 'uploaded':
        return ScriptLocation.uploaded;
      case 'creatorMachine':
        return ScriptLocation.creatorMachine;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ScriptLocation"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
