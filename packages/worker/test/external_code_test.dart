import 'dart:io';

import 'package:discoman_worker/src/external_code.dart';
import 'package:test/test.dart';

void main() {
  final hasGit = () {
    try {
      return Process.runSync('git', ['--version']).exitCode == 0;
    } on ProcessException {
      return false;
    }
  }();

  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('discoman_ext'));
  tearDown(() => temp.deleteSync(recursive: true));

  void git(List<String> args) {
    final result = Process.runSync('git', [
      '-C',
      temp.path,
      '-c',
      'user.name=Test',
      '-c',
      'user.email=test@example.com',
      ...args,
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
  }

  test('a typed version is reported as typed', () async {
    final version = await readExternalCodeVersion(
      'p1',
      const ExternalCodeSource(name: 'MATLAB', version: 'R2024b'),
    );

    expect(version.manualVersion, 'R2024b');
    expect(version.commit, isNull);
  });

  test(
    'a git checkout reports its commit, branch and uncommitted changes',
    () async {
      git(['init', '-q', '-b', 'main']);
      File('${temp.path}/filter.py').writeAsStringSync('a = 1\n');
      git(['add', '.']);
      git(['commit', '-q', '-m', 'Add the filter']);

      final source = ExternalCodeSource(name: 'Library', gitPath: temp.path);
      final clean = await readExternalCodeVersion('p1', source);

      expect(clean.commit, hasLength(40));
      expect(clean.commitMessage, 'Add the filter');
      expect(clean.branch, 'main');
      expect(clean.dirty, isFalse);
      expect(clean.commitDate, isNotNull);
      expect(clean.problem, isNull);

      File('${temp.path}/filter.py').writeAsStringSync('a = 2\n');
      final dirty = await readExternalCodeVersion('p1', source);
      expect(dirty.dirty, isTrue);
    },
    skip: hasGit ? false : 'git is not installed',
  );

  test(
    'a folder that is not a checkout says so',
    () async {
      final version = await readExternalCodeVersion(
        'p1',
        ExternalCodeSource(name: 'Library', gitPath: temp.path),
      );

      expect(version.problem, contains('Not a git checkout'));
      expect(version.commit, isNull);
    },
    skip: hasGit ? false : 'git is not installed',
  );

  test('a missing git says so', () async {
    final version = await readExternalCodeVersion(
      'p1',
      const ExternalCodeSource(name: 'Library', gitPath: '/src/lib'),
      runGit: (executable, arguments) async =>
          throw const ProcessException('git', []),
    );

    expect(version.problem, 'Git is not installed on this computer.');
  });

  test('reads every project\'s code', () async {
    final versions = await readExternalCode({
      'p1': const [ExternalCodeSource(name: 'A', version: '1')],
      'p2': const [
        ExternalCodeSource(name: 'B', version: '2'),
        ExternalCodeSource(name: 'C', version: '3'),
      ],
    });

    expect(versions.map((v) => '${v.projectId}/${v.name}'), [
      'p1/A',
      'p2/B',
      'p2/C',
    ]);
  });
}
