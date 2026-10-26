import 'package:discoman_client/discoman_client.dart';

import 'script_store.dart';

/// What [syncScripts] changed on this computer and in Discoman.
class ScriptSyncResult {
  const ScriptSyncResult({required this.downloaded, required this.offered});

  /// Projects whose script was copied here from Discoman.
  final List<String> downloaded;

  /// Projects whose script this computer sent, because Discoman had none.
  final List<String> offered;
}

/// The calls [syncScripts] needs, so tests can stand in for the server.
class SyncedScriptsApi {
  const SyncedScriptsApi({
    required this.list,
    required this.download,
    required this.offer,
  });

  SyncedScriptsApi.of(Client client)
    : list = client.computeWorker.listSyncedScripts,
      download = client.computeWorker.downloadSyncedScript,
      offer = client.computeWorker.offerSyncedScript;

  final Future<List<SyncedScriptInfo>> Function() list;
  final Future<String> Function(String projectId) download;
  final Future<bool> Function(
    String projectId,
    String source,
    String fingerprint,
  )
  offer;
}

final _safeProjectId = RegExp(r'^[A-Za-z0-9_-]+$');

/// Copies every script the creator keeps in Discoman onto this computer,
/// and sends this computer's copy of any that Discoman does not hold yet.
Future<ScriptSyncResult> syncScripts(
  SyncedScriptsApi api,
  ScriptStore store,
) async {
  final downloaded = <String>[];
  final offered = <String>[];
  for (final script in await api.list()) {
    // The id becomes a file name here.
    if (!_safeProjectId.hasMatch(script.projectId)) continue;
    final file = store.fileFor(script.projectId);
    final local = file.existsSync() ? file.readAsStringSync() : null;
    final localFingerprint = local == null ? null : fingerprintScript(local);

    if (script.fingerprint == null) {
      if (local != null &&
          await api.offer(script.projectId, local, localFingerprint!)) {
        offered.add(script.projectId);
      }
      continue;
    }
    if (localFingerprint == script.fingerprint) continue;

    store.store(script.projectId, await api.download(script.projectId));
    downloaded.add(script.projectId);
  }
  return ScriptSyncResult(downloaded: downloaded, offered: offered);
}

/// Sends a script just linked here to Discoman when its project keeps its
/// script there, so the creator's other computers get it. Returns whether it
/// was sent.
Future<bool> keepInDiscomanIfChosen(
  Client client, {
  required String projectId,
  required String source,
  required String fingerprint,
}) async {
  if (await client.creatorScript.getScriptSync(projectId) != true) {
    return false;
  }
  await client.creatorScript.uploadSyncedScript(projectId, source, fingerprint);
  return true;
}
