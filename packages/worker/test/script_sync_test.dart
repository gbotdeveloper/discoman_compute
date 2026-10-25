import 'dart:io';

import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/src/scripts/script_store.dart';
import 'package:discoman_worker/src/scripts/script_sync.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late ScriptStore store;
  late Map<String, String> server;
  late List<String> downloads;
  late List<String> offers;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('discoman_sync');
    store = ScriptStore(Directory('${temp.path}/scripts'));
    server = {};
    downloads = [];
    offers = [];
  });

  tearDown(() => temp.deleteSync(recursive: true));

  SyncedScriptsApi api({Set<String> chosen = const {}}) => SyncedScriptsApi(
    list: () async => [
      for (final id in {...chosen, ...server.keys})
        SyncedScriptInfo(
          projectId: id,
          fingerprint: server.containsKey(id)
              ? fingerprintScript(server[id]!)
              : null,
        ),
    ],
    download: (projectId) async {
      downloads.add(projectId);
      return server[projectId]!;
    },
    offer: (projectId, source, fingerprint) async {
      offers.add(projectId);
      if (server.containsKey(projectId)) return false;
      server[projectId] = source;
      return true;
    },
  );

  test('copies a script kept in Discoman onto a new computer', () async {
    server['p1'] = 'def main():\n    return 1\n';

    final result = await syncScripts(api(), store);

    expect(result.downloaded, ['p1']);
    expect(store.fileFor('p1').readAsStringSync(), server['p1']);
  });

  test('replaces an older copy and leaves a current one alone', () async {
    server['p1'] = 'def main():\n    return 2\n';
    server['p2'] = 'def main():\n    return 3\n';
    store
      ..store('p1', 'def main():\n    return 1\n')
      ..store('p2', server['p2']!);

    final result = await syncScripts(api(), store);

    expect(result.downloaded, ['p1']);
    expect(downloads, ['p1']);
    expect(store.fileFor('p1').readAsStringSync(), server['p1']);
  });

  test('sends its copy when Discoman has none yet', () async {
    store.store('p1', 'def main():\n    return 1\n');

    final result = await syncScripts(api(chosen: {'p1', 'p2'}), store);

    expect(result.offered, ['p1']);
    expect(offers, ['p1']);
    expect(server['p1'], 'def main():\n    return 1\n');
    expect(store.fileFor('p2').existsSync(), isFalse);
  });

  test('leaves scripts that are not kept in Discoman alone', () async {
    store.store('local-only', 'def main():\n    return 1\n');

    final result = await syncScripts(api(), store);

    expect(result.downloaded, isEmpty);
    expect(result.offered, isEmpty);
    expect(store.fileFor('local-only').existsSync(), isTrue);
  });
}
