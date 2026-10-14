import 'dart:convert';
import 'dart:io';

import 'package:discoman_worker/src/python/runner_script.dart';
import 'package:test/test.dart';

const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3];

/// Runs the runner on [script] the way the worker does: the job on stdin, the
/// result read back from result.json.
Future<Map<String, dynamic>> _run(
  String script, {
  Map<String, String> modules = const {},
}) async {
  final dir = await Directory.systemTemp.createTemp('runner_test');
  addTearDown(() => dir.delete(recursive: true));
  await File('${dir.path}/runner.py').writeAsString(runnerPy);
  await File('${dir.path}/user_script.py').writeAsString(script);
  for (final module in modules.entries) {
    final file = File('${dir.path}/${module.key}');
    await file.parent.create(recursive: true);
    await file.writeAsString(module.value);
  }

  final process = await Process.start('python3', [
    'runner.py',
  ], workingDirectory: dir.path);
  process.stdin.write(jsonEncode({'entrypointName': 'run', 'inputs': {}}));
  await process.stdin.close();
  final stderr = await process.stderr.transform(utf8.decoder).join();
  final exitCode = await process.exitCode;
  expect(exitCode, 0, reason: stderr);

  final result = File('${dir.path}/result.json').readAsStringSync();
  return (jsonDecode(result) as Map<String, dynamic>)['outputs']
      as Map<String, dynamic>;
}

void main() {
  final hasPython = Process.runSync('python3', ['--version']).exitCode == 0;

  test(
    'turns a returned list of image bytes into a list of images',
    () async {
      final outputs = await _run('''
def run():
    png = bytes($_png)
    return {"pages": [png, png], "count": 2}
''');

      final pages = (outputs['pages'] as List).cast<Map<String, dynamic>>();
      expect(pages.map((page) => page['kind']), ['image', 'image']);
      expect(pages.map((page) => page['name']), ['pages_1.png', 'pages_2.png']);
      expect(base64Decode(pages.first['base64'] as String), _png);
      expect(outputs['count'], 2);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'saves a PIL image as a PNG',
    () async {
      final outputs = await _run(
        '''
from PIL.Image import Image

def run():
    return {"photo": Image(), "photos": [Image(), Image()]}
''',
        modules: {
          'PIL/__init__.py': '',
          'PIL/Image.py':
              '''
class Image:
    mode = "RGB"

    def save(self, buffer, format):
        buffer.write(bytes($_png))
''',
        },
      );

      final photo = outputs['photo'] as Map<String, dynamic>;
      expect(photo['mimeType'], 'image/png');
      expect(base64Decode(photo['base64'] as String), _png);
      expect((outputs['photos'] as List).map((item) => item['name']), [
        'photos_1.png',
        'photos_2.png',
      ]);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'keeps a list of plain values as data',
    () async {
      final outputs = await _run('''
def run():
    return {"values": [1, 2.5, "x"]}
''');

      expect(outputs['values'], [1, 2.5, 'x']);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );
}
