# discoman_client (vendored)

A copy of the Serverpod client generated from the discoman backend. It is what
lets this worker call the server with typed methods instead of hand-written
HTTP.

**Do not edit these files.** They are generated output. The source of truth is
`discoman_client/` in the backend repository, produced by `serverpod generate`.

## What it contains

Endpoint call stubs and the model classes they send and receive — the shape of
the protocol, nothing else. There is no server logic here: no queue engine, no
database access, no credentials. A call like `claimNext` is one line that posts
to `computeWorker/claimNext` and parses the reply.

Doc comments have been removed from this copy; the upstream files carry them.

## Updating it

When the backend protocol changes, copy `lib/`, `pubspec.yaml`,
`analysis_options.yaml` and `.gitignore` over from the generated package, strip
`///` lines, and drop the `resolution: workspace` line from `pubspec.yaml` —
that line ties the package to the backend's pub workspace and stops it
resolving on its own.

Then rebuild the worker and run one real execution end to end. Compilation
proves the method signatures; only a real run proves the serialization registry,
because a missing type fails at runtime rather than at build time.
