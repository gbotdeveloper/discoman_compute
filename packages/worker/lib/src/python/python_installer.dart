import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../home_path.dart';
import 'interpreter_check.dart';
import 'packages.dart';

/// One downloadable Python from python-build-standalone.
class PythonBuild {
  const PythonBuild({required this.url, required this.sha256});

  final String url;
  final String sha256;
}

const _release =
    'https://github.com/astral-sh/python-build-standalone/'
    'releases/download/20261003';

/// The Python the installer puts on a machine.
const managedPythonVersion = '3.11.17';

const _builds = {
  Abi.macosArm64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-aarch64-apple-darwin-install_only.tar.gz',
    sha256: '3663b71c18364eccfbad74c4f21f9f6149e40b07329cd776287410cc1da5d612',
  ),
  Abi.macosX64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-x86_64-apple-darwin-install_only.tar.gz',
    sha256: '4338dc0c2b954f20ca6437406db5b806626c69bae3cafeec43f1b7d57dd72a88',
  ),
  Abi.windowsX64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-x86_64-pc-windows-msvc-install_only.tar.gz',
    sha256: '0f7defa7a0ed99b61e0df0bba5027474711521f1307cc3830c2f456401beeed5',
  ),
  Abi.windowsArm64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-aarch64-pc-windows-msvc-install_only.tar.gz',
    sha256: '4a3aac3c777333185a53e866b75d9bfe411b4e89a9230019bccbe5e58ca277e8',
  ),
  Abi.linuxX64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-x86_64-unknown-linux-gnu-install_only.tar.gz',
    sha256: 'c624af93ad62a596806bbd2404e1fb80744a407ca7279854445ede16d93858b8',
  ),
  Abi.linuxArm64: PythonBuild(
    url:
        '$_release/cpython-3.11.17+20261003-aarch64-unknown-linux-gnu-install_only.tar.gz',
    sha256: '2238f0556d3a9777d42261b1e4d7b9834d56f111d3dd879a0647c27c824cc31d',
  ),
};

/// The packages Discoman's cloud has, so a script that runs there runs here.
const basePythonPackages = ['numpy', 'pandas', 'matplotlib', 'Pillow'];

enum PythonInstallStep { download, verify, unpack, packages, check }

class PythonInstallProgress {
  const PythonInstallProgress(this.step, {this.fraction, this.line});

  final PythonInstallStep step;

  /// How much of the download has arrived, when its size is known.
  final double? fraction;

  /// A line pip printed.
  final String? line;
}

class PythonInstallException implements Exception {
  const PythonInstallException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Downloads a standalone Python into `~/.discoman/python` and installs the
/// packages scripts need into it, without touching any other Python.
class PythonInstaller {
  PythonInstaller({
    Directory? home,
    PythonBuild? build,
    http.Client? httpClient,
    StartProcess? startProcess,
    RunProcess? runProcess,
    bool? isWindows,
    this.retryDelay = const Duration(seconds: 2),
  }) : _home = home,
       _build = build ?? _builds[Abi.current()],
       _http = httpClient ?? http.Client(),
       _startProcess = startProcess,
       _runProcess = runProcess,
       _isWindows = isWindows ?? Platform.isWindows;

  final Directory? _home;
  final PythonBuild? _build;
  final http.Client _http;
  final StartProcess? _startProcess;
  final RunProcess? _runProcess;
  final bool _isWindows;
  final Duration retryDelay;

  static const _attempts = 3;

  Directory get _root => _home ?? discomanHomeDirectory();

  Directory get directory => Directory(_join(_root.path, 'python'));

  /// Whether there is a Python build for this computer at all.
  bool get isSupported => _build != null;

  String get executablePath => _isWindows
      ? _join(directory.path, 'python.exe')
      : _join(directory.path, 'bin', 'python3');

  bool get isInstalled => File(executablePath).existsSync();

  /// Installs Python and [packages] on top of [basePythonPackages], and
  /// returns the path of the new interpreter. A Python installed earlier is
  /// replaced.
  Future<String> install({
    List<String> packages = const [],
    required void Function(PythonInstallProgress progress) onProgress,
  }) async {
    final build = _build;
    if (build == null) {
      throw PythonInstallException(
        'There is no Python download for ${Abi.current()}.',
      );
    }

    _root.createSync(recursive: true);
    final archive = File(_join(_root.path, 'python-download.tar.gz'));
    final staging = Directory(_join(_root.path, 'python.partial'));
    try {
      await _download(build.url, archive, onProgress);

      onProgress(const PythonInstallProgress(PythonInstallStep.verify));
      final digest = await sha256.bind(archive.openRead()).first;
      if ('$digest' != build.sha256) {
        throw const PythonInstallException(
          'The download did not match its checksum. Try again.',
        );
      }

      onProgress(const PythonInstallProgress(PythonInstallStep.unpack));
      if (staging.existsSync()) staging.deleteSync(recursive: true);
      staging.createSync(recursive: true);
      final unpacked = await Process.run(_tar, [
        '-xzf',
        archive.path,
        '-C',
        staging.path,
      ]);
      if (unpacked.exitCode != 0) {
        throw PythonInstallException(
          'Could not unpack Python: ${'${unpacked.stderr}'.trim()}',
        );
      }
      if (directory.existsSync()) directory.deleteSync(recursive: true);
      Directory(_join(staging.path, 'python')).renameSync(directory.path);

      onProgress(const PythonInstallProgress(PythonInstallStep.packages));
      final installed = await installPackages(
        executablePath,
        {...basePythonPackages, ...packages}.toList(),
        onOutput: (line) => onProgress(
          PythonInstallProgress(PythonInstallStep.packages, line: line),
        ),
        startProcess: _startProcess,
      );
      if (!installed.success) {
        throw const PythonInstallException(
          'Python is installed, but its packages could not be. '
          'See what pip said above.',
        );
      }

      onProgress(const PythonInstallProgress(PythonInstallStep.check));
      final check = await checkInterpreter(
        executablePath,
        runProcess: _runProcess,
      );
      if (!check.isUsable) throw PythonInstallException(check.message);
      return executablePath;
    } finally {
      if (archive.existsSync()) archive.deleteSync();
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  Future<void> _download(
    String url,
    File target,
    void Function(PythonInstallProgress progress) onProgress,
  ) async {
    for (var attempt = 1; ; attempt++) {
      onProgress(
        const PythonInstallProgress(PythonInstallStep.download, fraction: 0),
      );
      try {
        final response = await _http.send(http.Request('GET', Uri.parse(url)));
        if (response.statusCode != 200) {
          throw PythonInstallException(
            'The download failed with HTTP ${response.statusCode}.',
          );
        }
        final total = response.contentLength;
        var received = 0;
        final sink = target.openWrite();
        try {
          await for (final chunk in response.stream) {
            sink.add(chunk);
            received += chunk.length;
            if (total != null && total > 0) {
              onProgress(
                PythonInstallProgress(
                  PythonInstallStep.download,
                  fraction: received / total,
                ),
              );
            }
          }
        } finally {
          await sink.close();
        }
        return;
      } catch (error) {
        if (attempt >= _attempts) {
          throw error is PythonInstallException
              ? error
              : PythonInstallException(
                  'Could not download Python. Check your internet connection '
                  'and try again. ($error)',
                );
        }
        await Future<void>.delayed(retryDelay);
      }
    }
  }

  /// Windows' own bsdtar: a GNU tar earlier on the PATH, as Git for Windows
  /// installs, reads `C:` in a path as a remote host.
  String get _tar {
    if (!_isWindows) return 'tar';
    final root = Platform.environment['SystemRoot'] ?? r'C:\Windows';
    return '$root\\System32\\tar.exe';
  }

  String _join(String first, String second, [String? third]) {
    final separator = _isWindows ? r'\' : '/';
    return [first, second, ?third].join(separator);
  }
}
