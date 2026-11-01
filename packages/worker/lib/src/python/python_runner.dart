import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../machine_resources.dart';
import 'run_usage.dart';
import 'runner_script.dart';

/// The tail of user log output kept for a run: last 200 lines, each clipped to
/// 2000 characters — matching the legacy executor's bounds.
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

  /// Bounded stderr (user prints + failure details).
  final List<String> logs;

  /// Present on failure: the last stderr line or a specific failure message.
  final String? errorMessage;

  /// The top-level module the script could not import, when that is why it
  /// failed.
  final String? missingModule;

  /// What the run used, when it was measured.
  final RunUsage? usage;
}

/// Runs a single claimed execution's Python source with a local interpreter,
/// a faithful port of the legacy executor's subprocess protocol: user_script.py
/// + runner.py in a throwaway temp dir, the job JSON on stdin, the result read
/// back from result.json, stderr collected as logs.
class PythonRunner {
  PythonRunner(this.pythonPath, {this.measureUsage = false});

  /// Interpreter to invoke (e.g. `python3` or an absolute path).
  final String pythonPath;

  /// Whether to record the memory, processor time and graphics memory each
  /// run uses.
  final bool measureUsage;

  Future<PythonRunResult> run({
    required String source,
    required String entrypointName,
    required Map<String, dynamic> inputs,
    required int timeoutSeconds,
    required bool Function() cancelRequested,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync('discoman_compute_');
    final stopwatch = Stopwatch()..start();
    try {
      File(
        '${tempDir.path}${Platform.pathSeparator}user_script.py',
      ).writeAsStringSync(source);
      File(
        '${tempDir.path}${Platform.pathSeparator}runner.py',
      ).writeAsStringSync(runnerPy);
      if (measureUsage) {
        File(
          '${tempDir.path}${Platform.pathSeparator}measure.py',
        ).writeAsStringSync(measurePy);
      }

      final process = await Process.start(pythonPath, [
        measureUsage ? 'measure.py' : 'runner.py',
      ], workingDirectory: tempDir.path);
      final vram = measureUsage ? _VramWatch(process.pid) : null;

      final stderrBuffer = StringBuffer();
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .forEach(stderrBuffer.write);
      // The runner reports through result.json, not stdout, but drain stdout so
      // a script that writes a lot to it cannot fill the pipe and deadlock.
      final stdoutDone = process.stdout.drain<void>();

      process.stdin.write(
        jsonEncode({'entrypointName': entrypointName, 'inputs': inputs}),
      );
      await process.stdin.close();

      var timedOut = false;
      var canceled = false;

      final effectiveTimeout = timeoutSeconds > 0 ? timeoutSeconds : 15;
      final timeoutTimer = Timer(Duration(seconds: effectiveTimeout), () {
        timedOut = true;
        process.kill(ProcessSignal.sigkill);
      });
      final cancelTimer = Timer.periodic(const Duration(milliseconds: 200), (
        timer,
      ) {
        if (cancelRequested()) {
          canceled = true;
          process.kill(ProcessSignal.sigkill);
          timer.cancel();
        }
      });

      final exitCode = await process.exitCode;
      timeoutTimer.cancel();
      cancelTimer.cancel();
      vram?.stop();
      await stderrDone;
      await stdoutDone;
      stopwatch.stop();

      final logs = _truncateLogs(_splitStderr(stderrBuffer.toString()));
      final usage = measureUsage
          ? _readUsage(tempDir, stopwatch.elapsedMilliseconds, vram?.peak)
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
        final last = logs.isNotEmpty ? logs.last : 'Python execution failed.';
        return _failure(
          logs,
          stopwatch,
          last,
          missingModule: _missingModuleIn(logs),
          usage: usage,
        );
      }

      final resultFile = File(
        '${tempDir.path}${Platform.pathSeparator}result.json',
      );
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
    } finally {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // Best effort cleanup.
      }
    }
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

  RunUsage? _readUsage(Directory tempDir, int wallMs, int? peakVramBytes) {
    try {
      final json = jsonDecode(
        File(
          '${tempDir.path}${Platform.pathSeparator}usage.json',
        ).readAsStringSync(),
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

  /// Splits stderr the way the executor did: line by line, trimmed, dropping
  /// blank lines.
  List<String> _splitStderr(String stderr) {
    return const LineSplitter()
        .convert(stderr)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Keeps the last [_maxLogLines] lines (tracebacks and the failure message
  /// come last) and clips each to [_maxLogLineLength].
  List<String> _truncateLogs(List<String> lines) {
    final dropped = lines.length > _maxLogLines
        ? lines.length - _maxLogLines
        : 0;
    final tail = lines.length > _maxLogLines
        ? lines.sublist(lines.length - _maxLogLines)
        : lines;
    final kept = tail
        .map(
          (line) => line.length <= _maxLogLineLength
              ? line
              : '${line.substring(0, _maxLogLineLength)}… (truncated)',
        )
        .toList();
    if (dropped > 0) {
      return ['… ($dropped earlier log lines omitted)', ...kept];
    }
    return kept;
  }
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
