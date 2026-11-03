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
  Map<String, Object?> inputs = const {},
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
  process.stdin.write(jsonEncode({'entrypointName': 'run', 'inputs': inputs}));
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

  test(
    'hands a date parameter a date and leaves other text alone',
    () async {
      final outputs = await _run(
        '''
import datetime
from typing import Optional

def run(start: datetime.date, at: Optional[datetime.datetime], note: str, bad: datetime.date):
    return {
        "start": type(start).__name__ + ":" + start.isoformat(),
        "at": type(at).__name__ + ":" + at.isoformat(),
        "note": note,
        "bad": bad,
    }
''',
        inputs: {
          'start': '2026-10-15',
          'at': '2026-10-15T08:30:00',
          'note': '2026-10-15',
          'bad': 'not a date',
        },
      );

      expect(outputs, {
        'start': 'date:2026-10-15',
        'at': 'datetime:2026-10-15T08:30:00',
        'note': '2026-10-15',
        'bad': 'not a date',
      });
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  test(
    'hands a DataFrame parameter its rows as a DataFrame',
    () async {
      final outputs = await _run(
        '''
from pandas import DataFrame

def run(rows: DataFrame, raw: list):
    return {"rows": type(rows).__name__, "count": rows.count, "raw": type(raw).__name__}
''',
        modules: {
          'pandas/__init__.py': '''
class DataFrame:
    def __init__(self, data):
        self.count = len(data)
''',
        },
        inputs: {
          'rows': [
            {'a': 1},
            {'a': 2},
          ],
          'raw': [1],
        },
      );

      expect(outputs, {'rows': 'DataFrame', 'count': 2, 'raw': 'list'});
    },
    skip: hasPython ? false : 'python3 is not installed',
  );

  group('image parameters', () {
    const fakePil = {
      'PIL/__init__.py': '',
      'PIL/Image.py': '''
class Image:
    def __init__(self, data):
        self.data = data
        self.loaded = False

    def load(self):
        self.loaded = True


def open(fp):
    return Image(fp.read())
''',
    };
    Map<String, Object?> file(List<int> bytes) => {
      'kind': 'image',
      'name': 'in.png',
      'extension': 'png',
      'mimeType': 'image/png',
      'sizeBytes': bytes.length,
      'base64': base64Encode(bytes),
    };

    test(
      'hands each parameter the kind of image it asks for',
      () async {
        final outputs = await _run(
          '''
from typing import Optional, Sequence
from PIL import Image

def describe(value):
    if isinstance(value, Image.Image):
        return "image:%d:%s" % (len(value.data), value.loaded)
    if isinstance(value, bytes):
        return "bytes:%d" % len(value)
    if isinstance(value, dict):
        return "dict:" + ",".join(sorted(value))
    return type(value).__name__

def run(
    photo: Image.Image,
    module_photo: Image,
    raw: bytes,
    maybe: Optional[Image.Image],
    photos: list[Image.Image],
    blobs: Sequence[bytes],
    frames: tuple[Image.Image, ...],
    quoted: "list[Image.Image]",
    plain_image,
    data: dict,
):
    return {
        "photo": describe(photo),
        "module_photo": describe(module_photo),
        "raw": describe(raw),
        "maybe": describe(maybe),
        "photos": [describe(item) for item in photos],
        "blobs": [describe(item) for item in blobs],
        "frames": [describe(item) for item in frames],
        "quoted": [describe(item) for item in quoted],
        "plain_image": describe(plain_image),
        "data": describe(data),
    }
''',
          modules: fakePil,
          inputs: {
            'photo': file([1, 2, 3]),
            'module_photo': file([1]),
            'raw': file([1, 2]),
            'maybe': file([1, 2, 3, 4]),
            'photos': [
              file([1]),
              file([1, 2]),
            ],
            'blobs': [
              file([1]),
            ],
            'frames': [
              file([1, 2, 3]),
            ],
            'quoted': [
              file([1]),
            ],
            'plain_image': file([1]),
            'data': file([1]),
          },
        );

        const dict = 'dict:base64,extension,kind,mimeType,name,sizeBytes';
        expect(outputs, {
          'photo': 'image:3:True',
          'module_photo': 'image:1:True',
          'raw': 'bytes:2',
          'maybe': 'image:4:True',
          'photos': ['image:1:True', 'image:2:True'],
          'blobs': ['bytes:1'],
          'frames': ['image:3:True'],
          'quoted': ['image:1:True'],
          'plain_image': dict,
          'data': dict,
        });
      },
      skip: hasPython ? false : 'python3 is not installed',
    );

    test(
      'reads the file from its path when it has one',
      () async {
        final dir = await Directory.systemTemp.createTemp('runner_input');
        addTearDown(() => dir.delete(recursive: true));
        final path = '${dir.path}/in.png';
        File(path).writeAsBytesSync([9, 9, 9, 9, 9]);

        final outputs = await _run(
          '''
def run(raw: bytes):
    return {"raw": len(raw)}
''',
          inputs: {
            'raw': {
              ...file([1]),
              'path': path,
            },
          },
        );

        expect(outputs['raw'], 5);
      },
      skip: hasPython ? false : 'python3 is not installed',
    );
  });

  test(
    'reads an output returned alone by its path',
    () async {
      final dir = await Directory.systemTemp.createTemp('runner_output');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/out.png';
      File(path).writeAsBytesSync(_png);

      final outputs = await _run('''
def run():
    return {"kind": "image", "path": ${jsonEncode(path)}}
''');

      final result = outputs['result'] as Map<String, dynamic>;
      expect(result['name'], 'out.png');
      expect(base64Decode(result['base64'] as String), _png);
    },
    skip: hasPython ? false : 'python3 is not installed',
  );
}
