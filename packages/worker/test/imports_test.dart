import 'package:discoman_worker/src/python/imports.dart';
import 'package:test/test.dart';

void main() {
  test('reads plain, aliased, dotted and from imports', () {
    const source = '''
import os, sys as system
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.linear_model import LinearRegression

def run():
    import pandas
    return {}
''';

    expect(importedModules(source), [
      'os',
      'sys',
      'numpy',
      'matplotlib',
      'PIL',
      'sklearn',
      'pandas',
    ]);
  });

  test('skips relative imports, __future__ and comments', () {
    const source = '''
from __future__ import annotations
from . import helpers
# import requests
x = 1  # import yaml
''';

    expect(importedModules(source), isEmpty);
  });
}
