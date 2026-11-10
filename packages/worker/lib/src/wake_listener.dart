import 'dart:async';

import 'package:discoman_client/discoman_client.dart';
import 'package:http/http.dart' as http;

/// Waits to be told there is something to do, instead of asking Discoman
/// every few seconds.
///
/// Discoman hands this machine a queue of its own that it may only read
/// (a [WakeChannel]). One request is kept open against that queue; it
/// answers the moment a wake-up arrives, or empty after about a minute, and
/// is then opened again. None of that reaches the Discoman API, which is
/// what lets the API sleep while nobody is running anything.
///
/// [listening] says whether the channel is in working order. While it is
/// not (no channel on offer, or the queue cannot be reached), the worker
/// falls back to asking.
class WakeListener {
  WakeListener({
    required this.open,
    required this.onWake,
    this.onListeningChanged,
    http.Client? httpClient,
    this.renewBefore = const Duration(hours: 1),
    this.retryDelay = const Duration(seconds: 5),
    this.reopenDelay = const Duration(minutes: 5),
  }) : _http = httpClient ?? http.Client();

  /// Asks Discoman for the channel; null when it offers none.
  final Future<WakeChannel?> Function() open;

  /// Called for every wake-up taken off the queue.
  final void Function() onWake;

  final void Function({required bool listening})? onListeningChanged;

  /// A new channel is opened this long before the current one expires.
  final Duration renewBefore;

  /// The pause after a receive that failed.
  final Duration retryDelay;

  /// How long to wait before asking for a channel again after there was
  /// none, or after the queue kept failing.
  final Duration reopenDelay;

  final http.Client _http;
  bool _stopped = false;
  bool _listening = false;
  Completer<void>? _pause;

  bool get listening => _listening;

  /// Runs until [stop]. Never throws.
  Future<void> run() async {
    WakeChannel? channel;
    var failures = 0;
    while (!_stopped) {
      final current = channel;
      if (current == null ||
          current.expiresAt.difference(DateTime.now().toUtc()) < renewBefore) {
        try {
          channel = await open();
        } on Object {
          channel = null;
        }
        if (channel == null) {
          _setListening(false);
          await _wait(reopenDelay);
          continue;
        }
        failures = 0;
        _setListening(true);
        // Whatever was queued before the channel existed was never
        // announced: look once.
        onWake();
        continue;
      }

      final int status;
      try {
        final response = await _http
            .delete(
              Uri.parse(current.receiveUrl),
              headers: {'Authorization': current.authorization},
            )
            .timeout(const Duration(seconds: 90));
        status = response.statusCode;
      } on Object {
        failures++;
        if (failures >= 3) {
          // The queue cannot be reached: ask instead, and try for a fresh
          // channel later.
          _setListening(false);
          channel = null;
          await _wait(reopenDelay);
        } else {
          await _wait(retryDelay);
        }
        continue;
      }

      if (status == 200 || status == 201) {
        failures = 0;
        onWake();
      } else if (status == 204) {
        failures = 0;
      } else {
        // Refused (an expired or replaced key, a removed queue): a new
        // channel sorts that out, or there is none any more.
        channel = null;
        failures++;
        if (failures >= 3) {
          _setListening(false);
          await _wait(reopenDelay);
        } else {
          await _wait(retryDelay);
        }
      }
    }
    _setListening(false);
  }

  void stop() {
    _stopped = true;
    _pause?.complete();
    _http.close();
  }

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    onListeningChanged?.call(listening: value);
  }

  /// Waits [delay], cut short by [stop].
  Future<void> _wait(Duration delay) async {
    if (_stopped) return;
    final pause = _pause = Completer<void>();
    final timer = Timer(delay, () {
      if (!pause.isCompleted) pause.complete();
    });
    await pause.future;
    timer.cancel();
  }
}
