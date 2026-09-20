# Cloud compute worker image (Azure Container App Job).
#
# Build context is this package, so from here:
#   docker build -t discoman-compute .
#
# Stage 1 compiles the Dart worker to an AOT snapshot; stage 2 is a slim Python
# runtime carrying the pinned scientific stack plus the dartaotruntime + snapshot.

# ---------------------------------------------------------------------------
# Stage 1: build the Dart worker.
# ---------------------------------------------------------------------------
FROM dart:3.11.4 AS dart_builder

# Only the worker package is built here. The repository root is the Flutter
# desktop app, which this image has no SDK for and the cloud worker does not
# need — .dockerignore keeps it out of the context entirely.
WORKDIR /app/packages/worker

# Manifests and the vendored client first, so a source-only change reuses the
# resolved dependency layer.
COPY packages/worker/pubspec.yaml packages/worker/pubspec.lock ./
COPY packages/discoman_client/ ../discoman_client/
RUN dart pub get

COPY packages/worker/ ./
RUN dart compile aot-snapshot bin/cloud_worker.dart -o /app/discoman_compute.aot

# ---------------------------------------------------------------------------
# Stage 2: minimal Python runtime.
# ---------------------------------------------------------------------------
FROM python:3.11-slim

# fonts-dejavu-core: matplotlib needs a font on headless machines.
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Same pinned scientific stack the executor used (no FastAPI/uvicorn).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache/pip

# Fail the build early if any runtime import is broken.
RUN python -c "import matplotlib; matplotlib.use('Agg'); import numpy, pandas, PIL"

# The Dart runtime + snapshot change most often, so copy them last.
COPY --from=dart_builder /usr/lib/dart/bin/dartaotruntime .
COPY --from=dart_builder /app/discoman_compute.aot .

# Run as a non-root user.
RUN useradd -u 10001 -m worker && chown -R worker:worker /app
USER worker

RUN chmod +x dartaotruntime

ENV MPLBACKEND=Agg \
    WORKER_MODE=cloud

# Drain the cloud queue and exit. DISCOMAN_API_URL and WORKER_AUTH_SECRET are
# provided by the Container App Job environment / Key Vault.
CMD ["./dartaotruntime", "discoman_compute.aot"]
