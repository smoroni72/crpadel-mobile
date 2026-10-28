import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_mark.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  String? _emailWhenEditingStarted;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String get _normalizedEmail => _email.text.trim().toLowerCase();

  void _startEditingEmail() {
    _emailWhenEditingStarted ??= _normalizedEmail;
  }

  void _emailChanged(String _) {
    final previous = _emailWhenEditingStarted;
    if (previous != null &&
        _normalizedEmail != previous &&
        _password.text.isNotEmpty) {
      _password.clear();
    }
    setState(() {});
  }

  void _clearCredentials() {
    TextInput.finishAutofillContext(shouldSave: false);
    _email.clear();
    _password.clear();
    _emailWhenEditingStarted = null;
    setState(() {});
    _emailFocus.requestFocus();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_email.text, _password.text);
    if (!mounted) return;
    final result = ref.read(authControllerProvider);
    if (result.hasError) {
      _password.clear();
      setState(() {});
      _passwordFocus.requestFocus();
    } else {
      TextInput.finishAutofillContext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = auth.hasError
        ? (auth.error is ApiException
              ? (auth.error! as ApiException).message
              : 'Accesso non riuscito')
        : null;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LoginHeader(),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _email,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      enableSuggestions: false,
                      onTap: _startEditingEmail,
                      onChanged: _emailChanged,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: _email.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _clearCredentials,
                                tooltip: 'Usa un altro account',
                                icon: const Icon(Icons.close),
                              ),
                      ),
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Inserisci un indirizzo email valido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Inserisci la password'
                          : null,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(color: context.colors.primaryText),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Accedi'),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.forgotPassword),
                      child: const Text('Hai dimenticato la password?'),
                    ),
                    const Divider(height: 32),
                    OutlinedButton(
                      onPressed: () => context.pushNamed(AppRoutes.register),
                      child: const Text('Crea un account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const BrandMark(size: 84),
        const SizedBox(height: 18),
        Text('Benvenuto in CRPadel', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Accedi per prenotare e giocare',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
