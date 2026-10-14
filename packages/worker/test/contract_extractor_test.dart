import 'package:discoman_client/discoman_client.dart';
import 'package:discoman_worker/src/python/contract_extractor.dart';
import 'package:test/test.dart';

void main() {
  group('extractContractDraft', () {
    test('detects entrypoint and infers input types from annotations', () {
      const source = '''
def run(age: int, name: str, ratio: float, active: bool) -> dict:
    return {"ok": True}
''';
      final draft = extractContractDraft(source);
      expect(draft.entrypointName, 'run');
      expect(draft.inputFields.map((f) => f.parameterName), [
        'age',
        'name',
        'ratio',
        'active',
      ]);
      expect(draft.inputFields[0].type, PythonFieldType.integer);
      expect(draft.inputFields[1].type, PythonFieldType.text);
      expect(draft.inputFields[2].type, PythonFieldType.decimal);
      expect(draft.inputFields[3].type, PythonFieldType.boolean);
    });

    test('prefers main/run/execute among multiple functions', () {
      const source = '''
def helper(x): return x
def run(name: str): return {"greeting": name}
''';
      expect(extractContractDraft(source).entrypointName, 'run');
    });

    test('throws when multiple functions and no clear entrypoint', () {
      const source = 'def a(x): return x\ndef b(y): return y';
      expect(
        () => extractContractDraft(source),
        throwsA(
          isA<ScriptRunException>().having(
            (e) => e.reason,
            'reason',
            'extractionFailed',
          ),
        ),
      );
    });

    test('throws when no top-level function exists', () {
      expect(
        () => extractContractDraft('x = 1'),
        throwsA(isA<ScriptRunException>()),
      );
    });

    test('infers category + options from Literal annotation', () {
      const source = '''
def run(mode: Literal["fast", "slow"]):
    return {"r": 1}
''';
      final field = extractContractDraft(source).inputFields.single;
      expect(field.type, PythonFieldType.category);
      expect(field.options, ['fast', 'slow']);
    });

    test('infers category + options from a top-level Enum', () {
      const source = '''
class Color(Enum):
    RED = "red"
    BLUE = "blue"

def run(color: Color):
    return {"r": 1}
''';
      final field = extractContractDraft(source).inputFields.single;
      expect(field.type, PythonFieldType.category);
      expect(field.options, ['red', 'blue']);
    });

    test('marks parameters with defaults as optional', () {
      const source = 'def run(name: str, count: int = 3):\n    return {"r": 1}';
      final fields = extractContractDraft(source).inputFields;
      expect(fields[0].isRequired, isTrue);
      expect(fields[1].isRequired, isFalse);
    });

    test('infers output fields from a literal return dict', () {
      const source = '''
def run(w: float, h: float):
    bmi = round(w / (h * h), 2)
    return {"bmi": bmi, "label": "healthy"}
''';
      final outputs = extractContractDraft(source).outputFields;
      expect(outputs.map((o) => o.outputKey), ['bmi', 'label']);
      expect(outputs[0].type, PythonFieldType.decimal);
      expect(outputs[1].type, PythonFieldType.text);
    });

    test('infers image input from parameter name when annotated dict', () {
      const source = 'def run(source_image: dict):\n    return {"r": 1}';
      final field = extractContractDraft(source).inputFields.single;
      expect(field.type, PythonFieldType.image);
    });

    test('falls back to a generic result output when nothing is inferable', () {
      const source = 'def run(x):\n    return compute(x)';
      final outputs = extractContractDraft(source).outputFields;
      expect(outputs.single.outputKey, 'result');
      expect(outputs.single.type, PythonFieldType.text);
    });

    test('types an annotation by its outermost type', () {
      const cases = {
        'list[int]': PythonFieldType.list,
        'List[float]': PythonFieldType.list,
        'tuple[int, int]': PythonFieldType.list,
        'dict[str, int]': PythonFieldType.table,
        'typing.Dict[str, float]': PythonFieldType.table,
        'Optional[int]': PythonFieldType.integer,
        'int | None': PythonFieldType.integer,
        'Union[float, None]': PythonFieldType.decimal,
        'Optional[dict[str, Any]]': PythonFieldType.table,
        "Annotated[int, 'meters']": PythonFieldType.integer,
        'int | float': PythonFieldType.decimal,
        'int | str': PythonFieldType.text,
        'Point': PythonFieldType.text,
        'Optional[Point]': PythonFieldType.text,
        'Printer': PythonFieldType.text,
        "'int'": PythonFieldType.integer,
      };
      for (final entry in cases.entries) {
        final source = 'def run(value: ${entry.key}):\n    return {"r": 1}';
        expect(
          extractContractDraft(source).inputFields.single.type,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('infers integer outputs from int(), len() and integer literals', () {
      const source = '''
def run(samples: list[float]):
    score = int(min(100, max(0, round(sum(samples)))))
    return {
        'score': score,
        'count': len(samples),
        'version': 2,
        'ratio': 0.5,
    }
''';
      final outputs = extractContractDraft(source).outputFields;
      expect(outputs.map((f) => [f.outputKey, f.type]), [
        ['score', PythonFieldType.integer],
        ['count', PythonFieldType.integer],
        ['version', PythonFieldType.integer],
        ['ratio', PythonFieldType.decimal],
      ]);
    });

    test('reads an optional dict input as an image from its name', () {
      const source =
          'def run(photo: Optional[dict[str, Any]]):\n    return {"r": 1}';
      final field = extractContractDraft(source).inputFields.single;
      expect(field.type, PythonFieldType.image);
    });
  });
}
