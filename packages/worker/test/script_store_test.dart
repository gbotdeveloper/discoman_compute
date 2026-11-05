import 'dart:io';

import 'package:discoman_worker/src/scripts/script_store.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late ScriptStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_script_store');
    store = ScriptStore(Directory('${temp.path}/scripts'));
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('store writes the script under the project id', () {
    final file = store.store('abc123', 'def run():\n    return {}\n');

    expect(file.path, endsWith('abc123.py'));
    expect(file.readAsStringSync(), 'def run():\n    return {}\n');
  });

  test('store replaces a previously linked script', () {
    store.store('abc123', 'def run():\n    return {"a": 1}\n');
    store.store('abc123', 'def run():\n    return {"b": 2}\n');

    expect(store.fileFor('abc123').readAsStringSync(), contains('"b": 2'));
    // The temp file the atomic write goes through must not be left behind.
    expect(
      Directory('${temp.path}/scripts').listSync().map((e) => e.path),
      everyElement(endsWith('.py')),
    );
  });

  group('sourceDirectoryFor', () {
    test('is the folder the script was linked from', () {
      final folder = Directory('${temp.path}/work')..createSync();
      final script = File('${folder.path}/script.py')..writeAsStringSync('');

      store.store('abc123', '', sourcePath: script.path);

      expect(store.sourceDirectoryFor('abc123')?.path, folder.path);
      expect(store.linkedProjectIds(), ['abc123']);
    });

    test('is null for a script that was not linked here', () {
      store.store('abc123', '');

      expect(store.sourceDirectoryFor('abc123'), isNull);
    });

    test('is null once that folder is gone', () {
      final folder = Directory('${temp.path}/work')..createSync();
      store.store('abc123', '', sourcePath: '${folder.path}/script.py');
      folder.deleteSync(recursive: true);

      expect(store.sourceDirectoryFor('abc123'), isNull);
    });

    test('survives a copy from Discoman replacing the script', () {
      final folder = Directory('${temp.path}/work')..createSync();
      store.store('abc123', 'v1', sourcePath: '${folder.path}/script.py');
      store.store('abc123', 'v2');

      expect(store.sourceDirectoryFor('abc123')?.path, folder.path);
    });
  });

  group('linkedProjectIds', () {
    test('lists the projects this machine holds a script for', () {
      store.store('abc123', 'def run():\n    return {}\n');
      store.store('xyz789', 'def run():\n    return {}\n');

      expect(store.linkedProjectIds(), ['abc123', 'xyz789']);
    });

    test('is empty before anything has been linked', () {
      expect(store.linkedProjectIds(), isEmpty);
    });

    test('ignores anything that is not a script', () {
      store.store('abc123', 'def run():\n    return {}\n');
      File('${store.directory.path}/notes.txt').writeAsStringSync('hello');

      expect(store.linkedProjectIds(), ['abc123']);
    });
  });

  test('fingerprint is stable and prefixed with the algorithm', () {
    const source = 'def run():\n    return {}\n';

    expect(fingerprintScript(source), startsWith('sha256:'));
    expect(fingerprintScript(source), fingerprintScript(source));
  });

  test('fingerprint ignores line endings', () {
    expect(
      fingerprintScript('def run():\r\n    return {}\r\n'),
      fingerprintScript('def run():\n    return {}\n'),
    );
  });

  test('fingerprint changes when the script changes', () {
    expect(
      fingerprintScript('def run():\n    return {}\n'),
      isNot(fingerprintScript('def run():\n    return {"a": 1}\n')),
    );
  });
}
