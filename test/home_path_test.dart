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
    const windowsEnv = {'USERPROFILE': r'C:\Users\barkin'};

    test('falls back to USERPROFILE', () {
      expect(
        expandHomePath('~/py/python.exe', environment: windowsEnv),
        r'C:\Users\barkin/py/python.exe',
      );
    });

    test('expands a backslash tilde, which is what gets typed there', () {
      expect(
        expandHomePath(r'~\py\Scripts\python.exe', environment: windowsEnv),
        r'C:\Users\barkin\py\Scripts\python.exe',
      );
    });

    test('prefers HOME when both are set, as Git Bash leaves them', () {
      expect(
        expandHomePath(
          '~/py',
          environment: {'HOME': '/c/Users/barkin', ...windowsEnv},
        ),
        '/c/Users/barkin/py',
      );
    });
  });

  test('leaves the path alone when there is no home to expand to', () {
    expect(expandHomePath('~/py', environment: const {}), '~/py');
  });
}
