import 'dart:io';

import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import '../worker_config.dart';
import 'file_auth_storage.dart';
import 'session.dart';

/// Thrown when the stored machine token is missing, revoked, or otherwise
/// rejected — the worker cannot run and the creator must re-run `login`.
class RemoteAuthException implements Exception {
  RemoteAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Signs [email] in and returns a [WorkerSession] carrying their own Serverpod
/// session.
///
/// Used wherever a creator is present — the `login` and `link` commands, and
/// the desktop app. None of them persist the session: a creator session grants
/// far more than the machine token does (see `loginRemote` on the server), so
/// it lives only as long as the command or the window. The caller closes the
/// client.
///
/// Throws [RemoteAuthException] with a readable message on any failure.
Future<WorkerSession> signIn(
  WorkerConfig config, {
  required String email,
  required String password,
  SavedSignInStore? remember,
}) async {
  if (email.trim().isEmpty || password.isEmpty) {
    throw RemoteAuthException('Email and password are both required.');
  }

  final session = _creatorSession(config, email.trim(), remember);
  try {
    final authSuccess = await session.client.emailIdp.login(
      email: email.trim(),
      password: password,
    );
    await session.sessionManager.updateSignedInUser(authSuccess);
    return session;
  } on EmailAccountLoginException catch (error) {
    session.client.close();
    throw RemoteAuthException(switch (error.reason) {
      EmailAccountLoginExceptionReason.invalidCredentials =>
        'Email or password is incorrect.',
      EmailAccountLoginExceptionReason.tooManyAttempts =>
        'Too many attempts. Try again in a few minutes.',
      _ => 'Sign-in failed.',
    });
  } catch (error) {
    session.client.close();
    throw RemoteAuthException('Could not reach Discoman to sign in: $error');
  }
}

/// Signs the creator saved in [store] back in, or returns null when nobody
/// is saved or Discoman no longer accepts the saved sign-in.
///
/// Throws [RemoteAuthException] when Discoman cannot be reached, leaving the
/// saved sign-in for the next try.
Future<({WorkerSession session, String email})?> restoreSignIn(
  WorkerConfig config,
  SavedSignInStore store,
) async {
  final saved = store.read();
  if (saved == null) return null;

  final session = _creatorSession(config, saved.email, store);
  try {
    final authSuccess = await session.client.jwtRefresh.refreshAccessToken(
      refreshToken: saved.refreshToken,
    );
    await session.sessionManager.updateSignedInUser(authSuccess);
    return (session: session, email: saved.email);
  } on ServerpodClientException catch (error) {
    session.client.close();
    // The backend answered and said no: the saved sign-in is spent.
    if (error.statusCode >= 400 && error.statusCode < 500) {
      store.clear();
      return null;
    }
    throw RemoteAuthException('Could not reach Discoman to sign in: $error');
  } on SerializableException {
    // A refresh token the backend refuses (expired, used, revoked).
    session.client.close();
    store.clear();
    return null;
  } catch (error) {
    session.client.close();
    throw RemoteAuthException('Could not reach Discoman to sign in: $error');
  }
}

/// A session for a creator. With [remember], every refresh token the session
/// is issued (signing in, and each time the session manager rotates it) is
/// saved, so the app can sign the creator back in next time.
WorkerSession _creatorSession(
  WorkerConfig config,
  String email,
  SavedSignInStore? remember,
) => buildWorkerSession(
  config.serverUrl,
  storage: remember == null ? null : _RememberingStorage(remember, email),
);

class _RememberingStorage implements ClientAuthSuccessStorage {
  _RememberingStorage(this._store, this._email);

  final SavedSignInStore _store;
  final String _email;
  AuthSuccess? _authSuccess;

  @override
  Future<AuthSuccess?> get() async => _authSuccess;

  @override
  Future<void> set(AuthSuccess? data) async {
    _authSuccess = data;
    final refreshToken = data?.refreshToken;
    if (refreshToken != null) {
      _store.write(SavedSignIn(email: _email, refreshToken: refreshToken));
    }
  }
}

/// As [signIn], but reads the credentials from the terminal.
Future<WorkerSession> signInInteractively(WorkerConfig config) async {
  stdout.write('Email: ');
  final email = stdin.readLineSync()?.trim() ?? '';
  final password = _promptHidden('Password: ');
  return signIn(config, email: email, password: password);
}

/// Mints a revocable per-machine credential for [session]'s creator and stores
/// its token at `~/.discoman/credentials.json`.
///
/// This is what lets the worker run later without the creator's own session.
/// Returns the name the machine will show under in GBot.
Future<String> enrolMachine(WorkerSession session, WorkerConfig config) async {
  final created = await session.client.computeSettings
      .createComputeClientCredential(config.hostname);
  MachineTokenStore.defaultLocation().write(
    created.token,
    credentialId: created.info.credentialId.uuid,
  );
  return created.info.name;
}

/// Keeps this machine's stored credential when it is still live for
/// [session]'s creator, and enrols the machine otherwise.
///
/// Signing in again would otherwise add another entry for the same computer.
Future<void> ensureMachineEnrolled(
  WorkerSession session,
  WorkerConfig config,
) async {
  final store = MachineTokenStore.defaultLocation();
  final credentialId = store.readCredentialId();
  if (store.read() != null && credentialId != null) {
    final credentials = await session.client.computeSettings
        .listComputeClientCredentials();
    if (credentials.any(
      (c) => c.credentialId.uuid == credentialId && !c.revoked,
    )) {
      return;
    }
  }
  await enrolMachine(session, config);
}

/// The `login` flow (interactive, run once per machine).
///
/// Prompts for the creator's email + password, signs in to Discoman, mints a per-machine compute
/// client credential, and persists ONLY the returned plaintext token to
/// `~/.discoman/credentials.json`. The Serverpod session is discarded when the
/// process exits — it is never written to disk.
Future<int> runRemoteLogin(WorkerConfig config) async {
  final WorkerSession session;
  try {
    session = await signInInteractively(config);
  } on RemoteAuthException catch (error) {
    stderr.writeln(error.message);
    return 1;
  }

  try {
    final name = await enrolMachine(session, config);

    stdout.writeln('Registered compute client "$name".');
    stdout.writeln(
      'Machine token saved to ${MachineTokenStore.defaultLocation().path}.',
    );
    stdout.writeln("Run 'discoman-compute start' to begin processing runs.");
    return 0;
  } catch (error) {
    stderr.writeln('Login failed while registering this machine: $error');
    return 1;
  } finally {
    session.client.close();
  }
}

/// The runtime flow (flow b): reads the stored machine token and exchanges it
/// via `workerAuth.loginRemote` for a Serverpod session, installed on
/// [session]. Throws [RemoteAuthException] when there is no token or the server
/// rejects it (revoked/invalid) so the caller can print the recovery hint.
Future<void> remoteRuntimeLogin(WorkerSession session) async {
  final store = MachineTokenStore.defaultLocation();
  final token = store.read();
  if (token == null) {
    throw RemoteAuthException(
      "No machine token found. Run 'discoman-compute login' first.",
    );
  }

  try {
    final authSuccess = await session.client.workerAuth.loginRemote(token);
    await session.sessionManager.updateSignedInUser(authSuccess);
  } catch (_) {
    // A rejected token cannot be recovered here; the creator must re-run login.
    throw RemoteAuthException("Run 'discoman-compute login' again.");
  }
}

/// Prompts for a secret on stdin with terminal echo disabled where possible.
String _promptHidden(String prompt) {
  stdout.write(prompt);
  var restored = false;
  final hasTerminal = stdin.hasTerminal;
  if (hasTerminal) {
    try {
      stdin.echoMode = false;
      restored = true;
    } catch (_) {
      // Some terminals disallow toggling echo; fall back to visible input.
    }
  }
  final line = stdin.readLineSync() ?? '';
  if (restored) {
    try {
      stdin.echoMode = true;
    } catch (_) {
      // Ignore: best effort to restore the terminal.
    }
    stdout.writeln();
  }
  return line.trim();
}
