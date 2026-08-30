import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

/// Holds the Serverpod [AuthSuccess] for the lifetime of the process only.
///
/// Both worker modes use this: cloud has no durable credential to persist, and
/// remote deliberately never persists the Serverpod session (its rotating beta
/// refresh token is fragile to store and would grant far more than
/// claim/report rights). The durable thing in remote mode is the machine token
/// file, held separately by [MachineTokenStore].
class InMemoryAuthSuccessStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _authSuccess;

  @override
  Future<AuthSuccess?> get() async => _authSuccess;

  @override
  Future<void> set(AuthSuccess? data) async => _authSuccess = data;
}
