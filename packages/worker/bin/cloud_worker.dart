import 'dart:io';

import 'package:discoman_worker/src/worker_config.dart';
import 'package:discoman_worker/src/worker_loop.dart';

/// Entry point for the cloud pool's container image.
///
/// Separate from the `discoman-compute` CLI on purpose: the Container App Job
/// runs this unattended, and a rename or a changed flag on a CLI command it
/// happened to share would break the production image with nothing to catch it.
/// There is one mode here and no arguments to get wrong.
Future<void> main() async {
  exit(await runWorker(WorkerConfig.resolve(modeArg: 'cloud')));
}
