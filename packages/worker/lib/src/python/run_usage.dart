/// What one run of a script used on this computer.
class RunUsage {
  const RunUsage({
    required this.peakRamBytes,
    required this.cpuSeconds,
    required this.wallMs,
    this.peakVramBytes,
  });

  /// The most memory the Python process held at once.
  final int peakRamBytes;

  /// Processor time the run spent, across every core it used.
  final double cpuSeconds;

  final int wallMs;

  /// Graphics memory, where an NVIDIA card could report it.
  final int? peakVramBytes;

  /// How many cores the run kept busy on average.
  double get cores => wallMs <= 0 ? 0 : cpuSeconds / (wallMs / 1000);

  Map<String, Object?> toJson() => {
    'peakRamBytes': peakRamBytes,
    'cpuSeconds': cpuSeconds,
    'wallMs': wallMs,
    if (peakVramBytes != null) 'peakVramBytes': peakVramBytes,
  };

  static RunUsage? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final ram = json['peakRamBytes'];
    final cpu = json['cpuSeconds'];
    final wall = json['wallMs'];
    final vram = json['peakVramBytes'];
    if (ram is! int || cpu is! num || wall is! int) return null;
    return RunUsage(
      peakRamBytes: ram,
      cpuSeconds: cpu.toDouble(),
      wallMs: wall,
      peakVramBytes: vram is int ? vram : null,
    );
  }
}

/// Runs runner.py unchanged and records what the process used on the way out,
/// even when the script fails.
const String measurePy = r'''
import json
import runpy
import sys
from pathlib import Path

USAGE_FILE = Path("usage.json").resolve()
RUNNER_FILE = str(Path("runner.py").resolve())


def _usage():
    try:
        import resource
    except ImportError:
        return _windows_usage()
    own = resource.getrusage(resource.RUSAGE_SELF)
    children = resource.getrusage(resource.RUSAGE_CHILDREN)
    scale = 1 if sys.platform == "darwin" else 1024
    return {
        "peakRamBytes": max(own.ru_maxrss, children.ru_maxrss) * scale,
        "cpuSeconds": own.ru_utime + own.ru_stime
        + children.ru_utime + children.ru_stime,
    }


def _windows_usage():
    import ctypes
    from ctypes import wintypes

    class Counters(ctypes.Structure):
        _fields_ = [
            ("cb", wintypes.DWORD),
            ("PageFaultCount", wintypes.DWORD),
            ("PeakWorkingSetSize", ctypes.c_size_t),
            ("WorkingSetSize", ctypes.c_size_t),
            ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
            ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
            ("PagefileUsage", ctypes.c_size_t),
            ("PeakPagefileUsage", ctypes.c_size_t),
        ]

    kernel32 = ctypes.WinDLL("kernel32")
    psapi = ctypes.WinDLL("psapi")
    kernel32.GetCurrentProcess.restype = wintypes.HANDLE
    handle = kernel32.GetCurrentProcess()
    counters = Counters()
    counters.cb = ctypes.sizeof(Counters)
    psapi.GetProcessMemoryInfo.argtypes = [
        wintypes.HANDLE, ctypes.POINTER(Counters), wintypes.DWORD,
    ]
    psapi.GetProcessMemoryInfo(handle, ctypes.byref(counters), counters.cb)
    times = [wintypes.FILETIME() for _ in range(4)]
    kernel32.GetProcessTimes.argtypes = [wintypes.HANDLE] + [
        ctypes.POINTER(wintypes.FILETIME)
    ] * 4
    kernel32.GetProcessTimes(handle, *[ctypes.byref(t) for t in times])

    def seconds(t):
        return ((t.dwHighDateTime << 32) | t.dwLowDateTime) / 1e7

    return {
        "peakRamBytes": counters.PeakWorkingSetSize,
        "cpuSeconds": seconds(times[2]) + seconds(times[3]),
    }


try:
    runpy.run_path(RUNNER_FILE, run_name="__main__")
finally:
    try:
        USAGE_FILE.write_text(json.dumps(_usage()), encoding="utf-8")
    except Exception:
        pass
''';
