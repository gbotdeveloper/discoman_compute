"""An example Discoman script: sharpens photos and reports what it did.

Discoman reads the inputs from the parameters of `main` and the outputs from
`class Outputs`. Images and files come and go as paths to files.
"""

from pathlib import Path
from typing import Literal

from PIL import Image, ImageFilter, ImageOps

Images = list[str]
Files = list[str]


class Outputs:
    processed: Images
    report: Files
    summary: str
    count: int


def main(
    photos: Images,
    strength: int = 2,
    style: Literal["Sharpen", "Sharpen and gray"] = "Sharpen",
) -> Outputs:
    out = Path("out")
    out.mkdir(exist_ok=True)

    processed = []
    lines = ["name,width,height"]
    for path in photos:
        image = Image.open(path).convert("RGB")
        for _ in range(strength):
            image = image.filter(ImageFilter.SHARPEN)
        if style == "Sharpen and gray":
            image = ImageOps.grayscale(image)
        target = out / f"{Path(path).stem}_sharp.png"
        image.save(target)
        processed.append(str(target))
        lines.append(f"{Path(path).name},{image.width},{image.height}")

    report = out / "report.csv"
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")

    return {
        "processed": processed,
        "report": [str(report)],
        "summary": f"Sharpened {len(processed)} photo(s) {strength} time(s)",
        "count": len(processed),
    }
