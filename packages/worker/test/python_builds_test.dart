import 'dart:ffi' show Abi;

import 'package:discoman_worker/src/python/python_installer.dart';
import 'package:test/test.dart';

void main() {
  test('every offered Python has a download for every supported computer', () {
    for (final version in managedPythonVersions) {
      for (final abi in [
        Abi.macosArm64,
        Abi.macosX64,
        Abi.windowsX64,
        Abi.windowsArm64,
        Abi.linuxX64,
        Abi.linuxArm64,
      ]) {
        final build = pythonBuildFor(version, abi);
        expect(build, isNotNull, reason: '$version on $abi');
        expect(build!.url, contains('cpython-$version+'));
        expect(build.sha256, hasLength(64));
      }
    }
  });

  test('the default is offered', () {
    expect(managedPythonVersions, contains(managedPythonVersion));
  });
}
