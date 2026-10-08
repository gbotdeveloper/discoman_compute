import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Deletes Service Bus wake-up messages. KEDA counts each running replica
/// against one, so a replica deletes one only when it exits for lack of work.
class WakeUpConsumer {
  WakeUpConsumer({
    required this.namespaceHost,
    required this.queueName,
    required Future<String> Function() token,
    http.Client? httpClient,
  }) : _token = token,
       _http = httpClient ?? http.Client();

  /// Null when no Service Bus is configured, as in local runs.
  static WakeUpConsumer? fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    final host = env['SERVICEBUS_FQDN']?.trim() ?? '';
    if (host.isEmpty) return null;
    final queue = env['SERVICEBUS_QUEUE_NAME']?.trim() ?? '';
    return WakeUpConsumer(
      namespaceHost: host,
      queueName: queue.isEmpty ? 'executions' : queue,
      token: _ManagedIdentityToken(env).get,
    );
  }

  final String namespaceHost;
  final String queueName;
  final Future<String> Function() _token;
  final http.Client _http;

  Future<void> consumeOne() async {
    try {
      final uri = Uri.https(namespaceHost, '/$queueName/messages/head', {
        'timeout': '1',
      });
      final response = await _http
          .delete(uri, headers: {'Authorization': 'Bearer ${await _token()}'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 && response.statusCode != 204) {
        stderr.writeln(
          'Could not remove a wake-up message (HTTP ${response.statusCode}).',
        );
      }
    } catch (error) {
      stderr.writeln('Could not remove a wake-up message: $error');
    }
  }

  void close() => _http.close();
}

class _ManagedIdentityToken {
  _ManagedIdentityToken(this._env);

  final Map<String, String> _env;

  String? _token;
  DateTime? _expiresAt;

  Future<String> get() async {
    final cached = _token;
    final expiresAt = _expiresAt;
    if (cached != null &&
        expiresAt != null &&
        DateTime.now().isBefore(expiresAt)) {
      return cached;
    }

    final endpoint = _env['IDENTITY_ENDPOINT'];
    final header = _env['IDENTITY_HEADER'];
    if (endpoint == null || header == null) {
      throw StateError('Managed identity endpoint not available.');
    }
    final clientId = _env['AZURE_CLIENT_ID'];
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'api-version': '2019-08-01',
        'resource': 'https://servicebus.azure.net/',
        if (clientId != null && clientId.isNotEmpty) 'client_id': clientId,
      },
    );
    final response = await http
        .get(uri, headers: {'X-IDENTITY-HEADER': header})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError(
        'Managed identity token request failed (HTTP ${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final token = payload['access_token'] as String;
    final expiresOnRaw = payload['expires_on'];
    final expiresOn = expiresOnRaw is int
        ? expiresOnRaw
        : int.tryParse(expiresOnRaw?.toString() ?? '') ??
              (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600);
    _token = token;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expiresOn * 1000,
    ).subtract(const Duration(minutes: 5));
    return token;
  }
}
