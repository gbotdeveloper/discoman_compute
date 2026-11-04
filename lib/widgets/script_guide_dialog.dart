import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_controller.dart';
import 'action_button.dart';

const _exampleAsset = 'examples/image_pipeline.py';

const _contractSample = '''Images = list[str]
Files = list[str]


class Outputs:
    processed: Images
    summary: str


def main(photos: Images, strength: int = 2) -> Outputs:
    Path("out").mkdir(exist_ok=True)
    processed = []
    for path in photos:
        target = Path("out") / (Path(path).stem + "_sharp.png")
        Image.open(path).filter(ImageFilter.SHARPEN).save(target)
        processed.append(str(target))
    return {"processed": processed, "summary": f"{len(processed)} done"}''';

const _typesSample = '''text: str              count: int
ratio: float           ok: bool
day: datetime.date     rows: pd.DataFrame
photos: Images         reports: Files
mode: Literal["Fast", "Exact"]
modes: list[Literal["Area", "Color"]]   # inputs only''';

const _outsideSample = '''import subprocess, sys

sys.path.insert(0, r"C:\\research")     # to import your own modules
import helper

model = r"C:\\research\\data\\model.bin"  # full paths to your files
subprocess.run(
    [r"C:\\Program Files\\MATLAB\\R2024b\\bin\\matlab.exe",
     "-batch", "process"],
    check=True, timeout=600,
)''';

Future<void> showScriptGuide(BuildContext context, AppController controller) {
  return showDialog<void>(
    context: context,
    builder: (context) => ScriptGuideDialog(controller: controller),
  );
}

/// What a script needs to look like, with a working example to save.
class ScriptGuideDialog extends StatefulWidget {
  const ScriptGuideDialog({required this.controller, this.saveTo, super.key});

  final AppController controller;

  /// Asks where to save the example. Injected by tests, which cannot open a
  /// native picker.
  final Future<String?> Function()? saveTo;

  @override
  State<ScriptGuideDialog> createState() => _ScriptGuideDialogState();
}

class _ScriptGuideDialogState extends State<ScriptGuideDialog> {
  String? _saved;
  String? _error;

  static Future<String?> _askWhere() async {
    final location = await getSaveLocation(
      suggestedName: 'image_pipeline.py',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Python', extensions: ['py']),
      ],
    );
    return location?.path;
  }

  Future<void> _saveExample() async {
    final path = await (widget.saveTo ?? _askWhere)();
    if (path == null) return;
    try {
      await File(
        path,
      ).writeAsString(await rootBundle.loadString(_exampleAsset));
      if (!mounted) return;
      setState(() {
        _saved = path;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save it: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.45,
    );

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to write a script',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Discoman runs a top-level function named main, run '
                        'or execute. Its parameters are the inputs, and '
                        'class Outputs lists the outputs, one name and type '
                        'per line. Images and files come in as paths to '
                        'files; save yours and return their paths.',
                        style: muted,
                      ),
                      const SizedBox(height: 12),
                      const _CodeSample(_contractSample),
                      const SizedBox(height: 16),
                      Text('The types you can use:', style: muted),
                      const SizedBox(height: 8),
                      const _CodeSample(_typesSample),
                      const SizedBox(height: 16),
                      Text(
                        'A copy of your script runs in a folder of its own, '
                        'so parallel runs never meet. Write outputs into '
                        '"out" there. To reach your own files, modules or '
                        'programs such as MATLAB, use their full paths.',
                        style: muted,
                      ),
                      const SizedBox(height: 12),
                      const _CodeSample(_outsideSample),
                      const SizedBox(height: 16),
                      Text(
                        'Each image or file can be up to 20 MB, with at most '
                        '50 files and 100 MB per run.',
                        style: muted,
                      ),
                    ],
                  ),
                ),
              ),
              if (_saved != null || _error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error ?? 'Saved to $_saved',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _error == null
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ActionButton(
                          label: 'Save example script',
                          isPrimary: false,
                          onPressed: _saveExample,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ActionButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeSample extends StatelessWidget {
  const _CodeSample(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: SelectableText(
            code,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'Menlo',
              fontFamilyFallback: const ['Consolas', 'monospace'],
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
