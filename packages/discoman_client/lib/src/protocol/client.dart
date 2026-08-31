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
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:discoman_client/src/protocol/execution/models/execution_status_view.dart'
    as _i5;
import 'package:discoman_client/src/protocol/execution/models/creator_compute_settings.dart'
    as _i6;
import 'package:discoman_client/src/protocol/execution/models/compute_mode.dart'
    as _i7;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i8;
import 'package:discoman_client/src/protocol/execution/models/created_compute_client_credential.dart'
    as _i9;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i10;
import 'package:discoman_client/src/protocol/execution/models/worker_registration.dart'
    as _i11;
import 'package:discoman_client/src/protocol/execution/models/claimed_execution.dart'
    as _i12;
import 'package:discoman_client/src/protocol/execution/models/heartbeat_response.dart'
    as _i13;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_ref.dart'
    as _i14;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_upload.dart'
    as _i15;
import 'package:discoman_client/src/protocol/execution/models/execution_outcome.dart'
    as _i16;
import 'package:discoman_client/src/protocol/execution/models/dashboard_profile.dart'
    as _i17;
import 'package:discoman_client/src/protocol/execution/models/execution_page.dart'
    as _i18;
import 'package:discoman_client/src/protocol/execution/models/execution_filter.dart'
    as _i19;
import 'package:discoman_client/src/protocol/execution/models/execution_detail_view.dart'
    as _i20;
import 'package:discoman_client/src/protocol/execution/models/queue_stats.dart'
    as _i21;
import 'package:discoman_client/src/protocol/execution/models/creator_usage_rollup.dart'
    as _i22;
import 'package:discoman_client/src/protocol/execution/models/execution_ticket.dart'
    as _i23;
import 'package:discoman_client/src/protocol/runtime/script_run_result.dart'
    as _i24;
import 'package:discoman_client/src/protocol/greetings/greeting.dart' as _i25;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i26;
import 'package:discoman_client/src/protocol/runtime/contract_draft.dart'
    as _i27;
import 'package:discoman_client/src/protocol/runtime/published_app_run_entry.dart'
    as _i28;
import 'package:http/http.dart' as _i29;
import 'protocol.dart' as _i30;

class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

class EndpointFirebaseIdp extends _i1.EndpointFirebaseIdpBase {
  EndpointFirebaseIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'firebaseIdp';

  @override
  _i3.Future<_i4.AuthSuccess> login({required String idToken}) =>
      caller.callServerEndpoint<_i4.AuthSuccess>(
        'firebaseIdp',
        'login',
        {'idToken': idToken},
      );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'firebaseIdp',
    'hasAccount',
    {},
  );
}

class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

class EndpointAdminManagement extends _i2.EndpointRef {
  EndpointAdminManagement(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminManagement';

  _i3.Future<void> grantAdmin(String firebaseUid) =>
      caller.callServerEndpoint<void>(
        'adminManagement',
        'grantAdmin',
        {'firebaseUid': firebaseUid},
      );

  _i3.Future<void> revokeAdmin(String firebaseUid) =>
      caller.callServerEndpoint<void>(
        'adminManagement',
        'revokeAdmin',
        {'firebaseUid': firebaseUid},
      );

  _i3.Future<_i5.ExecutionStatusView> requeueExecution(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i5.ExecutionStatusView>(
    'adminManagement',
    'requeueExecution',
    {'executionId': executionId},
  );

  _i3.Future<_i5.ExecutionStatusView> cancelExecution(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i5.ExecutionStatusView>(
    'adminManagement',
    'cancelExecution',
    {'executionId': executionId},
  );

  _i3.Future<_i5.ExecutionStatusView> failStuckExecution(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i5.ExecutionStatusView>(
    'adminManagement',
    'failStuckExecution',
    {'executionId': executionId},
  );
}

class EndpointComputeSettings extends _i2.EndpointRef {
  EndpointComputeSettings(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'computeSettings';

  _i3.Future<_i6.CreatorComputeSettings> getMySettings() =>
      caller.callServerEndpoint<_i6.CreatorComputeSettings>(
        'computeSettings',
        'getMySettings',
        {},
      );

  _i3.Future<_i6.CreatorComputeSettings> setComputeMode(_i7.ComputeMode mode) =>
      caller.callServerEndpoint<_i6.CreatorComputeSettings>(
        'computeSettings',
        'setComputeMode',
        {'mode': mode},
      );

  _i3.Future<List<_i8.ComputeWorkerInfo>> listMyWorkers() =>
      caller.callServerEndpoint<List<_i8.ComputeWorkerInfo>>(
        'computeSettings',
        'listMyWorkers',
        {},
      );

  _i3.Future<_i9.CreatedComputeClientCredential> createComputeClientCredential(
    String name,
  ) => caller.callServerEndpoint<_i9.CreatedComputeClientCredential>(
    'computeSettings',
    'createComputeClientCredential',
    {'name': name},
  );

  _i3.Future<List<_i10.ComputeClientCredentialInfo>>
  listComputeClientCredentials() =>
      caller.callServerEndpoint<List<_i10.ComputeClientCredentialInfo>>(
        'computeSettings',
        'listComputeClientCredentials',
        {},
      );

  _i3.Future<void> revokeComputeClientCredential(_i2.UuidValue credentialId) =>
      caller.callServerEndpoint<void>(
        'computeSettings',
        'revokeComputeClientCredential',
        {'credentialId': credentialId},
      );
}

class EndpointComputeWorker extends _i2.EndpointRef {
  EndpointComputeWorker(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'computeWorker';

  _i3.Future<_i11.WorkerRegistration> register(
    String? hostname,
    String? version,
  ) => caller.callServerEndpoint<_i11.WorkerRegistration>(
    'computeWorker',
    'register',
    {
      'hostname': hostname,
      'version': version,
    },
  );

  _i3.Future<_i12.ClaimedExecution?> claimNext(_i2.UuidValue workerId) =>
      caller.callServerEndpoint<_i12.ClaimedExecution?>(
        'computeWorker',
        'claimNext',
        {'workerId': workerId},
      );

  _i3.Future<_i13.HeartbeatResponse> heartbeat(
    _i2.UuidValue workerId,
    _i2.UuidValue? executionId,
  ) => caller.callServerEndpoint<_i13.HeartbeatResponse>(
    'computeWorker',
    'heartbeat',
    {
      'workerId': workerId,
      'executionId': executionId,
    },
  );

  _i3.Future<_i14.ExecutionAssetRef> uploadExecutionAsset(
    _i2.UuidValue workerId,
    _i2.UuidValue executionId,
    _i15.ExecutionAssetUpload asset,
  ) => caller.callServerEndpoint<_i14.ExecutionAssetRef>(
    'computeWorker',
    'uploadExecutionAsset',
    {
      'workerId': workerId,
      'executionId': executionId,
      'asset': asset,
    },
  );

  _i3.Future<void> reportResult(
    _i2.UuidValue workerId,
    _i2.UuidValue executionId,
    _i16.ExecutionOutcome outcome,
  ) => caller.callServerEndpoint<void>(
    'computeWorker',
    'reportResult',
    {
      'workerId': workerId,
      'executionId': executionId,
      'outcome': outcome,
    },
  );

  _i3.Future<void> deregister(_i2.UuidValue workerId) =>
      caller.callServerEndpoint<void>(
        'computeWorker',
        'deregister',
        {'workerId': workerId},
      );
}

class EndpointDashboard extends _i2.EndpointRef {
  EndpointDashboard(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'dashboard';

  _i3.Future<_i17.DashboardProfile> getProfile() =>
      caller.callServerEndpoint<_i17.DashboardProfile>(
        'dashboard',
        'getProfile',
        {},
      );

  _i3.Future<_i18.ExecutionPage> listExecutions(
    _i19.ExecutionFilter filter,
    int limit,
    int offset,
  ) => caller.callServerEndpoint<_i18.ExecutionPage>(
    'dashboard',
    'listExecutions',
    {
      'filter': filter,
      'limit': limit,
      'offset': offset,
    },
  );

  _i3.Future<_i20.ExecutionDetailView> getExecutionDetail(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i20.ExecutionDetailView>(
    'dashboard',
    'getExecutionDetail',
    {'executionId': executionId},
  );

  _i3.Future<_i21.QueueStats> getQueueStats() =>
      caller.callServerEndpoint<_i21.QueueStats>(
        'dashboard',
        'getQueueStats',
        {},
      );

  _i3.Future<List<_i8.ComputeWorkerInfo>> listWorkers() =>
      caller.callServerEndpoint<List<_i8.ComputeWorkerInfo>>(
        'dashboard',
        'listWorkers',
        {},
      );

  _i3.Future<List<_i22.CreatorUsageRollup>> getUsageRollups(
    String? creatorFirebaseUid,
    int monthsBack,
  ) => caller.callServerEndpoint<List<_i22.CreatorUsageRollup>>(
    'dashboard',
    'getUsageRollups',
    {
      'creatorFirebaseUid': creatorFirebaseUid,
      'monthsBack': monthsBack,
    },
  );
}

class EndpointExecution extends _i2.EndpointRef {
  EndpointExecution(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'execution';

  _i3.Future<_i23.ExecutionTicket> submitPublishedAppRun(
    String slug,
    String inputsJson,
  ) => caller.callServerEndpoint<_i23.ExecutionTicket>(
    'execution',
    'submitPublishedAppRun',
    {
      'slug': slug,
      'inputsJson': inputsJson,
    },
  );

  _i3.Future<_i23.ExecutionTicket> submitPreviewRun(
    String projectId,
    String inputsJson,
  ) => caller.callServerEndpoint<_i23.ExecutionTicket>(
    'execution',
    'submitPreviewRun',
    {
      'projectId': projectId,
      'inputsJson': inputsJson,
    },
  );

  _i3.Future<_i5.ExecutionStatusView> getExecution(_i2.UuidValue executionId) =>
      caller.callServerEndpoint<_i5.ExecutionStatusView>(
        'execution',
        'getExecution',
        {'executionId': executionId},
      );

  _i3.Future<_i24.ScriptRunResult> getExecutionResult(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i24.ScriptRunResult>(
    'execution',
    'getExecutionResult',
    {'executionId': executionId},
  );

  _i3.Future<_i5.ExecutionStatusView> cancelExecution(
    _i2.UuidValue executionId,
  ) => caller.callServerEndpoint<_i5.ExecutionStatusView>(
    'execution',
    'cancelExecution',
    {'executionId': executionId},
  );
}

class EndpointWorkerAuth extends _i2.EndpointRef {
  EndpointWorkerAuth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'workerAuth';

  _i3.Future<_i4.AuthSuccess> login(String workerSecret) =>
      caller.callServerEndpoint<_i4.AuthSuccess>(
        'workerAuth',
        'login',
        {'workerSecret': workerSecret},
      );

  _i3.Future<_i4.AuthSuccess> loginRemote(String clientToken) =>
      caller.callServerEndpoint<_i4.AuthSuccess>(
        'workerAuth',
        'loginRemote',
        {'clientToken': clientToken},
      );
}

class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  _i3.Future<_i25.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i25.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class EndpointCreatorScript extends _i2.EndpointRef {
  EndpointCreatorScript(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'creatorScript';

  _i3.Future<List<_i26.CreatorProjectSummary>> listProjects() =>
      caller.callServerEndpoint<List<_i26.CreatorProjectSummary>>(
        'creatorScript',
        'listProjects',
        {},
      );

  _i3.Future<void> publishContract(
    String projectId,
    _i27.ContractDraft draft,
    String fingerprint,
  ) => caller.callServerEndpoint<void>(
    'creatorScript',
    'publishContract',
    {
      'projectId': projectId,
      'draft': draft,
      'fingerprint': fingerprint,
    },
  );
}

class EndpointPublishedApp extends _i2.EndpointRef {
  EndpointPublishedApp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'publishedApp';

  _i3.Future<String> getExamples(String slug) =>
      caller.callServerEndpoint<String>(
        'publishedApp',
        'getExamples',
        {'slug': slug},
      );

  _i3.Future<List<_i28.PublishedAppRunEntry>> getHistory(
    String slug,
    int limit,
  ) => caller.callServerEndpoint<List<_i28.PublishedAppRunEntry>>(
    'publishedApp',
    'getHistory',
    {
      'slug': slug,
      'limit': limit,
    },
  );
}

class EndpointRuntime extends _i2.EndpointRef {
  EndpointRuntime(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'runtime';

  _i3.Future<_i27.ContractDraft> inspectScript(String projectId) =>
      caller.callServerEndpoint<_i27.ContractDraft>(
        'runtime',
        'inspectScript',
        {'projectId': projectId},
      );

  _i3.Future<_i24.ScriptRunResult> runScript(
    String projectId,
    String inputsJson,
  ) => caller.callServerEndpoint<_i24.ScriptRunResult>(
    'runtime',
    'runScript',
    {
      'projectId': projectId,
      'inputsJson': inputsJson,
    },
  );

  _i3.Future<_i24.ScriptRunResult> runPublishedApp(
    String slug,
    String inputsJson,
  ) => caller.callServerEndpoint<_i24.ScriptRunResult>(
    'runtime',
    'runPublishedApp',
    {
      'slug': slug,
      'inputsJson': inputsJson,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i29.Client? httpClientOverride,
  }) : super(
         host,
         _i30.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    firebaseIdp = EndpointFirebaseIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    adminManagement = EndpointAdminManagement(this);
    computeSettings = EndpointComputeSettings(this);
    computeWorker = EndpointComputeWorker(this);
    dashboard = EndpointDashboard(this);
    execution = EndpointExecution(this);
    workerAuth = EndpointWorkerAuth(this);
    greeting = EndpointGreeting(this);
    creatorScript = EndpointCreatorScript(this);
    publishedApp = EndpointPublishedApp(this);
    runtime = EndpointRuntime(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointFirebaseIdp firebaseIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAdminManagement adminManagement;

  late final EndpointComputeSettings computeSettings;

  late final EndpointComputeWorker computeWorker;

  late final EndpointDashboard dashboard;

  late final EndpointExecution execution;

  late final EndpointWorkerAuth workerAuth;

  late final EndpointGreeting greeting;

  late final EndpointCreatorScript creatorScript;

  late final EndpointPublishedApp publishedApp;

  late final EndpointRuntime runtime;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'firebaseIdp': firebaseIdp,
    'jwtRefresh': jwtRefresh,
    'adminManagement': adminManagement,
    'computeSettings': computeSettings,
    'computeWorker': computeWorker,
    'dashboard': dashboard,
    'execution': execution,
    'workerAuth': workerAuth,
    'greeting': greeting,
    'creatorScript': creatorScript,
    'publishedApp': publishedApp,
    'runtime': runtime,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
