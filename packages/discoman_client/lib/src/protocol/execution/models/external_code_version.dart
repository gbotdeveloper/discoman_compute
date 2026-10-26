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

/// Code a creator's script uses that Discoman does not see, as one computer
/// has it: a version the creator typed, or what a git checkout is on.
abstract class ExternalCodeVersion implements _i1.SerializableModel {
  ExternalCodeVersion._({
    required this.projectId,
    required this.name,
    this.manualVersion,
    this.gitPath,
    this.commit,
    this.commitDate,
    this.commitMessage,
    this.branch,
    this.dirty,
    this.problem,
  });

  factory ExternalCodeVersion({
    required String projectId,
    required String name,
    String? manualVersion,
    String? gitPath,
    String? commit,
    DateTime? commitDate,
    String? commitMessage,
    String? branch,
    bool? dirty,
    String? problem,
  }) = _ExternalCodeVersionImpl;

  factory ExternalCodeVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExternalCodeVersion(
      projectId: jsonSerialization['projectId'] as String,
      name: jsonSerialization['name'] as String,
      manualVersion: jsonSerialization['manualVersion'] as String?,
      gitPath: jsonSerialization['gitPath'] as String?,
      commit: jsonSerialization['commit'] as String?,
      commitDate: jsonSerialization['commitDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['commitDate']),
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      dirty: jsonSerialization['dirty'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['dirty']),
      problem: jsonSerialization['problem'] as String?,
    );
  }

  String projectId;

  /// What the creator calls it, such as "Signal processing library".
  String name;

  /// Set for a version typed by hand.
  String? manualVersion;

  /// Set for a git checkout: its folder on that computer.
  String? gitPath;

  String? commit;

  DateTime? commitDate;

  String? commitMessage;

  String? branch;

  /// The checkout has changes that are not committed.
  bool? dirty;

  /// Why a git checkout could not be read.
  String? problem;

  /// Returns a shallow copy of this [ExternalCodeVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ExternalCodeVersion copyWith({
    String? projectId,
    String? name,
    String? manualVersion,
    String? gitPath,
    String? commit,
    DateTime? commitDate,
    String? commitMessage,
    String? branch,
    bool? dirty,
    String? problem,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExternalCodeVersion',
      'projectId': projectId,
      'name': name,
      if (manualVersion != null) 'manualVersion': manualVersion,
      if (gitPath != null) 'gitPath': gitPath,
      if (commit != null) 'commit': commit,
      if (commitDate != null) 'commitDate': commitDate?.toJson(),
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (dirty != null) 'dirty': dirty,
      if (problem != null) 'problem': problem,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExternalCodeVersionImpl extends ExternalCodeVersion {
  _ExternalCodeVersionImpl({
    required String projectId,
    required String name,
    String? manualVersion,
    String? gitPath,
    String? commit,
    DateTime? commitDate,
    String? commitMessage,
    String? branch,
    bool? dirty,
    String? problem,
  }) : super._(
         projectId: projectId,
         name: name,
         manualVersion: manualVersion,
         gitPath: gitPath,
         commit: commit,
         commitDate: commitDate,
         commitMessage: commitMessage,
         branch: branch,
         dirty: dirty,
         problem: problem,
       );

  /// Returns a shallow copy of this [ExternalCodeVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ExternalCodeVersion copyWith({
    String? projectId,
    String? name,
    Object? manualVersion = _Undefined,
    Object? gitPath = _Undefined,
    Object? commit = _Undefined,
    Object? commitDate = _Undefined,
    Object? commitMessage = _Undefined,
    Object? branch = _Undefined,
    Object? dirty = _Undefined,
    Object? problem = _Undefined,
  }) {
    return ExternalCodeVersion(
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      manualVersion: manualVersion is String?
          ? manualVersion
          : this.manualVersion,
      gitPath: gitPath is String? ? gitPath : this.gitPath,
      commit: commit is String? ? commit : this.commit,
      commitDate: commitDate is DateTime? ? commitDate : this.commitDate,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      dirty: dirty is bool? ? dirty : this.dirty,
      problem: problem is String? ? problem : this.problem,
    );
  }
}
