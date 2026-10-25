final _importLine = RegExp(r'^\s*import\s+(.+)$');
final _fromLine = RegExp(r'^\s*from\s+([A-Za-z_][\w.]*)\s+import\b');

/// The top-level modules [source] imports, in first-seen order.
///
/// Reads `import a, b.c as d` and `from a.b import c` lines anywhere in the
/// file, nested ones included; relative imports and `__future__` are left
/// out. Imports built at run time (importlib, strings) cannot be seen.
List<String> importedModules(String source) {
  final modules = <String>{};
  for (final line in source.split('\n')) {
    final code = line.split('#').first;
    final from = _fromLine.firstMatch(code);
    if (from != null) {
      modules.add(from.group(1)!.split('.').first);
      continue;
    }
    final plain = _importLine.firstMatch(code);
    if (plain == null) continue;
    for (final part in plain.group(1)!.split(',')) {
      final name = part.trim().split(RegExp(r'\s+')).first.split('.').first;
      if (RegExp(r'^[A-Za-z_]\w*$').hasMatch(name)) modules.add(name);
    }
  }
  modules.remove('__future__');
  return modules.toList();
}
