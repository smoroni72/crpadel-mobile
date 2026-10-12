import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';

/// Cambio password. Il server chiude tutte le sessioni: al termine l'utente
/// torna al login.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  var _obscure = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password cambiata: accedi con la nuova password'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : 'Cambio non riuscito';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final toggle = IconButton(
      onPressed: () => setState(() => _obscure = !_obscure),
      tooltip: _obscure ? 'Mostra password' : 'Nascondi password',
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Cambia password')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _current,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password attuale',
                  suffixIcon: toggle,
                ),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Inserisci la password attuale' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _next,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Nuova password',
                  helperText: 'Almeno 12 caratteri',
                ),
                validator: (v) => (v ?? '').length < 12
                    ? 'La password deve contenere almeno 12 caratteri'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Ripeti la nuova password',
                ),
                validator: (v) =>
                    v != _next.text ? 'Le password non coincidono' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: context.colors.primaryText),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Dopo il cambio dovrai accedere di nuovo su tutti i dispositivi.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cambia password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
