import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
}

/// Runs a single claimed execution's Python source with a local interpreter,
/// a faithful port of the legacy executor's subprocess protocol: user_script.py
/// + runner.py in a throwaway temp dir, the job JSON on stdin, the result read
/// back from result.json, stderr collected as logs.
class PythonRunner {
  PythonRunner(this.pythonPath);

  /// Interpreter to invoke (e.g. `python3` or an absolute path).
  final String pythonPath;

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

      final process = await Process.start(pythonPath, [
        'runner.py',
      ], workingDirectory: tempDir.path);

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
      await stderrDone;
      await stdoutDone;
      stopwatch.stop();

      final logs = _truncateLogs(_splitStderr(stderrBuffer.toString()));

      if (canceled) {
        return PythonRunResult(
          success: false,
          canceled: true,
          timedOut: false,
          outputs: null,
          durationMs: stopwatch.elapsedMilliseconds,
          logs: logs,
          errorMessage: 'Execution canceled.',
        );
      }
      if (timedOut) {
        return _failure(
          logs,
          stopwatch,
          'Python execution timed out after ${effectiveTimeout}s.',
          timedOut: true,
        );
      }
      if (exitCode != 0) {
        final last = logs.isNotEmpty ? logs.last : 'Python execution failed.';
        return _failure(logs, stopwatch, last);
      }

      final resultFile = File(
        '${tempDir.path}${Platform.pathSeparator}result.json',
      );
      if (!resultFile.existsSync()) {
        return _failure(
          logs,
          stopwatch,
          'Python execution returned no JSON payload.',
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
          );
        }
        outputs = Map<String, dynamic>.from(payload['outputs'] as Map);
      } catch (_) {
        return _failure(
          logs,
          stopwatch,
          'Python execution returned a malformed JSON payload.',
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
  }) {
    return PythonRunResult(
      success: false,
      canceled: false,
      timedOut: timedOut,
      outputs: null,
      durationMs: stopwatch.elapsedMilliseconds,
      logs: logs,
      errorMessage: message,
    );
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
