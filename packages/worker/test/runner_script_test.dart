import 'dart:convert';
import 'dart:io';

import 'package:discoman_worker/src/python/runner_script.dart';
import 'package:test/test.dart';

const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3];

final _python = Platform.isWindows ? 'python' : 'python3';

bool _runs(String python) {
  try {
    return Process.runSync(python, ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Runs the runner on [script] the way the worker does: the job on stdin, the
/// result read back from result.json. Fails the test unless it succeeds.
Future<Map<String, dynamic>> _run(
  String script, {
  Map<String, String> modules = const {},
  Map<String, Object?> inputs = const {},
  Map<String, String>? outputTypes,
}) async {
  final (exitCode, stderr, dir) = await _start(
    script,
    modules: modules,
    inputs: inputs,
    outputTypes: outputTypes,
  );
  expect(exitCode, 0, reason: stderr);

  final result = File('${dir.path}/result.json').readAsStringSync();
  return (jsonDecode(result) as Map<String, dynamic>)['outputs']
      as Map<String, dynamic>;
}

/// The message a run of [script] that must fail ends on.
Future<String> _failure(
  String script, {
  Map<String, String>? outputTypes,
}) async {
  final (exitCode, stderr, _) = await _start(script, outputTypes: outputTypes);
  expect(exitCode, isNot(0));
  return stderr.trim().split('\n').last;
}

Future<(int, String, Directory)> _start(
  String script, {
  Map<String, String> modules = const {},
  Map<String, Object?> inputs = const {},
  Map<String, String>? outputTypes,
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

  final process = await Process.start(_python, [
    'runner.py',
  ], workingDirectory: dir.path);
  process.stdin.write(
    jsonEncode({
      'entrypointName': 'run',
      'inputs': inputs,
      'outputTypes': ?outputTypes,
    }),
  );
  await process.stdin.close();
  final stderr = await process.stderr.transform(utf8.decoder).join();
  return (await process.exitCode, stderr, dir);
}

void main() {
  final hasPython = _runs(_python);

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
      expect(File(pages.first['path'] as String).readAsBytesSync(), _png);
      expect(pages.first.containsKey('base64'), isFalse);
      expect(outputs['count'], 2);
    },
    skip: hasPython ? false : '$_python is not installed',
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

      final photo = (outputs['photo'] as List).single as Map<String, dynamic>;
      expect(photo['mimeType'], 'image/png');
      expect(File(photo['path'] as String).readAsBytesSync(), _png);
      expect((outputs['photos'] as List).map((item) => item['name']), [
        'photos_1.png',
        'photos_2.png',
      ]);
    },
    skip: hasPython ? false : '$_python is not installed',
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
    skip: hasPython ? false : '$_python is not installed',
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
    skip: hasPython ? false : '$_python is not installed',
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
    skip: hasPython ? false : '$_python is not installed',
  );

  group('declared outputs', () {
    test(
      'reads images and files from the paths the script returns',
      () async {
        final outputs = await _run(
          '''
from pathlib import Path

def run(photos):
    Path("out").mkdir(exist_ok=True)
    targets = []
    for index, source in enumerate(photos):
        target = Path("out") / f"done_{index}.png"
        target.write_bytes(Path(source).read_bytes())
        targets.append(str(target))
    Path("report.csv").write_text("a,b\\n1,2\\n")
    return {"processed": targets, "report": ["report.csv"], "count": 2}
''',
          inputs: {
            'photos': [_inputFile('a.png'), _inputFile('b.png')],
          },
          outputTypes: {
            'processed': 'image',
            'report': 'file',
            'count': 'integer',
          },
        );

        final processed = (outputs['processed'] as List)
            .cast<Map<String, dynamic>>();
        expect(processed.map((item) => item['name']), [
          'done_0.png',
          'done_1.png',
        ]);
        expect(processed.first['mimeType'], 'image/png');
        expect(File(processed.first['path'] as String).isAbsolute, isTrue);
        final report = (outputs['report'] as List).single as Map;
        expect([report['extension'], report['mimeType']], ['csv', 'text/csv']);
        expect(outputs['count'], 2);
      },
      skip: hasPython ? false : '$_python is not installed',
    );

    test(
      'names an output the run did not return',
      () async {
        expect(
          await _failure(
            'def run():\n    return {"summary": "x"}\n',
            outputTypes: {'summary': 'text', 'count': 'integer'},
          ),
          'The run did not return "count", declared in class Outputs.',
        );
      },
      skip: hasPython ? false : '$_python is not installed',
    );

    test(
      'names an output class Outputs does not declare',
      () async {
        expect(
          await _failure(
            'def run():\n    return {"summary": "x", "extra": 1}\n',
            outputTypes: {'summary': 'text'},
          ),
          'The run returned "extra", which class Outputs does not declare.',
        );
      },
      skip: hasPython ? false : '$_python is not installed',
    );

    test(
      'says which output has the wrong type',
      () async {
        expect(
          await _failure(
            'def run():\n    return {"count": "three"}\n',
            outputTypes: {'count': 'integer'},
          ),
          'Output "count" is declared as a whole number (int) in class '
          'Outputs, but the run returned str.',
        );
      },
      skip: hasPython ? false : '$_python is not installed',
    );

    test(
      'says when an image path does not exist',
      () async {
        expect(
          await _failure(
            'def run():\n    return {"photos": ["missing.png"]}\n',
            outputTypes: {'photos': 'image'},
          ),
          startsWith('Output "photos" names a file that does not exist'),
        );
      },
      skip: hasPython ? false : '$_python is not installed',
    );
  });

  test(
    'the out folder is there before the script runs',
    () async {
      final outputs = await _run(
        '''
def run():
    with open("out/note.txt", "w") as handle:
        handle.write("hi")
    return {"notes": ["out/note.txt"]}
''',
        outputTypes: {'notes': 'file'},
      );

      expect(((outputs['notes'] as List).single as Map)['name'], 'note.txt');
    },
    skip: hasPython ? false : '$_python is not installed',
  );

  test('run must return a dict', () async {
    expect(
      await _failure('def run():\n    return 42\n'),
      'run must return a dict with one entry per output; it returned int.',
    );
  }, skip: hasPython ? false : '$_python is not installed');
}

/// A PNG written to a folder of its own, as the worker saves an input image.
String _inputFile(String name) {
  final dir = Directory.systemTemp.createTempSync('runner_input');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = File('${dir.path}/$name')..writeAsBytesSync(_png);
  return file.path;
}
