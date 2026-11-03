import 'dart:io';

import 'package:discoman_worker/discoman_compute.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late SavedSignInStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('saved_sign_in_test');
    store = SavedSignInStore(File('${temp.path}/sign_in.json'));
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('remembers the sign-in until it is cleared', () {
    expect(store.read(), isNull);

    store.write(const SavedSignIn(email: 'a@b.co', refreshToken: 'r1'));
    final saved = store.read();
    expect(saved?.email, 'a@b.co');
    expect(saved?.refreshToken, 'r1');

    store.clear();
    expect(store.read(), isNull);
  });

  test('a corrupt file means signing in again', () {
    File('${temp.path}/sign_in.json').writeAsStringSync('{nope');
    expect(store.read(), isNull);
  });

  test('only the owner can read it', () {
    store.write(const SavedSignIn(email: 'a@b.co', refreshToken: 'r1'));
    final mode = File('${temp.path}/sign_in.json').statSync().modeString();
    expect(mode, 'rw-------');
  }, testOn: '!windows');
}
