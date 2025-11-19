import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool showPassword = false;

  String get strengthKey {
    final value = passwordController.text;
    if (value.length >= 12 &&
        value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'\d')) &&
        value.contains(RegExp(r'[!@#\$%^&*]'))) {
      return 'strong';
    }
    if (value.length >= 8) return 'medium';
    if (value.isEmpty) return '';
    return 'weak';
  }

  Color strengthColor(String key) {
    switch (key) {
      case 'strong':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'weak':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('signup.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: strings.t('signup.name')),
                validator: (value) =>
                    value == null || value.isEmpty ? strings.t('form.required') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: strings.t('signup.email')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.t('form.required');
                  }
                  if (!value.contains('@')) {
                    return strings.t('form.invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: strings.t('signup.password'),
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? IconlyBold.show : IconlyLight.show),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
                validator: (value) =>
                    value != null && value.length >= 8 ? null : strings.t('form.password_long'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.t('signup.confirm')),
                validator: (value) =>
                    value == passwordController.text ? null : strings.t('form.password_mismatch'),
              ),
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final key = strengthKey;
                final strengthLabel = key.isEmpty ? '' : strings.t('auth.strength.$key');
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text('${strings.t('auth.strength.label')} $strengthLabel'),
                    backgroundColor: strengthColor(key).withOpacity(0.2),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(context, '/auth/verify');
                  }
                },
                child: Text(strings.t('signup.create')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
