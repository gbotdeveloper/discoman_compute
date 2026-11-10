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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset('assets/logo.png', width: 64, height: 64),
                ),
              ),
              const SizedBox(height: 16),
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
              if (controller.browserSignIn != null)
                _BrowserSignInWait(controller: controller)
              else ...[
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: controller.isBusy
                      ? null
                      : controller.signInWithBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: const Text('Sign in with your browser'),
                ),
                const SizedBox(height: 8),
                Text(
                  'For accounts that sign in with Google.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown while a browser sign-in waits: the code to compare with the page
/// that opened, and a way back.
class _BrowserSignInWait extends StatelessWidget {
  const _BrowserSignInWait({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Approve the sign-in in your browser',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'A page opened in your browser. Check that it shows this code, '
          'then approve.',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SelectableText(
          controller.browserSignIn!.userCode,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: controller.reopenBrowserSignIn,
          child: const Text('Open the page again'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.cancelBrowserSignIn,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
