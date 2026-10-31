import 'dart:io';

import 'python/run_usage.dart';

/// What this computer has to share between runs.
class MachineResources {
  const MachineResources({
    required this.cores,
    required this.ramBytes,
    this.vramBytes,
  });

  final int cores;

  /// Null when the platform would not say.
  final int? ramBytes;

  /// The largest NVIDIA card's memory; null without one.
  final int? vramBytes;

  static Future<MachineResources> read() async => MachineResources(
    cores: Platform.numberOfProcessors,
    ramBytes: await _totalRamBytes(),
    vramBytes: await _totalVramBytes(),
  );

  static Future<int?> _totalRamBytes() async {
    try {
      if (Platform.isMacOS) {
        final result = await Process.run('sysctl', ['-n', 'hw.memsize']);
        return int.tryParse((result.stdout as String).trim());
      }
      if (Platform.isLinux) {
        final line = File(
          '/proc/meminfo',
        ).readAsLinesSync().firstWhere((line) => line.startsWith('MemTotal:'));
        final kb = int.tryParse(line.split(RegExp(r'\s+'))[1]);
        return kb == null ? null : kb * 1024;
      }
      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          '(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory',
        ]);
        return int.tryParse((result.stdout as String).trim());
      }
    } catch (_) {
      // Unknown, and the suggestion leaves memory out.
    }
    return null;
  }

  static Future<int?> _totalVramBytes() async {
    final lines = await _nvidiaSmi([
      '--query-gpu=memory.total',
      '--format=csv,noheader,nounits',
    ]);
    final sizes = [
      for (final line in lines ?? const <String>[]) ?int.tryParse(line.trim()),
    ];
    if (sizes.isEmpty) return null;
    return sizes.reduce((a, b) => a > b ? a : b) * 1024 * 1024;
  }
}

/// Graphics memory [pid] holds right now, or null without an NVIDIA card.
Future<int?> vramUsedBy(int pid) async {
  final lines = await _nvidiaSmi([
    '--query-compute-apps=pid,used_memory',
    '--format=csv,noheader,nounits',
  ]);
  if (lines == null) return null;
  var total = 0;
  for (final line in lines) {
    final parts = line.split(',');
    if (parts.length < 2 || int.tryParse(parts[0].trim()) != pid) continue;
    final mib = int.tryParse(parts[1].trim());
    if (mib != null) total += mib * 1024 * 1024;
  }
  return total;
}

Future<List<String>?> _nvidiaSmi(List<String> arguments) async {
  try {
    final result = await Process.run('nvidia-smi', arguments);
    if (result.exitCode != 0) return null;
    return (result.stdout as String)
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  } catch (_) {
    return null;
  }
}

/// How many runs this computer can take at once without running out of
/// memory or cores, judged by the heaviest script measured so far.
///
/// Leaves a quarter of the memory and one core for everything else on the
/// computer. Null until at least one run has been measured.
int? suggestedParallelRuns(
  MachineResources machine,
  Iterable<RunUsage> usages,
) {
  if (usages.isEmpty) return null;
  final ram = usages.map((u) => u.peakRamBytes).reduce(_max);
  final cores = usages.map((u) => u.cores).reduce((a, b) => a > b ? a : b);
  final vrams = [for (final u in usages) ?u.peakVramBytes];

  final freeCores = machine.cores > 1 ? machine.cores - 1 : 1;
  var limit = (freeCores / (cores < 0.25 ? 0.25 : cores)).floor();
  final machineRam = machine.ramBytes;
  if (machineRam != null && ram > 0) {
    limit = _min(limit, (machineRam * 0.75 / ram).floor());
  }
  final machineVram = machine.vramBytes;
  if (machineVram != null && vrams.isNotEmpty) {
    final vram = vrams.reduce(_max);
    if (vram > 0) limit = _min(limit, (machineVram * 0.9 / vram).floor());
  }
  return limit < 1 ? 1 : limit;
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;
