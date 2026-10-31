import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:discoman_worker/src/auth/remote_auth.dart';
import 'package:discoman_worker/src/python/imports.dart';
import 'package:discoman_worker/src/python/python_installer.dart';
import 'package:discoman_worker/src/scripts/link_script.dart';
import 'package:discoman_worker/src/scripts/script_store.dart';
import 'package:discoman_worker/src/settings/worker_settings.dart';
import 'package:discoman_worker/src/worker_config.dart';
import 'package:discoman_worker/src/worker_loop.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<int>(
          'discoman-compute',
          'Discoman compute worker: runs queued Python executions in the cloud '
              'pool or on a creator\'s own machine.',
        )
        ..addCommand(StartCommand())
        ..addCommand(LoginCommand())
        ..addCommand(LinkCommand())
        ..addCommand(InstallPythonCommand());

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
      )
      ..addOption(
        'parallel',
        help:
            'How many runs to take at once. Defaults to what the desktop app '
            'saved, then 1.',
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
    final parallelArg = argResults?['parallel'] as String?;
    final parallelRuns = parallelArg == null ? null : int.tryParse(parallelArg);
    if (parallelArg != null && (parallelRuns == null || parallelRuns < 1)) {
      stderr.writeln('--parallel takes a whole number of at least 1.');
      return 64;
    }
    return runWorker(config, parallelRuns: parallelRuns);
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

/// `discoman-compute install-python` — downloads Discoman's own Python into
/// ~/.discoman/python and makes it the one remote runs use.
class InstallPythonCommand extends Command<int> {
  InstallPythonCommand() {
    argParser.addMultiOption(
      'package',
      help: 'An extra pip package to install. Repeat for more.',
    );
  }

  @override
  String get name => 'install-python';

  @override
  String get description =>
      'Install Python $managedPythonVersion with numpy, pandas, matplotlib '
      'and Pillow for this machine\'s runs.';

  @override
  Future<int> run() async {
    final installer = PythonInstaller();
    final scripts = ScriptStore.defaultLocation();
    PythonInstallStep? step;
    try {
      final result = await installer.install(
        packages: argResults?['package'] as List<String>? ?? const [],
        modules: {
          for (final id in scripts.linkedProjectIds())
            ...importedModules(scripts.fileFor(id).readAsStringSync()),
        }.toList(),
        confirmGuessed: _confirmGuessedPackages,
        onProgress: (progress) {
          if (progress.step != step) {
            step = progress.step;
            stdout.writeln('${progress.step.name}…');
          }
          if (progress.line != null) stdout.writeln('  ${progress.line}');
        },
      );
      final store = WorkerSettingsStore.defaultLocation();
      store.save(store.load().copyWith(pythonPath: result.path));
      stdout.writeln('Done. Remote runs now use ${result.path}');
      if (result.unavailablePackages.isNotEmpty) {
        stdout.writeln(
          'pip could not install ${result.unavailablePackages.join(', ')}. '
          'Install them yourself if your scripts need them.',
        );
      }
      return 0;
    } on PythonInstallException catch (error) {
      stderr.writeln(error.message);
      return 1;
    } catch (error) {
      stderr.writeln('Installing Python failed: $error');
      return 1;
    }
  }
}

/// Asks in the terminal before installing packages guessed from import
/// names. Installs none when nobody is there to ask.
Future<List<String>> _confirmGuessedPackages(List<String> packages) async {
  if (!stdin.hasTerminal) {
    stdout.writeln(
      'Not installing ${packages.join(', ')}: pass them with --package.',
    );
    return const [];
  }
  stdout.write(
    'Your scripts import modules this Python lacks. Install '
    '${packages.join(', ')} from PyPI? [y/N] ',
  );
  final answer = stdin.readLineSync()?.trim().toLowerCase();
  return answer == 'y' || answer == 'yes' ? packages : const [];
}
