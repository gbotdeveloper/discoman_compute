import 'dart:io';

import 'package:discoman_compute/src/remote_worker.dart';
import 'package:discoman_compute/src/scripts/script_store.dart';
import 'package:discoman_compute/src/settings/worker_settings.dart';
import 'package:discoman_compute/src/worker_config.dart';
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
      WorkerConfig.resolve(modeArg: 'remote'),
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
}
