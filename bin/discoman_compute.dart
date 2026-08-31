import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:discoman_compute/src/auth/remote_auth.dart';
import 'package:discoman_compute/src/scripts/link_script.dart';
import 'package:discoman_compute/src/worker_config.dart';
import 'package:discoman_compute/src/worker_loop.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<int>(
          'discoman-compute',
          'Discoman compute worker: runs queued Python executions in the cloud '
              'pool or on a creator\'s own machine.',
        )
        ..addCommand(StartCommand())
        ..addCommand(LoginCommand())
        ..addCommand(LinkCommand());

  try {
    final code = await runner.run(arguments) ?? 0;
    exit(code);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exit(64);
  }
}

/// `discoman-compute start` — runs the worker loop (cloud or remote).
class StartCommand extends Command<int> {
  StartCommand() {
    argParser
      ..addOption(
        'mode',
        allowed: ['cloud', 'remote'],
        help:
            'Which lane to drain. Falls back to the WORKER_MODE env var, '
            'then "remote".',
      )
      ..addOption(
        'server-url',
        help:
            'Serverpod server URL. Falls back to DISCOMAN_API_URL, then '
            'the production backend.',
      )
      ..addOption(
        'python',
        help:
            'Python interpreter for remote runs. Falls back to '
            'DISCOMAN_PYTHON, then "python3".',
      )
      ..addOption(
        'name',
        help:
            'Hostname reported on register. Defaults to this machine\'s name.',
      );
  }

  @override
  String get name => 'start';

  @override
  String get description => 'Start processing queued executions.';

  @override
  Future<int> run() async {
    final WorkerConfig config;
    try {
      config = WorkerConfig.resolve(
        modeArg: argResults?['mode'] as String?,
        serverUrlArg: argResults?['server-url'] as String?,
        pythonArg: argResults?['python'] as String?,
        nameArg: argResults?['name'] as String?,
      );
    } on FormatException catch (error) {
      stderr.writeln(error.message);
      return 64;
    }
    return runWorker(config);
  }
}

/// `discoman-compute login` — interactive one-time machine enrollment.
class LoginCommand extends Command<int> {
  LoginCommand() {
    argParser
      ..addOption(
        'server-url',
        help:
            'Serverpod server URL. Falls back to DISCOMAN_API_URL, then '
            'the production backend.',
      )
      ..addOption(
        'name',
        help: 'Name for this machine credential. Defaults to the hostname.',
      );
  }

  @override
  String get name => 'login';

  @override
  String get description =>
      'Enroll this machine as a self-hosted compute client.';

  @override
  Future<int> run() async {
    final config = WorkerConfig.resolve(
      modeArg: 'remote',
      serverUrlArg: argResults?['server-url'] as String?,
      nameArg: argResults?['name'] as String?,
    );
    return runRemoteLogin(config);
  }
}

/// `discoman-compute link` — attaches a Python script on this machine to one of
/// the creator's projects.
class LinkCommand extends Command<int> {
  LinkCommand() {
    argParser
      ..addOption(
        'script',
        help: 'Path to the Python script. Prompts for it when omitted.',
      )
      ..addOption(
        'project',
        help: 'Project id to link to. Prompts with a list when omitted.',
      )
      ..addOption(
        'server-url',
        help:
            'Serverpod server URL. Falls back to DISCOMAN_API_URL, then '
            'the production backend.',
      );
  }

  @override
  String get name => 'link';

  @override
  String get description =>
      'Link a Python script on this machine to one of your projects.';

  @override
  Future<int> run() async {
    final config = WorkerConfig.resolve(
      modeArg: 'remote',
      serverUrlArg: argResults?['server-url'] as String?,
    );
    return runLink(
      config,
      scriptPathArg: argResults?['script'] as String?,
      projectIdArg: argResults?['project'] as String?,
    );
  }
}
