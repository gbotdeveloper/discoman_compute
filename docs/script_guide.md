# Writing a script for Discoman Compute

Discoman Compute runs your Python script on your own computer each time
someone uses your app. This guide covers what the script needs to look like
and how it can use your files and other programs.

A working example is in
[`examples/image_pipeline.py`](../examples/image_pipeline.py). In the app,
**How to write a script → Save example script** saves a copy of it.

## The entrypoint

Discoman calls one function in your script:

- a top-level function named `main`, `run` or `execute`, in that order of
  preference, or
- the only top-level function in the file, if there is just one.

If the file has several top-level functions and none of those names, linking
fails and asks you to name one of them `main`.

Its parameters are the app's inputs, and the keys of the dictionary it
returns are the app's outputs:

```python
def main(photo: dict, strength: int = 2, caption: str = ""):
    """Sharpens a photo.

    - photo -> image
    - result_image -> image
    """
    ...
    return {"result_image": image, "note": "done"}
```

When you link the script, Discoman Compute shows the inputs and outputs it
read from it before anything is sent. Check them there.

## How inputs and outputs are detected

Plain values come from the parameter's annotation: `str` (text), `int`,
`float`, `bool`, `date`/`datetime`, `Literal[...]` or an `Enum` (a choice),
`list[...]`, and `dict` or `pandas.DataFrame` (a table). A parameter with a
default is optional.

**The most reliable way to declare images and files is a docstring line** in
the entrypoint, one per input or output: `- name -> image`, `- name -> file`,
`- name -> image[]` or `- name -> file[]` (the `[]` means a list). The other
rules below also work, but a docstring line leaves nothing to guess.

Single image input:

- a parameter annotated `Image.Image`, `PIL.Image.Image`, `Image` or `bytes`
  (or `Optional[...]` / `X | None` of those);
- an unannotated or `str` parameter with no default or `= None` whose name ends
  in image, photo, picture, screenshot, frame, mask, scan, overlay, thumbnail,
  plot or figure;
- a `dict` parameter whose name contains image, photo, picture or screenshot;
- any parameter with a docstring line `- name -> image`.

Multiple image input:

- `list[Image.Image]`, `list[PIL.Image.Image]`, `list[bytes]`, `list[dict]`
  with an image word in the name, or `Sequence[...]` / `tuple[X, ...]` of the
  same;
- a bare `list` parameter whose name contains or ends in an image word;
- an unannotated or `str` parameter (no default or `= None`) whose name ends in
  a plural of those words (photos, masks…);
- a docstring line `- name -> image[]`.

`*images` is not supported.

Image list output (under a key of the returned dict, or returned alone as
`result`):

- a list literal or comprehension of image dicts, PIL images or matplotlib
  figures;
- a variable set to `[]` or `list()` and then filled with `.append(...)` of
  those;
- a list under a key whose name ends in a plural image word;
- a docstring line `- key -> image[]` (`- result -> image[]` when the list is
  returned alone);
- a return annotation `-> list[Image.Image]`, `-> list[PIL.Image.Image]` or
  `-> list[Figure]`. `-> list[dict]` alone stays a plain list.

Single image output: one image dict, PIL image or figure; a docstring line
`- key -> image`; or `-> Image.Image`.

In short: for several images, return a list of image dicts or PIL images under
one key, and add the docstring line.

## Inputs your script receives

An image or file input arrives as a dictionary:

```python
{
    "kind": "image",            # or "file"
    "name": "cat.png",
    "extension": "png",
    "mimeType": "image/png",
    "sizeBytes": 48213,
    "path": "/…/discoman_run_x/cat.png",   # the file, in this run's folder
    "base64": "iVBORw0KG…",                 # the same bytes, inline
}
```

Use `path` to open it like any file (`Image.open(photo["path"])`, or pass it to
another program). A list input is a list of these, in the order they were
given. Parameters annotated as `Image.Image` get an opened PIL image instead,
and `bytes` get the raw bytes.

## Outputs your script returns

Return a dictionary; each key is one output. For an image or file, any of
these works:

- a file you wrote: `{"kind": "image", "path": "result.png"}` or
  `{"kind": "file", "path": "report.csv"}` (a relative path is read from the
  run's folder, which is the current folder when your script starts; add
  `"name"` to choose the file name people download);
- a PIL image or a matplotlib figure (saved as PNG);
- `bytes` of a PNG, JPEG, WEBP, PDF, CSV, JSON, XLSX or text file;
- a list of any of those, for a gallery or several files.

Images must be PNG, JPEG or WEBP. Files must be PDF, CSV, TXT, JSON or XLSX.
Numbers, text, lists, dicts, numpy values and pandas tables are returned as
data.

## Your files, other scripts and other programs

Each run gets a fresh folder of its own. Your script is copied into it as it
is now, and everything else in your script's folder is linked into it, so:

- `import helper` works for `helper.py` (or a `helper/` package) beside your
  script, and Discoman never offers to pip install those;
- `open("model.bin")`, `Path(__file__).parent / "data"` and other relative
  paths find the files beside your script;
- `subprocess.run([sys.executable, "other_script.py"])` runs a script beside
  yours.

For files somewhere else, use their full path.

Other programs (MATLAB, conda tools, command line tools) are found through the
same PATH your terminal uses. If one is still not found, add its folder under
**Extra PATH** in Discoman Compute, or call it by its full path. Always pass a
`timeout` and capture its output, so a stuck program fails the run instead of
holding it:

```python
done = subprocess.run(["matlab", "-batch", "process"], capture_output=True,
                      text=True, timeout=600)
```

What programs print is kept in the run's log (the last 200 lines of each of
stdout and stderr). When a run is stopped or times out, Discoman Compute stops
the programs it started too.

The environment variables `DISCOMAN_RUN_DIR` (this run's folder) and
`DISCOMAN_SCRIPT_DIR` (your script's own folder) say where things are.

## Runs at the same time

Several runs of a project can go at once. Each has its own run folder, so:

- **write outputs into the run folder, or next to the input file** (its
  `path` is in the run folder);
- **don't overwrite files in your own folder**: the run folder links to them,
  so writing to `model.bin` or to a file beside your script changes the
  original, for every run.

Files you write into the run folder are deleted when the run ends; the files
they link to are never touched.

## Editing the script

Runs always use the script as it is on disk. If you edit it and its inputs and
outputs stay the same, the next run uses the new code. If they change, runs
fail and the project shows a warning until you link the script again. If you
move or delete the script, link it again.

Scripts linked before this way of running was introduced keep running from the
copy Discoman Compute keeps, until you link them again.

## Limits

- Each output image or file: 20 MB.
- At most 50 output files per run, 100 MB in all.
- Each input file: 20 MB; 100 MB per run.
- A run that goes past the project's timeout is stopped.

## Python and packages

Runs use the Python shown in Discoman Compute (change it there, or install
Discoman's own Python with numpy, pandas, matplotlib and Pillow). Packages your
script imports that this Python lacks are listed on the project, with an
Install button that runs pip. The MATLAB Engine (`import matlab`) is never
installed automatically: it has to match your MATLAB release, so install it
from your MATLAB as MathWorks describes.
