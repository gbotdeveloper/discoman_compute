import 'package:discoman_client/discoman_client.dart';

/// Parameter-name hints that mark an input as carrying an image or a file.
const Set<String> imagePayloadWords = {
  'image',
  'photo',
  'picture',
  'screenshot',
};
const Set<String> filePayloadWords = {
  'file',
  'attachment',
  'upload',
  'pdf',
  'csv',
};

// NOTE: this inference mirrors `python_contract_extractor.dart` in the discoman
// server, which runs the same pass for projects whose script is uploaded there.
// A creator's script is read here and never leaves this machine, so the two
// cannot share one implementation. Fix a parsing bug in both.

/// Statically extracts a [ContractDraft] (entrypoint + input/output fields) from
/// a user's Python source. Dart port of the legacy `extractContractDraft` and
/// its helpers in `python-parser.ts` — the logic behind `inspectPythonScript`.
///
/// Field types are inferred as strings internally (matching the TS union) and
/// converted to [PythonFieldType] at the end.
ContractDraft extractContractDraft(String source) {
  final functions = _findTopLevelFunctions(source);
  if (functions.isEmpty) {
    throw ScriptRunException(
      message: 'No top-level Python function could be identified.',
      reason: 'extractionFailed',
    );
  }

  final entrypoint = _chooseEntrypoint(functions);
  final notes = <String>[];
  final docstringBody = _extractEntrypointDocstringBody(
    source,
    entrypoint.name,
  );
  final inputFields = _buildInputFields(
    source,
    entrypoint.parameters,
    docstringBody,
    notes,
  );
  final outputFields = _buildOutputFields(source, entrypoint, notes);
  final docstring = _extractDocstringSummary(docstringBody);
  if (docstring != null) {
    notes.add('Docstring: $docstring');
  }

  return ContractDraft(
    entrypointName: entrypoint.name,
    inputFields: inputFields,
    outputFields: outputFields,
    notes: notes,
    summaryMessage:
        'Detected entrypoint "${entrypoint.name}" with ${inputFields.length} '
        'inputs and ${outputFields.length} outputs.',
  );
}

class _TopLevelFunction {
  _TopLevelFunction(this.name, this.parameters, this.returnAnnotation);
  final String name;
  final String parameters;
  final String? returnAnnotation;
}

List<_TopLevelFunction> _findTopLevelFunctions(String source) {
  final regex = RegExp(
    r'^def\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([\s\S]*?)\)\s*(?:->\s*([^:]+?))?\s*:',
    multiLine: true,
  );
  return regex
      .allMatches(source)
      .map(
        (m) => _TopLevelFunction(
          m.group(1) ?? '',
          m.group(2) ?? '',
          m.group(3)?.trim(),
        ),
      )
      .toList();
}

_TopLevelFunction _chooseEntrypoint(List<_TopLevelFunction> functions) {
  for (final preferred in ['main', 'run', 'execute']) {
    for (final fn in functions) {
      if (fn.name == preferred) return fn;
    }
  }
  if (functions.length == 1) return functions.first;
  throw ScriptRunException(
    message:
        'Multiple top-level functions were found. Add a clear entrypoint '
        'named main, run, or execute.',
    reason: 'extractionFailed',
  );
}

// --- Inputs ---------------------------------------------------------------

List<ContractInputField> _buildInputFields(
  String source,
  String parametersSource,
  String? docstringBody,
  List<String> notes,
) {
  final parts = _splitParameters(parametersSource);
  final fields = <ContractInputField>[];
  final enumExtraction = _collectTopLevelEnumStringOptions(source);

  for (var index = 0; index < parts.length; index++) {
    final trimmed = parts[index].trim();
    if (trimmed.isEmpty || trimmed == '/') continue;

    if (trimmed.startsWith('*')) {
      notes.add('Skipped variadic parameter "$trimmed" during extraction.');
      continue;
    }

    final match = RegExp(
      r'^([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*([^=]+))?\s*(?:=\s*(.+))?$',
    ).firstMatch(trimmed);
    if (match == null) {
      notes.add('Skipped unsupported parameter syntax "$trimmed".');
      continue;
    }

    final parameterName = match.group(1)!;
    final annotation = match.group(2)?.trim();
    final defaultValue = match.group(3)?.trim();
    final categoryResolution = _resolveCategoryOptionsFromAnnotation(
      annotation,
      enumExtraction,
    );
    final type = categoryResolution.options.isNotEmpty
        ? 'category'
        : _resolveInputFieldType(
            parameterName,
            annotation,
            docstringBody,
            notes,
          );
    if (categoryResolution.note != null) {
      notes.add(categoryResolution.note!);
    }

    fields.add(
      ContractInputField(
        id: 'draft-input-${index + 1}',
        parameterName: parameterName,
        label: _titleize(parameterName),
        type: _fieldType(type),
        isRequired: defaultValue == null,
        controlHint: _buildControlHint(type),
        validationHint: '',
        options: categoryResolution.options,
      ),
    );
  }

  return fields;
}

String _resolveInputFieldType(
  String parameterName,
  String? annotation,
  String? docstringBody,
  List<String> notes,
) {
  final normalized = annotation?.toLowerCase().trim() ?? '';
  if (normalized.contains('dict') || normalized.contains('mapping')) {
    final docstringHint = _inferAssetPayloadTypeFromDocstringHints(
      docstringBody,
      parameterName,
    );
    if (docstringHint != null) {
      notes.add(
        'Inferred "$parameterName" as $docstringHint from inline script guidance.',
      );
      return docstringHint;
    }
    final nameHint = _inferAssetPayloadTypeFromParameterName(parameterName);
    if (nameHint != null) {
      notes.add(
        'Inferred "$parameterName" as $nameHint from the parameter name.',
      );
      return nameHint;
    }
  }
  return _mapAnnotationToFieldType(annotation);
}

// --- Outputs --------------------------------------------------------------

List<ContractOutputField> _buildOutputFields(
  String source,
  _TopLevelFunction entrypoint,
  List<String> notes,
) {
  final literal = _entrypointSourceReturnLiteral(source, entrypoint.name);
  if (literal.keys.isNotEmpty) {
    return [
      for (var i = 0; i < literal.keys.length; i++)
        ContractOutputField(
          id: 'draft-output-${i + 1}',
          outputKey: literal.keys[i],
          displayLabel: _titleize(literal.keys[i]),
          type: _fieldType(literal.typeHints[literal.keys[i]] ?? 'text'),
          presentationHint:
              'Result field inferred from a literal return dictionary key.',
        ),
    ];
  }

  if (entrypoint.returnAnnotation != null) {
    return [
      ContractOutputField(
        id: 'draft-output-1',
        outputKey: 'result',
        displayLabel: 'Result',
        type: _fieldType(
          _mapAnnotationToFieldType(entrypoint.returnAnnotation),
        ),
        presentationHint:
            'Result inferred from the function return annotation.',
      ),
    ];
  }

  notes.add(
    'Output structure could not be inferred with confidence. A generic result '
    'field was suggested.',
  );
  return [
    ContractOutputField(
      id: 'draft-output-1',
      outputKey: 'result',
      displayLabel: 'Result',
      type: _fieldType('text'),
      presentationHint:
          'Generic output suggested because no reliable return annotation was '
          'found.',
    ),
  ];
}

class _ReturnLiteral {
  _ReturnLiteral(this.keys, this.typeHints);
  final List<String> keys;
  final Map<String, String> typeHints;
}

_ReturnLiteral _entrypointSourceReturnLiteral(String source, String name) {
  final keys = <String>[];
  final typeHints = <String, String>{};
  final escaped = _escapeRegExp(name);
  final headerRegex = RegExp(
    'def\\s+$escaped\\s*\\([^)]*\\)\\s*(?:->\\s*[^:\\n]+)?\\s*:[\\s\\S]*?return\\s*\\{',
    multiLine: true,
  );
  final headerMatch = headerRegex.firstMatch(source);
  if (headerMatch == null) return _ReturnLiteral(keys, typeHints);

  final headerText = headerMatch.group(0)!;
  final bodyStart = headerMatch.start + headerText.length;
  final bodyEnd = findBalancedBraceEnd(source, bodyStart);
  if (bodyEnd == -1) return _ReturnLiteral(keys, typeHints);

  final sourceBeforeReturn = headerText.substring(
    0,
    headerText.lastIndexOf('return'),
  );
  final assignmentTypeHints = _collectAssignmentTypeHints(sourceBeforeReturn);
  final body = source.substring(bodyStart, bodyEnd);
  for (final entry in _extractTopLevelLiteralDictEntries(body)) {
    keys.add(entry.key);
    final inferred = _inferLiteralReturnValueType(
      entry.value,
      assignmentTypeHints,
    );
    if (inferred != null) typeHints[entry.key] = inferred;
  }
  return _ReturnLiteral(keys, typeHints);
}

class _LiteralDictEntry {
  _LiteralDictEntry(this.key, this.value);
  final String key;
  final String value;
}

List<_LiteralDictEntry> _extractTopLevelLiteralDictEntries(String body) {
  return _splitTopLevelCommaSegments(
    body,
  ).map(_parseLiteralDictEntry).whereType<_LiteralDictEntry>().toList();
}

_LiteralDictEntry? _parseLiteralDictEntry(String segment) {
  final match = RegExp(
    r'''^["']([A-Za-z0-9_ -]+)["']\s*:\s*([\s\S]*)$''',
  ).firstMatch(segment.trim());
  if (match == null || match.group(1) == null) return null;
  return _LiteralDictEntry(match.group(1)!, match.group(2)?.trim() ?? '');
}

List<String> _splitTopLevelCommaSegments(String source) {
  final segments = <String>[];
  var depth = 0;
  var segmentStart = 0;
  var i = 0;
  while (i < source.length) {
    final ch = source[i];
    if (_isTripleQuotedStringStart(source, i)) {
      i = _skipTripleQuotedString(source, i);
      continue;
    }
    if (ch == '"' || ch == "'") {
      i = _skipQuotedString(source, i);
      continue;
    }
    if (ch == '#') {
      i = _skipComment(source, i);
      continue;
    }
    if (ch == '{' || ch == '[' || ch == '(') {
      depth++;
    } else if (ch == '}' || ch == ']' || ch == ')') {
      depth = depth > 0 ? depth - 1 : 0;
    } else if (ch == ',' && depth == 0) {
      segments.add(source.substring(segmentStart, i));
      segmentStart = i + 1;
    }
    i++;
  }
  final tail = source.substring(segmentStart);
  if (tail.trim().isNotEmpty) segments.add(tail);
  return segments;
}

Map<String, String> _collectAssignmentTypeHints(String sourceBeforeReturn) {
  final hints = <String, String>{};
  for (final line in sourceBeforeReturn.split(RegExp(r'\r?\n'))) {
    final match = RegExp(
      r'^\s*([A-Za-z_][A-Za-z0-9_]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)\s*=\s*(.+)$',
    ).firstMatch(line);
    if (match == null || match.group(1) == null) continue;
    final targets = match.group(1)!.split(',').map((t) => t.trim()).toList();
    final expression = match.group(2)?.trim() ?? '';
    if (targets.length > 1 && _isMatplotlibSubplotsExpression(expression)) {
      hints[targets[0]] = 'image';
      continue;
    }
    final expressionType = _inferAssignmentExpressionType(expression, hints);
    if (expressionType == null) continue;
    for (final target in targets) {
      hints[target] = expressionType;
    }
  }
  return hints;
}

String? _inferAssignmentExpressionType(String expr, Map<String, String> hints) {
  final assigned = hints[expr.trim()];
  if (assigned != null) return assigned;
  if (_isMatplotlibFigureExpression(expr)) return 'image';
  return _inferNumericExpressionType(expr, hints);
}

String? _inferLiteralReturnValueType(String expr, Map<String, String> hints) {
  final asset = _inferCanonicalAssetPayloadType(expr);
  if (asset != null) return asset;
  final assigned = hints[expr.trim()];
  if (assigned != null) return assigned;
  if (_isMatplotlibFigureExpression(expr)) return 'image';
  return _inferNumericExpressionType(expr, hints);
}

String? _inferCanonicalAssetPayloadType(String expression) {
  final trimmed = expression.trim();
  if (!trimmed.startsWith('{')) return null;
  final nestedEnd = findBalancedBraceEnd(trimmed, 1);
  if (nestedEnd == -1) return null;
  final nested = trimmed.substring(1, nestedEnd);
  if (RegExp(r'''["']kind["']\s*:\s*["']file["']''').hasMatch(nested)) {
    return 'file';
  }
  if (RegExp(r'''["']kind["']\s*:\s*["']image["']''').hasMatch(nested)) {
    return 'image';
  }
  return null;
}

String? _inferNumericExpressionType(
  String expression,
  Map<String, String> hints,
) {
  final trimmed = expression.trim();
  if (hints[trimmed] == 'decimal') return 'decimal';
  if (_isNumericLiteralExpression(trimmed)) return 'decimal';
  if (RegExp(r'^(?:round|sum)\s*\(').hasMatch(trimmed)) return 'decimal';
  if (_containsStringLiteral(trimmed)) return null;
  if (!_hasArithmeticOperator(trimmed)) return null;
  if (_hasNumericLiteral(trimmed) || _referencesDecimalHint(trimmed, hints)) {
    return 'decimal';
  }
  return null;
}

bool _isMatplotlibSubplotsExpression(String e) =>
    RegExp(r'\b(?:plt|pyplot|matplotlib\.pyplot)\.subplots\s*\(').hasMatch(e);

bool _isMatplotlibFigureExpression(String e) =>
    RegExp(
      r'\b(?:plt|pyplot|matplotlib\.pyplot)\.(?:figure|gcf)\s*\(',
    ).hasMatch(e) ||
    RegExp(r'\bFigure\s*\(').hasMatch(e);

bool _isNumericLiteralExpression(String e) => RegExp(
  r'^[-+]?(?:\d+\.?\d*|\.\d+)(?:e[-+]?\d+)?$',
  caseSensitive: false,
).hasMatch(e);

bool _containsStringLiteral(String e) => RegExp('["\']').hasMatch(e);

bool _hasArithmeticOperator(String e) => RegExp(
  r'[A-Za-z0-9_)\]]\s*(?:\*\*|[+\-*/%])\s*[A-Za-z0-9_(\[]',
).hasMatch(e);

bool _hasNumericLiteral(String e) => RegExp(
  r'(^|[^A-Za-z_])[-+]?(?:\d+\.?\d*|\.\d+)(?:e[-+]?\d+)?\b',
  caseSensitive: false,
).hasMatch(e);

bool _referencesDecimalHint(String expression, Map<String, String> hints) {
  for (final match in RegExp(
    r'\b[A-Za-z_][A-Za-z0-9_]*\b',
  ).allMatches(expression)) {
    if (hints[match.group(0)] == 'decimal') return true;
  }
  return false;
}

// --- String scanning helpers ----------------------------------------------

bool _isTripleQuotedStringStart(String source, int index) {
  final ch = source[index];
  return (ch == '"' || ch == "'") &&
      index + 2 < source.length &&
      source[index + 1] == ch &&
      source[index + 2] == ch;
}

int _skipTripleQuotedString(String source, int index) {
  final ch = source[index];
  final closer = ch + ch + ch;
  var i = index + 3;
  while (i + 2 < source.length && source.substring(i, i + 3) != closer) {
    i++;
  }
  final end = i + 3;
  return end < source.length ? end : source.length;
}

int _skipQuotedString(String source, int index) {
  final quote = source[index];
  var i = index + 1;
  while (i < source.length && source[i] != quote) {
    if (source[i] == r'\') i++;
    i++;
  }
  final end = i + 1;
  return end < source.length ? end : source.length;
}

int _skipComment(String source, int index) {
  final nl = source.indexOf('\n', index);
  return nl == -1 ? source.length : nl + 1;
}

/// Starting right after an opening `{`, finds its matching `}`, skipping string
/// literals and comments. Returns the index of the closing `}` or -1.
int findBalancedBraceEnd(String source, int start) {
  var depth = 1;
  var i = start;
  while (i < source.length && depth > 0) {
    final ch = source[i];
    if ((ch == '"' || ch == "'") &&
        i + 2 < source.length &&
        source[i + 1] == ch &&
        source[i + 2] == ch) {
      final closer = ch + ch + ch;
      i += 3;
      while (i + 2 < source.length && source.substring(i, i + 3) != closer) {
        i++;
      }
      i += 3;
      continue;
    }
    if (ch == '"' || ch == "'") {
      i++;
      while (i < source.length && source[i] != ch) {
        if (source[i] == r'\') i++;
        i++;
      }
      i++;
      continue;
    }
    if (ch == '#') {
      final nl = source.indexOf('\n', i);
      i = nl == -1 ? source.length : nl + 1;
      continue;
    }
    if (ch == '{' || ch == '[' || ch == '(') {
      depth++;
    } else if (ch == '}' || ch == ']' || ch == ')') {
      depth--;
    }
    if (depth > 0) i++;
  }
  return depth == 0 ? i : -1;
}

List<String> _splitParameters(String parametersSource) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var depth = 0;
  for (final character in parametersSource.split('')) {
    if (character == ',' && depth == 0) {
      parts.add(buffer.toString());
      buffer.clear();
      continue;
    }
    if (character == '(' || character == '[' || character == '{') {
      depth += 1;
    } else if (character == ')' || character == ']' || character == '}') {
      depth = depth > 0 ? depth - 1 : 0;
    }
    buffer.write(character);
  }
  if (buffer.toString().trim().isNotEmpty) parts.add(buffer.toString());
  return parts;
}

String _mapAnnotationToFieldType(String? annotation) {
  final n = annotation?.toLowerCase().trim() ?? '';
  if (n.contains('literal[')) return 'category';
  if (n.contains('bool')) return 'boolean';
  if (n.contains('int')) return 'integer';
  if (n.contains('float') || n.contains('decimal')) return 'decimal';
  if (n.contains('dict') || n.contains('mapping')) return 'table';
  if (n.contains('list') || n.contains('tuple') || n.contains('sequence')) {
    return 'list';
  }
  if (n.contains('str')) return 'text';
  return 'text';
}

String? _inferAssetPayloadTypeFromDocstringHints(
  String? docstringBody,
  String parameterName,
) {
  if (docstringBody == null) return null;
  final pattern = RegExp(
    '^\\s*[-*]\\s*${_escapeRegExp(parameterName)}\\s*->\\s*(image|file)\\b',
    multiLine: true,
    caseSensitive: false,
  );
  final match = pattern.firstMatch(docstringBody);
  if (match == null) return null;
  return match.group(1)!.toLowerCase() == 'image' ? 'image' : 'file';
}

String? _inferAssetPayloadTypeFromParameterName(String parameterName) {
  final words = _tokenizeIdentifier(parameterName);
  if (words.any(imagePayloadWords.contains)) return 'image';
  if (words.any(filePayloadWords.contains)) return 'file';
  return null;
}

List<String> _tokenizeIdentifier(String identifier) {
  final normalized = identifier
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
  return normalized
      .split(RegExp(r'[^a-z0-9]+'))
      .where((p) => p.isNotEmpty)
      .toList();
}

String _escapeRegExp(String value) =>
    value.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (m) => '\\${m[0]}');

String _buildControlHint(String type) {
  switch (type) {
    case 'boolean':
      return 'Toggle or checkbox';
    case 'integer':
    case 'decimal':
      return 'Numeric input field';
    case 'list':
      return 'Repeated or multi-value input';
    case 'table':
      return 'Structured table or object input';
    case 'category':
      return 'Dropdown or segmented selection';
    case 'image':
      return 'Image upload field';
    case 'file':
      return 'File upload field';
    case 'text':
    default:
      return 'Single-line text input';
  }
}

// --- Enum / category extraction -------------------------------------------

class _EnumExtractionResult {
  _EnumExtractionResult(this.optionsByName, this.unsupportedNames);
  final Map<String, List<String>> optionsByName;
  final Set<String> unsupportedNames;
}

class _CategoryResolution {
  _CategoryResolution(this.options, this.note);
  final List<String> options;
  final String? note;
}

_EnumExtractionResult _collectTopLevelEnumStringOptions(String source) {
  final optionsByName = <String, List<String>>{};
  final unsupportedNames = <String>{};
  final matches = RegExp(
    r'^class\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*:\s*$',
    multiLine: true,
  ).allMatches(source);

  for (final match in matches) {
    final className = match.group(1) ?? '';
    final baseList = match.group(2) ?? '';
    if (!RegExp(r'(^|[\s,])(Enum|StrEnum)([\s,]|$)').hasMatch(baseList)) {
      continue;
    }
    final body = _extractIndentedBlock(
      source,
      match.start + match.group(0)!.length,
    );
    final values = _extractEnumStringValues(body);
    if (values.isNotEmpty) {
      optionsByName[className] = values;
    } else {
      unsupportedNames.add(className);
    }
  }
  return _EnumExtractionResult(optionsByName, unsupportedNames);
}

String _extractIndentedBlock(String source, int start) {
  var cursor = start;
  if (cursor < source.length && source[cursor] == '\r') cursor += 1;
  if (cursor < source.length && source[cursor] == '\n') cursor += 1;

  final lines = <String>[];
  String? expectedIndent;

  while (cursor < source.length) {
    final nextBreak = source.indexOf('\n', cursor);
    final rawLine = source.substring(
      cursor,
      nextBreak == -1 ? source.length : nextBreak,
    );
    final normalizedLine = rawLine.replaceFirst(RegExp(r'\r$'), '');

    if (normalizedLine.trim().isEmpty) {
      if (expectedIndent != null) lines.add(normalizedLine);
      cursor = nextBreak == -1 ? source.length : nextBreak + 1;
      continue;
    }

    final indent = RegExp(r'^\s*').firstMatch(normalizedLine)?.group(0) ?? '';
    if (indent.isEmpty) break;
    expectedIndent ??= indent;
    if (!indent.startsWith(expectedIndent)) break;

    lines.add(normalizedLine);
    cursor = nextBreak == -1 ? source.length : nextBreak + 1;
  }
  return lines.join('\n');
}

List<String> _extractEnumStringValues(String body) {
  final values = <String>[];
  final seen = <String>{};
  for (final rawLine in body.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final match = RegExp(
      r'''^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(['"])(.*?)\2\s*$''',
    ).firstMatch(line);
    if (match == null) continue;
    final value = match.group(3)?.trim() ?? '';
    if (value.isEmpty || seen.contains(value)) continue;
    seen.add(value);
    values.add(value);
  }
  return values;
}

List<String> _extractLiteralStringOptions(String annotation) {
  final literalMatch = RegExp(
    r'(?:^|[\s\[(|])(?:typing\.)?Literal\s*\[([\s\S]+?)\]',
  ).firstMatch(annotation);
  if (literalMatch?.group(1) == null) return [];
  final values = <String>[];
  final seen = <String>{};
  for (final match in RegExp(
    r'''(['"])(.*?)\1''',
  ).allMatches(literalMatch!.group(1)!)) {
    final value = match.group(2)?.trim() ?? '';
    if (value.isEmpty || seen.contains(value)) continue;
    seen.add(value);
    values.add(value);
  }
  return values;
}

_CategoryResolution _resolveCategoryOptionsFromAnnotation(
  String? annotation,
  _EnumExtractionResult enumExtraction,
) {
  if (annotation == null) return _CategoryResolution([], null);
  final literalOptions = _extractLiteralStringOptions(annotation);
  if (literalOptions.isNotEmpty) {
    return _CategoryResolution(literalOptions, null);
  }

  for (final match in RegExp(
    r'\b[A-Za-z_][A-Za-z0-9_]*\b',
  ).allMatches(annotation)) {
    final candidate = match.group(0) ?? '';
    if (enumExtraction.optionsByName.containsKey(candidate)) {
      return _CategoryResolution(
        enumExtraction.optionsByName[candidate] ?? [],
        null,
      );
    }
    if (enumExtraction.unsupportedNames.contains(candidate)) {
      return _CategoryResolution(
        [],
        'Enum "$candidate" was detected in a parameter annotation, but only '
        'simple string-valued enum members can be converted into dropdown '
        'options.',
      );
    }
  }
  return _CategoryResolution([], null);
}

// --- Small helpers --------------------------------------------------------

String _titleize(String value) => value
    .split(RegExp(r'[_\s-]+'))
    .where((p) => p.isNotEmpty)
    .map((p) => p[0].toUpperCase() + p.substring(1))
    .join(' ');

String? _extractDocstringSummary(String? docstringBody) {
  if (docstringBody == null) return null;
  final first = docstringBody.split('\n').first.trim();
  return first;
}

String? _extractEntrypointDocstringBody(String source, String functionName) {
  final regex = RegExp(
    'def\\s+${_escapeRegExp(functionName)}\\s*\\([^)]*\\)\\s*(?:->\\s*[^:\\n]+)?'
    '\\s*:\\s*\\n\\s+["\']{3}([\\s\\S]*?)["\']{3}',
    multiLine: true,
  );
  final match = regex.firstMatch(source);
  final docstring = match?.group(1)?.trim();
  if (docstring == null || docstring.isEmpty) return null;
  return docstring;
}

/// Converts an inferred type string to the [PythonFieldType] enum.
PythonFieldType _fieldType(String type) => PythonFieldType.values.byName(type);
