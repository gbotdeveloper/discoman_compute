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
import 'execution/models/compute_mode.dart' as _i8;
import 'execution/models/compute_worker_info.dart' as _i9;
import 'execution/models/created_compute_client_credential.dart' as _i10;
import 'execution/models/creator_compute_settings.dart' as _i11;
import 'execution/models/execution_asset_ref.dart' as _i14;
import 'execution/models/execution_asset_upload.dart' as _i15;
import 'execution/models/execution_asset_upload_request.dart' as _i16;
import 'execution/models/execution_asset_upload_ticket.dart' as _i17;
import 'execution/models/execution_kind.dart' as _i20;
import 'execution/models/execution_outcome.dart' as _i21;
import 'execution/models/execution_status.dart' as _i23;
import 'execution/models/external_code_version.dart' as _i26;
import 'execution/models/heartbeat_response.dart' as _i27;
import 'execution/models/machine_check_result.dart' as _i30;
import 'execution/models/machine_check_script.dart' as _i31;
import 'execution/models/machine_check_status.dart' as _i32;
import 'execution/models/machine_check_view.dart' as _i33;
import 'execution/models/machine_report.dart' as _i34;
import 'execution/models/wake_channel.dart' as _i36;
import 'execution/models/worker_last_run.dart' as _i37;
import 'execution/models/worker_registration.dart' as _i38;
import 'runtime/contract_draft.dart' as _i42;
import 'runtime/contract_input_field.dart' as _i43;
import 'runtime/contract_output_field.dart' as _i44;
import 'runtime/creator_project_summary.dart' as _i45;
import 'runtime/python_field_type.dart' as _i62;
import 'runtime/script_location.dart' as _i63;
import 'runtime/script_run_exception.dart' as _i64;
import 'runtime/synced_script_info.dart' as _i67;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i71;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i72;
import 'package:discoman_client/src/protocol/execution/models/external_code_version.dart'
    as _i73;
import 'package:discoman_client/src/protocol/runtime/synced_script_info.dart'
    as _i74;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i78;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i82;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i83;
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
export 'execution/models/wake_channel.dart';
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
    if (t == _i8.ComputeMode) {
      return _i8.ComputeMode.fromJson(data) as T;
    }
    if (t == _i9.ComputeWorkerInfo) {
      return _i9.ComputeWorkerInfo.fromJson(data) as T;
    }
    if (t == _i10.CreatedComputeClientCredential) {
      return _i10.CreatedComputeClientCredential.fromJson(data) as T;
    }
    if (t == _i11.CreatorComputeSettings) {
      return _i11.CreatorComputeSettings.fromJson(data) as T;
    }
    if (t == _i14.ExecutionAssetRef) {
      return _i14.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _i15.ExecutionAssetUpload) {
      return _i15.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i16.ExecutionAssetUploadRequest) {
      return _i16.ExecutionAssetUploadRequest.fromJson(data) as T;
    }
    if (t == _i17.ExecutionAssetUploadTicket) {
      return _i17.ExecutionAssetUploadTicket.fromJson(data) as T;
    }
    if (t == _i20.ExecutionKind) {
      return _i20.ExecutionKind.fromJson(data) as T;
    }
    if (t == _i21.ExecutionOutcome) {
      return _i21.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _i23.ExecutionStatus) {
      return _i23.ExecutionStatus.fromJson(data) as T;
    }
    if (t == _i26.ExternalCodeVersion) {
      return _i26.ExternalCodeVersion.fromJson(data) as T;
    }
    if (t == _i27.HeartbeatResponse) {
      return _i27.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _i30.MachineCheckResult) {
      return _i30.MachineCheckResult.fromJson(data) as T;
    }
    if (t == _i31.MachineCheckScript) {
      return _i31.MachineCheckScript.fromJson(data) as T;
    }
    if (t == _i32.MachineCheckStatus) {
      return _i32.MachineCheckStatus.fromJson(data) as T;
    }
    if (t == _i33.MachineCheckView) {
      return _i33.MachineCheckView.fromJson(data) as T;
    }
    if (t == _i34.MachineReport) {
      return _i34.MachineReport.fromJson(data) as T;
    }
    if (t == _i36.WakeChannel) {
      return _i36.WakeChannel.fromJson(data) as T;
    }
    if (t == _i37.WorkerLastRun) {
      return _i37.WorkerLastRun.fromJson(data) as T;
    }
    if (t == _i38.WorkerRegistration) {
      return _i38.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _i42.ContractDraft) {
      return _i42.ContractDraft.fromJson(data) as T;
    }
    if (t == _i43.ContractInputField) {
      return _i43.ContractInputField.fromJson(data) as T;
    }
    if (t == _i44.ContractOutputField) {
      return _i44.ContractOutputField.fromJson(data) as T;
    }
    if (t == _i45.CreatorProjectSummary) {
      return _i45.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _i62.PythonFieldType) {
      return _i62.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i63.ScriptLocation) {
      return _i63.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i64.ScriptRunException) {
      return _i64.ScriptRunException.fromJson(data) as T;
    }
    if (t == _i67.SyncedScriptInfo) {
      return _i67.SyncedScriptInfo.fromJson(data) as T;
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
    if (t == _i1.getType<_i8.ComputeMode?>()) {
      return (data != null ? _i8.ComputeMode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ComputeWorkerInfo?>()) {
      return (data != null ? _i9.ComputeWorkerInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CreatedComputeClientCredential?>()) {
      return (data != null
              ? _i10.CreatedComputeClientCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.CreatorComputeSettings?>()) {
      return (data != null ? _i11.CreatorComputeSettings.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.ExecutionAssetRef?>()) {
      return (data != null ? _i14.ExecutionAssetRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ExecutionAssetUpload?>()) {
      return (data != null ? _i15.ExecutionAssetUpload.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.ExecutionAssetUploadRequest?>()) {
      return (data != null
              ? _i16.ExecutionAssetUploadRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i17.ExecutionAssetUploadTicket?>()) {
      return (data != null
              ? _i17.ExecutionAssetUploadTicket.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.ExecutionKind?>()) {
      return (data != null ? _i20.ExecutionKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.ExecutionOutcome?>()) {
      return (data != null ? _i21.ExecutionOutcome.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.ExecutionStatus?>()) {
      return (data != null ? _i23.ExecutionStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.ExternalCodeVersion?>()) {
      return (data != null ? _i26.ExternalCodeVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.HeartbeatResponse?>()) {
      return (data != null ? _i27.HeartbeatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.MachineCheckResult?>()) {
      return (data != null ? _i30.MachineCheckResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.MachineCheckScript?>()) {
      return (data != null ? _i31.MachineCheckScript.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.MachineCheckStatus?>()) {
      return (data != null ? _i32.MachineCheckStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.MachineCheckView?>()) {
      return (data != null ? _i33.MachineCheckView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.MachineReport?>()) {
      return (data != null ? _i34.MachineReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.WakeChannel?>()) {
      return (data != null ? _i36.WakeChannel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.WorkerLastRun?>()) {
      return (data != null ? _i37.WorkerLastRun.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.WorkerRegistration?>()) {
      return (data != null ? _i38.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.ContractDraft?>()) {
      return (data != null ? _i42.ContractDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.ContractInputField?>()) {
      return (data != null ? _i43.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i44.ContractOutputField?>()) {
      return (data != null ? _i44.ContractOutputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i45.CreatorProjectSummary?>()) {
      return (data != null ? _i45.CreatorProjectSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i62.PythonFieldType?>()) {
      return (data != null ? _i62.PythonFieldType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i63.ScriptLocation?>()) {
      return (data != null ? _i63.ScriptLocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i64.ScriptRunException?>()) {
      return (data != null ? _i64.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i67.SyncedScriptInfo?>()) {
      return (data != null ? _i67.SyncedScriptInfo.fromJson(data) : null) as T;
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
    if (t == List<_i26.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i26.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i26.ExternalCodeVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i26.ExternalCodeVersion>(e))
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
    if (t == List<_i23.ExecutionStatus>) {
      return (data as List)
              .map((e) => deserialize<_i23.ExecutionStatus>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i23.ExecutionStatus>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i23.ExecutionStatus>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i31.MachineCheckScript>) {
      return (data as List)
              .map((e) => deserialize<_i31.MachineCheckScript>(e))
              .toList()
          as T;
    }
    if (t == List<_i43.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_i43.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i44.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_i44.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i71.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_i71.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i72.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_i72.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i73.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i73.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i74.SyncedScriptInfo>) {
      return (data as List)
              .map((e) => deserialize<_i74.SyncedScriptInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i78.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i78.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    try {
      return _i82.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i83.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ClaimedExecution => 'ClaimedExecution',
      _i3.ClaimedMachineCheck => 'ClaimedMachineCheck',
      _i4.ComputeClientCredentialInfo => 'ComputeClientCredentialInfo',
      _i8.ComputeMode => 'ComputeMode',
      _i9.ComputeWorkerInfo => 'ComputeWorkerInfo',
      _i10.CreatedComputeClientCredential => 'CreatedComputeClientCredential',
      _i11.CreatorComputeSettings => 'CreatorComputeSettings',
      _i14.ExecutionAssetRef => 'ExecutionAssetRef',
      _i15.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i16.ExecutionAssetUploadRequest => 'ExecutionAssetUploadRequest',
      _i17.ExecutionAssetUploadTicket => 'ExecutionAssetUploadTicket',
      _i20.ExecutionKind => 'ExecutionKind',
      _i21.ExecutionOutcome => 'ExecutionOutcome',
      _i23.ExecutionStatus => 'ExecutionStatus',
      _i26.ExternalCodeVersion => 'ExternalCodeVersion',
      _i27.HeartbeatResponse => 'HeartbeatResponse',
      _i30.MachineCheckResult => 'MachineCheckResult',
      _i31.MachineCheckScript => 'MachineCheckScript',
      _i32.MachineCheckStatus => 'MachineCheckStatus',
      _i33.MachineCheckView => 'MachineCheckView',
      _i34.MachineReport => 'MachineReport',
      _i36.WakeChannel => 'WakeChannel',
      _i37.WorkerLastRun => 'WorkerLastRun',
      _i38.WorkerRegistration => 'WorkerRegistration',
      _i42.ContractDraft => 'ContractDraft',
      _i43.ContractInputField => 'ContractInputField',
      _i44.ContractOutputField => 'ContractOutputField',
      _i45.CreatorProjectSummary => 'CreatorProjectSummary',
      _i62.PythonFieldType => 'PythonFieldType',
      _i63.ScriptLocation => 'ScriptLocation',
      _i64.ScriptRunException => 'ScriptRunException',
      _i67.SyncedScriptInfo => 'SyncedScriptInfo',
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
      case _i8.ComputeMode():
        return 'ComputeMode';
      case _i9.ComputeWorkerInfo():
        return 'ComputeWorkerInfo';
      case _i10.CreatedComputeClientCredential():
        return 'CreatedComputeClientCredential';
      case _i11.CreatorComputeSettings():
        return 'CreatorComputeSettings';
      case _i14.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _i15.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i16.ExecutionAssetUploadRequest():
        return 'ExecutionAssetUploadRequest';
      case _i17.ExecutionAssetUploadTicket():
        return 'ExecutionAssetUploadTicket';
      case _i20.ExecutionKind():
        return 'ExecutionKind';
      case _i21.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _i23.ExecutionStatus():
        return 'ExecutionStatus';
      case _i26.ExternalCodeVersion():
        return 'ExternalCodeVersion';
      case _i27.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _i30.MachineCheckResult():
        return 'MachineCheckResult';
      case _i31.MachineCheckScript():
        return 'MachineCheckScript';
      case _i32.MachineCheckStatus():
        return 'MachineCheckStatus';
      case _i33.MachineCheckView():
        return 'MachineCheckView';
      case _i34.MachineReport():
        return 'MachineReport';
      case _i36.WakeChannel():
        return 'WakeChannel';
      case _i37.WorkerLastRun():
        return 'WorkerLastRun';
      case _i38.WorkerRegistration():
        return 'WorkerRegistration';
      case _i42.ContractDraft():
        return 'ContractDraft';
      case _i43.ContractInputField():
        return 'ContractInputField';
      case _i44.ContractOutputField():
        return 'ContractOutputField';
      case _i45.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _i62.PythonFieldType():
        return 'PythonFieldType';
      case _i63.ScriptLocation():
        return 'ScriptLocation';
      case _i64.ScriptRunException():
        return 'ScriptRunException';
      case _i67.SyncedScriptInfo():
        return 'SyncedScriptInfo';
    }
    className = _i82.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i83.Protocol().getClassNameForObject(data);
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
      return deserialize<_i8.ComputeMode>(data['data']);
    }
    if (dataClassName == 'ComputeWorkerInfo') {
      return deserialize<_i9.ComputeWorkerInfo>(data['data']);
    }
    if (dataClassName == 'CreatedComputeClientCredential') {
      return deserialize<_i10.CreatedComputeClientCredential>(data['data']);
    }
    if (dataClassName == 'CreatorComputeSettings') {
      return deserialize<_i11.CreatorComputeSettings>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_i14.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_i15.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadRequest') {
      return deserialize<_i16.ExecutionAssetUploadRequest>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadTicket') {
      return deserialize<_i17.ExecutionAssetUploadTicket>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i20.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_i21.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'ExecutionStatus') {
      return deserialize<_i23.ExecutionStatus>(data['data']);
    }
    if (dataClassName == 'ExternalCodeVersion') {
      return deserialize<_i26.ExternalCodeVersion>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_i27.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'MachineCheckResult') {
      return deserialize<_i30.MachineCheckResult>(data['data']);
    }
    if (dataClassName == 'MachineCheckScript') {
      return deserialize<_i31.MachineCheckScript>(data['data']);
    }
    if (dataClassName == 'MachineCheckStatus') {
      return deserialize<_i32.MachineCheckStatus>(data['data']);
    }
    if (dataClassName == 'MachineCheckView') {
      return deserialize<_i33.MachineCheckView>(data['data']);
    }
    if (dataClassName == 'MachineReport') {
      return deserialize<_i34.MachineReport>(data['data']);
    }
    if (dataClassName == 'WakeChannel') {
      return deserialize<_i36.WakeChannel>(data['data']);
    }
    if (dataClassName == 'WorkerLastRun') {
      return deserialize<_i37.WorkerLastRun>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_i38.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_i42.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_i43.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_i44.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_i45.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_i62.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i63.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i64.ScriptRunException>(data['data']);
    }
    if (dataClassName == 'SyncedScriptInfo') {
      return deserialize<_i67.SyncedScriptInfo>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i82.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i83.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i82.Protocol().registerHostProtocol('discoman', this);
    _i83.Protocol().registerHostProtocol('discoman', this);
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
      return _i82.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i83.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
