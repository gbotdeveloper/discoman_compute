import 'dart:io';

import 'package:discoman_worker/src/python/run_usage.dart';
import 'package:discoman_worker/src/settings/usage_store.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late UsageStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_usage');
    store = UsageStore(File('${temp.path}/usage.json'));
  });

  tearDown(() => temp.deleteSync(recursive: true));

  RunUsage usage(int ram) =>
      RunUsage(peakRamBytes: ram, cpuSeconds: 1.5, wallMs: 2000);

  test('reads back what was recorded, by project', () {
    store
      ..record('p1', usage(10))
      ..record('p2', usage(20));

    final all = store.load();
    expect(all['p1']!.single.peakRamBytes, 10);
    expect(all['p2']!.single.cpuSeconds, 1.5);
  });

  test('keeps only the latest runs of a project', () {
    for (var i = 0; i < 7; i++) {
      store.record('p1', usage(i));
    }

    expect(store.load()['p1']!.map((u) => u.peakRamBytes), [2, 3, 4, 5, 6]);
  });

  test('a missing or corrupt file reads as nothing measured', () {
    expect(store.load(), isEmpty);
    store.file.writeAsStringSync('{not json');
    expect(store.load(), isEmpty);
  });

  test('keeps graphics memory when there was some', () {
    store.record(
      'p1',
      const RunUsage(
        peakRamBytes: 1,
        cpuSeconds: 1,
        wallMs: 1,
        peakVramBytes: 512,
      ),
    );

    expect(store.load()['p1']!.single.peakVramBytes, 512);
  });
}
