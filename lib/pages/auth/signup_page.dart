import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.contains('@') ? null : 'Invalid',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
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
                decoration: const InputDecoration(labelText: 'Confirm password'),
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
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
