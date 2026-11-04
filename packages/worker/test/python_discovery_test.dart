import 'dart:io';

import 'package:discoman_worker/src/python/python_discovery.dart';
import 'package:test/test.dart';

void main() {
  late Directory home;

  setUp(() => home = Directory.systemTemp.createTempSync('discovery_test'));

  tearDown(() => home.deleteSync(recursive: true));

  void python(String relative) =>
      File('${home.path}/$relative').createSync(recursive: true);

  test(
    'finds conda, pyenv, venvs and Discoman Pythons where tools put them',
    () {
      python('.discoman/python/bin/python3');
      python('anaconda3/bin/python');
      python('anaconda3/envs/imaging/bin/python');
      python('miniforge3/envs/stats/bin/python');
      python('.pyenv/versions/3.12.4/bin/python');
      python('.virtualenvs/research/bin/python');
      python('elsewhere/thesis/bin/python');
      File('${home.path}/.conda/environments.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '${home.path}/anaconda3/envs/imaging\n${home.path}/elsewhere/thesis\n',
        );

      final found = findPythons(
        environment: {'HOME': home.path},
        isWindows: false,
        includeSystem: false,
      );

      expect(found.map((p) => p.label), [
        "Discoman's Python",
        'Anaconda · base',
        'Anaconda · imaging',
        'Miniforge · stats',
        'conda · thesis',
        'pyenv 3.12.4',
        'venv · research',
      ]);
      expect(found[2].path, '${home.path}/anaconda3/envs/imaging/bin/python');
    },
    testOn: '!windows',
  );

  test('finds nothing in an empty home', () {
    expect(
      findPythons(
        environment: {'HOME': home.path, 'USERPROFILE': home.path},
        includeSystem: false,
      ),
      isEmpty,
    );
  });
}
