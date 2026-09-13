import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'action_button.dart';
import 'error_banner.dart';

/// The first thing a creator sees: sign in with the same account they use for
/// GBot. Signing in also enrols this machine, so the worker can run later
/// without asking again.
class SignInPage extends StatefulWidget {
  const SignInPage({required this.controller, super.key});

  final AppController controller;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.controller.isBusy) return;
    widget.controller.signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    // The page listens for itself rather than relying on an ancestor to
    // rebuild it: a caller that forgets loses the busy state and the error
    // message with no visible sign of why.
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Discoman Compute',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Run your apps on this computer, with your scripts staying '
                'here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (controller.errorMessage != null) ...[
                ErrorBanner(message: controller.errorMessage!),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              ActionButton(
                label: controller.isBusy ? 'Signing in…' : 'Sign in',
                onPressed: controller.isBusy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
