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

  String get strength {
    final value = passwordController.text;
    if (value.length >= 12 &&
        value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'\d')) &&
        value.contains(RegExp(r'[!@#\$%^&*]'))) {
      return 'Strong';
    }
    if (value.length >= 8) return 'Medium';
    if (value.isEmpty) return '';
    return 'Weak';
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
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: strings.t('signup.email')),
                validator: (value) => value!.contains('@') ? null : 'Invalid',
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
                validator: (value) => value!.length < 8 ? 'Min 8 chars' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.t('signup.confirm')),
                validator: (value) => value == passwordController.text ? null : 'Mismatch',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Strength: $strength'),
                  backgroundColor: strength == 'Strong'
                      ? Colors.green.withOpacity(0.2)
                      : strength == 'Medium'
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                ),
              ),
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
