import 'dart:io';

import 'package:discoman_worker/src/remote_worker.dart';
import 'package:discoman_worker/src/scripts/script_store.dart';
import 'package:discoman_worker/src/settings/worker_settings.dart';
import 'package:discoman_worker/src/worker_config.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late ScriptStore scripts;
  late WorkerSettingsStore settings;
  late RemoteWorker worker;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_served');
    scripts = ScriptStore(Directory('${temp.path}/scripts'))
      ..store('alpha', 'def run():\n    return 1\n')
      ..store('beta', 'def run():\n    return 2\n');
    settings = WorkerSettingsStore(File('${temp.path}/settings.json'));
    worker = RemoteWorker(
      WorkerConfig.resolve(),
      scriptStore: scripts,
      settingsStore: settings,
    );
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('every linked script is served by default', () {
    expect(worker.servedProjectIds(), ['alpha', 'beta']);
  });

  test('a switched-off project is left out', () {
    settings.save(const WorkerSettings(pausedProjectIds: {'alpha'}));

    expect(worker.servedProjectIds(), ['beta']);
  });

  test('a pause saved after the worker was built still counts', () {
    // The loop asks on every poll, so switching a project off reaches the
    // server on the next one — no restart, no message to the worker.
    expect(worker.servedProjectIds(), ['alpha', 'beta']);

    settings.save(const WorkerSettings(pausedProjectIds: {'beta'}));

    expect(worker.servedProjectIds(), ['alpha']);
  });

  test('a pause for a project with no script here changes nothing', () {
    settings.save(const WorkerSettings(pausedProjectIds: {'gamma'}));

    expect(worker.servedProjectIds(), ['alpha', 'beta']);
  });

  group('project run limits', () {
    test('a project at its limit is left out until a run ends', () {
      expect(
        claimableProjectIds(['alpha', 'beta'], {'alpha': 1}, {'alpha': 1}),
        ['beta'],
      );
      expect(
        claimableProjectIds(['alpha', 'beta'], {'alpha': 1}, {'alpha': 0}),
        ['alpha', 'beta'],
      );
    });

    test('a project without a limit takes every worker', () {
      expect(claimableProjectIds(['alpha'], const {}, {'alpha': 30}), [
        'alpha',
      ]);
    });

    test('a limit for a project not served changes nothing', () {
      expect(claimableProjectIds(['beta'], {'alpha': 1}, {'alpha': 1}), [
        'beta',
      ]);
    });
  });
}
