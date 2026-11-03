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
}
