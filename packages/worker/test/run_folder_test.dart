import 'dart:convert';
import 'dart:io';

import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:discoman_worker/src/python/run_folder.dart';
import 'package:test/test.dart';

const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3];

bool _runs(String python) {
  try {
    return Process.runSync(python, ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

void main() {
  final python = Platform.isWindows ? 'python' : 'python3';
  final skip = _runs(python) ? false : '$python is not installed';
  late Directory temp;
  late Directory project;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('run_folder_test');
    project = Directory('${temp.path}${Platform.pathSeparator}project')
      ..createSync();
  });

  tearDown(() {
    try {
      temp.deleteSync(recursive: true);
    } catch (_) {}
  });

  File write(String name, String content) {
    final file = File('${project.path}${Platform.pathSeparator}$name');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  Future<PythonRunResult> run(
    String script, {
    Map<String, dynamic> inputs = const {},
    int timeoutSeconds = 60,
    List<String> extraPath = const [],
    bool measureUsage = false,
  }) {
    final file = write('main.py', script);
    return PythonRunner(
      python,
      extraPath: extraPath,
      measureUsage: measureUsage,
    ).run(
      source: file.readAsStringSync(),
      entrypointName: 'main',
      inputs: inputs,
      timeoutSeconds: timeoutSeconds,
      cancelRequested: () => false,
      scriptPath: file.path,
    );
  }

  Map<String, dynamic> image(String name, List<int> bytes) => {
    'kind': 'image',
    'name': name,
    'extension': 'png',
    'mimeType': 'image/png',
    'sizeBytes': bytes.length,
    'base64': base64Encode(bytes),
  };

  test('imports a module beside the script', () async {
    write('helper.py', 'def shout(text):\n    return text.upper()\n');
    write('tools/__init__.py', 'NAME = "tools"\n');

    final result = await run(
      'import helper\nimport tools\n\n'
      'def main():\n    return {"value": helper.shout("hi") + tools.NAME}\n',
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs?['value'], 'HItools');
  }, skip: skip);

  test('opens a file beside the script by relative name', () async {
    write('weights.txt', '42');
    write('data/labels.txt', 'cat');

    final result = await run(
      'from pathlib import Path\n\n'
      'def main():\n'
      '    here = Path(__file__).parent\n'
      '    return {\n'
      '        "weights": open("weights.txt").read(),\n'
      '        "labels": (here / "data" / "labels.txt").read_text(),\n'
      '    }\n',
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs, {'weights': '42', 'labels': 'cat'});
  }, skip: skip);

  test('runs a script beside it as a program', () async {
    write('other.py', 'import helper\nprint(helper.VALUE)\n');
    write('helper.py', 'VALUE = "from the other script"\n');

    final result = await run(
      'import subprocess, sys\n\n'
      'def main():\n'
      '    done = subprocess.run([sys.executable, "other.py"], '
      'capture_output=True, text=True, timeout=30, check=True)\n'
      '    return {"value": done.stdout.strip()}\n',
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs?['value'], 'from the other script');
  }, skip: skip);

  test('hands inputs over with a path and returns outputs by path', () async {
    final result = await run(
      'from pathlib import Path\n\n'
      'def main(photos: list, note: dict):\n'
      '    first = Path(photos[0]["path"])\n'
      '    out = first.with_name("result.png")\n'
      '    out.write_bytes(first.read_bytes())\n'
      '    Path("summary.txt").write_text("done")\n'
      '    return {\n'
      '        "names": [Path(p["path"]).name for p in photos],\n'
      '        "same": all(Path(p["path"]).read_bytes() == '
      '__import__("base64").b64decode(p["base64"]) for p in photos),\n'
      '        "image": {"kind": "image", "path": str(out)},\n'
      '        "files": [{"kind": "file", "path": "summary.txt"}],\n'
      '    }\n',
      inputs: {
        'photos': [image('a.png', _png), image('a.png', _png)],
        'note': {'text': 'kept as it is'},
      },
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs?['names'], ['a.png', 'a_2.png']);
    expect(result.outputs?['same'], isTrue);
    final out = result.outputs!['image'] as Map;
    expect(out['kind'], 'image');
    expect(out['name'], 'result.png');
    expect(base64Decode(out['base64'] as String), _png);
    final files = (result.outputs!['files'] as List)
        .cast<Map<String, dynamic>>();
    expect(files.single['extension'], 'txt');
    expect(utf8.decode(base64Decode(files.single['base64'] as String)), 'done');
  }, skip: skip);

  test('parallel runs writing the same file name do not clash', () async {
    final file = write(
      'main.py',
      'from pathlib import Path\n\n'
          'def main(photo: dict):\n'
          '    data = Path(photo["path"]).read_bytes()\n'
          '    out = Path(photo["path"]).with_name("result.png")\n'
          '    import time; time.sleep(0.5)\n'
          '    out.write_bytes(data)\n'
          '    time.sleep(0.5)\n'
          '    return {"image": {"kind": "image", "path": str(out)}}\n',
    );
    final runner = PythonRunner(python);
    final pictures = [
      for (var i = 0; i < 3; i++) [..._png, i],
    ];

    final results = await Future.wait([
      for (final picture in pictures)
        runner.run(
          source: file.readAsStringSync(),
          entrypointName: 'main',
          inputs: {'photo': image('in.png', picture)},
          timeoutSeconds: 60,
          cancelRequested: () => false,
          scriptPath: file.path,
        ),
    ]);

    for (final (i, result) in results.indexed) {
      expect(result.success, isTrue, reason: result.logs.join('\n'));
      final out = result.outputs!['image'] as Map;
      expect(base64Decode(out['base64'] as String), pictures[i]);
    }
    expect(File('${project.path}/result.png').existsSync(), isFalse);
  }, skip: skip);

  test('deletes the run folder and leaves the script folder alone', () async {
    final data = write('data/keep.txt', 'keep');
    final model = write('model.bin', 'weights');

    final result = await run(
      'import os\n\n'
      'def main():\n'
      '    return {"runDir": os.environ["DISCOMAN_RUN_DIR"], '
      '"scriptDir": os.environ["DISCOMAN_SCRIPT_DIR"], "cwd": os.getcwd()}\n',
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    final runDir = result.outputs!['runDir'] as String;
    expect(
      File(result.outputs!['scriptDir'] as String).absolute.path,
      project.absolute.path,
    );
    String last(String path) => path.split(RegExp(r'[\\/]')).last;
    expect(last(result.outputs!['cwd'] as String), last(runDir));
    expect(Directory(runDir).existsSync(), isFalse);
    expect(data.readAsStringSync(), 'keep');
    expect(model.readAsStringSync(), 'weights');
    expect(File('${project.path}/main.py').existsSync(), isTrue);
  }, skip: skip);

  test('links folders and files into a run folder', () {
    write('data/keep.txt', 'keep');
    final script = write('main.py', 'x = 1\n');

    final folder = RunFolder.linked('x = 2\n', script.path);
    addTearDown(folder.delete);

    expect(folder.inScriptFolder, isFalse);
    final sep = Platform.pathSeparator;
    expect(File(folder.scriptFile).readAsStringSync(), 'x = 2\n');
    expect(
      File(
        '${folder.directory.path}${sep}data${sep}keep.txt',
      ).readAsStringSync(),
      'keep',
    );
    folder.delete();
    expect(folder.directory.existsSync(), isFalse);
    expect(
      File('${project.path}${sep}data${sep}keep.txt').existsSync(),
      isTrue,
    );
    expect(script.readAsStringSync(), 'x = 1\n');
  });

  test('a timeout stops what the script started and returns promptly', () async {
    final marker = '${project.path}${Platform.pathSeparator}still_running';
    write(
      'child.py',
      'import sys, time\ntime.sleep(4)\nopen(sys.argv[1], "w").close()\n',
    );
    final stopwatch = Stopwatch()..start();

    final result = await run(
      'import subprocess, sys, time\n\n'
      'def main():\n'
      '    subprocess.Popen([sys.executable, "child.py", ${jsonEncode(marker)}])\n'
      '    time.sleep(60)\n',
      timeoutSeconds: 1,
    );

    expect(result.timedOut, isTrue);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
    await Future<void>.delayed(const Duration(seconds: 6));
    expect(File(marker).existsSync(), isFalse);
  }, skip: skip);

  test(
    'a program left running after the script returns does not hold the run',
    () async {
      final stopwatch = Stopwatch()..start();

      final result = await run(
        'import subprocess, sys\n\n'
        'def main():\n'
        '    subprocess.Popen([sys.executable, "-c", '
        '"import time; time.sleep(15)"])\n'
        '    return {"value": 1}\n',
      );

      expect(result.success, isTrue, reason: result.logs.join('\n'));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
    },
    skip: skip,
  );

  test('keeps what programs print to stdout in the logs', () async {
    final result = await run(
      'import subprocess, sys\n\n'
      'def main():\n'
      '    subprocess.run([sys.executable, "-c", "print(\'from a program\')"])\n'
      '    raise ValueError("bad input")\n',
    );

    expect(result.success, isFalse);
    expect(result.logs, contains('[stdout] from a program'));
    expect(result.errorMessage, 'bad input');
  }, skip: skip);

  test('puts the extra PATH folders first', () async {
    final extra = Directory('${temp.path}${Platform.pathSeparator}bin')
      ..createSync();

    final result = await run(
      'import os\n\n'
      'def main():\n'
      '    return {"first": os.environ["PATH"].split(os.pathsep)[0]}\n',
      extraPath: [extra.path],
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs?['first'], extra.path);
  }, skip: skip);

  test('says when a run returns too many files', () async {
    final result = await run(
      'def main():\n'
      '    png = bytes($_png)\n'
      '    return {"pages": [png] * 51}\n',
    );

    expect(result.success, isFalse);
    expect(result.errorMessage, contains('at most 50 files'));
  }, skip: skip);

  test('measures a run from its folder', () async {
    write('helper.py', 'VALUE = 3\n');

    final result = await run(
      'import helper\n\ndef main():\n    return {"value": helper.VALUE}\n',
      measureUsage: true,
    );

    expect(result.success, isTrue, reason: result.logs.join('\n'));
    expect(result.outputs?['value'], 3);
    expect(result.usage, isNotNull);
  }, skip: skip);
}
