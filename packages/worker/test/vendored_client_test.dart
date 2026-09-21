// Guards the two things about the vendored client that the analyser cannot see.
//
// The copy carries only the endpoints and models this worker needs. Both of the
// things below are reached by name at runtime rather than through a compiled
// reference, so trimming either one away leaves the package analysing perfectly
// clean and failing only once it is talking to a real server.

import 'package:discoman_client/discoman_client.dart';
// Prefixed: this package exports a `Protocol` of its own.
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core;
import 'package:test/test.dart';

void main() {
  test('the client carries an endpoint the JWT session manager can find', () {
    // ClientAuthSessionManager builds its refresher with
    // `getEndpointOfType<EndpointRefreshJwtTokens>()`, which scans the client's
    // endpoints by type. The worker never calls jwtRefresh itself, so nothing
    // else keeps it alive, and the failure lands on the first authenticated
    // call after a sign-in.
    final client = Client('http://localhost:8080/');

    expect(
      () => client.getEndpointOfType<auth_core.EndpointRefreshJwtTokens>(),
      returnsNormally,
    );
  });

  test('ScriptRunException still deserialises by class name', () {
    // The server throws this from every endpoint the worker calls. The client
    // resolves it through the serialization registry, and a miss there is
    // swallowed: the typed exception quietly becomes a generic client error and
    // every `on ScriptRunException` block stops matching.
    final decoded = Protocol().deserializeByClassName({
      'className': 'ScriptRunException',
      'data': {
        'message': 'Invalid worker credentials.',
        'reason': 'unauthenticated',
      },
    });

    expect(decoded, isA<ScriptRunException>());
    expect((decoded as ScriptRunException).reason, 'unauthenticated');
  });
}
