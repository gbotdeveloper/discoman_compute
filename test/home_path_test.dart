import 'dart:io';

import 'package:discoman_compute/src/home_path.dart';
import 'package:test/test.dart';

void main() {
  final home = Platform.environment['HOME'] ?? '';

  test('expands a leading tilde', () {
    expect(
      expandHomePath('~/.gbot-python/bin/python3'),
      '$home/.gbot-python/bin/python3',
    );
  });

  test('expands a bare tilde', () {
    expect(expandHomePath('~'), home);
  });

  test('leaves an absolute path alone', () {
    expect(expandHomePath('/usr/bin/python3'), '/usr/bin/python3');
  });

  test('leaves a tilde in the middle alone', () {
    // Only a leading `~` is a home reference; `/tmp/a~b` is a real file name.
    expect(expandHomePath('/tmp/a~b/python3'), '/tmp/a~b/python3');
  });

  test('trims surrounding whitespace', () {
    expect(expandHomePath('  /usr/bin/python3  '), '/usr/bin/python3');
  });

  group('on Windows, where HOME is usually unset', () {
    const windowsEnv = {'USERPROFILE': r'C:\Users\creator'};

    test('falls back to USERPROFILE', () {
      expect(
        expandHomePath('~/py/python.exe', environment: windowsEnv),
        r'C:\Users\creator/py/python.exe',
      );
    });

    test('expands a backslash tilde, which is what gets typed there', () {
      expect(
        expandHomePath(r'~\py\Scripts\python.exe', environment: windowsEnv),
        r'C:\Users\creator\py\Scripts\python.exe',
      );
    });

    test('prefers HOME when both are set, as Git Bash leaves them', () {
      expect(
        expandHomePath(
          '~/py',
          environment: {'HOME': '/c/Users/creator', ...windowsEnv},
        ),
        '/c/Users/creator/py',
      );
    });
  });

  test('leaves the path alone when there is no home to expand to', () {
    expect(expandHomePath('~/py', environment: const {}), '~/py');
  });

  group('discomanHomeDirectory', () {
    test('falls back to ~/.discoman', () {
      final dir = discomanHomeDirectory(
        environment: {'HOME': '/Users/someone'},
      );
      expect(dir.path, '/Users/someone/.discoman');
    });

    test('uses USERPROFILE when HOME is absent', () {
      final dir = discomanHomeDirectory(
        environment: {'USERPROFILE': '/Users/someone'},
      );
      expect(dir.path, '/Users/someone/.discoman');
    });

    test('DISCOMAN_HOME wins over the home directory', () {
      final dir = discomanHomeDirectory(
        environment: {'HOME': '/Users/someone', 'DISCOMAN_HOME': '/tmp/two'},
      );
      expect(dir.path, '/tmp/two');
    });

    test('expands a tilde in DISCOMAN_HOME', () {
      final dir = discomanHomeDirectory(
        environment: {'HOME': '/Users/someone', 'DISCOMAN_HOME': '~/second'},
      );
      expect(dir.path, '/Users/someone/second');
    });

    test('an empty DISCOMAN_HOME is no override at all', () {
      // Shells export an unset variable as the empty string often enough that
      // treating it as "put my state in /" would be a nasty surprise.
      final dir = discomanHomeDirectory(
        environment: {'HOME': '/Users/someone', 'DISCOMAN_HOME': '   '},
      );
      expect(dir.path, '/Users/someone/.discoman');
    });

    test('throws when there is no home to fall back to', () {
      expect(() => discomanHomeDirectory(environment: {}), throwsStateError);
    });
  });

}
