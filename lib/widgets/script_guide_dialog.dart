import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_controller.dart';
import 'action_button.dart';

const scriptGuideUrl =
    'https://github.com/gbotdeveloper/discoman_compute/blob/main/docs/script_guide.md';

const _exampleAsset = 'examples/image_pipeline.py';

const _inputsSample = '''def main(photos: list, strength: int = 2):
    """Sharpens photos.

    - photos -> image[]
    - processed -> image[]
    """
    processed = []
    for photo in photos:
        image = Image.open(photo["path"])
        out = Path(photo["path"]).with_name("sharp.png")
        image.filter(ImageFilter.SHARPEN).save(out)
        processed.append({"kind": "image", "path": str(out)})
    return {"processed": processed}''';

const _programSample = '''HERE = Path(__file__).parent  # your script's folder

done = subprocess.run(
    ["matlab", "-batch", "process"],
    capture_output=True, text=True, timeout=600,
)
model = HERE / "model.bin"  # files beside the script''';

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
                        'Discoman calls a top-level function named main, run '
                        'or execute. Its parameters are the inputs and the '
                        'keys of the dict it returns are the outputs. Declare '
                        'images with docstring lines like "- photos -> '
                        'image[]". Each input file comes as a dict with a '
                        '"path"; return images as {"kind": "image", "path": '
                        '...}, PIL images or bytes.',
                        style: muted,
                      ),
                      const SizedBox(height: 12),
                      const _CodeSample(_inputsSample),
                      const SizedBox(height: 16),
                      Text(
                        'Each run gets its own folder with your script and '
                        'links to everything beside it, so imports of sibling '
                        'files, relative paths and other scripts just work. '
                        'Programs are found through your terminal\'s PATH, '
                        'plus Extra PATH. Write outputs next to the input, '
                        'never over files in your own folder: runs can go at '
                        'once. Each output may be up to 20 MB, at most 50 '
                        'files and 100 MB per run.',
                        style: muted,
                      ),
                      const SizedBox(height: 12),
                      const _CodeSample(_programSample),
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
                        ActionButton(
                          label: 'Open full guide',
                          isPrimary: false,
                          onPressed: () =>
                              widget.controller.openUrl(scriptGuideUrl),
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
