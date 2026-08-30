import 'dart:async';

import 'package:discoman_client/discoman_client.dart';

/// Sends periodic heartbeats for the execution currently running and surfaces
/// the server's cancel signal.
///
/// While an execution runs, a heartbeat both proves the worker is alive and
/// renews the execution's lease. The response's `cancelRequested` flag (which
/// also fires when the lease was lost and the run was given away) is latched
/// into [cancelRequested]; the Python runner polls it to SIGKILL the process.
class ExecutionHeartbeat {
  ExecutionHeartbeat(this._client, this._workerId, this._intervalSeconds);

  final Client _client;
  final UuidValue _workerId;
  final int _intervalSeconds;

  Timer? _timer;

  /// Latched true once the server asks for the running execution to stop.
  bool cancelRequested = false;

  /// Starts heartbeating for [executionId]. Resets the cancel flag.
  void start(UuidValue executionId) {
    cancelRequested = false;
    _timer?.cancel();
    final seconds = _intervalSeconds < 1 ? 1 : _intervalSeconds;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) async {
      try {
        final response = await _client.computeWorker.heartbeat(
          _workerId,
          executionId,
        );
        if (response.cancelRequested) {
          cancelRequested = true;
        }
      } catch (_) {
        // A transient heartbeat failure is not fatal: if the worker truly went
        // away the server's lease sweeper reclaims the run.
      }
    });
  }

  /// Stops heartbeating for the current execution.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
