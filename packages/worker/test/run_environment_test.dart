import 'dart:io';

import 'package:discoman_worker/src/python/run_environment.dart';
import 'package:test/test.dart';

void main() {
  test('puts the login shell PATH before the inherited one', () {
    final env = runEnvironment(
      inherited: {'PATH': '/usr/bin:/bin'},
      loginShellPath: '/opt/homebrew/bin:/usr/bin',
    );

    expect(env, {'PATH': '/opt/homebrew/bin:/usr/bin:/bin'});
  }, testOn: '!windows');

  test('keeps the inherited PATH on Windows', () {
    final env = runEnvironment(
      inherited: {'Path': r'C:\Windows'},
      loginShellPath: '/ignored',
    );

    expect(env, {'Path': r'C:\Windows'});
  }, testOn: 'windows');

  test('reads the login shell PATH without failing', () async {
    await loadLoginShellPath();

    expect(runEnvironment()['PATH'], isNotEmpty);
  }, testOn: '!windows');

  test('the folders in a PATH stay folders', () {
    expect(
      runEnvironment(inherited: Platform.environment).values.single,
      isNot(contains('__DISCOMAN_PATH__')),
    );
  });

  group('the environment the chosen Python lives in', () {
    late Directory root;
    final windows = Platform.isWindows;
    final sep = Platform.pathSeparator;
    final pathSep = windows ? ';' : ':';
    const inherited = {'PATH': 'inherited'};

    setUp(() => root = Directory.systemTemp.createTempSync('env_test_'));
    tearDown(() => root.deleteSync(recursive: true));

    String make(List<String> parts, {bool file = false}) {
      final path = [root.path, ...parts].join(sep);
      if (file) {
        File(path).createSync(recursive: true);
      } else {
        Directory(path).createSync(recursive: true);
      }
      return path;
    }

    String condaPython(String prefix) => windows
        ? make([prefix, 'python.exe'], file: true)
        : make([prefix, 'bin', 'python'], file: true);

    test('a conda environment is set up as conda activate would', () {
      final prefix = make(['anaconda3', 'envs', 'matlabpy']);
      make(['anaconda3', 'envs', 'matlabpy', 'conda-meta']);
      final python = condaPython(['anaconda3', 'envs', 'matlabpy'].join(sep));

      final env = runEnvironment(
        inherited: inherited,
        loginShellPath: '',
        pythonPath: python,
      );

      expect(env['CONDA_PREFIX'], prefix);
      expect(env['CONDA_DEFAULT_ENV'], 'matlabpy');
      final folders = env['PATH']!.split(pathSep);
      expect(folders.last, 'inherited');
      expect(folders.first, windows ? prefix : [prefix, 'bin'].join(sep));
      if (windows) {
        expect(folders, contains([prefix, 'Library', 'bin'].join(sep)));
        expect(folders, contains([prefix, 'Scripts'].join(sep)));
      }
    });

    test('conda base is named base', () {
      make(['miniconda3', 'conda-meta']);
      final env = runEnvironment(
        inherited: inherited,
        loginShellPath: '',
        pythonPath: condaPython('miniconda3'),
      );

      expect(env['CONDA_DEFAULT_ENV'], 'base');
    });

    test('a venv gets VIRTUAL_ENV and its scripts folder first', () {
      final prefix = make(['.virtualenvs', 'proje']);
      make(['.virtualenvs', 'proje', 'pyvenv.cfg'], file: true);
      final bin = windows ? 'Scripts' : 'bin';
      final python = make([
        '.virtualenvs',
        'proje',
        bin,
        windows ? 'python.exe' : 'python',
      ], file: true);

      final env = runEnvironment(
        inherited: inherited,
        loginShellPath: '',
        pythonPath: python,
      );

      expect(env['VIRTUAL_ENV'], prefix);
      expect(env['PATH']!.split(pathSep).first, [prefix, bin].join(sep));
    });

    test('a plain Python changes nothing', () {
      final python = make(['python', 'python.exe'], file: true);

      final env = runEnvironment(
        inherited: inherited,
        loginShellPath: '',
        pythonPath: python,
      );

      expect(env, {'PATH': 'inherited'});
    });
  });
}
