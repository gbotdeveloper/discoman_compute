# discoman_client (vendored)

A copy of the Serverpod client generated from the discoman backend, trimmed to
the endpoints and models this worker uses. It is what lets the worker call the
server with typed methods instead of hand-written HTTP.

**Do not edit these files.** They are generated output, copied by
`tool/sync_compute_client.dart` in the backend repository. To update them,
run `serverpod generate` there and then run that script.

## What was left out

Endpoints the worker never calls, and the models only those endpoints use.
The kept set is computed from the source on every sync: the endpoints are
listed in the script, the models are whatever those endpoints' signatures, the
worker's own source, and the protocol's exceptions reach.

`jwtRefresh` is kept although nothing calls it — the auth-core session manager
looks it up by type at runtime when a JWT session refreshes.

`ScriptRunException` is kept for the same kind of reason: the server throws it
from every endpoint the worker calls, and an exception that is not in the
serialization registry is silently downgraded to a generic client error.
