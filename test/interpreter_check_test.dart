import 'dart:io';

import 'package:discoman_compute/src/python/interpreter_check.dart';
import 'package:test/test.dart';

void main() {
  /// Stands in for launching a real interpreter, so these tests do not depend
  /// on what happens to be installed on the machine running them.
  Future<ProcessResult> Function(String, List<String>) replying({
    int exitCode = 0,
    String stdout = '',
    String stderr = '',
  }) {
    return (_, _) async => ProcessResult(0, exitCode, stdout, stderr);
  }

  test('accepts a Python that reports its version on stdout', () async {
    final result = await checkInterpreter(
      '/usr/bin/python3',
      runProcess: replying(stdout: 'Python 3.11.9\n'),
    );

    expect(result.isUsable, isTrue);
    expect(result.version, 'Python 3.11.9');
    expect(result.message, contains('Python 3.11.9'));
  });

  test('accepts one that reports on stderr, as older builds do', () async {
    final result = await checkInterpreter(
      '/usr/bin/python',
      runProcess: replying(stderr: 'Python 2.7.18'),
    );

    expect(result.isUsable, isTrue);
    expect(result.version, 'Python 2.7.18');
  });

  test('rejects a path that cannot be run', () async {
    final result = await checkInterpreter(
      '/nope/python3',
      runProcess: (_, _) async =>
          throw const ProcessException('/nope/python3', ['--version']),
    );

    expect(result.isUsable, isFalse);
    expect(result.message, contains('/nope/python3'));
  });

  test('rejects something runnable that is not Python', () async {
    final result = await checkInterpreter(
      '/bin/echo',
      runProcess: replying(stdout: 'hello'),
    );

    expect(result.isUsable, isFalse);
    expect(result.message, contains('does not look like Python'));
  });

  test('rejects a non-zero exit', () async {
    final result = await checkInterpreter(
      '/usr/bin/python3',
      runProcess: replying(exitCode: 127),
    );

    expect(result.isUsable, isFalse);
    expect(result.message, contains('127'));
  });

  test('rejects an empty path without launching anything', () async {
    var launched = false;
    final result = await checkInterpreter(
      '   ',
      runProcess: (_, _) async {
        launched = true;
        return ProcessResult(0, 0, '', '');
      },
    );

    expect(result.isUsable, isFalse);
    expect(launched, isFalse);
  });
}
