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

abstract class HeartbeatResponse implements _i1.SerializableModel {
  HeartbeatResponse._({required this.cancelRequested});

  factory HeartbeatResponse({required bool cancelRequested}) =
      _HeartbeatResponseImpl;

  factory HeartbeatResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return HeartbeatResponse(
      cancelRequested: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['cancelRequested'],
      ),
    );
  }

  bool cancelRequested;

  @_i1.useResult
  HeartbeatResponse copyWith({bool? cancelRequested});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HeartbeatResponse',
      'cancelRequested': cancelRequested,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _HeartbeatResponseImpl extends HeartbeatResponse {
  _HeartbeatResponseImpl({required bool cancelRequested})
    : super._(cancelRequested: cancelRequested);

  @_i1.useResult
  @override
  HeartbeatResponse copyWith({bool? cancelRequested}) {
    return HeartbeatResponse(
      cancelRequested: cancelRequested ?? this.cancelRequested,
    );
  }
}
