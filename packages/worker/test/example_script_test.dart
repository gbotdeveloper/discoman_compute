import 'dart:convert';
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
    final photos = draft.inputFields.firstWhere(
      (field) => field.parameterName == 'photos',
    );
    expect(photos.type.name, 'image');
    expect(photos.multiple, isTrue);
  });

  final python = _pythonWithPillow();
  test(
    'the example script turns photos into processed images',
    () async {
      final png = await Process.run(python!, [
        '-c',
        'import base64, io, sys\n'
            'from PIL import Image\n'
            'buffer = io.BytesIO()\n'
            'Image.new("RGB", (8, 8), "red").save(buffer, format="PNG")\n'
            'sys.stdout.write(base64.b64encode(buffer.getvalue()).decode())',
      ]);
      final photo = {
        'kind': 'image',
        'name': 'photo.png',
        'extension': 'png',
        'mimeType': 'image/png',
        'sizeBytes': base64Decode(png.stdout as String).length,
        'base64': png.stdout,
      };

      final result = await PythonRunner(python).run(
        source: example.readAsStringSync(),
        entrypointName: 'main',
        inputs: {
          'photos': [photo, photo],
          'strength': 1,
        },
        timeoutSeconds: 60,
        cancelRequested: () => false,
        scriptPath: example.absolute.path,
      );

      expect(result.success, isTrue, reason: result.logs.join('\n'));
      final processed = (result.outputs!['processed'] as List)
          .cast<Map<String, dynamic>>();
      expect(processed, hasLength(4));
      expect(processed.every((image) => image['kind'] == 'image'), isTrue);
      expect(processed.map((image) => image['name']), [
        'photo_sharpened.png',
        'photo_outline.png',
        'photo_2_sharpened.png',
        'photo_2_outline.png',
      ]);
      expect(result.outputs!['summary'], startsWith('Processed 2 photo(s)'));
    },
    skip: python == null ? 'no Python with Pillow' : false,
  );
}
