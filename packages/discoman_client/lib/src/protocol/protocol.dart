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
import 'auth/models/device_sign_in_request.dart' as _i2;
import 'auth/models/device_sign_in_start.dart' as _i3;
import 'execution/models/claimed_execution.dart' as _i4;
import 'execution/models/claimed_machine_check.dart' as _i5;
import 'execution/models/compute_client_credential_info.dart' as _i6;
import 'execution/models/compute_mode.dart' as _i10;
import 'execution/models/compute_worker_info.dart' as _i11;
import 'execution/models/created_compute_client_credential.dart' as _i12;
import 'execution/models/creator_compute_settings.dart' as _i13;
import 'execution/models/execution_asset_ref.dart' as _i16;
import 'execution/models/execution_asset_upload.dart' as _i17;
import 'execution/models/execution_asset_upload_request.dart' as _i18;
import 'execution/models/execution_asset_upload_ticket.dart' as _i19;
import 'execution/models/execution_kind.dart' as _i22;
import 'execution/models/execution_outcome.dart' as _i23;
import 'execution/models/execution_status.dart' as _i25;
import 'execution/models/external_code_version.dart' as _i28;
import 'execution/models/heartbeat_response.dart' as _i29;
import 'execution/models/machine_check_result.dart' as _i32;
import 'execution/models/machine_check_script.dart' as _i33;
import 'execution/models/machine_check_status.dart' as _i34;
import 'execution/models/machine_check_view.dart' as _i35;
import 'execution/models/machine_report.dart' as _i36;
import 'execution/models/wake_channel.dart' as _i38;
import 'execution/models/worker_last_run.dart' as _i39;
import 'execution/models/worker_registration.dart' as _i40;
import 'runtime/account_info.dart' as _i42;
import 'runtime/contract_draft.dart' as _i44;
import 'runtime/contract_input_field.dart' as _i45;
import 'runtime/contract_output_field.dart' as _i46;
import 'runtime/creator_project_summary.dart' as _i47;
import 'runtime/python_field_type.dart' as _i64;
import 'runtime/script_location.dart' as _i65;
import 'runtime/script_run_exception.dart' as _i66;
import 'runtime/synced_script_info.dart' as _i69;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i73;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i74;
import 'package:discoman_client/src/protocol/execution/models/external_code_version.dart'
    as _i75;
import 'package:discoman_client/src/protocol/runtime/synced_script_info.dart'
    as _i76;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i80;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i84;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i85;
export 'auth/models/device_sign_in_request.dart';
export 'auth/models/device_sign_in_start.dart';
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
export 'runtime/account_info.dart';
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

    if (t == _i2.DeviceSignInRequest) {
      return _i2.DeviceSignInRequest.fromJson(data) as T;
    }
    if (t == _i3.DeviceSignInStart) {
      return _i3.DeviceSignInStart.fromJson(data) as T;
    }
    if (t == _i4.ClaimedExecution) {
      return _i4.ClaimedExecution.fromJson(data) as T;
    }
    if (t == _i5.ClaimedMachineCheck) {
      return _i5.ClaimedMachineCheck.fromJson(data) as T;
    }
    if (t == _i6.ComputeClientCredentialInfo) {
      return _i6.ComputeClientCredentialInfo.fromJson(data) as T;
    }
    if (t == _i10.ComputeMode) {
      return _i10.ComputeMode.fromJson(data) as T;
    }
    if (t == _i11.ComputeWorkerInfo) {
      return _i11.ComputeWorkerInfo.fromJson(data) as T;
    }
    if (t == _i12.CreatedComputeClientCredential) {
      return _i12.CreatedComputeClientCredential.fromJson(data) as T;
    }
    if (t == _i13.CreatorComputeSettings) {
      return _i13.CreatorComputeSettings.fromJson(data) as T;
    }
    if (t == _i16.ExecutionAssetRef) {
      return _i16.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _i17.ExecutionAssetUpload) {
      return _i17.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i18.ExecutionAssetUploadRequest) {
      return _i18.ExecutionAssetUploadRequest.fromJson(data) as T;
    }
    if (t == _i19.ExecutionAssetUploadTicket) {
      return _i19.ExecutionAssetUploadTicket.fromJson(data) as T;
    }
    if (t == _i22.ExecutionKind) {
      return _i22.ExecutionKind.fromJson(data) as T;
    }
    if (t == _i23.ExecutionOutcome) {
      return _i23.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _i25.ExecutionStatus) {
      return _i25.ExecutionStatus.fromJson(data) as T;
    }
    if (t == _i28.ExternalCodeVersion) {
      return _i28.ExternalCodeVersion.fromJson(data) as T;
    }
    if (t == _i29.HeartbeatResponse) {
      return _i29.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _i32.MachineCheckResult) {
      return _i32.MachineCheckResult.fromJson(data) as T;
    }
    if (t == _i33.MachineCheckScript) {
      return _i33.MachineCheckScript.fromJson(data) as T;
    }
    if (t == _i34.MachineCheckStatus) {
      return _i34.MachineCheckStatus.fromJson(data) as T;
    }
    if (t == _i35.MachineCheckView) {
      return _i35.MachineCheckView.fromJson(data) as T;
    }
    if (t == _i36.MachineReport) {
      return _i36.MachineReport.fromJson(data) as T;
    }
    if (t == _i38.WakeChannel) {
      return _i38.WakeChannel.fromJson(data) as T;
    }
    if (t == _i39.WorkerLastRun) {
      return _i39.WorkerLastRun.fromJson(data) as T;
    }
    if (t == _i40.WorkerRegistration) {
      return _i40.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _i42.AccountInfo) {
      return _i42.AccountInfo.fromJson(data) as T;
    }
    if (t == _i44.ContractDraft) {
      return _i44.ContractDraft.fromJson(data) as T;
    }
    if (t == _i45.ContractInputField) {
      return _i45.ContractInputField.fromJson(data) as T;
    }
    if (t == _i46.ContractOutputField) {
      return _i46.ContractOutputField.fromJson(data) as T;
    }
    if (t == _i47.CreatorProjectSummary) {
      return _i47.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _i64.PythonFieldType) {
      return _i64.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i65.ScriptLocation) {
      return _i65.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i66.ScriptRunException) {
      return _i66.ScriptRunException.fromJson(data) as T;
    }
    if (t == _i69.SyncedScriptInfo) {
      return _i69.SyncedScriptInfo.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.DeviceSignInRequest?>()) {
      return (data != null ? _i2.DeviceSignInRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.DeviceSignInStart?>()) {
      return (data != null ? _i3.DeviceSignInStart.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ClaimedExecution?>()) {
      return (data != null ? _i4.ClaimedExecution.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ClaimedMachineCheck?>()) {
      return (data != null ? _i5.ClaimedMachineCheck.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.ComputeClientCredentialInfo?>()) {
      return (data != null
              ? _i6.ComputeClientCredentialInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i10.ComputeMode?>()) {
      return (data != null ? _i10.ComputeMode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ComputeWorkerInfo?>()) {
      return (data != null ? _i11.ComputeWorkerInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.CreatedComputeClientCredential?>()) {
      return (data != null
              ? _i12.CreatedComputeClientCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i13.CreatorComputeSettings?>()) {
      return (data != null ? _i13.CreatorComputeSettings.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.ExecutionAssetRef?>()) {
      return (data != null ? _i16.ExecutionAssetRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ExecutionAssetUpload?>()) {
      return (data != null ? _i17.ExecutionAssetUpload.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.ExecutionAssetUploadRequest?>()) {
      return (data != null
              ? _i18.ExecutionAssetUploadRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.ExecutionAssetUploadTicket?>()) {
      return (data != null
              ? _i19.ExecutionAssetUploadTicket.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i22.ExecutionKind?>()) {
      return (data != null ? _i22.ExecutionKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.ExecutionOutcome?>()) {
      return (data != null ? _i23.ExecutionOutcome.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ExecutionStatus?>()) {
      return (data != null ? _i25.ExecutionStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.ExternalCodeVersion?>()) {
      return (data != null ? _i28.ExternalCodeVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.HeartbeatResponse?>()) {
      return (data != null ? _i29.HeartbeatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.MachineCheckResult?>()) {
      return (data != null ? _i32.MachineCheckResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.MachineCheckScript?>()) {
      return (data != null ? _i33.MachineCheckScript.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.MachineCheckStatus?>()) {
      return (data != null ? _i34.MachineCheckStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.MachineCheckView?>()) {
      return (data != null ? _i35.MachineCheckView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.MachineReport?>()) {
      return (data != null ? _i36.MachineReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.WakeChannel?>()) {
      return (data != null ? _i38.WakeChannel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.WorkerLastRun?>()) {
      return (data != null ? _i39.WorkerLastRun.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.WorkerRegistration?>()) {
      return (data != null ? _i40.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.AccountInfo?>()) {
      return (data != null ? _i42.AccountInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.ContractDraft?>()) {
      return (data != null ? _i44.ContractDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ContractInputField?>()) {
      return (data != null ? _i45.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i46.ContractOutputField?>()) {
      return (data != null ? _i46.ContractOutputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i47.CreatorProjectSummary?>()) {
      return (data != null ? _i47.CreatorProjectSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i64.PythonFieldType?>()) {
      return (data != null ? _i64.PythonFieldType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i65.ScriptLocation?>()) {
      return (data != null ? _i65.ScriptLocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i66.ScriptRunException?>()) {
      return (data != null ? _i66.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i69.SyncedScriptInfo?>()) {
      return (data != null ? _i69.SyncedScriptInfo.fromJson(data) : null) as T;
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
    if (t == List<_i28.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i28.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i28.ExternalCodeVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i28.ExternalCodeVersion>(e))
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
    if (t == List<_i25.ExecutionStatus>) {
      return (data as List)
              .map((e) => deserialize<_i25.ExecutionStatus>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i25.ExecutionStatus>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i25.ExecutionStatus>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i33.MachineCheckScript>) {
      return (data as List)
              .map((e) => deserialize<_i33.MachineCheckScript>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_i45.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i46.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_i46.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i73.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_i73.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i74.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_i74.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i75.ExternalCodeVersion>) {
      return (data as List)
              .map((e) => deserialize<_i75.ExternalCodeVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i76.SyncedScriptInfo>) {
      return (data as List)
              .map((e) => deserialize<_i76.SyncedScriptInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i80.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i80.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    try {
      return _i84.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i85.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.DeviceSignInRequest => 'DeviceSignInRequest',
      _i3.DeviceSignInStart => 'DeviceSignInStart',
      _i4.ClaimedExecution => 'ClaimedExecution',
      _i5.ClaimedMachineCheck => 'ClaimedMachineCheck',
      _i6.ComputeClientCredentialInfo => 'ComputeClientCredentialInfo',
      _i10.ComputeMode => 'ComputeMode',
      _i11.ComputeWorkerInfo => 'ComputeWorkerInfo',
      _i12.CreatedComputeClientCredential => 'CreatedComputeClientCredential',
      _i13.CreatorComputeSettings => 'CreatorComputeSettings',
      _i16.ExecutionAssetRef => 'ExecutionAssetRef',
      _i17.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i18.ExecutionAssetUploadRequest => 'ExecutionAssetUploadRequest',
      _i19.ExecutionAssetUploadTicket => 'ExecutionAssetUploadTicket',
      _i22.ExecutionKind => 'ExecutionKind',
      _i23.ExecutionOutcome => 'ExecutionOutcome',
      _i25.ExecutionStatus => 'ExecutionStatus',
      _i28.ExternalCodeVersion => 'ExternalCodeVersion',
      _i29.HeartbeatResponse => 'HeartbeatResponse',
      _i32.MachineCheckResult => 'MachineCheckResult',
      _i33.MachineCheckScript => 'MachineCheckScript',
      _i34.MachineCheckStatus => 'MachineCheckStatus',
      _i35.MachineCheckView => 'MachineCheckView',
      _i36.MachineReport => 'MachineReport',
      _i38.WakeChannel => 'WakeChannel',
      _i39.WorkerLastRun => 'WorkerLastRun',
      _i40.WorkerRegistration => 'WorkerRegistration',
      _i42.AccountInfo => 'AccountInfo',
      _i44.ContractDraft => 'ContractDraft',
      _i45.ContractInputField => 'ContractInputField',
      _i46.ContractOutputField => 'ContractOutputField',
      _i47.CreatorProjectSummary => 'CreatorProjectSummary',
      _i64.PythonFieldType => 'PythonFieldType',
      _i65.ScriptLocation => 'ScriptLocation',
      _i66.ScriptRunException => 'ScriptRunException',
      _i69.SyncedScriptInfo => 'SyncedScriptInfo',
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
      case _i2.DeviceSignInRequest():
        return 'DeviceSignInRequest';
      case _i3.DeviceSignInStart():
        return 'DeviceSignInStart';
      case _i4.ClaimedExecution():
        return 'ClaimedExecution';
      case _i5.ClaimedMachineCheck():
        return 'ClaimedMachineCheck';
      case _i6.ComputeClientCredentialInfo():
        return 'ComputeClientCredentialInfo';
      case _i10.ComputeMode():
        return 'ComputeMode';
      case _i11.ComputeWorkerInfo():
        return 'ComputeWorkerInfo';
      case _i12.CreatedComputeClientCredential():
        return 'CreatedComputeClientCredential';
      case _i13.CreatorComputeSettings():
        return 'CreatorComputeSettings';
      case _i16.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _i17.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i18.ExecutionAssetUploadRequest():
        return 'ExecutionAssetUploadRequest';
      case _i19.ExecutionAssetUploadTicket():
        return 'ExecutionAssetUploadTicket';
      case _i22.ExecutionKind():
        return 'ExecutionKind';
      case _i23.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _i25.ExecutionStatus():
        return 'ExecutionStatus';
      case _i28.ExternalCodeVersion():
        return 'ExternalCodeVersion';
      case _i29.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _i32.MachineCheckResult():
        return 'MachineCheckResult';
      case _i33.MachineCheckScript():
        return 'MachineCheckScript';
      case _i34.MachineCheckStatus():
        return 'MachineCheckStatus';
      case _i35.MachineCheckView():
        return 'MachineCheckView';
      case _i36.MachineReport():
        return 'MachineReport';
      case _i38.WakeChannel():
        return 'WakeChannel';
      case _i39.WorkerLastRun():
        return 'WorkerLastRun';
      case _i40.WorkerRegistration():
        return 'WorkerRegistration';
      case _i42.AccountInfo():
        return 'AccountInfo';
      case _i44.ContractDraft():
        return 'ContractDraft';
      case _i45.ContractInputField():
        return 'ContractInputField';
      case _i46.ContractOutputField():
        return 'ContractOutputField';
      case _i47.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _i64.PythonFieldType():
        return 'PythonFieldType';
      case _i65.ScriptLocation():
        return 'ScriptLocation';
      case _i66.ScriptRunException():
        return 'ScriptRunException';
      case _i69.SyncedScriptInfo():
        return 'SyncedScriptInfo';
    }
    className = _i84.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i85.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'DeviceSignInRequest') {
      return deserialize<_i2.DeviceSignInRequest>(data['data']);
    }
    if (dataClassName == 'DeviceSignInStart') {
      return deserialize<_i3.DeviceSignInStart>(data['data']);
    }
    if (dataClassName == 'ClaimedExecution') {
      return deserialize<_i4.ClaimedExecution>(data['data']);
    }
    if (dataClassName == 'ClaimedMachineCheck') {
      return deserialize<_i5.ClaimedMachineCheck>(data['data']);
    }
    if (dataClassName == 'ComputeClientCredentialInfo') {
      return deserialize<_i6.ComputeClientCredentialInfo>(data['data']);
    }
    if (dataClassName == 'ComputeMode') {
      return deserialize<_i10.ComputeMode>(data['data']);
    }
    if (dataClassName == 'ComputeWorkerInfo') {
      return deserialize<_i11.ComputeWorkerInfo>(data['data']);
    }
    if (dataClassName == 'CreatedComputeClientCredential') {
      return deserialize<_i12.CreatedComputeClientCredential>(data['data']);
    }
    if (dataClassName == 'CreatorComputeSettings') {
      return deserialize<_i13.CreatorComputeSettings>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_i16.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_i17.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadRequest') {
      return deserialize<_i18.ExecutionAssetUploadRequest>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUploadTicket') {
      return deserialize<_i19.ExecutionAssetUploadTicket>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i22.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_i23.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'ExecutionStatus') {
      return deserialize<_i25.ExecutionStatus>(data['data']);
    }
    if (dataClassName == 'ExternalCodeVersion') {
      return deserialize<_i28.ExternalCodeVersion>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_i29.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'MachineCheckResult') {
      return deserialize<_i32.MachineCheckResult>(data['data']);
    }
    if (dataClassName == 'MachineCheckScript') {
      return deserialize<_i33.MachineCheckScript>(data['data']);
    }
    if (dataClassName == 'MachineCheckStatus') {
      return deserialize<_i34.MachineCheckStatus>(data['data']);
    }
    if (dataClassName == 'MachineCheckView') {
      return deserialize<_i35.MachineCheckView>(data['data']);
    }
    if (dataClassName == 'MachineReport') {
      return deserialize<_i36.MachineReport>(data['data']);
    }
    if (dataClassName == 'WakeChannel') {
      return deserialize<_i38.WakeChannel>(data['data']);
    }
    if (dataClassName == 'WorkerLastRun') {
      return deserialize<_i39.WorkerLastRun>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_i40.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'AccountInfo') {
      return deserialize<_i42.AccountInfo>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_i44.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_i45.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_i46.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_i47.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_i64.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i65.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i66.ScriptRunException>(data['data']);
    }
    if (dataClassName == 'SyncedScriptInfo') {
      return deserialize<_i69.SyncedScriptInfo>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i84.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i85.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i84.Protocol().registerHostProtocol('discoman', this);
    _i85.Protocol().registerHostProtocol('discoman', this);
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
      return _i84.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i85.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
