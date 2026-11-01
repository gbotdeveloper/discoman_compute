import 'package:discoman_worker/src/machine_resources.dart';
import 'package:discoman_worker/src/python/run_usage.dart';
import 'package:test/test.dart';

const _gb = 1024 * 1024 * 1024;

RunUsage _usage({int ram = _gb, double cores = 1, int? vram}) => RunUsage(
  peakRamBytes: ram,
  cpuSeconds: cores * 10,
  wallMs: 10000,
  peakVramBytes: vram,
);

void main() {
  const machine = MachineResources(cores: 9, ramBytes: 16 * _gb);

  test('suggests nothing before a run was measured', () {
    expect(suggestedParallelRuns(machine, const []), isNull);
  });

  test('keeps one core free for the rest of the computer', () {
    expect(suggestedParallelRuns(machine, [_usage(ram: 1)]), 8);
  });

  test('a script using every core runs alone', () {
    expect(suggestedParallelRuns(machine, [_usage(cores: 8)]), 1);
  });

  test('leaves a quarter of the memory free', () {
    expect(suggestedParallelRuns(machine, [_usage(ram: 4 * _gb)]), 3);
  });

  test('judges by the heaviest script', () {
    expect(
      suggestedParallelRuns(machine, [
        _usage(ram: _gb, cores: 0.5),
        _usage(ram: 6 * _gb, cores: 1),
      ]),
      2,
    );
  });

  test('never suggests fewer than one', () {
    expect(suggestedParallelRuns(machine, [_usage(ram: 64 * _gb)]), 1);
  });

  test('counts graphics memory when the card says', () {
    const withCard = MachineResources(
      cores: 9,
      ramBytes: 64 * _gb,
      vramBytes: 10 * _gb,
    );
    expect(suggestedParallelRuns(withCard, [_usage(ram: 1, vram: 4 * _gb)]), 2);
  });

  test('leaves memory out when the computer would not say', () {
    const unknown = MachineResources(cores: 5, ramBytes: null);
    expect(suggestedParallelRuns(unknown, [_usage(ram: 64 * _gb)]), 4);
  });

  test('reads the cores a run kept busy', () {
    expect(_usage(cores: 2.5).cores, closeTo(2.5, 1e-9));
  });
}
