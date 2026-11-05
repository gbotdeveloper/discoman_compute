import 'package:discoman_client/discoman_client.dart';

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
  final inputFields = _buildInputFields(source, entrypoint.parameters, notes);
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

/// The alias a script declares as `Images = list[str]`: a list of image paths.
const imagesAlias = 'Images';

/// The alias a script declares as `Files = list[str]`: a list of file paths.
const filesAlias = 'Files';

/// The alias a script declares as `Image = str`: the path to one image.
const imageAlias = 'Image';

/// The alias a script declares as `File = str`: the path to one file.
const fileAlias = 'File';

List<ContractInputField> _buildInputFields(
  String source,
  String parametersSource,
  List<String> notes,
) {
  final parts = _splitParameters(parametersSource);
  final fields = <ContractInputField>[];
  final enums = _collectTopLevelEnumStringOptions(source);

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
    final defaultValue = match.group(3)?.trim();
    final field = _resolveField(
      parameterName,
      match.group(2)?.trim(),
      enums,
      notes,
    );

    fields.add(
      ContractInputField(
        id: 'draft-input-${index + 1}',
        parameterName: parameterName,
        label: _titleize(parameterName),
        type: _fieldType(field.type),
        isRequired: defaultValue == null,
        controlHint: field.multiple
            ? '${_buildControlHint(field.type)} (multiple)'
            : _buildControlHint(field.type),
        validationHint: '',
        options: field.options,
        multiple: field.multiple,
      ),
    );
  }

  return fields;
}

class _ResolvedField {
  const _ResolvedField(
    this.type, {
    this.multiple = false,
    this.options = const [],
  });

  final String type;
  final bool multiple;
  final List<String> options;
}

/// The field a parameter or an `Outputs` entry declares with [annotation].
/// Types outside the supported set are read as text, with a note saying so.
_ResolvedField _resolveField(
  String name,
  String? annotation,
  _EnumExtractionResult enums,
  List<String> notes,
) {
  final bare = _withoutOptional(annotation ?? '');
  if (bare == imagesAlias) return const _ResolvedField('image', multiple: true);
  if (bare == filesAlias) return const _ResolvedField('file', multiple: true);
  if (bare == imageAlias) return const _ResolvedField('image');
  if (bare == fileAlias) return const _ResolvedField('file');

  final itemAnnotation = _listItemAnnotation(bare);
  final category = _resolveCategoryOptionsFromAnnotation(
    itemAnnotation ?? bare,
    enums,
  );
  if (category.note != null) notes.add(category.note!);
  if (category.options.isNotEmpty) {
    return _ResolvedField(
      'category',
      multiple: itemAnnotation != null,
      options: category.options,
    );
  }

  // A list of rows, `list[dict]`, is a table.
  if (itemAnnotation != null &&
      _mapAnnotationToFieldType(itemAnnotation) == 'table') {
    return const _ResolvedField('table');
  }
  final type = _mapAnnotationToFieldType(bare);
  if (type == 'list' || (itemAnnotation != null && type != 'table')) {
    notes.add(
      'Lists of values are not supported, so "$name" is read as text. Use '
      '$imagesAlias or $filesAlias for images and files.',
    );
    return const _ResolvedField('text');
  }
  return _ResolvedField(type);
}

/// [annotation] without the `Optional[...]`, `X | None` or quotes around it.
String _withoutOptional(String annotation) {
  var compact = annotation
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'''^["']|["']$'''), '');
  final members = _splitTopLevel(
    compact,
    '|',
  ).where((member) => member.toLowerCase() != 'none').toList();
  if (members.length == 1) compact = members.single;
  final optional = RegExp(
    r'^(?:typing\.)?Optional\[(.*)\]$',
  ).firstMatch(compact);
  return optional == null ? compact : _withoutOptional(optional.group(1)!);
}

const _listAnnotationNames = {
  'list',
  'sequence',
  'tuple',
  'set',
  'frozenset',
  'iterable',
};

/// The item annotation of `list[X]`, `Sequence[X]` or `tuple[X, ...]`, kept in
/// its original case so Literal options survive. Null for anything else.
String? _listItemAnnotation(String? annotation) {
  final compact = (annotation ?? '').replaceAll(RegExp(r'\s+'), '');
  final members = _splitTopLevel(
    compact,
    '|',
  ).where((member) => member.toLowerCase() != 'none').toList();
  if (members.length != 1) return null;
  final member = members.single;
  final bracketIndex = member.indexOf('[');
  if (bracketIndex == -1 || !member.endsWith(']')) return null;
  final head = member.substring(0, bracketIndex).toLowerCase();
  final headName = head.substring(head.lastIndexOf('.') + 1);
  final args = _splitParameters(
    member.substring(bracketIndex + 1, member.length - 1),
  );
  if ((headName == 'optional' || headName == 'annotated') && args.isNotEmpty) {
    return _listItemAnnotation(args.first);
  }
  if (!_listAnnotationNames.contains(headName)) return null;
  if (args.length == 1) return args.single;
  if (headName == 'tuple' && args.length == 2 && args.last == '...') {
    return args.first;
  }
  return null;
}

// --- Outputs --------------------------------------------------------------

/// The class a script declares its outputs in, one `name: type` line each.
const outputsClassName = 'Outputs';

List<ContractOutputField> _buildOutputFields(
  String source,
  _TopLevelFunction entrypoint,
  List<String> notes,
) {
  final declared = _declaredOutputs(source);
  if (declared != null) {
    final enums = _collectTopLevelEnumStringOptions(source);
    return [
      for (var i = 0; i < declared.length; i++)
        _declaredOutputField(i, declared[i], enums, notes),
    ];
  }

  final literal = _entrypointSourceReturnLiteral(source, entrypoint.name);
  if (literal.keys.isNotEmpty) {
    notes.add(
      'Outputs were read from the return statement. Declare them in a class '
      '$outputsClassName to set their types exactly.',
    );
    return [
      for (var i = 0; i < literal.keys.length; i++)
        _literalOutputField(i, literal.keys[i], literal.typeHints),
    ];
  }

  notes.add(
    'Output structure could not be inferred. Declare the outputs in a class '
    '$outputsClassName.',
  );
  return [
    ContractOutputField(
      id: 'draft-output-1',
      outputKey: 'result',
      displayLabel: 'Result',
      type: _fieldType('text'),
      presentationHint:
          'Generic output suggested because no outputs were declared.',
    ),
  ];
}

/// Each output a script declares in its `class Outputs`, by key, with the
/// [PythonFieldType] name it is shown as. Null when the script declares none.
Map<String, String>? declaredOutputTypes(String source) {
  final declared = _declaredOutputs(source);
  if (declared == null) return null;
  final enums = _collectTopLevelEnumStringOptions(source);
  return {
    for (final (i, entry) in declared.indexed)
      entry.$1: _declaredOutputField(i, entry, enums, []).type.name,
  };
}

/// The `name: annotation` lines of a top-level `class Outputs`, or null when
/// the script has none.
List<(String, String)>? _declaredOutputs(String source) {
  final header = RegExp(
    '^class\\s+$outputsClassName\\s*(?:\\([^)]*\\))?\\s*:[^\\n]*\$',
    multiLine: true,
  ).firstMatch(source);
  if (header == null) return null;
  final body = _extractIndentedBlock(source, header.end);
  final entries = <(String, String)>[];
  var i = 0;
  while (i < body.length) {
    if (_isTripleQuotedStringStart(body, i)) {
      i = _skipTripleQuotedString(body, i);
      continue;
    }
    final lineEnd = body.indexOf('\n', i);
    final line = body.substring(i, lineEnd == -1 ? body.length : lineEnd);
    i = lineEnd == -1 ? body.length : lineEnd + 1;
    final match = RegExp(
      r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^=#]+?)\s*(?:=.*)?(?:#.*)?$',
    ).firstMatch(line);
    if (match != null) entries.add((match.group(1)!, match.group(2)!));
  }
  return entries;
}

ContractOutputField _declaredOutputField(
  int index,
  (String, String) entry,
  _EnumExtractionResult enums,
  List<String> notes,
) {
  final (key, annotation) = entry;
  var field = _resolveField(key, annotation, enums, notes);
  if (field.type == 'category') {
    notes.add('Output "$key" is shown as text: choices only apply to inputs.');
    field = const _ResolvedField('text');
  }
  return ContractOutputField(
    id: 'draft-output-${index + 1}',
    outputKey: key,
    displayLabel: _titleize(key),
    type: _fieldType(field.type),
    presentationHint: 'Declared in class $outputsClassName.',
    multiple: field.multiple,
  );
}

/// An output from a literal return key. A `[]` suffix on its type hint marks a
/// list of files.
ContractOutputField _literalOutputField(
  int index,
  String key,
  Map<String, String> typeHints,
) {
  final hint = typeHints[key] ?? 'text';
  final multiple = hint.endsWith('[]');
  return ContractOutputField(
    id: 'draft-output-${index + 1}',
    outputKey: key,
    displayLabel: _titleize(key),
    type: _fieldType(multiple ? hint.substring(0, hint.length - 2) : hint),
    presentationHint:
        'Result field inferred from a literal return dictionary key.',
    multiple: multiple,
  );
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
  // A comment after the previous entry's comma lands at the start of this one.
  final withoutComments = segment.replaceAll(
    RegExp(r'^\s*#.*$', multiLine: true),
    '',
  );
  final match = RegExp(
    r'''^["']([A-Za-z0-9_ -]+)["']\s*:\s*([\s\S]*)$''',
  ).firstMatch(withoutComments.trim());
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
  if (_isDataFrameExpression(expr)) return 'table';
  final assetList = _inferAssetListExpressionType(expr, hints);
  if (assetList != null) return assetList;
  return _inferNumericExpressionType(expr, hints);
}

String? _inferLiteralReturnValueType(String expr, Map<String, String> hints) {
  final asset = _inferCanonicalAssetPayloadType(expr);
  if (asset != null) return asset;
  final assetList = _inferAssetListExpressionType(expr, hints);
  if (assetList != null) return assetList;
  if (_isDataFrameExpression(expr)) return 'table';
  final assigned = hints[expr.trim()];
  if (assigned != null) return assigned;
  if (_isMatplotlibFigureExpression(expr)) return 'image';
  return _inferNumericExpressionType(expr, hints);
}

/// `image[]` or `file[]` for a list literal whose items are all images or all
/// files, such as `[fig, other_fig]`.
String? _inferAssetListExpressionType(String expr, Map<String, String> hints) {
  final trimmed = expr.trim();
  if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) return null;
  final items = _splitTopLevelCommaSegments(
    trimmed.substring(1, trimmed.length - 1),
  ).map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  if (items.isEmpty) return null;
  final types = {
    for (final item in items)
      _inferCanonicalAssetPayloadType(item) ??
          hints[item] ??
          (_isMatplotlibFigureExpression(item) ? 'image' : null),
  };
  if (types.length != 1) return null;
  final type = types.single;
  return type == 'image' || type == 'file' ? '$type[]' : null;
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
  if (RegExp(r'^[-+]?\d+$').hasMatch(trimmed) ||
      RegExp(r'^(?:int|len)\s*\(').hasMatch(trimmed)) {
    return 'integer';
  }
  if (_isNumericLiteralExpression(trimmed)) return 'decimal';
  if (RegExp(r'^(?:round|sum)\s*\(').hasMatch(trimmed)) return 'decimal';
  if (_containsStringLiteral(trimmed)) return null;
  if (!_hasArithmeticOperator(trimmed)) return null;
  if (_hasNumericLiteral(trimmed) || _referencesDecimalHint(trimmed, hints)) {
    return 'decimal';
  }
  return null;
}

bool _isDataFrameExpression(String e) => RegExp(
  r'^\s*(?:pd|pandas)\.(?:DataFrame|read_csv|read_excel|read_json|concat)\s*\(',
).hasMatch(e);

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

const _annotationTypeNames = {
  'literal': 'category',
  'bool': 'boolean',
  'int': 'integer',
  'float': 'decimal',
  'decimal': 'decimal',
  'dict': 'table',
  'mapping': 'table',
  'list': 'list',
  'tuple': 'list',
  'sequence': 'list',
  'str': 'text',
  'date': 'date',
  'datetime': 'date',
  'dataframe': 'table',
};

/// Maps an annotation by its outermost type, so `list[int]` is a list and not
/// an integer. `Optional[X]`, `X | None` and `Union[X, None]` resolve to `X`.
String _mapAnnotationToFieldType(String? annotation) {
  final normalized = (annotation ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'''^["']|["']$'''), '');
  if (normalized.isEmpty) return 'text';

  final members = _splitTopLevel(normalized, '|');
  if (members.length > 1) return _mapUnionMembersToFieldType(members);

  final bracketIndex = normalized.indexOf('[');
  final head = bracketIndex == -1
      ? normalized
      : normalized.substring(0, bracketIndex);
  final headName = head.substring(head.lastIndexOf('.') + 1);
  final args = bracketIndex != -1 && normalized.endsWith(']')
      ? _splitParameters(
          normalized.substring(bracketIndex + 1, normalized.length - 1),
        )
      : const <String>[];

  if (headName == 'optional' && args.length == 1) {
    return _mapAnnotationToFieldType(args.first);
  }
  if (headName == 'annotated' && args.isNotEmpty) {
    return _mapAnnotationToFieldType(args.first);
  }
  if (headName == 'union' && args.isNotEmpty) {
    return _mapUnionMembersToFieldType(args);
  }
  return _annotationTypeNames[headName] ?? 'text';
}

String _mapUnionMembersToFieldType(List<String> members) {
  final types = {
    for (final member in members)
      if (member != 'none') _mapAnnotationToFieldType(member),
  };
  if (types.length == 1) return types.first;
  if (types.length == 2 &&
      types.contains('integer') &&
      types.contains('decimal')) {
    return 'decimal';
  }
  return 'text';
}

List<String> _splitTopLevel(String source, String separator) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var depth = 0;
  for (final character in source.split('')) {
    if (character == separator && depth == 0) {
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
  parts.add(buffer.toString());
  return parts;
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
    case 'date':
      return 'Date picker';
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
