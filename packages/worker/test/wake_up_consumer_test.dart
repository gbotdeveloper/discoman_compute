import 'package:discoman_worker/src/wake_up_consumer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  WakeUpConsumer consumerWith(
    MockClientHandler handler, {
    Future<String> Function()? token,
  }) => WakeUpConsumer(
    namespaceHost: 'sb-test.servicebus.windows.net',
    queueName: 'executions',
    token: token ?? () async => 'token-123',
    httpClient: MockClient(handler),
  );

  test('deletes the message at the head of the queue', () async {
    late http.Request sent;
    final consumer = consumerWith((request) async {
      sent = request;
      return http.Response('', 200);
    });

    await consumer.consumeOne();

    expect(sent.method, 'DELETE');
    expect(
      sent.url.toString(),
      'https://sb-test.servicebus.windows.net/executions/messages/head?timeout=1',
    );
    expect(sent.headers['Authorization'], 'Bearer token-123');
  });

  test('treats an empty queue as success', () async {
    final consumer = consumerWith((_) async => http.Response('', 204));
    await expectLater(consumer.consumeOne(), completes);
  });

  test('never throws on an error response', () async {
    final consumer = consumerWith((_) async => http.Response('', 401));
    await expectLater(consumer.consumeOne(), completes);
  });

  test('never throws when the request fails', () async {
    final consumer = consumerWith(
      (_) async => throw http.ClientException('connection refused'),
    );
    await expectLater(consumer.consumeOne(), completes);
  });

  test('never throws when no token can be obtained', () async {
    var called = false;
    final consumer = consumerWith((_) async {
      called = true;
      return http.Response('', 200);
    }, token: () async => throw StateError('no managed identity'));

    await expectLater(consumer.consumeOne(), completes);
    expect(called, isFalse);
  });

  group('fromEnvironment', () {
    test('is null without a Service Bus, as in local runs', () {
      expect(WakeUpConsumer.fromEnvironment(const {}), isNull);
      expect(
        WakeUpConsumer.fromEnvironment(const {'SERVICEBUS_FQDN': '  '}),
        isNull,
      );
    });

    test('defaults to the executions queue', () {
      final consumer = WakeUpConsumer.fromEnvironment(const {
        'SERVICEBUS_FQDN': 'sb-dscm-prod.servicebus.windows.net',
      })!;
      expect(consumer.namespaceHost, 'sb-dscm-prod.servicebus.windows.net');
      expect(consumer.queueName, 'executions');
    });

    test('honours an explicit queue name', () {
      final consumer = WakeUpConsumer.fromEnvironment(const {
        'SERVICEBUS_FQDN': 'sb-dscm-prod.servicebus.windows.net',
        'SERVICEBUS_QUEUE_NAME': 'executions-staging',
      })!;
      expect(consumer.queueName, 'executions-staging');
    });
  });
}
