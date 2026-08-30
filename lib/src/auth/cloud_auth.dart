import 'session.dart';

/// Authenticates a cloud worker: exchanges the shared cloud secret for a
/// Serverpod session carrying `discoman.computeWorker`, then installs it on the
/// session manager so every subsequent call is authenticated.
Future<void> cloudLogin(WorkerSession session, String workerSecret) async {
  if (workerSecret.isEmpty) {
    throw StateError(
      'WORKER_AUTH_SECRET is not set; a cloud worker cannot authenticate.',
    );
  }
  final authSuccess = await session.client.workerAuth.login(workerSecret);
  await session.sessionManager.updateSignedInUser(authSuccess);
}
