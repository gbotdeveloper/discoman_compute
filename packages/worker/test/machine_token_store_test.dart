import 'dart:io';

import 'package:discoman_worker/discoman_compute.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late File file;
  late MachineTokenStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('machine_token_test');
    file = File('${temp.path}/credentials.json');
    store = MachineTokenStore(file);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('keeps the credential id beside the token', () {
    store.write('t1', credentialId: 'c1');
    expect(store.read(), 't1');
    expect(store.readCredentialId(), 'c1');
  });

  test('a token saved without an id still reads', () {
    file.writeAsStringSync('{"machineToken":"t1"}');
    expect(store.read(), 't1');
    expect(store.readCredentialId(), isNull);
  });
}
