import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'app_theme.dart';
import 'widgets/home_page.dart';
import 'widgets/sign_in_page.dart';

void main() {
  runApp(const DiscomanComputeApp());
}

class DiscomanComputeApp extends StatefulWidget {
  const DiscomanComputeApp({super.key});

  @override
  State<DiscomanComputeApp> createState() => _DiscomanComputeAppState();
}

class _DiscomanComputeAppState extends State<DiscomanComputeApp> {
  final _controller = AppController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBot compute',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        // Only which page is shown depends on this rebuild; each page
        // subscribes to the controller for its own contents.
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return _controller.isSignedIn
                ? HomePage(controller: _controller)
                : SignInPage(controller: _controller);
          },
        ),
      ),
    );
  }
}
