import 'dart:async';
import 'dart:ui';

import 'package:discoman_worker/discoman_compute.dart'
    show PythonRunner, ThemePreference, loadLoginShellPath;
import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'app_theme.dart';
import 'widgets/home_page.dart';
import 'widgets/sign_in_page.dart';

void main() {
  // Read before the first run, so runs find what the terminal finds.
  unawaited(loadLoginShellPath());
  runApp(const DiscomanComputeApp());
}

class DiscomanComputeApp extends StatefulWidget {
  const DiscomanComputeApp({super.key});

  @override
  State<DiscomanComputeApp> createState() => _DiscomanComputeAppState();
}

class _DiscomanComputeAppState extends State<DiscomanComputeApp> {
  final _controller = AppController();

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Runs are in process groups of their own, so they would outlive the app.
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        PythonRunner.killAll();
        return AppExitResponse.exit;
      },
    );
    _controller.restoreSignIn();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only the theme and which page is shown depend on this rebuild; each
    // page subscribes to the controller for its own contents.
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => MaterialApp(
        title: 'Discoman Compute',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: switch (_controller.theme) {
          ThemePreference.system => ThemeMode.system,
          ThemePreference.light => ThemeMode.light,
          ThemePreference.dark => ThemeMode.dark,
        },
        home: Scaffold(
          body: _controller.isRestoring
              ? const Center(child: CircularProgressIndicator())
              : _controller.isSignedIn
              ? HomePage(controller: _controller)
              : SignInPage(controller: _controller),
        ),
      ),
    );
  }
}
