import 'dart:async';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/src/wake_listener.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

WakeChannel _channel({Duration validFor = const Duration(hours: 12)}) =>
    WakeChannel(
      receiveUrl: 'https://bus.test/device-1/messages/head?timeout=55',
      authorization: 'SharedAccessSignature test',
      expiresAt: DateTime.now().toUtc().add(validFor),
    );

void main() {
  test('wakes once on opening, then once per message', () async {
    final answers = [200, 204, 200];
    var requests = 0;
    final done = Completer<void>();
    late WakeListener listener;
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.headers['Authorization'], 'SharedAccessSignature test');
      if (requests >= answers.length) {
        if (!done.isCompleted) done.complete();
        listener.stop();
        return http.Response('', 204);
      }
      return http.Response('{"reason":"run"}', answers[requests++]);
    });
    var wakes = 0;
    listener = WakeListener(
      open: () async => _channel(),
      onWake: () => wakes++,
      onListeningChanged: ({required bool listening}) =>
          _record(listening, into: listening_),
      httpClient: client,
    );
    final run = listener.run();
    await done.future;
    await run;

    // One look when the channel opened, two messages.
    expect(wakes, 3);
    expect(listening_, [true, false]);
  });

  test('with no channel on offer it does not listen', () async {
    var opens = 0;
    late WakeListener listener;
    listener = WakeListener(
      open: () async {
        opens++;
        if (opens == 2) listener.stop();
        return null;
      },
      onWake: () => fail('nothing to wake for'),
      httpClient: MockClient((_) async => fail('no queue to ask')),
      reopenDelay: const Duration(milliseconds: 10),
    );
    await listener.run();
    expect(opens, 2);
    expect(listener.listening, isFalse);
  });

  test('a refused receive opens a new channel', () async {
    var opens = 0;
    var requests = 0;
    late WakeListener listener;
    listener = WakeListener(
      open: () async {
        opens++;
        return _channel();
      },
      onWake: () {},
      httpClient: MockClient((_) async {
        requests++;
        if (requests == 1) return http.Response('', 401);
        listener.stop();
        return http.Response('', 204);
      }),
      retryDelay: const Duration(milliseconds: 10),
    );
    await listener.run();
    expect(opens, 2);
  });

  test('a channel close to expiry is renewed before it is used', () async {
    var opens = 0;
    late WakeListener listener;
    listener = WakeListener(
      open: () async {
        opens++;
        if (opens == 3) listener.stop();
        return _channel(validFor: const Duration(minutes: 5));
      },
      onWake: () {},
      httpClient: MockClient((_) async => fail('an expiring channel')),
    );
    await listener.run();
    expect(opens, 3);
  });
}

final listening_ = <bool>[];
void _record(bool value, {required List<bool> into}) => into.add(value);
