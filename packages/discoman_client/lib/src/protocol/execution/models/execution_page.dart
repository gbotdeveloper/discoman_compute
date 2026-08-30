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
import '../../execution/models/execution_status_view.dart' as _i2;
import 'package:discoman_client/src/protocol/protocol.dart' as _i3;

abstract class ExecutionPage implements _i1.SerializableModel {
  ExecutionPage._({
    required this.items,
    required this.totalCount,
  });

  factory ExecutionPage({
    required List<_i2.ExecutionStatusView> items,
    required int totalCount,
  }) = _ExecutionPageImpl;

  factory ExecutionPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExecutionPage(
      items: _i3.Protocol().deserialize<List<_i2.ExecutionStatusView>>(
        jsonSerialization['items'],
      ),
      totalCount: jsonSerialization['totalCount'] as int,
    );
  }

  List<_i2.ExecutionStatusView> items;

  int totalCount;

  @_i1.useResult
  ExecutionPage copyWith({
    List<_i2.ExecutionStatusView>? items,
    int? totalCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExecutionPage',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ExecutionPageImpl extends ExecutionPage {
  _ExecutionPageImpl({
    required List<_i2.ExecutionStatusView> items,
    required int totalCount,
  }) : super._(
         items: items,
         totalCount: totalCount,
       );

  @_i1.useResult
  @override
  ExecutionPage copyWith({
    List<_i2.ExecutionStatusView>? items,
    int? totalCount,
  }) {
    return ExecutionPage(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
