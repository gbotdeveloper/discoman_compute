# GBot compute — desktop app

The window creators use: sign in, link a script to a project, and start or stop
the worker.

This is a front end only. Everything it does — signing in, reading a script and
inferring its contract, claiming runs and executing Python — lives in the
`discoman_compute` package one directory up, which the command-line worker and
the cloud worker use too.

It is kept a separate package on purpose: adding Flutter to the engine would
pull the Flutter SDK into the cloud worker's Docker image, which is a plain Dart
build.

macOS and Windows are both supported.

```sh
flutter run -d macos                  # from this directory
flutter build macos --release
flutter build windows --release       # on a Windows machine
```

## macOS

App Sandbox is switched off in `macos/Runner/*.entitlements`. The app runs the
creator's own Python interpreter and shares `~/.discoman` with the CLI, neither
of which a sandboxed app can do. It is distributed directly (notarized), not
through the Mac App Store.

## Windows

Nothing to configure. Credentials and scripts go under `%USERPROFILE%\.discoman`
— the same layout as macOS, minus the file permissions, which the engine only
applies on POSIX.

The default interpreter is `python` rather than `python3`: on Windows `python3`
usually resolves to the Store stub, which opens a download page instead of
running anything.
