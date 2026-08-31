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
import 'execution/models/creator_usage_rollup.dart' as _i8;
import 'execution/models/dashboard_profile.dart' as _i9;
import 'execution/models/execution_asset_ref.dart' as _i10;
import 'execution/models/execution_asset_upload.dart' as _i11;
import 'execution/models/execution_detail_view.dart' as _i12;
import 'execution/models/execution_filter.dart' as _i13;
import 'execution/models/execution_kind.dart' as _i14;
import 'execution/models/execution_outcome.dart' as _i15;
import 'execution/models/execution_page.dart' as _i16;
import 'execution/models/execution_status.dart' as _i17;
import 'execution/models/execution_status_view.dart' as _i18;
import 'execution/models/execution_ticket.dart' as _i19;
import 'execution/models/heartbeat_response.dart' as _i20;
import 'execution/models/queue_stats.dart' as _i21;
import 'execution/models/worker_registration.dart' as _i22;
import 'greetings/greeting.dart' as _i23;
import 'runtime/contract_draft.dart' as _i24;
import 'runtime/contract_input_field.dart' as _i25;
import 'runtime/contract_output_field.dart' as _i26;
import 'runtime/creator_project_summary.dart' as _i27;
import 'runtime/history_field_descriptor.dart' as _i28;
import 'runtime/published_app_run_entry.dart' as _i29;
import 'runtime/python_field_type.dart' as _i30;
import 'runtime/script_location.dart' as _i31;
import 'runtime/script_run_exception.dart' as _i32;
import 'runtime/script_run_result.dart' as _i33;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i34;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i35;
import 'package:discoman_client/src/protocol/execution/models/creator_usage_rollup.dart'
    as _i36;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i37;
import 'package:discoman_client/src/protocol/runtime/published_app_run_entry.dart'
    as _i38;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i39;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i40;
export 'execution/models/claimed_execution.dart';
export 'execution/models/compute_client_credential_info.dart';
export 'execution/models/compute_mode.dart';
export 'execution/models/compute_worker_info.dart';
export 'execution/models/created_compute_client_credential.dart';
export 'execution/models/creator_compute_settings.dart';
export 'execution/models/creator_usage_rollup.dart';
export 'execution/models/dashboard_profile.dart';
export 'execution/models/execution_asset_ref.dart';
export 'execution/models/execution_asset_upload.dart';
export 'execution/models/execution_detail_view.dart';
export 'execution/models/execution_filter.dart';
export 'execution/models/execution_kind.dart';
export 'execution/models/execution_outcome.dart';
export 'execution/models/execution_page.dart';
export 'execution/models/execution_status.dart';
export 'execution/models/execution_status_view.dart';
export 'execution/models/execution_ticket.dart';
export 'execution/models/heartbeat_response.dart';
export 'execution/models/queue_stats.dart';
export 'execution/models/worker_registration.dart';
export 'greetings/greeting.dart';
export 'runtime/contract_draft.dart';
export 'runtime/contract_input_field.dart';
export 'runtime/contract_output_field.dart';
export 'runtime/creator_project_summary.dart';
export 'runtime/history_field_descriptor.dart';
export 'runtime/published_app_run_entry.dart';
export 'runtime/python_field_type.dart';
export 'runtime/script_location.dart';
export 'runtime/script_run_exception.dart';
export 'runtime/script_run_result.dart';
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
    if (t == _i8.CreatorUsageRollup) {
      return _i8.CreatorUsageRollup.fromJson(data) as T;
    }
    if (t == _i9.DashboardProfile) {
      return _i9.DashboardProfile.fromJson(data) as T;
    }
    if (t == _i10.ExecutionAssetRef) {
      return _i10.ExecutionAssetRef.fromJson(data) as T;
    }
    if (t == _i11.ExecutionAssetUpload) {
      return _i11.ExecutionAssetUpload.fromJson(data) as T;
    }
    if (t == _i12.ExecutionDetailView) {
      return _i12.ExecutionDetailView.fromJson(data) as T;
    }
    if (t == _i13.ExecutionFilter) {
      return _i13.ExecutionFilter.fromJson(data) as T;
    }
    if (t == _i14.ExecutionKind) {
      return _i14.ExecutionKind.fromJson(data) as T;
    }
    if (t == _i15.ExecutionOutcome) {
      return _i15.ExecutionOutcome.fromJson(data) as T;
    }
    if (t == _i16.ExecutionPage) {
      return _i16.ExecutionPage.fromJson(data) as T;
    }
    if (t == _i17.ExecutionStatus) {
      return _i17.ExecutionStatus.fromJson(data) as T;
    }
    if (t == _i18.ExecutionStatusView) {
      return _i18.ExecutionStatusView.fromJson(data) as T;
    }
    if (t == _i19.ExecutionTicket) {
      return _i19.ExecutionTicket.fromJson(data) as T;
    }
    if (t == _i20.HeartbeatResponse) {
      return _i20.HeartbeatResponse.fromJson(data) as T;
    }
    if (t == _i21.QueueStats) {
      return _i21.QueueStats.fromJson(data) as T;
    }
    if (t == _i22.WorkerRegistration) {
      return _i22.WorkerRegistration.fromJson(data) as T;
    }
    if (t == _i23.Greeting) {
      return _i23.Greeting.fromJson(data) as T;
    }
    if (t == _i24.ContractDraft) {
      return _i24.ContractDraft.fromJson(data) as T;
    }
    if (t == _i25.ContractInputField) {
      return _i25.ContractInputField.fromJson(data) as T;
    }
    if (t == _i26.ContractOutputField) {
      return _i26.ContractOutputField.fromJson(data) as T;
    }
    if (t == _i27.CreatorProjectSummary) {
      return _i27.CreatorProjectSummary.fromJson(data) as T;
    }
    if (t == _i28.HistoryFieldDescriptor) {
      return _i28.HistoryFieldDescriptor.fromJson(data) as T;
    }
    if (t == _i29.PublishedAppRunEntry) {
      return _i29.PublishedAppRunEntry.fromJson(data) as T;
    }
    if (t == _i30.PythonFieldType) {
      return _i30.PythonFieldType.fromJson(data) as T;
    }
    if (t == _i31.ScriptLocation) {
      return _i31.ScriptLocation.fromJson(data) as T;
    }
    if (t == _i32.ScriptRunException) {
      return _i32.ScriptRunException.fromJson(data) as T;
    }
    if (t == _i33.ScriptRunResult) {
      return _i33.ScriptRunResult.fromJson(data) as T;
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
    if (t == _i1.getType<_i8.CreatorUsageRollup?>()) {
      return (data != null ? _i8.CreatorUsageRollup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DashboardProfile?>()) {
      return (data != null ? _i9.DashboardProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ExecutionAssetRef?>()) {
      return (data != null ? _i10.ExecutionAssetRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ExecutionAssetUpload?>()) {
      return (data != null ? _i11.ExecutionAssetUpload.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ExecutionDetailView?>()) {
      return (data != null ? _i12.ExecutionDetailView.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.ExecutionFilter?>()) {
      return (data != null ? _i13.ExecutionFilter.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ExecutionKind?>()) {
      return (data != null ? _i14.ExecutionKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ExecutionOutcome?>()) {
      return (data != null ? _i15.ExecutionOutcome.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ExecutionPage?>()) {
      return (data != null ? _i16.ExecutionPage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ExecutionStatus?>()) {
      return (data != null ? _i17.ExecutionStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.ExecutionStatusView?>()) {
      return (data != null ? _i18.ExecutionStatusView.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.ExecutionTicket?>()) {
      return (data != null ? _i19.ExecutionTicket.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.HeartbeatResponse?>()) {
      return (data != null ? _i20.HeartbeatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.QueueStats?>()) {
      return (data != null ? _i21.QueueStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.WorkerRegistration?>()) {
      return (data != null ? _i22.WorkerRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.Greeting?>()) {
      return (data != null ? _i23.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.ContractDraft?>()) {
      return (data != null ? _i24.ContractDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ContractInputField?>()) {
      return (data != null ? _i25.ContractInputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.ContractOutputField?>()) {
      return (data != null ? _i26.ContractOutputField.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.CreatorProjectSummary?>()) {
      return (data != null ? _i27.CreatorProjectSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.HistoryFieldDescriptor?>()) {
      return (data != null ? _i28.HistoryFieldDescriptor.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.PublishedAppRunEntry?>()) {
      return (data != null ? _i29.PublishedAppRunEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.PythonFieldType?>()) {
      return (data != null ? _i30.PythonFieldType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.ScriptLocation?>()) {
      return (data != null ? _i31.ScriptLocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ScriptRunException?>()) {
      return (data != null ? _i32.ScriptRunException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.ScriptRunResult?>()) {
      return (data != null ? _i33.ScriptRunResult.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i17.ExecutionStatus>) {
      return (data as List)
              .map((e) => deserialize<_i17.ExecutionStatus>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i17.ExecutionStatus>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i17.ExecutionStatus>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i18.ExecutionStatusView>) {
      return (data as List)
              .map((e) => deserialize<_i18.ExecutionStatusView>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.ContractInputField>) {
      return (data as List)
              .map((e) => deserialize<_i25.ContractInputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.ContractOutputField>) {
      return (data as List)
              .map((e) => deserialize<_i26.ContractOutputField>(e))
              .toList()
          as T;
    }
    if (t == List<_i28.HistoryFieldDescriptor>) {
      return (data as List)
              .map((e) => deserialize<_i28.HistoryFieldDescriptor>(e))
              .toList()
          as T;
    }
    if (t == List<_i34.ComputeWorkerInfo>) {
      return (data as List)
              .map((e) => deserialize<_i34.ComputeWorkerInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.ComputeClientCredentialInfo>) {
      return (data as List)
              .map((e) => deserialize<_i35.ComputeClientCredentialInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i36.CreatorUsageRollup>) {
      return (data as List)
              .map((e) => deserialize<_i36.CreatorUsageRollup>(e))
              .toList()
          as T;
    }
    if (t == List<_i37.CreatorProjectSummary>) {
      return (data as List)
              .map((e) => deserialize<_i37.CreatorProjectSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i38.PublishedAppRunEntry>) {
      return (data as List)
              .map((e) => deserialize<_i38.PublishedAppRunEntry>(e))
              .toList()
          as T;
    }
    try {
      return _i39.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i40.Protocol().deserialize<T>(data, t);
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
      _i8.CreatorUsageRollup => 'CreatorUsageRollup',
      _i9.DashboardProfile => 'DashboardProfile',
      _i10.ExecutionAssetRef => 'ExecutionAssetRef',
      _i11.ExecutionAssetUpload => 'ExecutionAssetUpload',
      _i12.ExecutionDetailView => 'ExecutionDetailView',
      _i13.ExecutionFilter => 'ExecutionFilter',
      _i14.ExecutionKind => 'ExecutionKind',
      _i15.ExecutionOutcome => 'ExecutionOutcome',
      _i16.ExecutionPage => 'ExecutionPage',
      _i17.ExecutionStatus => 'ExecutionStatus',
      _i18.ExecutionStatusView => 'ExecutionStatusView',
      _i19.ExecutionTicket => 'ExecutionTicket',
      _i20.HeartbeatResponse => 'HeartbeatResponse',
      _i21.QueueStats => 'QueueStats',
      _i22.WorkerRegistration => 'WorkerRegistration',
      _i23.Greeting => 'Greeting',
      _i24.ContractDraft => 'ContractDraft',
      _i25.ContractInputField => 'ContractInputField',
      _i26.ContractOutputField => 'ContractOutputField',
      _i27.CreatorProjectSummary => 'CreatorProjectSummary',
      _i28.HistoryFieldDescriptor => 'HistoryFieldDescriptor',
      _i29.PublishedAppRunEntry => 'PublishedAppRunEntry',
      _i30.PythonFieldType => 'PythonFieldType',
      _i31.ScriptLocation => 'ScriptLocation',
      _i32.ScriptRunException => 'ScriptRunException',
      _i33.ScriptRunResult => 'ScriptRunResult',
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
      case _i8.CreatorUsageRollup():
        return 'CreatorUsageRollup';
      case _i9.DashboardProfile():
        return 'DashboardProfile';
      case _i10.ExecutionAssetRef():
        return 'ExecutionAssetRef';
      case _i11.ExecutionAssetUpload():
        return 'ExecutionAssetUpload';
      case _i12.ExecutionDetailView():
        return 'ExecutionDetailView';
      case _i13.ExecutionFilter():
        return 'ExecutionFilter';
      case _i14.ExecutionKind():
        return 'ExecutionKind';
      case _i15.ExecutionOutcome():
        return 'ExecutionOutcome';
      case _i16.ExecutionPage():
        return 'ExecutionPage';
      case _i17.ExecutionStatus():
        return 'ExecutionStatus';
      case _i18.ExecutionStatusView():
        return 'ExecutionStatusView';
      case _i19.ExecutionTicket():
        return 'ExecutionTicket';
      case _i20.HeartbeatResponse():
        return 'HeartbeatResponse';
      case _i21.QueueStats():
        return 'QueueStats';
      case _i22.WorkerRegistration():
        return 'WorkerRegistration';
      case _i23.Greeting():
        return 'Greeting';
      case _i24.ContractDraft():
        return 'ContractDraft';
      case _i25.ContractInputField():
        return 'ContractInputField';
      case _i26.ContractOutputField():
        return 'ContractOutputField';
      case _i27.CreatorProjectSummary():
        return 'CreatorProjectSummary';
      case _i28.HistoryFieldDescriptor():
        return 'HistoryFieldDescriptor';
      case _i29.PublishedAppRunEntry():
        return 'PublishedAppRunEntry';
      case _i30.PythonFieldType():
        return 'PythonFieldType';
      case _i31.ScriptLocation():
        return 'ScriptLocation';
      case _i32.ScriptRunException():
        return 'ScriptRunException';
      case _i33.ScriptRunResult():
        return 'ScriptRunResult';
    }
    className = _i39.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i40.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'CreatorUsageRollup') {
      return deserialize<_i8.CreatorUsageRollup>(data['data']);
    }
    if (dataClassName == 'DashboardProfile') {
      return deserialize<_i9.DashboardProfile>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetRef') {
      return deserialize<_i10.ExecutionAssetRef>(data['data']);
    }
    if (dataClassName == 'ExecutionAssetUpload') {
      return deserialize<_i11.ExecutionAssetUpload>(data['data']);
    }
    if (dataClassName == 'ExecutionDetailView') {
      return deserialize<_i12.ExecutionDetailView>(data['data']);
    }
    if (dataClassName == 'ExecutionFilter') {
      return deserialize<_i13.ExecutionFilter>(data['data']);
    }
    if (dataClassName == 'ExecutionKind') {
      return deserialize<_i14.ExecutionKind>(data['data']);
    }
    if (dataClassName == 'ExecutionOutcome') {
      return deserialize<_i15.ExecutionOutcome>(data['data']);
    }
    if (dataClassName == 'ExecutionPage') {
      return deserialize<_i16.ExecutionPage>(data['data']);
    }
    if (dataClassName == 'ExecutionStatus') {
      return deserialize<_i17.ExecutionStatus>(data['data']);
    }
    if (dataClassName == 'ExecutionStatusView') {
      return deserialize<_i18.ExecutionStatusView>(data['data']);
    }
    if (dataClassName == 'ExecutionTicket') {
      return deserialize<_i19.ExecutionTicket>(data['data']);
    }
    if (dataClassName == 'HeartbeatResponse') {
      return deserialize<_i20.HeartbeatResponse>(data['data']);
    }
    if (dataClassName == 'QueueStats') {
      return deserialize<_i21.QueueStats>(data['data']);
    }
    if (dataClassName == 'WorkerRegistration') {
      return deserialize<_i22.WorkerRegistration>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i23.Greeting>(data['data']);
    }
    if (dataClassName == 'ContractDraft') {
      return deserialize<_i24.ContractDraft>(data['data']);
    }
    if (dataClassName == 'ContractInputField') {
      return deserialize<_i25.ContractInputField>(data['data']);
    }
    if (dataClassName == 'ContractOutputField') {
      return deserialize<_i26.ContractOutputField>(data['data']);
    }
    if (dataClassName == 'CreatorProjectSummary') {
      return deserialize<_i27.CreatorProjectSummary>(data['data']);
    }
    if (dataClassName == 'HistoryFieldDescriptor') {
      return deserialize<_i28.HistoryFieldDescriptor>(data['data']);
    }
    if (dataClassName == 'PublishedAppRunEntry') {
      return deserialize<_i29.PublishedAppRunEntry>(data['data']);
    }
    if (dataClassName == 'PythonFieldType') {
      return deserialize<_i30.PythonFieldType>(data['data']);
    }
    if (dataClassName == 'ScriptLocation') {
      return deserialize<_i31.ScriptLocation>(data['data']);
    }
    if (dataClassName == 'ScriptRunException') {
      return deserialize<_i32.ScriptRunException>(data['data']);
    }
    if (dataClassName == 'ScriptRunResult') {
      return deserialize<_i33.ScriptRunResult>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i39.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i40.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i39.Protocol().registerHostProtocol('discoman', this);
    _i40.Protocol().registerHostProtocol('discoman', this);
  }

  @override
  String getModuleName() => 'discoman';

  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i39.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i40.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
