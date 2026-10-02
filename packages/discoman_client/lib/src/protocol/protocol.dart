/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _iywakebc;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _iu3gutcn;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i4qtshzf;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'execution/models/claimed_execution.dart' as _iawd25jn;
import 'execution/models/compute_client_credential_info.dart' as _ivg9lqrn;
import 'execution/models/compute_mode.dart' as _i0in2gxv;
import 'execution/models/compute_worker_info.dart' as _iife5tw8;
import 'execution/models/created_compute_client_credential.dart' as _ipqdvjbs;
import 'execution/models/creator_compute_settings.dart' as _ibbdejyk;
import 'execution/models/execution_asset_ref.dart' as _ijgs7z7c;
import 'execution/models/execution_asset_upload.dart' as _ivda8bev;
import 'execution/models/execution_kind.dart' as _i1bow5es;
import 'execution/models/execution_outcome.dart' as _iz3ik4nj;
import 'execution/models/heartbeat_response.dart' as _iakg6oi5;
import 'execution/models/worker_registration.dart' as _ixeou3vb;
import 'runtime/contract_draft.dart' as _isg42qwi;
import 'runtime/contract_input_field.dart' as _ikz23b0o;
import 'runtime/contract_output_field.dart' as _iw4gh6q0;
import 'runtime/creator_project_summary.dart' as _iygdtk1e;
import 'runtime/python_field_type.dart' as _irc3xa7s;
import 'runtime/script_location.dart' as _i7zdbq5c;
import 'runtime/script_run_exception.dart' as _i2xjf2ew;
export 'execution/models/claimed_execution.dart';
export 'execution/models/compute_client_credential_info.dart';
export 'execution/models/compute_mode.dart';
export 'execution/models/compute_worker_info.dart';
export 'execution/models/created_compute_client_credential.dart';
export 'execution/models/creator_compute_settings.dart';
export 'execution/models/execution_asset_ref.dart';
export 'execution/models/execution_asset_upload.dart';
export 'execution/models/execution_kind.dart';
export 'execution/models/execution_outcome.dart';
export 'execution/models/heartbeat_response.dart';
export 'execution/models/worker_registration.dart';
export 'runtime/contract_draft.dart';
export 'runtime/contract_input_field.dart';
export 'runtime/contract_output_field.dart';
export 'runtime/creator_project_summary.dart';
export 'runtime/python_field_type.dart';
export 'runtime/script_location.dart';
export 'runtime/script_run_exception.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iawd25jn.ClaimedExecution) {
      return _iawd25jn.ClaimedExecution.fromJson(data) as T;
    }
    if (t == _ivg9lqrn.ComputeClientCredentialInfo) {
      return _ivg9lqrn.ComputeClientCredentialInfo.fromJson(data) as T;
    }
    if (t == _i0in2gxv.ComputeMode) {
      return _i0in2gxv.ComputeMode.fromJson(data) as T;
    }
    if (t == _iife5tw8.ComputeWorkerInfo) {
      return _iife5tw8.ComputeWorkerInfo.fromJson(data) as T;
    }
    if (t == _ipqdvjbs.CreatedComputeClientCredential) {
      return _ipqdvjbs.CreatedComputeClientCredential.fromJson(data) as T;
    }
    if (t == _ibbdejyk.CreatorComputeSettings) {
      return _ibbdejyk.CreatorComputeSettings.fromJson(data) as T;
    }
    if (t == _ijgs7z7c.ExecutionAssetRef) {
      return _ijgs7z7c.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _ivda8bev.ExecutionAssetUpload) {
      return _ivda8bev.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i1bow5es.ExecutionKind) {
      return _i1bow5es.ExecutionKind.fromJson(data) as T;
    }
    if (t == _iz3ik4nj.ExecutionOutcome) {
      return _iz3ik4nj.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _iakg6oi5.HeartbeatResponse) {
      return _iakg6oi5.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _ixeou3vb.WorkerRegistration) {
      return _ixeou3vb.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _isg42qwi.ContractDraft) {
      return _isg42qwi.ContractDraft.fromJson(data) as T;
    }
    if (t == _ikz23b0o.ContractInputField) {
      return _ikz23b0o.ContractInputField.fromJson(data) as T;
    }
    if (t == _iw4gh6q0.ContractOutputField) {
      return _iw4gh6q0.ContractOutputField.fromJson(data) as T;
    }
    if (t == _iygdtk1e.CreatorProjectSummary) {
      return _iygdtk1e.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _irc3xa7s.PythonFieldType) {
      return _irc3xa7s.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i7zdbq5c.ScriptLocation) {
      return _i7zdbq5c.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i2xjf2ew.ScriptRunException) {
      return _i2xjf2ew.ScriptRunException.fromJson(data) as T;
    }
    if (t == _isc.getType<_iawd25jn.ClaimedExecution?>()) {
      return (data != null ? _iawd25jn.ClaimedExecution.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivg9lqrn.ComputeClientCredentialInfo?>()) {
      return (data != null
              ? _ivg9lqrn.ComputeClientCredentialInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i0in2gxv.ComputeMode?>()) {
      return (data != null ? _i0in2gxv.ComputeMode.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iife5tw8.ComputeWorkerInfo?>()) {
      return (data != null ? _iife5tw8.ComputeWorkerInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipqdvjbs.CreatedComputeClientCredential?>()) {
      return (data != null
              ? _ipqdvjbs.CreatedComputeClientCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ibbdejyk.CreatorComputeSettings?>()) {
      return (data != null
              ? _ibbdejyk.CreatorComputeSettings.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ijgs7z7c.ExecutionAssetRef?>()) {
      return (data != null ? _ijgs7z7c.ExecutionAssetRef.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivda8bev.ExecutionAssetUpload?>()) {
      return (data != null
              ? _ivda8bev.ExecutionAssetUpload.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i1bow5es.ExecutionKind?>()) {
      return (data != null ? _i1bow5es.ExecutionKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iz3ik4nj.ExecutionOutcome?>()) {
      return (data != null ? _iz3ik4nj.ExecutionOutcome.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iakg6oi5.HeartbeatResponse?>()) {
      return (data != null ? _iakg6oi5.HeartbeatResponse.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixeou3vb.WorkerRegistration?>()) {
      return (data != null ? _ixeou3vb.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_isg42qwi.ContractDraft?>()) {
      return (data != null ? _isg42qwi.ContractDraft.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikz23b0o.ContractInputField?>()) {
      return (data != null ? _ikz23b0o.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iw4gh6q0.ContractOutputField?>()) {
      return (data != null
              ? _iw4gh6q0.ContractOutputField.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iygdtk1e.CreatorProjectSummary?>()) {
      return (data != null
              ? _iygdtk1e.CreatorProjectSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_irc3xa7s.PythonFieldType?>()) {
      return (data != null ? _irc3xa7s.PythonFieldType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7zdbq5c.ScriptLocation?>()) {
      return (data != null ? _i7zdbq5c.ScriptLocation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2xjf2ew.ScriptRunException?>()) {
      return (data != null ? _i2xjf2ew.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_ikz23b0o.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_ikz23b0o.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_iw4gh6q0.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_iw4gh6q0.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<_iu3gutcn.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_iu3gutcn.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_iywakebc.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_iywakebc.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i4qtshzf.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i4qtshzf.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iawd25jn.ClaimedExecution => 'ClaimedExecution',
      _ivg9lqrn.ComputeClientCredentialInfo => 'ComputeClientCredentialInfo',
      _i0in2gxv.ComputeMode => 'ComputeMode',
      _iife5tw8.ComputeWorkerInfo => 'ComputeWorkerInfo',
      _ipqdvjbs.CreatedComputeClientCredential =>
        'CreatedComputeClientCredential',
      _ibbdejyk.CreatorComputeSettings => 'CreatorComputeSettings',
      _ijgs7z7c.ExecutionAssetRef => 'ExecutionAssetRef',
      _ivda8bev.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i1bow5es.ExecutionKind => 'ExecutionKind',
      _iz3ik4nj.ExecutionOutcome => 'ExecutionOutcome',
      _iakg6oi5.HeartbeatResponse => 'HeartbeatResponse',
      _ixeou3vb.WorkerRegistration => 'WorkerRegistration',
      _isg42qwi.ContractDraft => 'ContractDraft',
      _ikz23b0o.ContractInputField => 'ContractInputField',
      _iw4gh6q0.ContractOutputField => 'ContractOutputField',
      _iygdtk1e.CreatorProjectSummary => 'CreatorProjectSummary',
      _irc3xa7s.PythonFieldType => 'PythonFieldType',
      _i7zdbq5c.ScriptLocation => 'ScriptLocation',
      _i2xjf2ew.ScriptRunException => 'ScriptRunException',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('discoman.', '');
    }

    switch (data) {
      case _iawd25jn.ClaimedExecution():
        return 'ClaimedExecution';
      case _ivg9lqrn.ComputeClientCredentialInfo():
        return 'ComputeClientCredentialInfo';
      case _i0in2gxv.ComputeMode():
        return 'ComputeMode';
      case _iife5tw8.ComputeWorkerInfo():
        return 'ComputeWorkerInfo';
      case _ipqdvjbs.CreatedComputeClientCredential():
        return 'CreatedComputeClientCredential';
      case _ibbdejyk.CreatorComputeSettings():
        return 'CreatorComputeSettings';
      case _ijgs7z7c.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _ivda8bev.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i1bow5es.ExecutionKind():
        return 'ExecutionKind';
      case _iz3ik4nj.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _iakg6oi5.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _ixeou3vb.WorkerRegistration():
        return 'WorkerRegistration';
      case _isg42qwi.ContractDraft():
        return 'ContractDraft';
      case _ikz23b0o.ContractInputField():
        return 'ContractInputField';
      case _iw4gh6q0.ContractOutputField():
        return 'ContractOutputField';
      case _iygdtk1e.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _irc3xa7s.PythonFieldType():
        return 'PythonFieldType';
      case _i7zdbq5c.ScriptLocation():
        return 'ScriptLocation';
      case _i2xjf2ew.ScriptRunException():
        return 'ScriptRunException';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ClaimedExecution') {
      return deserialize<_iawd25jn.ClaimedExecution>(data['data']);
    }
    if (dataClassName == 'ComputeClientCredentialInfo') {
      return deserialize<_ivg9lqrn.ComputeClientCredentialInfo>(data['data']);
    }
    if (dataClassName == 'ComputeMode') {
      return deserialize<_i0in2gxv.ComputeMode>(data['data']);
    }
    if (dataClassName == 'ComputeWorkerInfo') {
      return deserialize<_iife5tw8.ComputeWorkerInfo>(data['data']);
    }
    if (dataClassName == 'CreatedComputeClientCredential') {
      return deserialize<_ipqdvjbs.CreatedComputeClientCredential>(
        data['data'],
      );
    }
    if (dataClassName == 'CreatorComputeSettings') {
      return deserialize<_ibbdejyk.CreatorComputeSettings>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_ijgs7z7c.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_ivda8bev.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i1bow5es.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_iz3ik4nj.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_iakg6oi5.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_ixeou3vb.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_isg42qwi.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_ikz23b0o.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_iw4gh6q0.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_iygdtk1e.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_irc3xa7s.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i7zdbq5c.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i2xjf2ew.ScriptRunException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('discoman', this);
    _iacc.Protocol().registerHostProtocol('discoman', this);
  }

  @override
  String getModuleName() => 'discoman';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
