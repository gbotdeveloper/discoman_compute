import 'dart:convert';
import 'dart:io';

/// Files on another drive than the run folder are copied on Windows when they
/// are no bigger than this, and left out otherwise.
const int maxCopiedFileBytes = 8 * 1024 * 1024;

/// Where one run's script lives and runs.
class RunFolder {
  RunFolder._({
    required this.directory,
    required this.scriptFile,
    required this.workingDirectory,
    required this.scriptDirectory,
    required this.notes,
    required this.inScriptFolder,
  });

  /// A fresh folder of this run's own, deleted afterwards. Inputs go here.
  final Directory directory;

  /// The script Python loads.
  final String scriptFile;

  /// The run's current directory: [directory], unless the script's folder
  /// could not be linked into it.
  final String workingDirectory;

  /// The folder the creator keeps the script in, when it is known.
  final String? scriptDirectory;

  /// What the creator should know about how the folder was set up.
  final List<String> notes;

  /// Whether the run uses the script's own folder because linking failed, so
  /// only one run of it may go at a time.
  final bool inScriptFolder;

  /// A folder holding [source] as `user_script.py`, as runs had before the
  /// script's own folder was known.
  static RunFolder detached(String source) {
    final dir = Directory.systemTemp.createTempSync('discoman_run_');
    final file = File(_join(dir.path, 'user_script.py'))
      ..writeAsStringSync(source);
    return RunFolder._(
      directory: dir,
      scriptFile: file.path,
      workingDirectory: dir.path,
      scriptDirectory: null,
      notes: const [],
      inScriptFolder: false,
    );
  }

  /// A folder holding [source] under the name of [scriptPath], with a link to
  /// everything else beside that script, so the script finds its files by
  /// relative name and parallel runs each write into their own folder.
  ///
  /// Falls back to running in the script's own folder when the links cannot
  /// be made.
  static RunFolder linked(String source, String scriptPath) {
    final original = File(scriptPath).absolute;
    final scriptDir = original.parent.path;
    final name = _baseName(original.path);
    final dir = Directory.systemTemp.createTempSync('discoman_run_');
    final file = File(_join(dir.path, name))..writeAsStringSync(source);
    final notes = <String>[];

    final siblings = [
      for (final entry in Directory(scriptDir).listSync(followLinks: false))
        if (_baseName(entry.path) != name &&
            _baseName(entry.path) != '__pycache__')
          entry,
    ];

    final failed = Platform.isWindows
        ? _linkOnWindows(siblings, dir.path, notes)
        : _linkOnPosix(siblings, dir.path);

    if (failed != null) {
      notes.add(
        'Could not link the files beside the script into the run folder '
        '($failed), so this run uses ${original.parent.path} itself and '
        "the project's runs go one at a time.",
      );
      return RunFolder._(
        directory: dir,
        scriptFile: original.path,
        workingDirectory: scriptDir,
        scriptDirectory: scriptDir,
        notes: notes,
        inScriptFolder: true,
      );
    }
    return RunFolder._(
      directory: dir,
      scriptFile: file.path,
      workingDirectory: dir.path,
      scriptDirectory: scriptDir,
      notes: notes,
      inScriptFolder: false,
    );
  }

  /// Writes every input file into [directory] and adds its `path`, keeping
  /// the inline `base64` too. Lists keep their order.
  Map<String, dynamic> writeInputs(Map<String, dynamic> inputs) {
    final result = <String, dynamic>{};
    for (final entry in inputs.entries) {
      final value = entry.value;
      if (_isInlineFile(value)) {
        result[entry.key] = _writeInput(entry.key, value as Map);
      } else if (value is List &&
          value.isNotEmpty &&
          value.every(_isInlineFile)) {
        result[entry.key] = [
          for (final (i, item) in value.indexed)
            _writeInput('${entry.key}_${i + 1}', item as Map),
        ];
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  static bool _isInlineFile(dynamic value) =>
      value is Map &&
      (value['kind'] == 'image' || value['kind'] == 'file') &&
      value['base64'] is String;

  Map<String, dynamic> _writeInput(String key, Map<dynamic, dynamic> value) {
    final extension = value['extension'] is String
        ? '.${(value['extension'] as String).replaceAll('.', '')}'
        : '';
    final given = value['name'] is String ? value['name'] as String : '';
    final name = _uniqueName(
      _safeName(given.isEmpty ? '$key$extension' : given),
    );
    final file = File(_join(directory.path, name))
      ..writeAsBytesSync(base64Decode(value['base64'] as String));
    return {...value.cast<String, dynamic>(), 'path': file.path};
  }

  String _uniqueName(String name) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final extension = dot > 0 ? name.substring(dot) : '';
    var candidate = name;
    for (var i = 2; _exists(_join(directory.path, candidate)); i++) {
      candidate = '${stem}_$i$extension';
    }
    return candidate;
  }

  /// Removes the folder without following any link in it, so the files the
  /// links point at are never touched.
  void delete() => deleteWithoutFollowingLinks(directory);
}

/// Deletes [dir] and what it holds, removing links rather than what they
/// point at.
void deleteWithoutFollowingLinks(Directory dir) {
  if (!dir.existsSync()) return;
  for (final entry in dir.listSync(followLinks: false)) {
    final type = FileSystemEntity.typeSync(entry.path, followLinks: false);
    try {
      if (type == FileSystemEntityType.link) {
        _deleteLink(entry.path);
      } else if (type == FileSystemEntityType.directory) {
        deleteWithoutFollowingLinks(Directory(entry.path));
      } else {
        File(entry.path).deleteSync();
      }
    } catch (_) {
      // Best effort: one stuck file must not keep the rest.
    }
  }
  try {
    dir.deleteSync();
  } catch (_) {}
}

void _deleteLink(String path) {
  try {
    Link(path).deleteSync();
  } on FileSystemException {
    if (!Platform.isWindows) rethrow;
    // A junction is removed like an empty folder; its target stays.
    Process.runSync('cmd', ['/c', 'rmdir', path]);
  }
}

/// Symbolic links for everything. Returns why it failed, or null.
String? _linkOnPosix(List<FileSystemEntity> siblings, String into) {
  for (final entry in siblings) {
    try {
      Link(_join(into, _baseName(entry.path))).createSync(entry.path);
    } on FileSystemException catch (error) {
      return '${_baseName(entry.path)}: ${error.osError?.message ?? error.message}';
    }
  }
  return null;
}

/// Junctions for folders and hard links for files, which need no special
/// rights. A file on another drive cannot be hard linked, so it is copied, or
/// left out when big. Returns why it failed, or null.
String? _linkOnWindows(
  List<FileSystemEntity> siblings,
  String into,
  List<String> notes,
) {
  if (siblings.isEmpty) return null;
  // One cmd for all of them: starting one per file would make a folder of a
  // few hundred files take seconds.
  final batch = StringBuffer('@echo off\r\nchcp 65001 >nul\r\n');
  for (final entry in siblings) {
    final isDir =
        FileSystemEntity.typeSync(entry.path) == FileSystemEntityType.directory;
    final link = _join(into, _baseName(entry.path));
    batch.write(
      'mklink ${isDir ? '/J' : '/H'} "${_batchQuoted(link)}" '
      '"${_batchQuoted(entry.path)}" >nul 2>&1\r\n',
    );
  }
  final script = File('$into.links.cmd')..writeAsStringSync(batch.toString());
  try {
    Process.runSync('cmd', ['/c', script.path]);
  } catch (error) {
    return '$error';
  } finally {
    try {
      script.deleteSync();
    } catch (_) {}
  }

  for (final entry in siblings) {
    final name = _baseName(entry.path);
    final link = _join(into, name);
    if (_exists(link)) continue;
    final type = FileSystemEntity.typeSync(entry.path);
    if (type == FileSystemEntityType.directory) {
      return '$name: the folder could not be linked';
    }
    try {
      final size = File(entry.path).lengthSync();
      if (size > maxCopiedFileBytes) {
        notes.add(
          'Left $name out of the run folder: it is on another drive and too '
          'big to copy. Open it by its full path.',
        );
        continue;
      }
      File(entry.path).copySync(link);
    } on FileSystemException catch (error) {
      return '$name: ${error.osError?.message ?? error.message}';
    }
  }
  return null;
}

String _batchQuoted(String path) => path.replaceAll('%', '%%');

bool _exists(String path) =>
    FileSystemEntity.typeSync(path, followLinks: false) !=
    FileSystemEntityType.notFound;

String _join(String dir, String name) => '$dir${Platform.pathSeparator}$name';

String _baseName(String path) =>
    path.split(RegExp(r'[\\/]')).where((part) => part.isNotEmpty).last;

final _unsafe = RegExp(r'[^A-Za-z0-9._-]+');

/// A file name made only of characters every file system takes.
String _safeName(String name) {
  var safe = _baseName(name.isEmpty ? 'input' : name).replaceAll(_unsafe, '_');
  safe = safe.replaceFirst(RegExp(r'^[._]+'), '');
  if (safe.isEmpty) safe = 'input';
  return safe.length > 100 ? safe.substring(safe.length - 100) : safe;
}
