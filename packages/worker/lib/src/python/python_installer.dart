import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../home_path.dart';
import 'interpreter_check.dart';
import 'packages.dart';
import 'pip_names.dart';

/// One downloadable Python from python-build-standalone.
class PythonBuild {
  const PythonBuild({required this.url, required this.sha256});

  final String url;
  final String sha256;
}

const _release =
    'https://github.com/astral-sh/python-build-standalone/'
    'releases/download/20261003';

/// The Python the installer puts on a machine unless another is chosen: the
/// one Discoman's cloud runs, so a script that runs here runs there.
const managedPythonVersion = '3.11.17';

/// The Pythons the installer offers, oldest first.
const managedPythonVersions = ['3.11.17', '3.12.15', '3.13.16', '3.14.8'];

const _targets = {
  Abi.macosArm64: 'aarch64-apple-darwin',
  Abi.macosX64: 'x86_64-apple-darwin',
  Abi.windowsX64: 'x86_64-pc-windows-msvc',
  Abi.windowsArm64: 'aarch64-pc-windows-msvc',
  Abi.linuxX64: 'x86_64-unknown-linux-gnu',
  Abi.linuxArm64: 'aarch64-unknown-linux-gnu',
};

const _sha256 = {
  '3.11.17': {
    Abi.macosArm64:
        '3663b71c18364eccfbad74c4f21f9f6149e40b07329cd776287410cc1da5d612',
    Abi.macosX64:
        '4338dc0c2b954f20ca6437406db5b806626c69bae3cafeec43f1b7d57dd72a88',
    Abi.windowsX64:
        '0f7defa7a0ed99b61e0df0bba5027474711521f1307cc3830c2f456401beeed5',
    Abi.windowsArm64:
        '4a3aac3c777333185a53e866b75d9bfe411b4e89a9230019bccbe5e58ca277e8',
    Abi.linuxX64:
        'c624af93ad62a596806bbd2404e1fb80744a407ca7279854445ede16d93858b8',
    Abi.linuxArm64:
        '2238f0556d3a9777d42261b1e4d7b9834d56f111d3dd879a0647c27c824cc31d',
  },
  '3.12.15': {
    Abi.macosArm64:
        '316a463172740e71d8dca1f2730784e325f3f720941137b5d674d5801a632213',
    Abi.macosX64:
        'a8fd7a91852f19b6d959793ef41fad048631ccb2a334a9ecdf573255298f7978',
    Abi.windowsX64:
        '4b6f0beebbb695a0f3ea237b8c3eaa5bd424f47a7bc25b2fbe3a43390c770f08',
    Abi.windowsArm64:
        '2de96a340fecdabe215094345ed3aea1b473e858bd098360f2253299e18f24d2',
    Abi.linuxX64:
        'f937814031eab4698ca6d07ec606ede1825768f3f3e99af76d9db3900bee03c5',
    Abi.linuxArm64:
        '95c01982c9fcb9d95b0acfdb5eb8a6e0099dd11edf062314a474228d93f2b765',
  },
  '3.13.16': {
    Abi.macosArm64:
        'd8975d7df4f08f7b1c7aafcdfacbddcec3d366415f2c1a72b2466b6850815933',
    Abi.macosX64:
        '8e9cb087305bfb8969f68a905f79f41469d4aa5220c1aa71ada7fc9953bdba0f',
    Abi.windowsX64:
        '5e100ee3d592ff500f4408a624f054d202e32d9dba8a12b2226bef81083fd778',
    Abi.windowsArm64:
        '701acbb2639168c03e3bf12feb189e6dcd3cf96ec2abaa333745cc7d1e28fd2e',
    Abi.linuxX64:
        '0a0272910b10417c659a9312fb3f2d7a6d774da7bd510999be7a3ba83273dc1f',
    Abi.linuxArm64:
        '6477121f22904963a066ac8ff89983baae781510815590e894daa3c11ce86652',
  },
  '3.14.8': {
    Abi.macosArm64:
        'd15291f940cfecd2e54010d5e37d2e03aa192f076a65d26ab741372fff2dabfe',
    Abi.macosX64:
        '4b25eec9616cf363ad7181b2e8098f76fc453705fce22322da2502c9e16f44a9',
    Abi.windowsX64:
        '74fd19aac6ef6014be21e5de293c68ae4e54608cf19f6bf559f185943eb35b3a',
    Abi.windowsArm64:
        '0f681df7bc4a6b12cbd1db7929a04bf22df5ce3d625acae2fd061ec4ec2ca1ac',
    Abi.linuxX64:
        '371b6c281bbb09b29279e9e3a2996bab4ae2ea03cca52bf869f8bd89286b0ae8',
    Abi.linuxArm64:
        'abc0c8dd54a144909a5e4905737bc33f244cb17ce8afc4a7b0791ee1e006ae23',
  },
};

/// The download of Python [version] for [abi], or null if there is none.
PythonBuild? pythonBuildFor(String version, Abi abi) {
  final target = _targets[abi];
  final sha = _sha256[version]?[abi];
  if (target == null || sha == null) return null;
  return PythonBuild(
    url: '$_release/cpython-$version+20261003-$target-install_only.tar.gz',
    sha256: sha,
  );
}

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

class PythonInstallResult {
  const PythonInstallResult({
    required this.path,
    this.unavailablePackages = const [],
  });

  /// The new interpreter.
  final String path;

  /// Packages the scripts need that pip could not install.
  final List<String> unavailablePackages;
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
    String version = managedPythonVersion,
    http.Client? httpClient,
    StartProcess? startProcess,
    RunProcess? runProcess,
    bool? isWindows,
    this.retryDelay = const Duration(seconds: 2),
  }) : _home = home,
       _build = build ?? pythonBuildFor(version, Abi.current()),
       _injectedHttp = httpClient,
       _startProcess = startProcess,
       _runProcess = runProcess,
       _isWindows = isWindows ?? Platform.isWindows;

  final Directory? _home;
  final PythonBuild? _build;
  final http.Client? _injectedHttp;
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

  /// Installs Python with [basePythonPackages], [packages], and the pip
  /// packages [confirmGuessed] approves for whatever of [modules] the new
  /// Python cannot import. A Python installed earlier is replaced, and put
  /// back if the new one fails to set up.
  ///
  /// Packages beyond the base that pip cannot install are listed in the
  /// result rather than failing the install.
  Future<PythonInstallResult> install({
    List<String> packages = const [],
    List<String> modules = const [],
    Future<List<String>> Function(List<String> packages)? confirmGuessed,
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
    final previous = Directory(_join(_root.path, 'python.previous'));
    final client = _injectedHttp ?? http.Client();
    var swapped = false;
    try {
      await _download(client, build.url, archive, onProgress);

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
      try {
        if (previous.existsSync()) previous.deleteSync(recursive: true);
        if (directory.existsSync()) directory.renameSync(previous.path);
        swapped = true;
        Directory(_join(staging.path, 'python')).renameSync(directory.path);
      } on FileSystemException catch (error) {
        throw PythonInstallException(
          'Could not replace the Python in ${directory.path}. Stop anything '
          'running with it, such as the Discoman Compute worker, and try '
          'again. (${error.message})',
        );
      }

      onProgress(const PythonInstallProgress(PythonInstallStep.packages));
      void pipLine(String line) => onProgress(
        PythonInstallProgress(PythonInstallStep.packages, line: line),
      );
      final base = await installPackages(
        executablePath,
        basePythonPackages,
        onOutput: pipLine,
        startProcess: _startProcess,
      );
      if (!base.success) {
        throw const PythonInstallException(
          'Python is installed, but its packages could not be. '
          'See what pip said above.',
        );
      }

      final missing = await findMissingModules(
        executablePath,
        modules,
        runProcess: _runProcess,
      );
      // Guessed from import names, so a creator's own module could name an
      // unrelated package: those are installed only once confirmed.
      final guessed = pipPackagesFor(modules.where(missing.contains))
          .where(
            (name) =>
                !basePythonPackages.contains(name) &&
                !packages.contains(name) &&
                manualInstallNote(name) == null,
          )
          .toList();
      final confirmed = guessed.isEmpty || confirmGuessed == null
          ? const <String>[]
          : await confirmGuessed(guessed);
      final extras = {
        ...packages,
        ...confirmed.where(guessed.contains),
      }.where((name) => !basePythonPackages.contains(name)).toList();
      final unavailable = <String>[];
      if (extras.isNotEmpty) {
        final all = await installPackages(
          executablePath,
          extras,
          onOutput: pipLine,
          startProcess: _startProcess,
        );
        // One name pip does not know fails the whole batch, so the rest are
        // tried on their own.
        if (!all.success) {
          for (final name in extras) {
            final one = await installPackages(
              executablePath,
              [name],
              onOutput: pipLine,
              startProcess: _startProcess,
            );
            if (!one.success) unavailable.add(name);
          }
        }
      }

      onProgress(const PythonInstallProgress(PythonInstallStep.check));
      final check = await checkInterpreter(
        executablePath,
        runProcess: _runProcess,
      );
      if (!check.isUsable) throw PythonInstallException(check.message);

      swapped = false;
      try {
        if (previous.existsSync()) previous.deleteSync(recursive: true);
      } on FileSystemException {
        // Removed by the next install.
      }
      return PythonInstallResult(
        path: executablePath,
        unavailablePackages: unavailable,
      );
    } finally {
      if (swapped) _restore(previous);
      if (_injectedHttp == null) client.close();
      if (archive.existsSync()) archive.deleteSync();
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  /// Puts back the Python that was there before a failed install.
  void _restore(Directory previous) {
    try {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
      if (previous.existsSync()) previous.renameSync(directory.path);
    } on FileSystemException {
      // Nothing more can be done; the next install starts over.
    }
  }

  Future<void> _download(
    http.Client client,
    String url,
    File target,
    void Function(PythonInstallProgress progress) onProgress,
  ) async {
    for (var attempt = 1; ; attempt++) {
      onProgress(
        const PythonInstallProgress(PythonInstallStep.download, fraction: 0),
      );
      try {
        final response = await client.send(http.Request('GET', Uri.parse(url)));
        if (response.statusCode != 200) {
          await response.stream.drain<void>();
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
