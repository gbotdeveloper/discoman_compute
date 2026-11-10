import 'dart:io';

/// Opens [url] in the creator's default browser, with what the operating
/// system ships: this app adds no package for it.
Future<void> openInBrowser(String url) async {
  if (Platform.isMacOS) {
    await Process.run('open', [url]);
  } else if (Platform.isWindows) {
    await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
  } else {
    await Process.run('xdg-open', [url]);
  }
}
