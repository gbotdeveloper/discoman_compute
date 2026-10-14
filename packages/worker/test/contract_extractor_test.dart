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
        'list[Any]': PythonFieldType.list,
        'List[Point]': PythonFieldType.list,
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

    test('reads list annotations as multiple values of their item type', () {
      const source = '''
def run(
    counts: list[int],
    weights: Sequence[float],
    names: list[str],
    modes: list[Literal["fast", "slow"]],
    photos: list[dict],
    attachments: Optional[list[dict[str, Any]]] = None,
    rows: list[dict],
    points: list[Point],
    anything: list,
    pair: tuple[int, int],
):
    return {"r": 1}
''';
      final fields = extractContractDraft(source).inputFields;
      expect(fields.map((f) => [f.parameterName, f.type, f.multiple]), [
        ['counts', PythonFieldType.integer, true],
        ['weights', PythonFieldType.decimal, true],
        ['names', PythonFieldType.text, true],
        ['modes', PythonFieldType.category, true],
        ['photos', PythonFieldType.image, true],
        ['attachments', PythonFieldType.file, true],
        ['rows', PythonFieldType.table, false],
        ['points', PythonFieldType.list, false],
        ['anything', PythonFieldType.list, false],
        ['pair', PythonFieldType.list, false],
      ]);
      expect(fields[3].options, ['fast', 'slow']);
      expect(fields[4].controlHint, 'Image upload field (multiple)');
      expect(fields.every((f) => f.maxItems == null), isTrue);
    });

    test('reads a bare list named after files as a list of files', () {
      const source = 'def run(images: list):\n    return {"r": 1}';
      final field = extractContractDraft(source).inputFields.single;
      expect([field.type, field.multiple], [PythonFieldType.image, true]);
    });

    test('reads a docstring image[] hint as a list of images', () {
      const source = '''
def run(scans):
    """Compares scans.

    - scans -> image[]
    """
    return {"r": 1}
''';
      final field = extractContractDraft(source).inputFields.single;
      expect([field.type, field.multiple], [PythonFieldType.image, true]);
    });

    test('keeps single values single', () {
      const source = 'def run(photo: dict, count: int):\n    return {"r": 1}';
      final fields = extractContractDraft(source).inputFields;
      expect(fields.map((f) => f.multiple), [false, false]);
    });

    test('marks a returned list of figures as multiple images', () {
      const source = '''
import matplotlib.pyplot as plt

def run(values: list[float]):
    fig, ax = plt.subplots()
    other = plt.figure()
    pages = [fig, other]
    return {
        "charts": [fig, other],
        "pages": pages,
        "total": sum(values),
        "values": [1, 2],
    }
''';
      final outputs = extractContractDraft(source).outputFields;
      expect(outputs.map((f) => [f.outputKey, f.type, f.multiple]), [
        ['charts', PythonFieldType.image, true],
        ['pages', PythonFieldType.image, true],
        ['total', PythonFieldType.decimal, false],
        ['values', PythonFieldType.text, false],
      ]);
    });

    test('reads date annotations as dates', () {
      const source = '''
def run(start: date, end: datetime.date, at: Optional[datetime], when: str):
    return {"r": 1}
''';
      final fields = extractContractDraft(source).inputFields;
      expect(fields.map((f) => f.type), [
        PythonFieldType.date,
        PythonFieldType.date,
        PythonFieldType.date,
        PythonFieldType.text,
      ]);
      expect(fields.first.controlHint, 'Date picker');
    });

    test('reads pandas DataFrames as tables', () {
      const source = '''
import pandas as pd

def run(rows: pd.DataFrame, photos_df: pd.DataFrame) -> pd.DataFrame:
    summary = pd.DataFrame(rows)
    return {
        "summary": summary,
        "raw": pd.read_csv("x.csv"),
    }
''';
      final draft = extractContractDraft(source);
      expect(draft.inputFields.map((f) => f.type), [
        PythonFieldType.table,
        PythonFieldType.table,
      ]);
      expect(draft.outputFields.map((f) => [f.outputKey, f.type]), [
        ['summary', PythonFieldType.table],
        ['raw', PythonFieldType.table],
      ]);
    });

    test('reads a DataFrame return annotation as a table result', () {
      const source = 'def run(x: int) -> pd.DataFrame:\n    return make(x)';
      final output = extractContractDraft(source).outputFields.single;
      expect(
        [output.outputKey, output.type],
        ['result', PythonFieldType.table],
      );
    });
  });
}
