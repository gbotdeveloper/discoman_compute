import 'dart:io';

import 'package:discoman_compute/src/settings/worker_settings.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late WorkerSettingsStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_settings');
    store = WorkerSettingsStore(File('${temp.path}/nested/settings.json'));
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('reads back what was written', () {
    store.save(const WorkerSettings(pythonPath: '/opt/py/bin/python3'));

    expect(store.load().pythonPath, '/opt/py/bin/python3');
  });

  test('a missing file reads as no preference', () {
    expect(store.load().pythonPath, isNull);
  });

  test('a corrupt file reads as no preference rather than throwing', () {
    store.file.parent.createSync(recursive: true);
    store.file.writeAsStringSync('{ this is not json');

    expect(store.load().pythonPath, isNull);
  });

  test('a blank path is stored as no preference', () {
    store.save(const WorkerSettings(pythonPath: '   '));

    expect(store.load().pythonPath, isNull);
  });

  test('saving leaves no temp file behind', () {
    store.save(const WorkerSettings(pythonPath: '/usr/bin/python3'));

    final leftovers = store.file.parent
        .listSync()
        .map((e) => e.path)
        .where((path) => path.endsWith('.tmp'));
    expect(leftovers, isEmpty);
  });
}
