import 'package:discoman_client/discoman_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

import 'in_memory_auth_storage.dart';

/// A Serverpod [Client] paired with the [ClientAuthSessionManager] that carries
/// its auth token on every call.
///
/// Both worker modes use the same plumbing the apps use: a session manager
/// installed as the client's `authKeyProvider`, with the [AuthSuccess] held in
/// memory only. What differs is how the session is obtained (see cloud_auth.dart
/// and remote_auth.dart).
class WorkerSession {
  WorkerSession(this.client, this.sessionManager);

  final Client client;
  final ClientAuthSessionManager sessionManager;
}

/// Builds a client whose session token is managed by an in-memory
/// [ClientAuthSessionManager].
WorkerSession buildWorkerSession(String serverUrl) {
  final client = Client(serverUrl);
  final sessionManager = ClientAuthSessionManager(
    caller: client.modules.serverpod_auth_core,
    storage: InMemoryAuthSuccessStorage(),
  );
  client.authKeyProvider = sessionManager;
  return WorkerSession(client, sessionManager);
}
