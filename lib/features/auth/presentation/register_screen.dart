import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/date_input_formatter.dart';
import '../../../core/utils/dates.dart';
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
  final _birthDate = TextEditingController();
  bool _obscure = true;
  String? _gender;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: Dates.parseNumeric(_birthDate.text) ?? DateTime(1990),
      firstDate: _firstBirthDate,
      lastDate: DateTime.now(),
    );
    if (value != null) _birthDate.text = Dates.numeric(value);
  }

  static final _firstBirthDate = DateTime(1920);

  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La data di nascita è obbligatoria';
    }
    final date = Dates.parseNumeric(value);
    if (date == null) return 'Usa il formato gg/mm/aaaa';
    if (date.isBefore(_firstBirthDate) || date.isAfter(DateTime.now())) {
      return 'Data di nascita non valida';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final message = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text,
            password: _password.text,
            fullName: _name.text,
            birthDate: Dates.parseNumeric(_birthDate.text)!,
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
      if (mounted) context.pop();
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
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'Almeno 12 caratteri',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure ? 'Mostra password' : 'Nascondi password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 12
                    ? 'La password deve contenere almeno 12 caratteri'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _birthDate,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  const DateInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Data di nascita',
                  hintText: 'gg/mm/aaaa',
                  suffixIcon: IconButton(
                    onPressed: _pickDate,
                    tooltip: 'Apri il calendario',
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                validator: _validateBirthDate,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                isExpanded: true,
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
