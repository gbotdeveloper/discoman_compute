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
import 'dart:async' as _i2;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:discoman_client/src/protocol/auth/models/device_sign_in_start.dart'
    as _i5;
import 'package:discoman_client/src/protocol/auth/models/device_sign_in_request.dart'
    as _i6;
import 'package:discoman_client/src/protocol/execution/models/creator_compute_settings.dart'
    as _i8;
import 'package:discoman_client/src/protocol/execution/models/compute_mode.dart'
    as _i9;
import 'package:discoman_client/src/protocol/execution/models/compute_worker_info.dart'
    as _i10;
import 'package:discoman_client/src/protocol/execution/models/created_compute_client_credential.dart'
    as _i11;
import 'package:discoman_client/src/protocol/execution/models/compute_client_credential_info.dart'
    as _i12;
import 'package:discoman_client/src/protocol/execution/models/worker_registration.dart'
    as _i13;
import 'package:discoman_client/src/protocol/execution/models/wake_channel.dart'
    as _i14;
import 'package:discoman_client/src/protocol/execution/models/machine_report.dart'
    as _i15;
import 'package:discoman_client/src/protocol/execution/models/external_code_version.dart'
    as _i16;
import 'package:discoman_client/src/protocol/runtime/synced_script_info.dart'
    as _i17;
import 'package:discoman_client/src/protocol/execution/models/claimed_execution.dart'
    as _i18;
import 'package:discoman_client/src/protocol/execution/models/heartbeat_response.dart'
    as _i19;
import 'package:discoman_client/src/protocol/execution/models/claimed_machine_check.dart'
    as _i20;
import 'package:discoman_client/src/protocol/execution/models/machine_check_result.dart'
    as _i21;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_ref.dart'
    as _i22;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_upload.dart'
    as _i23;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_upload_ticket.dart'
    as _i24;
import 'package:discoman_client/src/protocol/execution/models/execution_asset_upload_request.dart'
    as _i25;
import 'package:discoman_client/src/protocol/execution/models/execution_outcome.dart'
    as _i26;
import 'package:discoman_client/src/protocol/runtime/account_info.dart' as _i41;
import 'package:discoman_client/src/protocol/runtime/creator_project_summary.dart'
    as _i42;
import 'package:discoman_client/src/protocol/runtime/contract_draft.dart'
    as _i43;
import 'package:http/http.dart' as _i60;
import 'protocol.dart' as _i61;

/// Signing an app in through the browser: Discoman Compute has no browser of
/// its own, so it cannot show Google's sign-in. It asks for a request
/// ([start]), sends the person to the web app with the request's short code,
/// and collects a session ([claim]) once they have approved it there
/// ([approve]), signed in whichever way they like.
///
/// The session is an ordinary one for the approving account, the same a
/// sign-in with email and password gives.
/// {@category Endpoint}
class EndpointDeviceSignIn extends _i1.EndpointRef {
  EndpointDeviceSignIn(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deviceSignIn';

  /// Opens a request for the app on [deviceName]. Unauthenticated by
  /// design: this is how an app gets its session.
  _i2.Future<_i5.DeviceSignInStart> start(String deviceName) =>
      caller.callServerEndpoint<_i5.DeviceSignInStart>(
        'deviceSignIn',
        'start',
        {'deviceName': deviceName},
      );

  /// The pending request behind [userCode], for the approval page to show
  /// which computer is asking.
  _i2.Future<_i6.DeviceSignInRequest> describe(String userCode) =>
      caller.callServerEndpoint<_i6.DeviceSignInRequest>(
        'deviceSignIn',
        'describe',
        {'userCode': userCode},
      );

  /// Lets the app behind [userCode] sign in as the caller.
  _i2.Future<void> approve(String userCode) => caller.callServerEndpoint<void>(
    'deviceSignIn',
    'approve',
    {'userCode': userCode},
  );

  /// The session for the request behind [deviceCode]: null while nobody has
  /// approved it, the session exactly once after that. Unauthenticated; the
  /// device code is the proof.
  _i2.Future<_i4.AuthSuccess?> claim(String deviceCode) =>
      caller.callServerEndpoint<_i4.AuthSuccess?>(
        'deviceSignIn',
        'claim',
        {'deviceCode': deviceCode},
      );
}

/// Email and password accounts: creators of the web app, the dashboard's
/// admins and the compute client all sign in here.
/// {@category Endpoint}
class EndpointEmailIdp extends _i3.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  @override
  _i2.Future<_i4.AuthSuccess> login({
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
  _i2.Future<_i4.AuthSuccess> finishRegistration({
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

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
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
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i2.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Creator-facing compute configuration: where their executions run (cloud or
/// their own machine), their self-hosted limits, their live workers, and the
/// machine credentials their compute clients authenticate with.
/// {@category Endpoint}
class EndpointComputeSettings extends _i1.EndpointRef {
  EndpointComputeSettings(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'computeSettings';

  /// Returns the caller's compute settings, materializing the defaults on
  /// first read.
  _i2.Future<_i8.CreatorComputeSettings> getMySettings() =>
      caller.callServerEndpoint<_i8.CreatorComputeSettings>(
        'computeSettings',
        'getMySettings',
        {},
      );

  /// Switches the caller's executions between the cloud pool and their own
  /// machine. Applies to runs submitted from now on; queued runs keep the
  /// lane they were submitted in.
  _i2.Future<_i8.CreatorComputeSettings> setComputeMode(_i9.ComputeMode mode) =>
      caller.callServerEndpoint<_i8.CreatorComputeSettings>(
        'computeSettings',
        'setComputeMode',
        {'mode': mode},
      );

  /// The caller's own compute workers (self-hosted clients), newest first.
  _i2.Future<List<_i10.ComputeWorkerInfo>> listMyWorkers() =>
      caller.callServerEndpoint<List<_i10.ComputeWorkerInfo>>(
        'computeSettings',
        'listMyWorkers',
        {},
      );

  /// Deletes the finished runs the caller's computer [machineId] did, and
  /// returns how many went. Called by Discoman Compute on that computer.
  /// Queued and running runs stay; a computer Discoman has never seen has
  /// nothing to clear.
  _i2.Future<int> clearMachineRuns(String machineId) =>
      caller.callServerEndpoint<int>(
        'computeSettings',
        'clearMachineRuns',
        {'machineId': machineId},
      );

  /// Mints a new machine credential for the caller's compute client. The
  /// plaintext token is returned exactly once; only its hash is stored.
  _i2.Future<_i11.CreatedComputeClientCredential> createComputeClientCredential(
    String name,
  ) => caller.callServerEndpoint<_i11.CreatedComputeClientCredential>(
    'computeSettings',
    'createComputeClientCredential',
    {'name': name},
  );

  /// The caller's machine credentials, newest first.
  _i2.Future<List<_i12.ComputeClientCredentialInfo>>
  listComputeClientCredentials() =>
      caller.callServerEndpoint<List<_i12.ComputeClientCredentialInfo>>(
        'computeSettings',
        'listComputeClientCredentials',
        {},
      );

  /// Revokes a machine credential and kills its live sessions (the JWT
  /// refresh tokens of its dedicated AuthUser).
  _i2.Future<void> revokeComputeClientCredential(_i1.UuidValue credentialId) =>
      caller.callServerEndpoint<void>(
        'computeSettings',
        'revokeComputeClientCredential',
        {'credentialId': credentialId},
      );
}

/// The worker protocol, shared by the cloud Container App Job pool and the
/// remote compute client on a creator's machine: register, claim, heartbeat,
/// upload output assets, report the result.
///
/// Postgres is the source of truth throughout: claims are atomic row updates
/// with a lease, and everything a worker sends is re-validated server-side.
/// {@category Endpoint}
class EndpointComputeWorker extends _i1.EndpointRef {
  EndpointComputeWorker(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'computeWorker';

  /// Registers a worker process and returns the heartbeat/lease cadence it
  /// must follow.
  _i2.Future<_i13.WorkerRegistration> register(
    String? hostname,
    String? version,
  ) => caller.callServerEndpoint<_i13.WorkerRegistration>(
    'computeWorker',
    'register',
    {
      'hostname': hostname,
      'version': version,
    },
  );

  /// Opens the caller's wake channel for the run slots [workerIds] and marks
  /// them as listening: from here on they wait to be woken instead of
  /// asking for work. Null when this server has no wake-ups to offer, or the
  /// caller is not a machine with a credential of its own; the client then
  /// keeps polling.
  ///
  /// Called again before [WakeChannel.expiresAt], which is also how an idle
  /// machine shows it is still there.
  _i2.Future<_i14.WakeChannel?> openWakeChannel(
    List<_i1.UuidValue> workerIds,
  ) => caller.callServerEndpoint<_i14.WakeChannel?>(
    'computeWorker',
    'openWakeChannel',
    {'workerIds': workerIds},
  );

  /// Records which computer a self-hosted worker runs on and every script
  /// linked there, so the dashboard can show each computer once. Sent after
  /// [register] and again now and then while the worker is idle.
  _i2.Future<void> reportMachine(
    _i1.UuidValue workerId,
    _i15.MachineReport report,
  ) => caller.callServerEndpoint<void>(
    'computeWorker',
    'reportMachine',
    {
      'workerId': workerId,
      'report': report,
    },
  );

  /// Records the code outside Discoman that a self-hosted run is about to
  /// use, as the computer has it now, so the run can later say what produced
  /// its result.
  _i2.Future<void> stampExternalCode(
    _i1.UuidValue workerId,
    _i1.UuidValue executionId,
    List<_i16.ExternalCodeVersion> externalCode,
  ) => caller.callServerEndpoint<void>(
    'computeWorker',
    'stampExternalCode',
    {
      'workerId': workerId,
      'executionId': executionId,
      'externalCode': externalCode,
    },
  );

  /// The scripts the creator keeps in Discoman, for a computer to compare
  /// with the ones it has.
  _i2.Future<List<_i17.SyncedScriptInfo>> listSyncedScripts() =>
      caller.callServerEndpoint<List<_i17.SyncedScriptInfo>>(
        'computeWorker',
        'listSyncedScripts',
        {},
      );

  /// One script the creator keeps in Discoman.
  _i2.Future<String> downloadSyncedScript(String projectId) =>
      caller.callServerEndpoint<String>(
        'computeWorker',
        'downloadSyncedScript',
        {'projectId': projectId},
      );

  /// Fills in a script the creator chose to keep in Discoman but no computer
  /// has sent yet, from one that has it. Never replaces a script already
  /// held. Returns whether it was stored.
  _i2.Future<bool> offerSyncedScript(
    String projectId,
    String source,
    String fingerprint,
  ) => caller.callServerEndpoint<bool>(
    'computeWorker',
    'offerSyncedScript',
    {
      'projectId': projectId,
      'source': source,
      'fingerprint': fingerprint,
    },
  );

  /// Atomically claims the next runnable execution in the caller's lane, or
  /// returns null when nothing is claimable.
  ///
  /// [servedProjectIds] is how a self-hosted worker says which projects it can
  /// run: the ones whose script the creator has linked on that machine, and
  /// has left switched on. Sent on every claim rather than stored, so linking a
  /// script on a second computer takes effect on its next poll with nothing to
  /// register or refresh. Ignored for cloud workers, which run whatever the
  /// row carries.
  _i2.Future<_i18.ClaimedExecution?> claimNext(
    _i1.UuidValue workerId,
    List<String> servedProjectIds,
  ) => caller.callServerEndpoint<_i18.ClaimedExecution?>(
    'computeWorker',
    'claimNext',
    {
      'workerId': workerId,
      'servedProjectIds': servedProjectIds,
    },
  );

  /// Worker liveness plus lease renewal for the execution it is running.
  /// `cancelRequested: true` also doubles as the stop signal when the lease
  /// was lost (the sweeper already gave the run away).
  _i2.Future<_i19.HeartbeatResponse> heartbeat(
    _i1.UuidValue workerId,
    _i1.UuidValue? executionId,
  ) => caller.callServerEndpoint<_i19.HeartbeatResponse>(
    'computeWorker',
    'heartbeat',
    {
      'workerId': workerId,
      'executionId': executionId,
    },
  );

  /// Hands a self-hosted worker the check the dashboard asked it for, with
  /// the script every one of the creator's machine-kept projects should hold.
  /// Null when there is nothing to check.
  _i2.Future<_i20.ClaimedMachineCheck?> claimMachineCheck(
    _i1.UuidValue workerId,
  ) => caller.callServerEndpoint<_i20.ClaimedMachineCheck?>(
    'computeWorker',
    'claimMachineCheck',
    {'workerId': workerId},
  );

  /// Stores what the worker found when it checked itself.
  _i2.Future<void> reportMachineCheck(
    _i1.UuidValue workerId,
    _i1.UuidValue checkId,
    _i21.MachineCheckResult result,
  ) => caller.callServerEndpoint<void>(
    'computeWorker',
    'reportMachineCheck',
    {
      'workerId': workerId,
      'checkId': checkId,
      'result': result,
    },
  );

  /// Stores one output asset sent through the server and returns the
  /// reference the worker must substitute into its outputs. Workers that
  /// upload directly use [createOutputUpload]; this remains for older ones.
  ///
  /// Everything is enforced server-side: ownership, per-kind size caps,
  /// base64-length reconciliation, and per-execution asset count/byte caps.
  _i2.Future<_i22.ExecutionAssetRef> uploadExecutionAsset(
    _i1.UuidValue workerId,
    _i1.UuidValue executionId,
    _i23.ExecutionAssetUpload asset,
  ) => caller.callServerEndpoint<_i22.ExecutionAssetRef>(
    'computeWorker',
    'uploadExecutionAsset',
    {
      'workerId': workerId,
      'executionId': executionId,
      'asset': asset,
    },
  );

  /// Reserves one output file and returns a short-lived link the worker
  /// uploads it to directly, so its bytes never pass through the server.
  _i2.Future<_i24.ExecutionAssetUploadTicket> createOutputUpload(
    _i1.UuidValue workerId,
    _i1.UuidValue executionId,
    _i25.ExecutionAssetUploadRequest asset,
  ) => caller.callServerEndpoint<_i24.ExecutionAssetUploadTicket>(
    'computeWorker',
    'createOutputUpload',
    {
      'workerId': workerId,
      'executionId': executionId,
      'asset': asset,
    },
  );

  /// Finalizes a claimed execution with the worker's outcome. Exactly-once:
  /// stale or duplicate reports are no-ops. On success of a published-app run
  /// the Firestore history/usage documents are written afterwards —
  /// best-effort, exactly as the legacy synchronous path did.
  _i2.Future<void> reportResult(
    _i1.UuidValue workerId,
    _i1.UuidValue executionId,
    _i26.ExecutionOutcome outcome,
  ) => caller.callServerEndpoint<void>(
    'computeWorker',
    'reportResult',
    {
      'workerId': workerId,
      'executionId': executionId,
      'outcome': outcome,
    },
  );

  /// Marks the worker as stopped. Any execution it was still running is
  /// recovered by the sweeper via lease expiry.
  _i2.Future<void> deregister(_i1.UuidValue workerId) =>
      caller.callServerEndpoint<void>(
        'computeWorker',
        'deregister',
        {'workerId': workerId},
      );
}

/// Machine login endpoint for compute workers. Unauthenticated by design —
/// this is where workers obtain their session.
///
/// Two flavours:
///  * [login] — the cloud Container App Job pool, gated by the shared
///    `computeWorkerSecret` (Key Vault in production).
///  * [loginRemote] — a creator's self-hosted compute client, gated by a
///    revocable per-machine credential minted at `discoman-compute login`.
///    The client never stores the creator's own session: beta refresh tokens
///    are single-use rotating (fragile to persist) and a creator session
///    would grant far more than claim/report rights.
///
/// Both mint standard Serverpod JWT sessions via the auth-core token manager,
/// so workers reuse the exact same client-side session plumbing as the apps.
/// {@category Endpoint}
class EndpointWorkerAuth extends _i1.EndpointRef {
  EndpointWorkerAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'workerAuth';

  /// Exchanges the shared cloud worker secret for a session carrying
  /// `discoman.computeWorker`.
  _i2.Future<_i4.AuthSuccess> login(String workerSecret) =>
      caller.callServerEndpoint<_i4.AuthSuccess>(
        'workerAuth',
        'login',
        {'workerSecret': workerSecret},
      );

  /// Exchanges a per-machine compute-client token for a session carrying
  /// `discoman.remoteWorker`, bound (via the credential row) to the creator.
  _i2.Future<_i4.AuthSuccess> loginRemote(String clientToken) =>
      caller.callServerEndpoint<_i4.AuthSuccess>(
        'workerAuth',
        'loginRemote',
        {'clientToken': clientToken},
      );
}

/// The caller's account as a whole.
/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// The account behind the session.
  _i2.Future<_i41.AccountInfo> me() =>
      caller.callServerEndpoint<_i41.AccountInfo>(
        'account',
        'me',
        {},
      );

  /// Removes everything the server holds about the caller: their projects
  /// with everything a project deletion removes, their part in others'
  /// projects, their run history, their traces in others' usage, their
  /// profile and the account itself.
  ///
  /// An account with a password must present it as [password]; without it
  /// the call fails with `recentSignInRequired`, and with a wrong one with
  /// `invalidPassword`. An account that signs in through Google has none to
  /// ask for.
  _i2.Future<void> delete(String? password) => caller.callServerEndpoint<void>(
    'account',
    'delete',
    {'password': password},
  );
}

/// What a creator's compute client needs to link a script to a project.
///
/// The client reads the script on the creator's own machine and infers its
/// contract there, so the script itself never reaches us. These two calls carry
/// everything else: which projects they can link, and the contract that came
/// out of the one they chose.
/// {@category Endpoint}
class EndpointCreatorScript extends _i1.EndpointRef {
  EndpointCreatorScript(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'creatorScript';

  /// The creator's projects, newest first, for the client's project chooser.
  _i2.Future<List<_i42.CreatorProjectSummary>> listProjects() =>
      caller.callServerEndpoint<List<_i42.CreatorProjectSummary>>(
        'creatorScript',
        'listProjects',
        {},
      );

  /// Whether [projectId] keeps its script in Discoman so every one of the
  /// creator's computers gets it. Null until the creator has chosen.
  _i2.Future<bool?> getScriptSync(String projectId) =>
      caller.callServerEndpoint<bool?>(
        'creatorScript',
        'getScriptSync',
        {'projectId': projectId},
      );

  /// Chooses whether [projectId] keeps its script in Discoman. Turning it off
  /// deletes the copy held here; the computers keep theirs.
  _i2.Future<void> setScriptSync(
    String projectId,
    bool enabled,
  ) => caller.callServerEndpoint<void>(
    'creatorScript',
    'setScriptSync',
    {
      'projectId': projectId,
      'enabled': enabled,
    },
  );

  /// Keeps the script just linked on one computer in Discoman, for the
  /// creator's other computers. Only for projects that chose to.
  _i2.Future<void> uploadSyncedScript(
    String projectId,
    String source,
    String fingerprint,
  ) => caller.callServerEndpoint<void>(
    'creatorScript',
    'uploadSyncedScript',
    {
      'projectId': projectId,
      'source': source,
      'fingerprint': fingerprint,
    },
  );

  /// Keeps a script the creator uploaded in the web app in Discoman, for every
  /// computer they run Discoman Compute on, and records its contract as
  /// linking it on a computer would. The script still runs only on those
  /// computers.
  _i2.Future<void> keepScriptInDiscoman(
    String projectId,
    String source,
  ) => caller.callServerEndpoint<void>(
    'creatorScript',
    'keepScriptInDiscoman',
    {
      'projectId': projectId,
      'source': source,
    },
  );

  /// Moves a project's waiting runs into the cloud, after its script has been
  /// uploaded.
  ///
  /// Called once the web app has switched a project off the creator's machine.
  /// Runs already queued were stamped for that machine, and a mode change does
  /// not restamp them — so without this, a creator who moved to the cloud
  /// because their machine was overloaded would watch the backlog keep waiting
  /// for exactly that machine.
  ///
  /// Returns how many runs moved.
  _i2.Future<int> migrateQueuedRunsToCloud(String projectId) =>
      caller.callServerEndpoint<int>(
        'creatorScript',
        'migrateQueuedRunsToCloud',
        {'projectId': projectId},
      );

  /// Records the contract the client read from a script on the creator's
  /// machine, and marks the project as running there from now on.
  ///
  /// [fingerprint] identifies the file the contract came from. It is stored but
  /// not yet enforced at run time — a creator who edits their script keeps the
  /// old contract until they publish again.
  _i2.Future<void> publishContract(
    String projectId,
    _i43.ContractDraft draft,
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

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i3.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i3.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
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
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i60.Client? httpClientOverride,
  }) : super(
         host,
         _i61.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    deviceSignIn = EndpointDeviceSignIn(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    computeSettings = EndpointComputeSettings(this);
    computeWorker = EndpointComputeWorker(this);
    workerAuth = EndpointWorkerAuth(this);
    account = EndpointAccount(this);
    creatorScript = EndpointCreatorScript(this);
    modules = Modules(this);
  }

  late final EndpointDeviceSignIn deviceSignIn;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointComputeSettings computeSettings;

  late final EndpointComputeWorker computeWorker;

  late final EndpointWorkerAuth workerAuth;

  late final EndpointAccount account;

  late final EndpointCreatorScript creatorScript;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'deviceSignIn': deviceSignIn,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'computeSettings': computeSettings,
    'computeWorker': computeWorker,
    'workerAuth': workerAuth,
    'account': account,
    'creatorScript': creatorScript,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
