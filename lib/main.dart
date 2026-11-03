import 'dart:async';
import 'dart:ui';

import 'package:discoman_worker/discoman_compute.dart'
    show PythonRunner, loadLoginShellPath;
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
    return MaterialApp(
      title: 'Discoman Compute',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        // Only which page is shown depends on this rebuild; each page
        // subscribes to the controller for its own contents.
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isRestoring) {
              return const Center(child: CircularProgressIndicator());
            }
            return _controller.isSignedIn
                ? HomePage(controller: _controller)
                : SignInPage(controller: _controller);
          },
        ),
      ),
    );
  }
}
