import 'dart:io';
import 'dart:math';

import 'home_path.dart';

/// The id this computer goes by, kept in `<discomanHome>/machine_id` so every
/// start of the client on it, CLI or desktop app, reports the same computer.
class MachineIdStore {
  MachineIdStore(this._file);

  factory MachineIdStore.defaultLocation() => MachineIdStore(
    File('${discomanHomeDirectory().path}${Platform.pathSeparator}machine_id'),
  );

  final File _file;

  /// The stored id, created on first use.
  String read() {
    if (_file.existsSync()) {
      final stored = _file.readAsStringSync().trim();
      if (stored.isNotEmpty) return stored;
    }
    final random = Random.secure();
    final id = [
      for (var i = 0; i < 16; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    _file.parent.createSync(recursive: true);
    _file.writeAsStringSync(id);
    return id;
  }
}
