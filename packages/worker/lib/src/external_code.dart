import 'dart:io';

import 'package:discoman_client/discoman_client.dart';

typedef RunGit =
    Future<ProcessResult> Function(String executable, List<String> arguments);

/// One piece of code outside Discoman that a script uses, as the creator
/// described it on this machine: either a version they type, or a git
/// checkout whose state is read each time.
class ExternalCodeSource {
  const ExternalCodeSource({required this.name, this.version, this.gitPath});

  final String name;
  final String? version;
  final String? gitPath;

  Map<String, String> toJson() => {
    'name': name,
    'version': ?version,
    'gitPath': ?gitPath,
  };

  static ExternalCodeSource? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    final version = json['version'];
    final gitPath = json['gitPath'];
    if (name is! String || name.trim().isEmpty) return null;
    return ExternalCodeSource(
      name: name.trim(),
      version: version is String && version.trim().isNotEmpty
          ? version.trim()
          : null,
      gitPath: gitPath is String && gitPath.trim().isNotEmpty
          ? gitPath.trim()
          : null,
    );
  }
}

/// What every project's external code is on this machine right now.
Future<List<ExternalCodeVersion>> readExternalCode(
  Map<String, List<ExternalCodeSource>> sources, {
  RunGit? runGit,
}) async {
  return [
    for (final entry in sources.entries)
      for (final source in entry.value)
        await readExternalCodeVersion(entry.key, source, runGit: runGit),
  ];
}

/// What [source] is on this machine right now.
Future<ExternalCodeVersion> readExternalCodeVersion(
  String projectId,
  ExternalCodeSource source, {
  RunGit? runGit,
}) async {
  final path = source.gitPath;
  if (path == null) {
    return ExternalCodeVersion(
      projectId: projectId,
      name: source.name,
      manualVersion: source.version,
    );
  }

  final run = runGit ?? (exe, args) => Process.run(exe, args);
  ExternalCodeVersion failed(String problem) => ExternalCodeVersion(
    projectId: projectId,
    name: source.name,
    gitPath: path,
    problem: problem,
  );

  final ProcessResult log;
  try {
    log = await run('git', ['-C', path, 'log', '-1', '--format=%H%n%cI%n%s']);
  } on ProcessException {
    return failed('Git is not installed on this computer.');
  }
  if (log.exitCode != 0) {
    return failed(
      Directory(path).existsSync()
          ? 'Not a git checkout, or it has no commits.'
          : 'The folder no longer exists.',
    );
  }
  final lines = '${log.stdout}'.trim().split('\n');
  final branch = await run('git', [
    '-C',
    path,
    'rev-parse',
    '--abbrev-ref',
    'HEAD',
  ]);
  final status = await run('git', [
    '-C',
    path,
    'status',
    '--porcelain',
    '--untracked-files=no',
  ]);
  final branchName = '${branch.stdout}'.trim();

  return ExternalCodeVersion(
    projectId: projectId,
    name: source.name,
    gitPath: path,
    commit: lines.first,
    commitDate: lines.length > 1 ? DateTime.tryParse(lines[1])?.toUtc() : null,
    commitMessage: lines.length > 2 ? lines.sublist(2).join('\n') : null,
    branch: branch.exitCode == 0 && branchName != 'HEAD' ? branchName : null,
    dirty: status.exitCode == 0 ? '${status.stdout}'.trim().isNotEmpty : null,
  );
}
