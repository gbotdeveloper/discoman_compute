import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../machine_resources.dart';
import 'run_environment.dart';
import 'run_folder.dart';
import 'run_usage.dart';
import 'runner_script.dart';

/// The tail of each output stream kept for a run: last 200 lines, each
/// clipped to 2000 characters — matching the legacy executor's bounds.
const int _maxLogLines = 200;
const int _maxLogLineLength = 2000;

/// Outcome of one Python execution.
class PythonRunResult {
  PythonRunResult({
    required this.success,
    required this.canceled,
    required this.timedOut,
    required this.outputs,
    required this.durationMs,
    required this.logs,
    required this.errorMessage,
    this.missingModule,
    this.usage,
    this.inScriptFolder = false,
  });

  /// True only when the runner wrote a well-formed result payload.
  final bool success;

  /// True when the process was SIGKILLed because the server requested cancel.
  final bool canceled;

  /// True when the process was SIGKILLed for exceeding its timeout.
  final bool timedOut;

  /// The normalized outputs map (asset values are still inline base64 here).
  final Map<String, dynamic>? outputs;

  /// Wall time of the Python process, in milliseconds.
  final int durationMs;

  /// Bounded stdout (each line marked `[stdout]`) then stderr (user prints
  /// and failure details).
  final List<String> logs;

  /// Present on failure: the last stderr line or a specific failure message.
  final String? errorMessage;

  /// The top-level module the script could not import, when that is why it
  /// failed.
  final String? missingModule;

  /// What the run used, when it was measured.
  final RunUsage? usage;

  /// Whether the run had to use the script's own folder, since the files
  /// beside it could not be linked into a run folder.
  final bool inScriptFolder;
}

/// Runs a single claimed execution's Python source with a local interpreter,
/// following the legacy executor's subprocess protocol: the job JSON on stdin,
/// the result read back from result.json, output collected as logs.
///
/// The script runs in a fresh folder of its own. When its original path is
/// known, the files beside it are linked in, so it finds them by relative
/// name while parallel runs each write into their own folder. runner.py and
/// what it writes live in a second, private folder the script never sees.
class PythonRunner {
  PythonRunner(this.pythonPath, {this.measureUsage = false});

  /// Interpreter to invoke (e.g. `python3` or an absolute path).
  final String pythonPath;

  /// Whether to record the memory, processor time and graphics memory each
  /// run uses.
  final bool measureUsage;

  /// How long a stopped run's processes get to end before they are killed.
  static const killGrace = Duration(seconds: 3);

  /// How long output is still read after Python exits, in case something it
  /// started keeps the pipes open.
  static const outputGrace = Duration(seconds: 2);

  static final _running = <Process>{};

  /// Runs in a script's own folder, by folder, so they go one at a time.
  static final _folderTurns = <String, Completer<void>>{};

  /// Kills every run in progress and whatever each started, for when the app
  /// quits.
  static void killAll() {
    for (final process in [..._running]) {
      _killTree(process, ProcessSignal.sigkill);
    }
  }

  Future<PythonRunResult> run({
    required String source,
    required String entrypointName,
    required Map<String, dynamic> inputs,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
    String? scriptPath,
  }) async {
    final privateDir = Directory.systemTemp.createTempSync('discoman_compute_');
    final stopwatch = Stopwatch()..start();
    RunFolder? folder;
    try {
      folder = scriptPath == null
          ? RunFolder.detached(source)
          : RunFolder.linked(source, scriptPath);
      final runFolder = folder;
      final notes = [for (final note in runFolder.notes) 'Discoman: $note'];
      final Map<String, dynamic> runInputs;
      try {
        runInputs = runFolder.writeInputs(inputs);
      } catch (error) {
        return _failure(
          notes,
          stopwatch,
          'The input files could not be written for the script: $error',
        );
      }

      File(_join(privateDir.path, 'runner.py')).writeAsStringSync(runnerPy);
      if (measureUsage) {
        File(_join(privateDir.path, 'measure.py')).writeAsStringSync(measurePy);
      }

      if (!runFolder.inScriptFolder) {
        return await _start(
          privateDir,
          runFolder,
          notes,
          stopwatch,
          entrypointName: entrypointName,
          inputs: runInputs,
          timeoutSeconds: timeoutSeconds,
          cancelRequested: cancelRequested,
        );
      }
      // Runs sharing the script's own folder would write over each other.
      final key = runFolder.workingDirectory;
      final previous = _folderTurns[key]?.future;
      final turn = Completer<void>();
      _folderTurns[key] = turn;
      await previous;
      try {
        final result = await _start(
          privateDir,
          runFolder,
          notes,
          stopwatch,
          entrypointName: entrypointName,
          inputs: runInputs,
          timeoutSeconds: timeoutSeconds,
          cancelRequested: cancelRequested,
        );
        return PythonRunResult(
          success: result.success,
          canceled: result.canceled,
          timedOut: result.timedOut,
          outputs: result.outputs,
          durationMs: result.durationMs,
          logs: result.logs,
          errorMessage: result.errorMessage,
          missingModule: result.missingModule,
          usage: result.usage,
          inScriptFolder: true,
        );
      } finally {
        turn.complete();
        if (identical(_folderTurns[key], turn)) {
          _folderTurns.remove(key);
        }
      }
    } on FileSystemException catch (error) {
      return _failure(
        const [],
        stopwatch,
        'The run folder could not be set up: ${error.message}'
        '${error.path == null ? '' : ' (${error.path})'}',
      );
    } finally {
      folder?.delete();
      try {
        privateDir.deleteSync(recursive: true);
      } catch (_) {
        // Best effort cleanup.
      }
    }
  }

  Future<PythonRunResult> _start(
    Directory privateDir,
    RunFolder folder,
    List<String> notes,
    Stopwatch stopwatch, {
    required String entrypointName,
    required Map<String, dynamic> inputs,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
  }) async {
    final scriptDir = folder.scriptDirectory;
    final inherited = Platform.environment;
    final pythonPathKey = inherited.keys.firstWhere(
      (name) => name.toUpperCase() == 'PYTHONPATH',
      orElse: () => 'PYTHONPATH',
    );
    final existingPythonPath = inherited[pythonPathKey] ?? '';
    final environment = {
      ...runEnvironment(),
      'DISCOMAN_RUN_DIR': folder.directory.path,
      'DISCOMAN_SCRIPT_DIR': scriptDir ?? folder.directory.path,
      if (scriptDir != null)
        pythonPathKey: [
          scriptDir,
          if (existingPythonPath.isNotEmpty) existingPythonPath,
        ].join(Platform.isWindows ? ';' : ':'),
    };

    final process = await Process.start(
      pythonPath,
      [_join(privateDir.path, measureUsage ? 'measure.py' : 'runner.py')],
      workingDirectory: folder.workingDirectory,
      environment: environment,
    );
    _running.add(process);
    try {
      return await _watch(
        process,
        privateDir,
        notes,
        stopwatch,
        job: {
          'entrypointName': entrypointName,
          'inputs': inputs,
          'scriptFile': folder.scriptFile,
          'scriptDir': ?scriptDir,
        },
        timeoutSeconds: timeoutSeconds,
        cancelRequested: cancelRequested,
      );
    } finally {
      _running.remove(process);
    }
  }

  Future<PythonRunResult> _watch(
    Process process,
    Directory privateDir,
    List<String> notes,
    Stopwatch stopwatch, {
    required Map<String, dynamic> job,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
  }) async {
    final vram = measureUsage ? _VramWatch(process.pid) : null;

    final stderrTail = _LogTail();
    final stdoutTail = _LogTail();
    final stderrDone = _collect(process.stderr, stderrTail);
    // The runner reports through result.json, not stdout, but programs the
    // script starts write to it, so its tail is kept too.
    final stdoutDone = _collect(process.stdout, stdoutTail);

    try {
      process.stdin.write(jsonEncode(job));
      await process.stdin.close();
    } catch (_) {
      // Python ended before reading its job; its exit code says why.
    }

    var timedOut = false;
    var canceled = false;

    final effectiveTimeout = timeoutSeconds > 0 ? timeoutSeconds : 15;
    final timeoutTimer = Timer(Duration(seconds: effectiveTimeout), () {
      timedOut = true;
      _stop(process);
    });
    final cancelTimer = Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      if (cancelRequested()) {
        canceled = true;
        _stop(process);
        timer.cancel();
      }
    });

    final exitCode = await process.exitCode;
    timeoutTimer.cancel();
    cancelTimer.cancel();
    vram?.stop();
    // Something the script started may still hold the pipes open; its output
    // is not worth hanging the worker for.
    await Future.wait([
      stderrDone.future,
      stdoutDone.future,
    ]).timeout(outputGrace, onTimeout: () => const []);
    await stderrDone.cancel();
    await stdoutDone.cancel();
    stopwatch.stop();

    final stderrLines = stderrTail.lines;
    final logs = [
      ...notes,
      for (final line in stdoutTail.withOmitted()) '[stdout] $line',
      ...stderrTail.withOmitted(),
    ];
    final usage = measureUsage
        ? _readUsage(privateDir, stopwatch.elapsedMilliseconds, vram?.peak)
        : null;

    if (canceled) {
      return PythonRunResult(
        success: false,
        canceled: true,
        timedOut: false,
        outputs: null,
        durationMs: stopwatch.elapsedMilliseconds,
        logs: logs,
        errorMessage: 'Execution canceled.',
        usage: usage,
      );
    }
    if (timedOut) {
      return _failure(
        logs,
        stopwatch,
        'Python execution timed out after ${effectiveTimeout}s.',
        timedOut: true,
        usage: usage,
      );
    }
    if (exitCode != 0) {
      final last = stderrLines.isNotEmpty
          ? stderrLines.last
          : 'Python execution failed.';
      return _failure(
        logs,
        stopwatch,
        last,
        missingModule: _missingModuleIn(stderrLines),
        usage: usage,
      );
    }

    final resultFile = File(_join(privateDir.path, 'result.json'));
    if (!resultFile.existsSync()) {
      return _failure(
        logs,
        stopwatch,
        'Python execution returned no JSON payload.',
        usage: usage,
      );
    }

    Map<String, dynamic> outputs;
    try {
      final payload = jsonDecode(resultFile.readAsStringSync());
      if (payload is! Map || payload['outputs'] is! Map) {
        return _failure(
          logs,
          stopwatch,
          'Python execution did not return a JSON object.',
          usage: usage,
        );
      }
      outputs = Map<String, dynamic>.from(payload['outputs'] as Map);
    } catch (_) {
      return _failure(
        logs,
        stopwatch,
        'Python execution returned a malformed JSON payload.',
        usage: usage,
      );
    }

    return PythonRunResult(
      success: true,
      canceled: false,
      timedOut: false,
      outputs: outputs,
      durationMs: stopwatch.elapsedMilliseconds,
      logs: logs,
      errorMessage: null,
      usage: usage,
    );
  }

  /// Asks the run and everything it started to end, then kills what is left.
  static void _stop(Process process) {
    _killTree(process, ProcessSignal.sigterm);
    Timer(killGrace, () => _killTree(process, ProcessSignal.sigkill));
  }

  static void _killTree(Process process, ProcessSignal signal) {
    if (Platform.isWindows) {
      try {
        Process.runSync('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
      } catch (_) {}
      process.kill(ProcessSignal.sigkill);
      return;
    }
    // The runner put itself in a process group of its own, numbered after
    // it. Signal the process too, in case it had not got that far.
    try {
      Process.killPid(-process.pid, signal);
    } catch (_) {}
    process.kill(signal);
  }

  PythonRunResult _failure(
    List<String> logs,
    Stopwatch stopwatch,
    String message, {
    bool timedOut = false,
    String? missingModule,
    RunUsage? usage,
  }) {
    return PythonRunResult(
      success: false,
      canceled: false,
      timedOut: timedOut,
      outputs: null,
      durationMs: stopwatch.elapsedMilliseconds,
      logs: logs,
      errorMessage: message,
      missingModule: missingModule,
      usage: usage,
    );
  }

  RunUsage? _readUsage(Directory privateDir, int wallMs, int? peakVramBytes) {
    try {
      final json = jsonDecode(
        File(_join(privateDir.path, 'usage.json')).readAsStringSync(),
      );
      if (json is! Map) return null;
      return RunUsage.tryFromJson({
        ...json,
        'wallMs': wallMs,
        'peakVramBytes': ?peakVramBytes,
      });
    } catch (_) {
      // Killed runs and scripts that end the interpreter abruptly leave none.
      return null;
    }
  }

  /// The module named when the run ended on a `ModuleNotFoundError`. Only
  /// the last line counts: a script may log one it caught and fail later
  /// for another reason.
  String? _missingModuleIn(List<String> logs) {
    if (logs.isEmpty) return null;
    final match = RegExp(
      r"^(?:ModuleNotFoundError: )?No module named '([^'.]+)",
    ).firstMatch(logs.last);
    return match?.group(1);
  }
}

String _join(String dir, String name) => '$dir${Platform.pathSeparator}$name';

/// Reads [stream] line by line into [tail]; the subscription can be dropped
/// once the output stops mattering.
_Collecting _collect(Stream<List<int>> stream, _LogTail tail) {
  final done = Completer<void>();
  final subscription = stream
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter())
      .listen(
        tail.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
        onError: (_) {},
        cancelOnError: false,
      );
  return _Collecting(done.future, subscription);
}

class _Collecting {
  _Collecting(this.future, this._subscription);

  final Future<void> future;
  final StreamSubscription<String> _subscription;

  Future<void> cancel() => _subscription.cancel();
}

/// The last [_maxLogLines] non-blank lines of one stream, trimmed and each
/// clipped to [_maxLogLineLength], as the executor kept them.
class _LogTail {
  final _lines = ListQueue<String>();
  var _dropped = 0;

  void add(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;
    _lines.add(
      trimmed.length <= _maxLogLineLength
          ? trimmed
          : '${trimmed.substring(0, _maxLogLineLength)}… (truncated)',
    );
    if (_lines.length > _maxLogLines) {
      _lines.removeFirst();
      _dropped++;
    }
  }

  List<String> get lines => _lines.toList();

  List<String> withOmitted() => [
    if (_dropped > 0) '… ($_dropped earlier log lines omitted)',
    ..._lines,
  ];
}

/// Polls `nvidia-smi` for the graphics memory a run holds, keeping the peak.
/// Stops asking on a computer without an NVIDIA card.
class _VramWatch {
  _VramWatch(int pid) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_asking) return;
      _asking = true;
      final used = await vramUsedBy(pid);
      _asking = false;
      if (used == null) {
        stop();
        return;
      }
      if (peak == null || used > peak!) peak = used;
    });
  }

  late final Timer _timer;
  var _asking = false;
  int? peak;

  void stop() => _timer.cancel();
}
