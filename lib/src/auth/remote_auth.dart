import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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

/// The `login` flow (interactive, run once per machine).
///
/// Prompts for the creator's email + password, exchanges them with Firebase for
/// an ID token, trades that for a Serverpod session, mints a per-machine compute
/// client credential, and persists ONLY the returned plaintext token to
/// `~/.discoman/credentials.json`. The Serverpod session is discarded when the
/// process exits — it is never written to disk.
Future<int> runRemoteLogin(WorkerConfig config) async {
  final apiKey = config.firebaseApiKey;
  if (apiKey.isEmpty) {
    stderr.writeln(
      'FIREBASE_API_KEY is not set. Set it to the Firebase Web API key of the '
      'Discoman project before running `discoman-compute login`.',
    );
    return 1;
  }

  stdout.write('Email: ');
  final email = stdin.readLineSync()?.trim() ?? '';
  final password = _promptHidden('Password: ');
  if (email.isEmpty || password.isEmpty) {
    stderr.writeln('Email and password are both required.');
    return 1;
  }

  final String idToken;
  try {
    idToken = await _firebaseSignIn(apiKey, email, password);
  } on RemoteAuthException catch (error) {
    stderr.writeln(error.message);
    return 1;
  }

  final session = buildWorkerSession(config.serverUrl);
  try {
    final authSuccess = await session.client.firebaseIdp.login(
      idToken: idToken,
    );
    await session.sessionManager.updateSignedInUser(authSuccess);

    final created = await session.client.computeSettings
        .createComputeClientCredential(config.hostname);

    final store = MachineTokenStore.defaultLocation();
    store.write(created.token);

    stdout.writeln('Registered compute client "${created.info.name}".');
    stdout.writeln('Machine token saved to ${store.path}.');
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

/// Exchanges [email] + [password] for a Firebase ID token via the Identity
/// Toolkit REST API. Throws [RemoteAuthException] with a readable message on any
/// failure.
Future<String> _firebaseSignIn(
  String apiKey,
  String email,
  String password,
) async {
  final uri = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword'
    '?key=$apiKey',
  );
  http.Response response;
  try {
    response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
  } catch (error) {
    throw RemoteAuthException('Could not reach Firebase to sign in: $error');
  }

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded['idToken'] is String) {
      return decoded['idToken'] as String;
    }
    throw RemoteAuthException(
      'Firebase sign-in returned an unexpected response.',
    );
  }

  var detail = 'Firebase sign-in failed (HTTP ${response.statusCode}).';
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded['error'] is Map) {
      final message = (decoded['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) {
        detail = 'Firebase sign-in failed: $message';
      }
    }
  } catch (_) {
    // Keep the generic message.
  }
  throw RemoteAuthException(detail);
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
