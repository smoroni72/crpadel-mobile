import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (value != null) setState(() => _birthDate = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _birthDate == null ||
        _gender == null) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    try {
      final message = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text,
            password: _password.text,
            fullName: _name.text,
            birthDate: _birthDate!,
            gender: _gender!,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Controlla la posta'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ho capito'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Registrazione non riuscita';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Crea il tuo account')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nome e cognome'),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Inserisci nome e cognome'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Email non valida',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'Almeno 12 caratteri',
                ),
                validator: (value) => (value?.length ?? 0) < 12
                    ? 'La password deve contenere almeno 12 caratteri'
                    : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data di nascita',
                    errorText: _birthDate == null
                        ? 'La data di nascita è obbligatoria'
                        : null,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _birthDate == null
                        ? 'Seleziona'
                        : DateFormat('dd/MM/yyyy').format(_birthDate!),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Sesso'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Maschile')),
                  DropdownMenuItem(value: 'female', child: Text('Femminile')),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Altro / preferisco non indicarlo'),
                  ),
                ],
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) =>
                    value == null ? 'Il sesso è obbligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? 'Creazione…' : 'Registrati'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
