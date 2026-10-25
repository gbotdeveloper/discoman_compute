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
import 'execution/models/claimed_machine_check.dart' as _i3;
import 'execution/models/compute_client_credential_info.dart' as _i4;
import 'execution/models/compute_mode.dart' as _i7;
import 'execution/models/compute_worker_info.dart' as _i8;
import 'execution/models/created_compute_client_credential.dart' as _i9;
import 'execution/models/creator_compute_settings.dart' as _i10;
import 'execution/models/execution_asset_ref.dart' as _i13;
import 'execution/models/execution_asset_upload.dart' as _i14;
import 'execution/models/execution_asset_upload_request.dart' as _i15;
import 'execution/models/execution_asset_upload_ticket.dart' as _i16;
import 'execution/models/execution_kind.dart' as _i19;
import 'execution/models/execution_outcome.dart' as _i20;
import 'execution/models/execution_status.dart' as _i22;
import 'execution/models/external_code_version.dart' as _i25;
import 'execution/models/heartbeat_response.dart' as _i26;
import 'execution/models/machine_check_result.dart' as _i29;
import 'execution/models/machine_check_script.dart' as _i30;
import 'execution/models/machine_check_status.dart' as _i31;
import 'execution/models/machine_check_view.dart' as _i32;
import 'execution/models/machine_report.dart' as _i33;
import 'execution/models/worker_last_run.dart' as _i35;
import 'execution/models/worker_registration.dart' as _i36;
import 'runtime/contract_draft.dart' as _i38;
import 'runtime/contract_input_field.dart' as _i39;
import 'runtime/contract_output_field.dart' as _i40;
import 'runtime/creator_project_summary.dart' as _i41;
import 'runtime/python_field_type.dart' as _i44;
import 'runtime/script_location.dart' as _i45;
import 'runtime/script_run_exception.dart' as _i46;
import 'runtime/synced_script_info.dart' as _i48;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i49;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i50;
import 'package:discoman_client/src/protocol/execution/models/external_code_version.dart'
    as _i51;
import 'package:discoman_client/src/protocol/runtime/synced_script_info.dart'
    as _i52;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i56;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i58;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i59;
export 'execution/models/claimed_execution.dart';
export 'execution/models/claimed_machine_check.dart';
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
export 'execution/models/execution_status.dart';
export 'execution/models/external_code_version.dart';
export 'execution/models/heartbeat_response.dart';
export 'execution/models/machine_check_result.dart';
export 'execution/models/machine_check_script.dart';
export 'execution/models/machine_check_status.dart';
export 'execution/models/machine_check_view.dart';
export 'execution/models/machine_report.dart';
export 'execution/models/worker_last_run.dart';
export 'execution/models/worker_registration.dart';
export 'runtime/contract_draft.dart';
export 'runtime/contract_input_field.dart';
export 'runtime/contract_output_field.dart';
export 'runtime/creator_project_summary.dart';
export 'runtime/python_field_type.dart';
export 'runtime/script_location.dart';
export 'runtime/script_run_exception.dart';
export 'runtime/synced_script_info.dart';
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
    if (t == _i3.ClaimedMachineCheck) {
      return _i3.ClaimedMachineCheck.fromJson(data) as T;
    }
    if (t == _i4.ComputeClientCredentialInfo) {
      return _i4.ComputeClientCredentialInfo.fromJson(data) as T;
    }
    if (t == _i7.ComputeMode) {
      return _i7.ComputeMode.fromJson(data) as T;
    }
    if (t == _i8.ComputeWorkerInfo) {
      return _i8.ComputeWorkerInfo.fromJson(data) as T;
    }
    if (t == _i9.CreatedComputeClientCredential) {
      return _i9.CreatedComputeClientCredential.fromJson(data) as T;
    }
    if (t == _i10.CreatorComputeSettings) {
      return _i10.CreatorComputeSettings.fromJson(data) as T;
    }
    if (t == _i13.ExecutionAssetRef) {
      return _i13.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _i14.ExecutionAssetUpload) {
      return _i14.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i15.ExecutionAssetUploadRequest) {
      return _i15.ExecutionAssetUploadRequest.fromJson(data) as T;
    }
    if (t == _i16.ExecutionAssetUploadTicket) {
      return _i16.ExecutionAssetUploadTicket.fromJson(data) as T;
    }
    if (t == _i19.ExecutionKind) {
      return _i19.ExecutionKind.fromJson(data) as T;
    }
    if (t == _i20.ExecutionOutcome) {
      return _i20.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _i22.ExecutionStatus) {
      return _i22.ExecutionStatus.fromJson(data) as T;
    }
    if (t == _i25.ExternalCodeVersion) {
      return _i25.ExternalCodeVersion.fromJson(data) as T;
    }
    if (t == _i26.HeartbeatResponse) {
      return _i26.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _i29.MachineCheckResult) {
      return _i29.MachineCheckResult.fromJson(data) as T;
    }
    if (t == _i30.MachineCheckScript) {
      return _i30.MachineCheckScript.fromJson(data) as T;
    }
    if (t == _i31.MachineCheckStatus) {
      return _i31.MachineCheckStatus.fromJson(data) as T;
    }
    if (t == _i32.MachineCheckView) {
      return _i32.MachineCheckView.fromJson(data) as T;
    }
    if (t == _i33.MachineReport) {
      return _i33.MachineReport.fromJson(data) as T;
    }
    if (t == _i35.WorkerLastRun) {
      return _i35.WorkerLastRun.fromJson(data) as T;
    }
    if (t == _i36.WorkerRegistration) {
      return _i36.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _i38.ContractDraft) {
      return _i38.ContractDraft.fromJson(data) as T;
    }
    if (t == _i39.ContractInputField) {
      return _i39.ContractInputField.fromJson(data) as T;
    }
    if (t == _i40.ContractOutputField) {
      return _i40.ContractOutputField.fromJson(data) as T;
    }
    if (t == _i41.CreatorProjectSummary) {
      return _i41.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _i44.PythonFieldType) {
      return _i44.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i45.ScriptLocation) {
      return _i45.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i46.ScriptRunException) {
      return _i46.ScriptRunException.fromJson(data) as T;
    }
    if (t == _i48.SyncedScriptInfo) {
      return _i48.SyncedScriptInfo.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ClaimedExecution?>()) {
      return (data != null ? _i2.ClaimedExecution.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ClaimedMachineCheck?>()) {
      return (data != null ? _i3.ClaimedMachineCheck.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.ComputeClientCredentialInfo?>()) {
      return (data != null
              ? _i4.ComputeClientCredentialInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.ComputeMode?>()) {
      return (data != null ? _i7.ComputeMode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ComputeWorkerInfo?>()) {
      return (data != null ? _i8.ComputeWorkerInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CreatedComputeClientCredential?>()) {
      return (data != null
              ? _i9.CreatedComputeClientCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i10.CreatorComputeSettings?>()) {
      return (data != null ? _i10.CreatorComputeSettings.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.ExecutionAssetRef?>()) {
      return (data != null ? _i13.ExecutionAssetRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ExecutionAssetUpload?>()) {
      return (data != null ? _i14.ExecutionAssetUpload.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.ExecutionAssetUploadRequest?>()) {
      return (data != null
              ? _i15.ExecutionAssetUploadRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.ExecutionAssetUploadTicket?>()) {
      return (data != null
              ? _i16.ExecutionAssetUploadTicket.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.ExecutionKind?>()) {
      return (data != null ? _i19.ExecutionKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ExecutionOutcome?>()) {
      return (data != null ? _i20.ExecutionOutcome.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.ExecutionStatus?>()) {
      return (data != null ? _i22.ExecutionStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ExternalCodeVersion?>()) {
      return (data != null ? _i25.ExternalCodeVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.HeartbeatResponse?>()) {
      return (data != null ? _i26.HeartbeatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.MachineCheckResult?>()) {
      return (data != null ? _i29.MachineCheckResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.MachineCheckScript?>()) {
      return (data != null ? _i30.MachineCheckScript.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.MachineCheckStatus?>()) {
      return (data != null ? _i31.MachineCheckStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.MachineCheckView?>()) {
      return (data != null ? _i32.MachineCheckView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.MachineReport?>()) {
      return (data != null ? _i33.MachineReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.WorkerLastRun?>()) {
      return (data != null ? _i35.WorkerLastRun.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.WorkerRegistration?>()) {
      return (data != null ? _i36.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i38.ContractDraft?>()) {
      return (data != null ? _i38.ContractDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.ContractInputField?>()) {
      return (data != null ? _i39.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.ContractOutputField?>()) {
      return (data != null ? _i40.ContractOutputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i41.CreatorProjectSummary?>()) {
      return (data != null ? _i41.CreatorProjectSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i44.PythonFieldType?>()) {
      return (data != null ? _i44.PythonFieldType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ScriptLocation?>()) {
      return (data != null ? _i45.ScriptLocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.ScriptRunException?>()) {
      return (data != null ? _i46.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i48.SyncedScriptInfo?>()) {
      return (data != null ? _i48.SyncedScriptInfo.fromJson(data) : null) as T;
    }
    if (t == Map<String, String?>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String?>(v)),
          )
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i25.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i25.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i25.ExternalCodeVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i25.ExternalCodeVersion>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i22.ExecutionStatus>) {
      return (data as List)
              .map((e) => deserialize<_i22.ExecutionStatus>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i22.ExecutionStatus>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i22.ExecutionStatus>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i30.MachineCheckScript>) {
      return (data as List)
              .map((e) => deserialize<_i30.MachineCheckScript>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_i39.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_i40.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i49.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_i49.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i50.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_i50.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i51.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i51.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i52.SyncedScriptInfo>) {
      return (data as List)
              .map((e) => deserialize<_i52.SyncedScriptInfo>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i56.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i56.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    try {
      return _i58.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i59.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ClaimedExecution => 'ClaimedExecution',
      _i3.ClaimedMachineCheck => 'ClaimedMachineCheck',
      _i4.ComputeClientCredentialInfo => 'ComputeClientCredentialInfo',
      _i7.ComputeMode => 'ComputeMode',
      _i8.ComputeWorkerInfo => 'ComputeWorkerInfo',
      _i9.CreatedComputeClientCredential => 'CreatedComputeClientCredential',
      _i10.CreatorComputeSettings => 'CreatorComputeSettings',
      _i13.ExecutionAssetRef => 'ExecutionAssetRef',
      _i14.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i15.ExecutionAssetUploadRequest => 'ExecutionAssetUploadRequest',
      _i16.ExecutionAssetUploadTicket => 'ExecutionAssetUploadTicket',
      _i19.ExecutionKind => 'ExecutionKind',
      _i20.ExecutionOutcome => 'ExecutionOutcome',
      _i22.ExecutionStatus => 'ExecutionStatus',
      _i25.ExternalCodeVersion => 'ExternalCodeVersion',
      _i26.HeartbeatResponse => 'HeartbeatResponse',
      _i29.MachineCheckResult => 'MachineCheckResult',
      _i30.MachineCheckScript => 'MachineCheckScript',
      _i31.MachineCheckStatus => 'MachineCheckStatus',
      _i32.MachineCheckView => 'MachineCheckView',
      _i33.MachineReport => 'MachineReport',
      _i35.WorkerLastRun => 'WorkerLastRun',
      _i36.WorkerRegistration => 'WorkerRegistration',
      _i38.ContractDraft => 'ContractDraft',
      _i39.ContractInputField => 'ContractInputField',
      _i40.ContractOutputField => 'ContractOutputField',
      _i41.CreatorProjectSummary => 'CreatorProjectSummary',
      _i44.PythonFieldType => 'PythonFieldType',
      _i45.ScriptLocation => 'ScriptLocation',
      _i46.ScriptRunException => 'ScriptRunException',
      _i48.SyncedScriptInfo => 'SyncedScriptInfo',
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
      case _i3.ClaimedMachineCheck():
        return 'ClaimedMachineCheck';
      case _i4.ComputeClientCredentialInfo():
        return 'ComputeClientCredentialInfo';
      case _i7.ComputeMode():
        return 'ComputeMode';
      case _i8.ComputeWorkerInfo():
        return 'ComputeWorkerInfo';
      case _i9.CreatedComputeClientCredential():
        return 'CreatedComputeClientCredential';
      case _i10.CreatorComputeSettings():
        return 'CreatorComputeSettings';
      case _i13.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _i14.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i15.ExecutionAssetUploadRequest():
        return 'ExecutionAssetUploadRequest';
      case _i16.ExecutionAssetUploadTicket():
        return 'ExecutionAssetUploadTicket';
      case _i19.ExecutionKind():
        return 'ExecutionKind';
      case _i20.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _i22.ExecutionStatus():
        return 'ExecutionStatus';
      case _i25.ExternalCodeVersion():
        return 'ExternalCodeVersion';
      case _i26.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _i29.MachineCheckResult():
        return 'MachineCheckResult';
      case _i30.MachineCheckScript():
        return 'MachineCheckScript';
      case _i31.MachineCheckStatus():
        return 'MachineCheckStatus';
      case _i32.MachineCheckView():
        return 'MachineCheckView';
      case _i33.MachineReport():
        return 'MachineReport';
      case _i35.WorkerLastRun():
        return 'WorkerLastRun';
      case _i36.WorkerRegistration():
        return 'WorkerRegistration';
      case _i38.ContractDraft():
        return 'ContractDraft';
      case _i39.ContractInputField():
        return 'ContractInputField';
      case _i40.ContractOutputField():
        return 'ContractOutputField';
      case _i41.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _i44.PythonFieldType():
        return 'PythonFieldType';
      case _i45.ScriptLocation():
        return 'ScriptLocation';
      case _i46.ScriptRunException():
        return 'ScriptRunException';
      case _i48.SyncedScriptInfo():
        return 'SyncedScriptInfo';
    }
    className = _i58.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i59.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'ClaimedMachineCheck') {
      return deserialize<_i3.ClaimedMachineCheck>(data['data']);
    }
    if (dataClassName == 'ComputeClientCredentialInfo') {
      return deserialize<_i4.ComputeClientCredentialInfo>(data['data']);
    }
    if (dataClassName == 'ComputeMode') {
      return deserialize<_i7.ComputeMode>(data['data']);
    }
    if (dataClassName == 'ComputeWorkerInfo') {
      return deserialize<_i8.ComputeWorkerInfo>(data['data']);
    }
    if (dataClassName == 'CreatedComputeClientCredential') {
      return deserialize<_i9.CreatedComputeClientCredential>(data['data']);
    }
    if (dataClassName == 'CreatorComputeSettings') {
      return deserialize<_i10.CreatorComputeSettings>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_i13.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_i14.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadRequest') {
      return deserialize<_i15.ExecutionAssetUploadRequest>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadTicket') {
      return deserialize<_i16.ExecutionAssetUploadTicket>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i19.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_i20.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'ExecutionStatus') {
      return deserialize<_i22.ExecutionStatus>(data['data']);
    }
    if (dataClassName == 'ExternalCodeVersion') {
      return deserialize<_i25.ExternalCodeVersion>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_i26.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'MachineCheckResult') {
      return deserialize<_i29.MachineCheckResult>(data['data']);
    }
    if (dataClassName == 'MachineCheckScript') {
      return deserialize<_i30.MachineCheckScript>(data['data']);
    }
    if (dataClassName == 'MachineCheckStatus') {
      return deserialize<_i31.MachineCheckStatus>(data['data']);
    }
    if (dataClassName == 'MachineCheckView') {
      return deserialize<_i32.MachineCheckView>(data['data']);
    }
    if (dataClassName == 'MachineReport') {
      return deserialize<_i33.MachineReport>(data['data']);
    }
    if (dataClassName == 'WorkerLastRun') {
      return deserialize<_i35.WorkerLastRun>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_i36.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_i38.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_i39.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_i40.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_i41.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_i44.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i45.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i46.ScriptRunException>(data['data']);
    }
    if (dataClassName == 'SyncedScriptInfo') {
      return deserialize<_i48.SyncedScriptInfo>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i58.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i59.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i58.Protocol().registerHostProtocol('discoman', this);
    _i59.Protocol().registerHostProtocol('discoman', this);
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
      return _i58.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i59.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
