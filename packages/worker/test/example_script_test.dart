import 'dart:io';

import 'package:discoman_worker/src/python/contract_extractor.dart';
import 'package:discoman_worker/src/python/python_runner.dart';
import 'package:test/test.dart';

/// A Python with Pillow: DISCOMAN_PILLOW_PYTHON, or the default one if it
/// has Pillow.
String? _pythonWithPillow() {
  final python =
      Platform.environment['DISCOMAN_PILLOW_PYTHON'] ??
      (Platform.isWindows ? 'python' : 'python3');
  try {
    final check = Process.runSync(python, ['-c', 'import PIL']);
    return check.exitCode == 0 ? python : null;
  } on ProcessException {
    return null;
  }
}

void main() {
  final example = File('../../examples/image_pipeline.py');

  test('the example script reads as a contract', () {
    final draft = extractContractDraft(example.readAsStringSync());

    expect(draft.entrypointName, 'main');
    expect(draft.inputFields.map((f) => [f.parameterName, f.type.name]), [
      ['photos', 'image'],
      ['strength', 'integer'],
      ['style', 'category'],
    ]);
    expect(draft.outputFields.map((f) => [f.outputKey, f.type.name]), [
      ['processed', 'image'],
      ['report', 'file'],
      ['summary', 'text'],
      ['count', 'integer'],
    ]);
  });

  final python = _pythonWithPillow();
  test(
    'the example script turns photos into processed images',
    () async {
      final dir = Directory.systemTemp.createTempSync('example_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final photo = '${dir.path}${Platform.pathSeparator}photo.png';
      final made = await Process.run(python!, [
        '-c',
        'import sys\n'
            'from PIL import Image\n'
            'Image.new("RGB", (8, 6), "red").save(sys.argv[1])',
        photo,
      ]);
      expect(made.exitCode, 0, reason: '${made.stderr}');
      final source = example.readAsStringSync();

      final runDir = Directory.systemTemp.createTempSync('example_run');
      addTearDown(() => runDir.deleteSync(recursive: true));
      final result = await PythonRunner(python).run(
        source: source,
        entrypointName: 'main',
        inputs: {
          'photos': [photo],
          'strength': 1,
          'style': 'Sharpen and gray',
        },
        timeoutSeconds: 60,
        cancelRequested: () => false,
        outputTypes: declaredOutputTypes(source),
        runDirectory: runDir,
      );

      expect(result.success, isTrue, reason: result.logs.join('\n'));
      final processed = (result.outputs!['processed'] as List).single as Map;
      expect(processed['name'], 'photo_sharp.png');
      expect(File(processed['path'] as String).existsSync(), isTrue);
      final report = (result.outputs!['report'] as List).single as Map;
      expect(
        File(report['path'] as String).readAsStringSync(),
        'name,width,height\nphoto.png,8,6\n',
      );
      expect(result.outputs!['count'], 1);
    },
    skip: python == null ? 'no Python with Pillow' : false,
  );
}
