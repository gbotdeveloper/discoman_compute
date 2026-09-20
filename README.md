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

- The **GBot compute app** for your computer
- **Python 3.11** with the packages your scripts import

If your scripts use the usual data and plotting libraries, a virtual
environment is the cleanest way to get them:

```sh
python3.11 -m venv ~/.gbot-python
~/.gbot-python/bin/pip install matplotlib numpy pandas Pillow
```

On Windows:

```
py -3.11 -m venv %USERPROFILE%\.gbot-python
%USERPROFILE%\.gbot-python\Scripts\pip install matplotlib numpy pandas Pillow
```

Point the app at that interpreter under **This computer → Python → Change**.
Note the two layouts differ: macOS and Linux put it in `bin/python3`, Windows in
`Scripts\python.exe`.

    macOS, Linux   ~/.gbot-python/bin/python3
    Windows        C:\Users\<you>\.gbot-python\Scripts\python.exe

`~` is expanded for you, so typing it is fine. Windows environment variables
like `%USERPROFILE%` are not — use the full path there.

## Using the app

Open **GBot compute** and sign in with the same email and password you use for
GBot. That enrols this computer; you only do it once.

The window has two parts:

- **This computer** — Start and Stop, and a log of what has run. The **Python**
  row shows which interpreter your scripts run with; **Change** lets you pick
  another and checks it before you commit to it. Leave the worker started. In
  GBot, the **Compute** section of your project's Publish step will show the
  client as online. While it is stopped, requests to your apps wait in the queue
  rather than failing — they run as soon as you start it again.
- **Your projects** — pick one and choose **Link a script**. The app reads the
  `.py` file you select, shows you the inputs and outputs it found, and asks you
  to confirm. Only that list is sent; the script is copied to
  `~/.discoman/scripts/` and stays here.

Link again whenever you change what your script takes or returns.

## On a machine with no screen

The app is how this is meant to be used. The one case it cannot cover is a
computer you never sit at — a spare box or a server you leave running — where
there is no window to open. The same worker runs from a terminal there:

```sh
dart pub global activate --source git \
  https://github.com/gbotdeveloper/discoman_compute.git \
  --git-path packages/worker
```

Make sure `~/.pub-cache/bin` is on your `PATH`, then:

```sh
discoman-compute login                                  # once per computer
discoman-compute link --script ~/scripts/my_analysis.py
discoman-compute start --python ~/.gbot-python/bin/python3
```

`Ctrl+C` stops it.

Both read the same `~/.discoman`, so nothing diverges: the machine token, the
scripts you have linked, and the interpreter you picked in the app all apply
here too. `--python` overrides the saved interpreter for that one run.

## Acting as a second computer

Everything above lives in `~/.discoman`. Point `DISCOMAN_HOME` somewhere else
and you get a clean one: its own machine token, its own linked scripts, its own
interpreter. The server sees a second worker, because that is exactly what a
second computer looks like to it.

```
DISCOMAN_HOME=~/.discoman-machine-2 discoman-compute login
```

Useful for trying the split — this app on one machine, that app on another —
without a second machine.

## Keeping it running

Runs only happen while the worker is running. If your computer sleeps, or you
quit the app or close the terminal, visitors to your app will wait. For an app people use
regularly, run it on a machine that stays awake, or switch that app back to
GBot's cloud in the Compute section.

## If something goes wrong

**`Run 'discoman-compute login' again.`** — the machine token was revoked, or
the server could not be reached. Check your connection, then sign in again.

**`ModuleNotFoundError`** — your script imports a package your Python does not
have. Install it into that interpreter, or point the app at one that has it
(**This computer → Python → Change**).

**The client never shows as online** — check that the project's Compute setting
is "My own machine", and that the worker is started.

**GBot shows the wrong inputs** — the contract is only re-read when you link the
script. Link it again after changing your script's parameters or return value.

**`No script is linked to this project on this machine.`** — the project expects
a local script but this computer has none. Link one here, or link it on the
computer that is meant to serve the app.

## Terminal commands

Only needed on a machine with no screen; the app does all three for you.

```
discoman-compute login  [--name NAME]
discoman-compute link   [--script PATH] [--project ID]
discoman-compute start  [--python PATH] [--name NAME]
```

`--name` labels this machine in GBot; it defaults to your computer's hostname.

## Building it yourself

The repository root is the app; the worker it runs, and the command-line
version of the same thing, are in `packages/worker`.

```sh
flutter run -d macos                  # from the repository root
flutter build macos --release
flutter build windows --release       # on a Windows machine
```

### macOS

App Sandbox is switched off in `macos/Runner/*.entitlements`. The app runs your
own Python interpreter and shares `~/.discoman` with the command-line worker,
neither of which a sandboxed app can do. It is distributed directly (notarized),
not through the Mac App Store.

### Windows

Nothing to configure. Credentials and scripts go under `%USERPROFILE%\.discoman`
— the same layout as macOS, minus the file permissions, which are only applied
on POSIX.

The default interpreter is `python` rather than `python3`: on Windows `python3`
usually resolves to the Store stub, which opens a download page instead of
running anything.
