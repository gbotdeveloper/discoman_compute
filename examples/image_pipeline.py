"""Sharpens and outlines several photos, the way a Discoman Compute script does.

Discoman reads the inputs and outputs from the docstring lines below:
    - photos -> image[]
    - processed -> image[]

Run it on your own computer by linking it to a project in Discoman Compute.
It needs Pillow: python -m pip install Pillow
"""

import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageFilter, ImageOps

# The folder this script is kept in. Files beside it (models, lookup tables,
# other scripts) are found here, and also by their plain name.
HERE = Path(__file__).parent


def run_tool(args, timeout=60):
    """Runs another program and returns what it printed.

    Any program your terminal finds works here, such as matlab, conda tools or
    a command line tool: Discoman Compute uses your terminal's PATH, plus any
    folders you add under Extra PATH.
    """
    done = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    if done.returncode != 0:
        raise RuntimeError(f"{args[0]} failed: {done.stderr.strip()}")
    return done.stdout.strip()


def main(photos: list, strength: int = 2):
    """Sharpens and outlines each photo.

    - photos -> image[]
    - processed -> image[]
    """
    # An example of calling another program. Replace it with your own, for
    # example ["matlab", "-batch", "process_images"].
    python_version = run_tool([sys.executable, "--version"])

    watermark_file = HERE / "watermark.png"
    watermark = Image.open(watermark_file) if watermark_file.exists() else None

    processed = []
    for photo in photos:
        # Each input file is in this run's own folder; its "path" is where.
        source = Path(photo["path"])
        image = Image.open(source).convert("RGB")
        for _ in range(max(1, strength)):
            image = image.filter(ImageFilter.SHARPEN)
        outline = ImageOps.invert(image.convert("L").filter(ImageFilter.FIND_EDGES))
        if watermark is not None:
            image.paste(watermark, (0, 0))

        # Written next to the input, inside the run's own folder, so runs going
        # at the same time never overwrite each other's files.
        sharpened = source.with_name(source.stem + "_sharpened.png")
        outlined = source.with_name(source.stem + "_outline.png")
        image.save(sharpened)
        outline.save(outlined)
        processed.append({"kind": "image", "path": str(sharpened)})
        processed.append({"kind": "image", "path": str(outlined)})

    return {
        "processed": processed,
        "summary": f"Processed {len(photos)} photo(s) with {python_version}.",
    }
