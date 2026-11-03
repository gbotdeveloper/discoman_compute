// Started from the Python runner the legacy executor wrote to runner.py: it
// reads a JSON job {entrypointName, inputs, outputTypes} from stdin, imports
// user_script.py from the working directory and invokes the entrypoint with
// **inputs. Images and files arrive as paths to files in the run folder and
// leave the same way: each output named in outputTypes (the script's class
// Outputs) is checked against its declared type, and images or files the
// script returned as figures, PIL images or bytes are written to out/ first.
// The result, with every file as a path, goes to result.json. User stdout is
// redirected to stderr so it surfaces as logs and cannot corrupt the result.
//
// The limits match what the server keeps per run.

/// The Python runner script.
const String runnerPy = r'''
MAX_IMAGE_BYTES = 20971520
MAX_FILE_BYTES = 20971520
MAX_OUTPUT_FILES = 50
MAX_OUTPUT_BYTES = 104857600
import contextlib
import datetime
import importlib.util
import io
import json
import os
import sys
import traceback
import typing
from pathlib import Path

# Its own process group, so stopping a run stops what it started too.
if hasattr(os, "setpgrp"):
    try:
        os.setpgrp()
    except OSError:
        pass

SOURCE_FILE = Path("user_script.py")
# Resolved up front so a user script calling os.chdir() cannot move them.
RESULT_FILE = Path("result.json").resolve()
START_DIR = Path.cwd()
OUT_DIR = START_DIR / "out"
os.environ.setdefault("MPLBACKEND", "Agg")

_image_types = {
    "png": "image/png",
    "jpg": "image/jpeg",
    "webp": "image/webp",
    "gif": "image/gif",
}

_file_types = {
    "pdf": "application/pdf",
    "csv": "text/csv",
    "txt": "text/plain",
    "json": "application/json",
    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
}


def _detect_image(raw_bytes):
    if raw_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if raw_bytes[:3] == b"\xff\xd8\xff":
        return "jpg"
    if len(raw_bytes) >= 12 and raw_bytes[:4] == b"RIFF" and raw_bytes[8:12] == b"WEBP":
        return "webp"
    if raw_bytes[:6] in (b"GIF87a", b"GIF89a"):
        return "gif"
    return None


def _detect_file(raw_bytes):
    if raw_bytes.startswith(b"%PDF"):
        return "pdf"
    if raw_bytes[:2] == b"PK" and b"[Content_Types].xml" in raw_bytes and b"xl/" in raw_bytes:
        return "xlsx"
    try:
        text = raw_bytes.decode("utf-8")
    except (UnicodeDecodeError, ValueError):
        return None
    try:
        json.loads(text)
        return "json"
    except (ValueError, TypeError):
        pass
    lines = text.strip().splitlines()
    if len(lines) >= 2:
        for delimiter in (",", "\t", ";"):
            if all(delimiter in line for line in lines[:3]):
                return "csv"
    return "txt"


def _is_matplotlib_figure(value):
    return (
        value.__class__.__module__ == "matplotlib.figure"
        and value.__class__.__name__ == "Figure"
    )


def _is_pil_image(value):
    return (
        value.__class__.__module__.startswith("PIL.")
        and hasattr(value, "save")
        and hasattr(value, "mode")
    )


def _is_path(value):
    return isinstance(value, (str, os.PathLike))


def _is_file_item(value):
    return (
        isinstance(value, (bytes, bytearray))
        or _is_matplotlib_figure(value)
        or _is_pil_image(value)
    )


def _written(key, index, raw_bytes, extension):
    OUT_DIR.mkdir(exist_ok=True)
    path = OUT_DIR / f"{key}_{index}.{extension}"
    path.write_bytes(raw_bytes)
    return path


def _item_path(key, index, item, kind):
    """The file an output item names, writing it out first when the script
    returned the image or the bytes themselves."""
    if _is_path(item):
        path = Path(item)
        return path if path.is_absolute() else START_DIR / path
    if _is_matplotlib_figure(item):
        buffer = io.BytesIO()
        item.savefig(buffer, format="png", bbox_inches="tight")
        try:
            import matplotlib.pyplot as plt

            plt.close(item)
        except Exception:
            pass
        return _written(key, index, buffer.getvalue(), "png")
    if _is_pil_image(item):
        buffer = io.BytesIO()
        item.save(buffer, format="PNG")
        return _written(key, index, buffer.getvalue(), "png")
    if isinstance(item, (bytes, bytearray)):
        raw_bytes = bytes(item)
        extension = _detect_image(raw_bytes) if kind == "image" else _detect_file(raw_bytes)
        if extension is None:
            formats = (
                "a PNG, JPEG, WEBP or GIF image"
                if kind == "image"
                else "a PDF, CSV, TXT, JSON or XLSX file"
            )
            raise RuntimeError(
                f'Output "{key}" returned bytes that are not {formats}.'
            )
        return _written(key, index, raw_bytes, extension)
    raise RuntimeError(
        f'Output "{key}" must be a list of paths to {kind}s; item {index} is '
        f"{type(item).__name__}."
    )


def _file_output(key, index, item, kind):
    path = _item_path(key, index, item, kind)
    if not path.is_file():
        raise RuntimeError(f'Output "{key}" names a file that does not exist: {path}')
    size = path.stat().st_size
    limit = MAX_IMAGE_BYTES if kind == "image" else MAX_FILE_BYTES
    if size > limit:
        raise RuntimeError(
            f'"{path.name}" in output "{key}" is {size / (1024 * 1024):.1f} MB; '
            f"files can be at most {limit // (1024 * 1024)} MB."
        )
    if kind == "image":
        with path.open("rb") as handle:
            extension = _detect_image(handle.read(16))
        if extension is None:
            raise RuntimeError(
                f'"{path.name}" in output "{key}" is not a PNG, JPEG, WEBP or '
                "GIF image."
            )
        mime_type = _image_types[extension]
    else:
        extension = path.suffix.lower().lstrip(".")
        if extension not in _file_types:
            extension = _detect_file(path.read_bytes())
        if extension not in _file_types:
            raise RuntimeError(
                f'"{path.name}" in output "{key}" is not a PDF, CSV, TXT, JSON '
                "or XLSX file."
            )
        mime_type = _file_types[extension]
    return {
        "kind": kind,
        "name": path.name,
        "extension": extension,
        "mimeType": mime_type,
        "sizeBytes": size,
        "path": str(path.resolve()),
    }


def _file_outputs(key, value, kind):
    items = list(value) if isinstance(value, (list, tuple)) else [value]
    return [
        _file_output(key, index, item, kind)
        for index, item in enumerate(items, start=1)
    ]


def _to_json_compatible(value):
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, (datetime.date, datetime.datetime)):
        return value.isoformat()
    if hasattr(value, "item") and callable(value.item):
        try:
            return _to_json_compatible(value.item())
        except Exception:
            pass
    if hasattr(value, "to_dict") and callable(value.to_dict):
        try:
            return _to_json_compatible(value.to_dict(orient="records"))
        except TypeError:
            try:
                return _to_json_compatible(value.to_dict())
            except Exception:
                pass
    if hasattr(value, "tolist") and callable(value.tolist):
        try:
            return _to_json_compatible(value.tolist())
        except Exception:
            pass
    if isinstance(value, dict):
        return {str(key): _to_json_compatible(item) for key, item in value.items()}
    if isinstance(value, (list, tuple, set)):
        return [_to_json_compatible(item) for item in value]
    raise TypeError(f"Result type {type(value).__name__} is not JSON serializable.")


_type_names = {
    "text": "text (str)",
    "integer": "a whole number (int)",
    "decimal": "a number (float)",
    "boolean": "True or False (bool)",
    "date": "a date",
    "table": "a table (a DataFrame or a list of dicts)",
}


def _declared_value(key, value, field_type):
    if field_type in ("image", "file"):
        return _file_outputs(key, value, field_type)
    if value is None:
        return None
    plain = _to_json_compatible(value)
    matches = {
        "text": isinstance(plain, str),
        "integer": isinstance(plain, int) and not isinstance(plain, bool),
        "decimal": isinstance(plain, (int, float)) and not isinstance(plain, bool),
        "boolean": isinstance(plain, bool),
        "date": isinstance(plain, str),
        "table": isinstance(plain, list) and all(isinstance(row, dict) for row in plain),
    }.get(field_type, True)
    if not matches:
        raise RuntimeError(
            f'Output "{key}" is declared as {_type_names[field_type]} in class '
            f"Outputs, but the run returned {type(value).__name__}."
        )
    return plain


def _undeclared_value(key, value):
    if _is_file_item(value):
        is_file = isinstance(value, (bytes, bytearray)) and _detect_image(bytes(value)) is None
        return _file_outputs(key, value, "file" if is_file else "image")
    if isinstance(value, (list, tuple)) and value and all(_is_file_item(item) for item in value):
        return _file_outputs(key, value, "image")
    return _to_json_compatible(value)


def _outputs(result, output_types):
    if not isinstance(result, dict):
        raise RuntimeError(
            "run must return a dict with one entry per output; it returned "
            f"{type(result).__name__}."
        )
    result = {str(key): value for key, value in result.items()}
    if output_types is None:
        return {key: _undeclared_value(key, value) for key, value in result.items()}

    missing = [key for key in output_types if key not in result]
    if missing:
        raise RuntimeError(
            "The run did not return "
            + ", ".join(f'"{key}"' for key in missing)
            + ", declared in class Outputs."
        )
    extra = [key for key in result if key not in output_types]
    if extra:
        raise RuntimeError(
            "The run returned "
            + ", ".join(f'"{key}"' for key in extra)
            + ", which class Outputs does not declare."
        )
    return {
        key: _declared_value(key, result[key], field_type)
        for key, field_type in output_types.items()
    }


def _check_totals(outputs):
    files = [
        item
        for value in outputs.values()
        if isinstance(value, list)
        for item in value
        if isinstance(item, dict) and "path" in item and item.get("kind") in ("image", "file")
    ]
    if len(files) > MAX_OUTPUT_FILES:
        raise RuntimeError(
            f"The run returned {len(files)} files; at most {MAX_OUTPUT_FILES} "
            "are kept per run."
        )
    total = sum(item["sizeBytes"] for item in files)
    if total > MAX_OUTPUT_BYTES:
        raise RuntimeError(
            f"The run's files add up to {total / (1024 * 1024):.1f} MB; at most "
            f"{MAX_OUTPUT_BYTES // (1024 * 1024)} MB are kept per run."
        )


def _annotation_target(annotation):
    # Optional[X] and X | None coerce like X.
    args = [
        arg
        for arg in getattr(annotation, "__args__", None) or ()
        if arg is not type(None)
    ]
    is_union = (
        getattr(annotation, "__origin__", None) is typing.Union
        or type(annotation).__name__ == "UnionType"
    )
    return args[0] if is_union and len(args) == 1 else annotation


def _coerce_input(annotation, value):
    # Dates arrive as ISO text and tables as rows; hand the script the
    # type it asked for.
    target = _annotation_target(annotation)
    if (
        isinstance(value, (list, dict))
        and getattr(target, "__name__", None) == "DataFrame"
        and getattr(target, "__module__", "").startswith("pandas")
    ):
        return target(value)
    if not isinstance(value, str):
        return value
    try:
        if target is datetime.datetime:
            return datetime.datetime.fromisoformat(value)
        if target is datetime.date:
            return datetime.date.fromisoformat(value)
    except ValueError:
        return value
    return value


def _coerce_inputs(entrypoint, inputs):
    try:
        hints = typing.get_type_hints(entrypoint)
    except Exception:
        return inputs
    return {
        key: _coerce_input(hints[key], value) if key in hints else value
        for key, value in inputs.items()
    }


def _load_module():
    spec = importlib.util.spec_from_file_location("user_script", SOURCE_FILE)
    if spec is None or spec.loader is None:
        raise RuntimeError("Python script module could not be loaded.")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    payload = json.loads(sys.stdin.buffer.read().decode("utf-8") or "{}")
    entrypoint_name = payload.get("entrypointName")
    inputs = payload.get("inputs") or {}
    output_types = payload.get("outputTypes")
    if not isinstance(inputs, dict):
        raise RuntimeError("inputs must be a JSON object.")

    # Importing the module and calling the entrypoint both run user code,
    # which is free to print. Send that to stderr so it is surfaced as
    # logs instead of interleaving with anything we emit.
    with contextlib.redirect_stdout(sys.stderr):
        module = _load_module()
        if not hasattr(module, entrypoint_name):
            raise RuntimeError(
                f"Entrypoint '{entrypoint_name}' could not be found."
            )

        entrypoint = getattr(module, entrypoint_name)
        if not callable(entrypoint):
            raise RuntimeError(
                f"Entrypoint '{entrypoint_name}' is not callable."
            )

        # Ready before the script runs, so it can save into "out/..." without
        # making the folder, which the cloud's allowed imports cannot.
        OUT_DIR.mkdir(exist_ok=True)
        result = entrypoint(**_coerce_inputs(entrypoint, inputs))
        outputs = _outputs(result, output_types)
        _check_totals(outputs)

    RESULT_FILE.write_text(json.dumps({"outputs": outputs}), encoding="utf-8")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        traceback.print_exc(file=sys.stderr)
        sys.stderr.write(str(error))
        sys.exit(1)
''';
