import 'dart:io';

import 'package:discoman_worker/src/python/run_folder.dart';
import 'package:test/test.dart';

void main() {
  late Directory root;
  late Directory kept;

  setUp(() {
    root = Directory.systemTemp.createTempSync('stale_runs_test');
    kept = Directory('${root.path}/project')..createSync();
    File('${kept.path}/model.txt').writeAsStringSync('keep');
  });

  tearDown(() => root.deleteSync(recursive: true));

  Directory runFolder(String name, {required bool old}) {
    final dir = Directory('${root.path}/$name')..createSync();
    File('${dir.path}/input.png').writeAsStringSync('visitor file');
    Link('${dir.path}/model.txt').createSync('${kept.path}/model.txt');
    if (old) {
      final past = DateTime.now().subtract(const Duration(hours: 2));
      Process.runSync('touch', [
        '-t',
        '${past.year}${_two(past.month)}${_two(past.day)}'
            '${_two(past.hour)}${_two(past.minute)}',
        dir.path,
      ]);
    }
    return dir;
  }

  test(
    'removes old run folders and keeps recent ones and the originals',
    () {
      final old = runFolder('discoman_run_old', old: true);
      final oldPrivate = runFolder('discoman_compute_old', old: true);
      final recent = runFolder('discoman_run_recent', old: false);
      final other = runFolder('discoman_computeFlutterCache', old: true);

      deleteStaleRunFolders(root: root);

      expect(old.existsSync(), isFalse);
      expect(oldPrivate.existsSync(), isFalse);
      expect(recent.existsSync(), isTrue);
      expect(other.existsSync(), isTrue);
      expect(File('${kept.path}/model.txt').readAsStringSync(), 'keep');
    },
    testOn: '!windows',
  );
}

String _two(int value) => value.toString().padLeft(2, '0');
