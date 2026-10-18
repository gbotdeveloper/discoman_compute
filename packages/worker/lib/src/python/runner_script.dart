// AUTOMATICALLY PORTED from executor/main.py build_runner_script().
// DO NOT EDIT BY HAND. This is a verbatim port of the Python runner the legacy
// FastAPI executor wrote to runner.py: it reads a JSON job {entrypointName,
// inputs} from stdin, imports user_script.py from the working directory,
// invokes the entrypoint with **inputs, normalizes the outputs (matplotlib
// figures -> PNG, bytes -> sniffed image/file, numpy/pandas -> JSON), and
// writes {"outputs": ...} to result.json. User stdout is redirected to stderr
// so it surfaces as logs and cannot corrupt the result payload.
//
// The size limits (3MB image / 5MB file) are baked in exactly as the executor
// injected them, so worker input and output caps stay identical.

/// The Python runner script, byte-for-byte what executor/main.py produced.
const String runnerPy = r'''
MAX_IMAGE_BYTES = 3145728
MAX_FILE_BYTES = 5242880
import base64
import binascii
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

SOURCE_FILE = Path("user_script.py")
# Resolved up front so a user script calling os.chdir() cannot move it.
RESULT_FILE = Path("result.json").resolve()
os.environ.setdefault("MPLBACKEND", "Agg")

def _detect_image_metadata(raw_bytes):
    if raw_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return ("png", "image/png")

    if raw_bytes[:3] == b"\xff\xd8\xff":
        return ("jpg", "image/jpeg")

    if (
        len(raw_bytes) >= 12
        and raw_bytes[:4] == b"RIFF"
        and raw_bytes[8:12] == b"WEBP"
    ):
        return ("webp", "image/webp")

    return None


def _detect_file_metadata(raw_bytes):
    # PDF: %PDF- signature
    if raw_bytes.startswith(b"%PDF"):
        return ("pdf", "application/pdf")

    # XLSX: ZIP signature + workbook markers
    if (
        len(raw_bytes) >= 4
        and raw_bytes[:2] == b"PK"
        and b"[Content_Types].xml" in raw_bytes
        and b"xl/" in raw_bytes
    ):
        return ("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

    # UTF-8 text detection
    try:
        text = raw_bytes.decode("utf-8")
    except (UnicodeDecodeError, ValueError):
        return None

    # JSON
    try:
        import json as _json
        _json.loads(text)
        return ("json", "application/json")
    except (ValueError, TypeError):
        pass

    # CSV heuristic: contains commas/tabs/semicolons and multiple lines
    lines = text.strip().splitlines()
    if len(lines) >= 2:
        for delimiter in (",", "\t", ";"):
            if all(delimiter in line for line in lines[:3]):
                return ("csv", "text/csv")

    # Fallback: plain text
    return ("txt", "text/plain")


def _build_image_payload(output_key, raw_bytes, extension, mime_type, name=None):
    if len(raw_bytes) > MAX_IMAGE_BYTES:
        raise RuntimeError(
            f'Image output "{output_key}" exceeds the supported '
            f'{MAX_IMAGE_BYTES // (1024 * 1024)} MB size limit.'
        )

    return {
        "kind": "image",
        "name": name or f"{output_key}.{extension}",
        "extension": extension,
        "mimeType": mime_type,
        "sizeBytes": len(raw_bytes),
        "base64": base64.b64encode(raw_bytes).decode("ascii"),
    }


def _build_file_payload(output_key, raw_bytes, extension, mime_type, name=None):
    if len(raw_bytes) > MAX_FILE_BYTES:
        raise RuntimeError(
            f'File output "{output_key}" exceeds the supported '
            f'{MAX_FILE_BYTES // (1024 * 1024)} MB size limit.'
        )

    return {
        "kind": "file",
        "name": name or f"{output_key}.{extension}",
        "extension": extension,
        "mimeType": mime_type,
        "sizeBytes": len(raw_bytes),
        "base64": base64.b64encode(raw_bytes).decode("ascii"),
    }


def _looks_like_runtime_image_payload(value):
    if not isinstance(value, dict):
        return False

    return (
        value.get("kind") == "image"
        and isinstance(value.get("name"), str)
        and isinstance(value.get("extension"), str)
        and isinstance(value.get("mimeType"), str)
        and isinstance(value.get("sizeBytes"), int)
        and isinstance(value.get("base64"), str)
    )


def _looks_like_runtime_file_payload(value):
    if not isinstance(value, dict):
        return False

    return (
        value.get("kind") == "file"
        and isinstance(value.get("name"), str)
        and isinstance(value.get("extension"), str)
        and isinstance(value.get("mimeType"), str)
        and isinstance(value.get("sizeBytes"), int)
        and isinstance(value.get("base64"), str)
    )


def _normalize_runtime_image_payload(output_key, value):
    extension = str(value["extension"]).strip().lower().lstrip(".")
    mime_type = str(value["mimeType"]).strip().lower()
    name = str(value["name"]).strip() or f"{output_key}.{extension}"
    size_bytes = value["sizeBytes"]
    base64_content = str(value["base64"]).strip()

    if size_bytes <= 0:
        raise RuntimeError(
            f'Image output "{output_key}" must declare a positive sizeBytes value.'
        )

    try:
        raw_bytes = base64.b64decode(base64_content, validate=True)
    except (binascii.Error, ValueError) as error:
        raise RuntimeError(
            f'Image output "{output_key}" contains invalid base64 data.'
        ) from error

    if len(raw_bytes) != size_bytes:
        raise RuntimeError(
            f'Image output "{output_key}" sizeBytes does not match the decoded payload.'
        )

    detected = _detect_image_metadata(raw_bytes)
    if detected is None:
        raise RuntimeError(
            f'Image output "{output_key}" is not a supported PNG, JPEG, or WEBP image.'
        )

    detected_extension, detected_mime_type = detected
    allowed_extensions = {detected_extension}
    if detected_extension == "jpg":
        allowed_extensions.add("jpeg")
    elif detected_extension == "jpeg":
        allowed_extensions.add("jpg")

    if extension not in allowed_extensions:
        raise RuntimeError(
            f'Image output "{output_key}" metadata does not match the decoded image type.'
        )

    if mime_type != detected_mime_type:
        raise RuntimeError(
            f'Image output "{output_key}" MIME type does not match the decoded image type.'
        )

    return _build_image_payload(
        output_key,
        raw_bytes,
        detected_extension,
        detected_mime_type,
        name=name,
    )


_supported_file_extensions = {"pdf", "csv", "txt", "json", "xlsx"}
_supported_file_mime_types = {
    "pdf": "application/pdf",
    "csv": "text/csv",
    "txt": "text/plain",
    "json": "application/json",
    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
}

def _normalize_runtime_file_payload(output_key, value):
    extension = str(value["extension"]).strip().lower().lstrip(".")
    mime_type = str(value["mimeType"]).strip().lower()
    name = str(value["name"]).strip() or f"{output_key}.{extension}"
    size_bytes = value["sizeBytes"]
    base64_content = str(value["base64"]).strip()

    if extension not in _supported_file_extensions:
        raise RuntimeError(
            f'File output "{output_key}" uses unsupported extension "{extension}".'
        )

    if size_bytes <= 0:
        raise RuntimeError(
            f'File output "{output_key}" must declare a positive sizeBytes value.'
        )

    try:
        raw_bytes = base64.b64decode(base64_content, validate=True)
    except (binascii.Error, ValueError) as error:
        raise RuntimeError(
            f'File output "{output_key}" contains invalid base64 data.'
        ) from error

    if len(raw_bytes) != size_bytes:
        raise RuntimeError(
            f'File output "{output_key}" sizeBytes does not match the decoded payload.'
        )

    if len(raw_bytes) > MAX_FILE_BYTES:
        raise RuntimeError(
            f'File output "{output_key}" exceeds the supported '
            f'{MAX_FILE_BYTES // (1024 * 1024)} MB size limit.'
        )

    expected_mime = _supported_file_mime_types.get(extension)
    if expected_mime and mime_type != expected_mime:
        raise RuntimeError(
            f'File output "{output_key}" MIME type does not match .{extension}.'
        )

    return {
        "kind": "file",
        "name": name,
        "extension": extension,
        "mimeType": expected_mime or mime_type,
        "sizeBytes": size_bytes,
        "base64": base64_content,
    }


def _is_matplotlib_figure(value):
    return (
        value.__class__.__module__ == "matplotlib.figure"
        and value.__class__.__name__ == "Figure"
    )


def _figure_to_png_bytes(value):
    buffer = io.BytesIO()
    value.savefig(buffer, format="png", bbox_inches="tight")
    raw_bytes = buffer.getvalue()
    buffer.close()
    try:
        import matplotlib.pyplot as plt

        plt.close(value)
    except Exception:
        pass
    return raw_bytes


def _to_json_compatible(value):
    if value is None or isinstance(value, (str, int, float, bool)):
        return value

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
        return {
            str(key): _to_json_compatible(item)
            for key, item in value.items()
        }

    if isinstance(value, (list, tuple, set)):
        return [_to_json_compatible(item) for item in value]

    raise TypeError(
        f"Result type {type(value).__name__} is not JSON serializable."
    )


def _is_pil_image(value):
    return (
        value.__class__.__module__.startswith("PIL.")
        and hasattr(value, "save")
        and hasattr(value, "mode")
    )


def _pil_image_to_png_bytes(value):
    buffer = io.BytesIO()
    value.save(buffer, format="PNG")
    raw_bytes = buffer.getvalue()
    buffer.close()
    return raw_bytes


def _is_file_output(value):
    return (
        _looks_like_runtime_image_payload(value)
        or _looks_like_runtime_file_payload(value)
        or isinstance(value, (bytes, bytearray))
        or _is_matplotlib_figure(value)
        or _is_pil_image(value)
    )


def _normalize_output_value(output_key, value):
    # A list of files becomes a list of payloads, named by position.
    if (
        isinstance(value, (list, tuple))
        and value
        and all(_is_file_output(item) for item in value)
    ):
        return [
            _normalize_output_value(f"{output_key}_{index + 1}", item)
            for index, item in enumerate(value)
        ]

    if _looks_like_runtime_image_payload(value):
        return _normalize_runtime_image_payload(output_key, value)

    if _looks_like_runtime_file_payload(value):
        return _normalize_runtime_file_payload(output_key, value)

    if isinstance(value, (bytes, bytearray)):
        raw_bytes = bytes(value)

        detected_image = _detect_image_metadata(raw_bytes)
        if detected_image is not None:
            extension, mime_type = detected_image
            return _build_image_payload(output_key, raw_bytes, extension, mime_type)

        detected_file = _detect_file_metadata(raw_bytes)
        if detected_file is not None:
            extension, mime_type = detected_file
            return _build_file_payload(output_key, raw_bytes, extension, mime_type)

        raise RuntimeError(
            f'Output "{output_key}" returned an unsupported file format.'
        )

    if _is_matplotlib_figure(value):
        raw_bytes = _figure_to_png_bytes(value)
        return _build_image_payload(
            output_key,
            raw_bytes,
            "png",
            "image/png",
        )

    if _is_pil_image(value):
        return _build_image_payload(
            output_key,
            _pil_image_to_png_bytes(value),
            "png",
            "image/png",
        )

    return _to_json_compatible(value)


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
    payload = json.loads(sys.stdin.read() or "{}")
    entrypoint_name = payload.get("entrypointName")
    inputs = payload.get("inputs") or {}
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

        result = entrypoint(**_coerce_inputs(entrypoint, inputs))
        if isinstance(result, dict) and not _looks_like_runtime_image_payload(result) and not _looks_like_runtime_file_payload(result):
            outputs = {
                str(key): _normalize_output_value(str(key), value)
                for key, value in result.items()
            }
        else:
            outputs = {"result": _normalize_output_value("result", result)}

    RESULT_FILE.write_text(json.dumps({"outputs": outputs}), encoding="utf-8")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        traceback.print_exc(file=sys.stderr)
        sys.stderr.write(str(error))
        sys.exit(1)
''';
