# GBot compute client

Runs your app's Python on your own computer instead of ours.

Your script stays here. You point this program at a `.py` file, it works out
what inputs and outputs the script has, and sends GBot only that description —
never the code. You then design the app's screens in GBot, and when someone
uses it, each request is queued, picked up here, run with your Python, and the
result sent back. Nothing runs unless someone uses your app.

Your account is never stored on disk — only a revocable per-machine token, at
`~/.discoman/credentials.json`. Your linked scripts are kept beside it, in
`~/.discoman/scripts/`.

## What you need

- **Dart SDK** — to install this program ([install guide](https://dart.dev/get-dart))
- **Python 3.11** with the packages your scripts import

If your scripts use the usual data and plotting libraries, a virtual
environment is the cleanest way to get them:

```sh
python3.11 -m venv ~/.gbot-python
~/.gbot-python/bin/pip install matplotlib numpy pandas Pillow
```

You will pass that interpreter to `start` below.

## 1. Install

```sh
dart pub global activate --source git https://github.com/gbotdeveloper/discoman_compute.git
```

Make sure `~/.pub-cache/bin` is on your `PATH`, so the `discoman-compute`
command is found.

## 2. Sign in

```sh
discoman-compute login
```

Enter the same email and password you use for GBot. This enrolls the machine
and saves its token. You only do this once per computer.

## 3. Link a script

```sh
discoman-compute link --script ~/scripts/my_analysis.py
```

It reads the script, shows you the inputs and outputs it found, and asks which
of your projects to attach them to. Nothing is sent until you confirm, and what
is sent is the list you just saw — not the script.

Run it again whenever you change what your script takes or returns.

## 4. Start it

```sh
discoman-compute start --python ~/.gbot-python/bin/python3
```

Leave it running. In GBot, the **Compute** section of your project's Publish
step will show the client as online, and runs will start landing here.

Press `Ctrl+C` to stop. While it is stopped, requests to your app wait in the
queue rather than failing — they run as soon as you start it again.

## Keeping it running

Runs only happen while this program is running. If your computer sleeps or you
close the terminal, visitors to your app will wait. For an app people use
regularly, run it on a machine that stays awake, or switch that app back to
GBot's cloud in the Compute section.

## If something goes wrong

**`Run 'discoman-compute login' again.`** — the machine token was revoked, or
the server could not be reached. Check your connection, then sign in again.

**`ModuleNotFoundError`** — your script imports a package your Python does not
have. Install it into the interpreter you passed to `--python`.

**The client never shows as online** — check that the project's Compute setting
is "My own machine", and that `start` is still running in your terminal.

**GBot shows the wrong inputs** — the contract is only re-read when you run
`link`. Run it again after changing your script's parameters or return value.

## Commands

```
discoman-compute login  [--name NAME]
discoman-compute link   [--script PATH] [--project ID]
discoman-compute start  [--python PATH] [--name NAME]
```

`--name` labels this machine in GBot; it defaults to your computer's hostname.
