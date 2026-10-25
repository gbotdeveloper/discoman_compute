import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:discoman_worker/src/python/python_installer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late List<int> archive;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_python');
    final source = Directory('${temp.path}/src/python/bin')
      ..createSync(recursive: true);
    File('${source.path}/python3').writeAsStringSync('#!/bin/sh\n');
    Process.runSync('tar', [
      '-czf',
      '${temp.path}/python.tar.gz',
      '-C',
      '${temp.path}/src',
      'python',
    ]);
    archive = File('${temp.path}/python.tar.gz').readAsBytesSync();
  });

  tearDown(() => temp.deleteSync(recursive: true));

  PythonInstaller installer({
    required http.Client client,
    String? sha,
    List<List<String>>? pipCalls,
    Set<String> pipFails = const {},
    List<String> missingModules = const [],
  }) {
    return PythonInstaller(
      home: Directory('${temp.path}/home'),
      build: PythonBuild(
        url: 'https://python.test/python.tar.gz',
        sha256: sha ?? '${sha256.convert(archive)}',
      ),
      httpClient: client,
      isWindows: false,
      retryDelay: Duration.zero,
      startProcess: (executable, arguments) {
        pipCalls?.add(arguments);
        final fails = arguments.any(pipFails.contains);
        return Process.start('sh', [
          '-c',
          fails
              ? 'echo No matching distribution; exit 1'
              : 'echo Successfully installed',
        ]);
      },
      runProcess: (executable, arguments) async => arguments.first == '-c'
          ? ProcessResult(0, 0, jsonEncode(missingModules), '')
          : ProcessResult(0, 0, 'Python 3.11.17', ''),
    );
  }

  List<String> pipArgs(List<String> packages) => [
    '-m',
    'pip',
    'install',
    '--disable-pip-version-check',
    ...packages,
  ];

  test('downloads, unpacks and sets up Python with packages', () async {
    final pipCalls = <List<String>>[];
    final steps = <PythonInstallStep>{};
    final lines = <String>[];
    final python = installer(
      client: MockClient((_) async => http.Response.bytes(archive, 200)),
      pipCalls: pipCalls,
      missingModules: ['cv2'],
    );

    final result = await python.install(
      packages: ['numpy'],
      modules: ['cv2', 'json', 'numpy'],
      onProgress: (progress) {
        steps.add(progress.step);
        if (progress.line != null) lines.add(progress.line!);
      },
    );

    expect(result.path, '${temp.path}/home/python/bin/python3');
    expect(result.unavailablePackages, isEmpty);
    expect(File(result.path).existsSync(), isTrue);
    expect(steps, PythonInstallStep.values.toSet());
    expect(pipCalls, [
      pipArgs(basePythonPackages),
      pipArgs(['opencv-python']),
    ]);
    expect(lines, contains('Successfully installed'));
    expect(
      Directory('${temp.path}/home').listSync().map(
        (e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last,
      ),
      ['python'],
    );
  });

  test('lists a package pip cannot install instead of failing', () async {
    final pipCalls = <List<String>>[];
    final python = installer(
      client: MockClient((_) async => http.Response.bytes(archive, 200)),
      pipCalls: pipCalls,
      pipFails: {'helpers'},
      missingModules: ['cv2', 'helpers'],
    );

    final result = await python.install(
      modules: ['cv2', 'helpers'],
      onProgress: (_) {},
    );

    expect(result.unavailablePackages, ['helpers']);
    expect(pipCalls.last, pipArgs(['helpers']));
    expect(pipCalls, anyElement(equals(pipArgs(['opencv-python']))));
    expect(python.isInstalled, isTrue);
  });

  test('puts the previous Python back when a reinstall fails', () async {
    final client = MockClient((_) async => http.Response.bytes(archive, 200));
    final first = installer(client: client);
    await first.install(onProgress: (_) {});
    File('${first.directory.path}/marker').writeAsStringSync('old');

    final second = installer(client: client, pipFails: {'numpy'});
    await expectLater(
      second.install(onProgress: (_) {}),
      throwsA(isA<PythonInstallException>()),
    );

    expect(File('${first.directory.path}/marker').readAsStringSync(), 'old');
    expect(
      Directory('${temp.path}/home').listSync().map(
        (e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last,
      ),
      ['python'],
    );
  });

  test('refuses a download that does not match its checksum', () async {
    final python = installer(
      client: MockClient((_) async => http.Response.bytes(archive, 200)),
      sha: 'not-the-hash',
    );

    await expectLater(
      python.install(onProgress: (_) {}),
      throwsA(isA<PythonInstallException>()),
    );
    expect(python.isInstalled, isFalse);
    expect(Directory('${temp.path}/home').listSync(), isEmpty);
  });

  test('tries the download again when the connection drops', () async {
    var requests = 0;
    final python = installer(
      client: MockClient((_) async {
        requests++;
        if (requests == 1) throw const SocketException('connection reset');
        return http.Response.bytes(archive, 200);
      }),
    );

    await python.install(onProgress: (_) {});

    expect(requests, 2);
    expect(python.isInstalled, isTrue);
  });

  test('gives up after three failed downloads', () async {
    final python = installer(
      client: MockClient((_) async => http.Response('', 503)),
    );

    await expectLater(
      python.install(onProgress: (_) {}),
      throwsA(
        isA<PythonInstallException>().having(
          (e) => e.message,
          'message',
          contains('503'),
        ),
      ),
    );
  });
}
