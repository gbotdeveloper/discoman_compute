import 'dart:io';

import 'package:discoman_worker/src/external_code.dart';
import 'package:discoman_worker/src/settings/worker_settings.dart';
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

  group('paused projects', () {
    test('survive a round trip', () {
      store.save(const WorkerSettings(pausedProjectIds: {'b', 'a'}));

      expect(store.load().pausedProjectIds, {'a', 'b'});
    });

    test('an empty set writes no key at all', () {
      store.save(const WorkerSettings(pythonPath: '/p'));

      expect(store.file.readAsStringSync(), isNot(contains('paused')));
    });

    test('a stored interpreter is not lost when pauses change', () {
      store.save(const WorkerSettings(pythonPath: '/usr/bin/python3'));

      store.save(store.load().copyWith(pausedProjectIds: {'a'}));

      final loaded = store.load();
      expect(loaded.pythonPath, '/usr/bin/python3');
      expect(loaded.pausedProjectIds, {'a'});
    });

    test('pauses are not lost when the interpreter changes', () {
      // Both halves are written through the same file; a save that rebuilt
      // WorkerSettings from scratch used to drop the other one.
      store.save(const WorkerSettings(pausedProjectIds: {'a'}));

      store.save(store.load().copyWith(pythonPath: '/usr/bin/python3'));

      final loaded = store.load();
      expect(loaded.pausedProjectIds, {'a'});
      expect(loaded.pythonPath, '/usr/bin/python3');
    });

    test('junk in the file reads as no pauses', () {
      store.file.parent.createSync(recursive: true);
      store.file.writeAsStringSync('{"pausedProjectIds": "nope"}');

      expect(store.load().pausedProjectIds, isEmpty);
    });
  });

  group('external code', () {
    test('survives a round trip with the other settings', () {
      store.save(
        const WorkerSettings(
          pythonPath: '/usr/bin/python3',
          externalCode: {
            'p1': [
              ExternalCodeSource(name: 'MATLAB', version: 'R2024b'),
              ExternalCodeSource(name: 'Library', gitPath: '/src/lib'),
            ],
          },
        ),
      );

      store.save(store.load().copyWith(pausedProjectIds: {'p1'}));

      final loaded = store.load();
      expect(loaded.pythonPath, '/usr/bin/python3');
      final code = loaded.externalCode['p1']!;
      expect(code.map((c) => c.name), ['MATLAB', 'Library']);
      expect(code.first.version, 'R2024b');
      expect(code.last.gitPath, '/src/lib');
    });

    test('junk entries are dropped', () {
      store.file.parent.createSync(recursive: true);
      store.file.writeAsStringSync(
        '{"externalCode": {"p1": [{"name": ""}, 3, {"name": "Ok"}]}}',
      );

      expect(store.load().externalCode['p1']!.single.name, 'Ok');
    });
  });

  group('parallel runs', () {
    test('one at a time unless chosen otherwise', () {
      expect(store.load().parallelRuns, 1);
    });

    test('survive a change to another setting', () {
      store.save(const WorkerSettings(parallelRuns: 4));
      store.save(store.load().copyWith(pythonPath: '/usr/bin/python3'));

      expect(store.load().parallelRuns, 4);
    });

    test('junk reads as one', () {
      store.file.parent.createSync(recursive: true);
      store.file.writeAsStringSync('{"parallelRuns": -2}');

      expect(store.load().parallelRuns, 1);
    });
  });
}
