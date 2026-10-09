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
import 'execution/models/claimed_execution.dart' as _i2;
import 'execution/models/compute_client_credential_info.dart' as _i3;
import 'execution/models/compute_mode.dart' as _i4;
import 'execution/models/compute_worker_info.dart' as _i5;
import 'execution/models/created_compute_client_credential.dart' as _i6;
import 'execution/models/creator_compute_settings.dart' as _i7;
import 'execution/models/execution_asset_ref.dart' as _i10;
import 'execution/models/execution_asset_upload.dart' as _i11;
import 'execution/models/execution_asset_upload_request.dart' as _i12;
import 'execution/models/execution_asset_upload_ticket.dart' as _i13;
import 'execution/models/execution_kind.dart' as _i16;
import 'execution/models/execution_outcome.dart' as _i17;
import 'execution/models/heartbeat_response.dart' as _i22;
import 'execution/models/worker_registration.dart' as _i26;
import 'runtime/contract_draft.dart' as _i28;
import 'runtime/contract_input_field.dart' as _i29;
import 'runtime/contract_output_field.dart' as _i30;
import 'runtime/creator_project_summary.dart' as _i31;
import 'runtime/python_field_type.dart' as _i34;
import 'runtime/script_location.dart' as _i35;
import 'runtime/script_run_exception.dart' as _i36;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i38;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i39;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i43;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i45;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i46;
export 'execution/models/claimed_execution.dart';
export 'execution/models/compute_client_credential_info.dart';
export 'execution/models/compute_mode.dart';
export 'execution/models/compute_worker_info.dart';
export 'execution/models/created_compute_client_credential.dart';
export 'execution/models/creator_compute_settings.dart';
export 'execution/models/execution_asset_ref.dart';
export 'execution/models/execution_asset_upload.dart';
export 'execution/models/execution_asset_upload_request.dart';
export 'execution/models/execution_asset_upload_ticket.dart';
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

class Protocol extends _i1.SerializationManager {
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
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ClaimedExecution) {
      return _i2.ClaimedExecution.fromJson(data) as T;
    }
    if (t == _i3.ComputeClientCredentialInfo) {
      return _i3.ComputeClientCredentialInfo.fromJson(data) as T;
    }
    if (t == _i4.ComputeMode) {
      return _i4.ComputeMode.fromJson(data) as T;
    }
    if (t == _i5.ComputeWorkerInfo) {
      return _i5.ComputeWorkerInfo.fromJson(data) as T;
    }
    if (t == _i6.CreatedComputeClientCredential) {
      return _i6.CreatedComputeClientCredential.fromJson(data) as T;
    }
    if (t == _i7.CreatorComputeSettings) {
      return _i7.CreatorComputeSettings.fromJson(data) as T;
    }
    if (t == _i10.ExecutionAssetRef) {
      return _i10.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _i11.ExecutionAssetUpload) {
      return _i11.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i12.ExecutionAssetUploadRequest) {
      return _i12.ExecutionAssetUploadRequest.fromJson(data) as T;
    }
    if (t == _i13.ExecutionAssetUploadTicket) {
      return _i13.ExecutionAssetUploadTicket.fromJson(data) as T;
    }
    if (t == _i16.ExecutionKind) {
      return _i16.ExecutionKind.fromJson(data) as T;
    }
    if (t == _i17.ExecutionOutcome) {
      return _i17.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _i22.HeartbeatResponse) {
      return _i22.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _i26.WorkerRegistration) {
      return _i26.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _i28.ContractDraft) {
      return _i28.ContractDraft.fromJson(data) as T;
    }
    if (t == _i29.ContractInputField) {
      return _i29.ContractInputField.fromJson(data) as T;
    }
    if (t == _i30.ContractOutputField) {
      return _i30.ContractOutputField.fromJson(data) as T;
    }
    if (t == _i31.CreatorProjectSummary) {
      return _i31.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _i34.PythonFieldType) {
      return _i34.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i35.ScriptLocation) {
      return _i35.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i36.ScriptRunException) {
      return _i36.ScriptRunException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ClaimedExecution?>()) {
      return (data != null ? _i2.ClaimedExecution.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ComputeClientCredentialInfo?>()) {
      return (data != null
              ? _i3.ComputeClientCredentialInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i4.ComputeMode?>()) {
      return (data != null ? _i4.ComputeMode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ComputeWorkerInfo?>()) {
      return (data != null ? _i5.ComputeWorkerInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CreatedComputeClientCredential?>()) {
      return (data != null
              ? _i6.CreatedComputeClientCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.CreatorComputeSettings?>()) {
      return (data != null ? _i7.CreatorComputeSettings.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.ExecutionAssetRef?>()) {
      return (data != null ? _i10.ExecutionAssetRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ExecutionAssetUpload?>()) {
      return (data != null ? _i11.ExecutionAssetUpload.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ExecutionAssetUploadRequest?>()) {
      return (data != null
              ? _i12.ExecutionAssetUploadRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i13.ExecutionAssetUploadTicket?>()) {
      return (data != null
              ? _i13.ExecutionAssetUploadTicket.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.ExecutionKind?>()) {
      return (data != null ? _i16.ExecutionKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ExecutionOutcome?>()) {
      return (data != null ? _i17.ExecutionOutcome.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.HeartbeatResponse?>()) {
      return (data != null ? _i22.HeartbeatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.WorkerRegistration?>()) {
      return (data != null ? _i26.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.ContractDraft?>()) {
      return (data != null ? _i28.ContractDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.ContractInputField?>()) {
      return (data != null ? _i29.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.ContractOutputField?>()) {
      return (data != null ? _i30.ContractOutputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.CreatorProjectSummary?>()) {
      return (data != null ? _i31.CreatorProjectSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.PythonFieldType?>()) {
      return (data != null ? _i34.PythonFieldType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.ScriptLocation?>()) {
      return (data != null ? _i35.ScriptLocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.ScriptRunException?>()) {
      return (data != null ? _i36.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i29.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_i29.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_i30.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i38.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_i38.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_i39.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i43.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i43.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    try {
      return _i45.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i46.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ClaimedExecution => 'ClaimedExecution',
      _i3.ComputeClientCredentialInfo => 'ComputeClientCredentialInfo',
      _i4.ComputeMode => 'ComputeMode',
      _i5.ComputeWorkerInfo => 'ComputeWorkerInfo',
      _i6.CreatedComputeClientCredential => 'CreatedComputeClientCredential',
      _i7.CreatorComputeSettings => 'CreatorComputeSettings',
      _i10.ExecutionAssetRef => 'ExecutionAssetRef',
      _i11.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i12.ExecutionAssetUploadRequest => 'ExecutionAssetUploadRequest',
      _i13.ExecutionAssetUploadTicket => 'ExecutionAssetUploadTicket',
      _i16.ExecutionKind => 'ExecutionKind',
      _i17.ExecutionOutcome => 'ExecutionOutcome',
      _i22.HeartbeatResponse => 'HeartbeatResponse',
      _i26.WorkerRegistration => 'WorkerRegistration',
      _i28.ContractDraft => 'ContractDraft',
      _i29.ContractInputField => 'ContractInputField',
      _i30.ContractOutputField => 'ContractOutputField',
      _i31.CreatorProjectSummary => 'CreatorProjectSummary',
      _i34.PythonFieldType => 'PythonFieldType',
      _i35.ScriptLocation => 'ScriptLocation',
      _i36.ScriptRunException => 'ScriptRunException',
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
      case _i2.ClaimedExecution():
        return 'ClaimedExecution';
      case _i3.ComputeClientCredentialInfo():
        return 'ComputeClientCredentialInfo';
      case _i4.ComputeMode():
        return 'ComputeMode';
      case _i5.ComputeWorkerInfo():
        return 'ComputeWorkerInfo';
      case _i6.CreatedComputeClientCredential():
        return 'CreatedComputeClientCredential';
      case _i7.CreatorComputeSettings():
        return 'CreatorComputeSettings';
      case _i10.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _i11.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i12.ExecutionAssetUploadRequest():
        return 'ExecutionAssetUploadRequest';
      case _i13.ExecutionAssetUploadTicket():
        return 'ExecutionAssetUploadTicket';
      case _i16.ExecutionKind():
        return 'ExecutionKind';
      case _i17.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _i22.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _i26.WorkerRegistration():
        return 'WorkerRegistration';
      case _i28.ContractDraft():
        return 'ContractDraft';
      case _i29.ContractInputField():
        return 'ContractInputField';
      case _i30.ContractOutputField():
        return 'ContractOutputField';
      case _i31.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _i34.PythonFieldType():
        return 'PythonFieldType';
      case _i35.ScriptLocation():
        return 'ScriptLocation';
      case _i36.ScriptRunException():
        return 'ScriptRunException';
    }
    className = _i45.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i46.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.ClaimedExecution>(data['data']);
    }
    if (dataClassName == 'ComputeClientCredentialInfo') {
      return deserialize<_i3.ComputeClientCredentialInfo>(data['data']);
    }
    if (dataClassName == 'ComputeMode') {
      return deserialize<_i4.ComputeMode>(data['data']);
    }
    if (dataClassName == 'ComputeWorkerInfo') {
      return deserialize<_i5.ComputeWorkerInfo>(data['data']);
    }
    if (dataClassName == 'CreatedComputeClientCredential') {
      return deserialize<_i6.CreatedComputeClientCredential>(data['data']);
    }
    if (dataClassName == 'CreatorComputeSettings') {
      return deserialize<_i7.CreatorComputeSettings>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_i10.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_i11.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadRequest') {
      return deserialize<_i12.ExecutionAssetUploadRequest>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadTicket') {
      return deserialize<_i13.ExecutionAssetUploadTicket>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i16.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_i17.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_i22.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_i26.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_i28.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_i29.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_i30.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_i31.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_i34.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i35.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i36.ScriptRunException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i45.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i46.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i45.Protocol().registerHostProtocol('discoman', this);
    _i46.Protocol().registerHostProtocol('discoman', this);
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
      return _i45.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i46.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
