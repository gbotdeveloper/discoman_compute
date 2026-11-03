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

    test('types an annotation by its outermost type', () {
      const cases = {
        'list[Any]': PythonFieldType.text,
        'List[Point]': PythonFieldType.text,
        'tuple[int, int]': PythonFieldType.text,
        'list': PythonFieldType.text,
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

    test('reads Images and Files as lists of paths', () {
      const source = '''
Images = list[str]
Files = list[str]

def run(photos: Images, reports: Optional[Files] = None, label: str = ""):
    return {"r": 1}
''';
      final fields = extractContractDraft(source).inputFields;
      expect(fields.map((f) => [f.parameterName, f.type, f.multiple]), [
        ['photos', PythonFieldType.image, true],
        ['reports', PythonFieldType.file, true],
        ['label', PythonFieldType.text, false],
      ]);
      expect(fields.first.controlHint, 'Image upload field (multiple)');
      expect(fields[1].isRequired, isFalse);
    });

    test('no longer guesses images from names or docstrings', () {
      const source = '''
def run(photo: dict, scans):
    """Compares scans.

    - scans -> image[]
    """
    return {"r": 1}
''';
      expect(extractContractDraft(source).inputFields.map((f) => f.type), [
        PythonFieldType.table,
        PythonFieldType.text,
      ]);
    });

    test('reads lists of choices as multiple categories', () {
      const source = '''
def run(modes: list[Literal["fast", "slow"]], rows: list[dict]):
    return {"r": 1}
''';
      final fields = extractContractDraft(source).inputFields;
      expect(fields.map((f) => [f.type, f.multiple]), [
        [PythonFieldType.category, true],
        [PythonFieldType.table, false],
      ]);
      expect(fields.first.options, ['fast', 'slow']);
    });

    test('reads other lists as text and says why', () {
      const source = '''
def run(names: list[str], counts: list[int], anything: list):
    return {"r": 1}
''';
      final draft = extractContractDraft(source);
      expect(draft.inputFields.map((f) => [f.type, f.multiple]), [
        [PythonFieldType.text, false],
        [PythonFieldType.text, false],
        [PythonFieldType.text, false],
      ]);
      expect(
        draft.notes.where((n) => n.startsWith('Lists of values')),
        hasLength(3),
      );
    });

    test('reads pandas DataFrames as tables', () {
      const source = '''
import pandas as pd

def run(rows: pd.DataFrame, photos_df: pd.DataFrame):
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

    test('reads outputs and their types from class Outputs', () {
      const source = '''
from typing import Literal, TypedDict

Images = list[str]
Files = list[str]


class Outputs(TypedDict):
    """What the run returns."""

    processed: Images
    report: Files  # the PDF
    summary: str
    count: int
    ratio: float
    ok: bool
    day: datetime.date
    rows: pd.DataFrame
    level: Literal["low", "high"]


def run(photos: Images) -> Outputs:
    result = make(photos)
    return result
''';
      final draft = extractContractDraft(source);
      expect(
        draft.outputFields.map((f) => [f.outputKey, f.type, f.multiple]),
        [
          ['processed', PythonFieldType.image, true],
          ['report', PythonFieldType.file, true],
          ['summary', PythonFieldType.text, false],
          ['count', PythonFieldType.integer, false],
          ['ratio', PythonFieldType.decimal, false],
          ['ok', PythonFieldType.boolean, false],
          ['day', PythonFieldType.date, false],
          ['rows', PythonFieldType.table, false],
          ['level', PythonFieldType.text, false],
        ],
      );
    });

    test('a plain class Outputs works too', () {
      const source = '''
class Outputs:
    summary: str
    count: int = 0

def run(x: int) -> Outputs:
    return {"summary": "", "count": x}
''';
      expect(
        extractContractDraft(source).outputFields.map((f) => f.outputKey),
        ['summary', 'count'],
      );
    });

    test('without class Outputs reads the returned dict', () {
      const source = '''
def run(w: float, h: float):
    bmi = round(w / (h * h), 2)
    return {"bmi": bmi, "label": "healthy"}
''';
      final draft = extractContractDraft(source);
      expect(draft.outputFields.map((o) => o.outputKey), ['bmi', 'label']);
      expect(draft.outputFields[0].type, PythonFieldType.decimal);
      expect(draft.outputFields[1].type, PythonFieldType.text);
      expect(draft.notes, contains(startsWith('Outputs were read from')));
    });

    test('a comment after a returned entry keeps the entries after it', () {
      const source = '''
def run(x: int) -> dict:
    return {
        "summary": "",  # str
        "count": 1,  # int
        "ratio": 3.0,  # float
    }
''';
      expect(
        extractContractDraft(
          source,
        ).outputFields.map((f) => [f.outputKey, f.type]),
        [
          ['summary', PythonFieldType.text],
          ['count', PythonFieldType.integer],
          ['ratio', PythonFieldType.decimal],
        ],
      );
    });

    test('infers integer outputs from int(), len() and integer literals', () {
      const source = '''
def run(samples: str):
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

    test('falls back to a generic result output when nothing is inferable', () {
      const source = 'def run(x):\n    return compute(x)';
      final outputs = extractContractDraft(source).outputFields;
      expect(outputs.single.outputKey, 'result');
      expect(outputs.single.type, PythonFieldType.text);
    });
  });
}
