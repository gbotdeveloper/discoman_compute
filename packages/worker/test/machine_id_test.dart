import 'dart:io';

import 'package:discoman_worker/src/machine_id.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('discoman_machine'));
  tearDown(() => temp.deleteSync(recursive: true));

  test('creates an id once and keeps returning it', () {
    final file = File('${temp.path}/home/machine_id');

    final first = MachineIdStore(file).read();
    final again = MachineIdStore(file).read();

    expect(first, hasLength(32));
    expect(again, first);
    expect(file.readAsStringSync(), first);
  });

  test('two computers get different ids', () {
    final a = MachineIdStore(File('${temp.path}/a/machine_id')).read();
    final b = MachineIdStore(File('${temp.path}/b/machine_id')).read();

    expect(a, isNot(b));
  });
}
