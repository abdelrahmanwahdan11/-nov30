import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/app_controller.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  String get passwordStrength {
    final password = passwordController.text;
    if (password.length > 10 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'\d'))) {
      return 'Strong';
    }
    if (password.length > 6) {
      return 'Medium';
    }
    if (password.isEmpty) {
      return '';
    }
    return 'Weak';
  }

  Color strengthColor(String label) {
    switch (label) {
      case 'Strong':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Weak':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('login.title'), style: GoogleFonts.nunito()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.t('app.name'), style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: strings.t('login.email'),
                  prefixIcon: const Icon(IconlyLight.message),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: strings.t('login.password'),
                  prefixIcon: const Icon(IconlyLight.lock),
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? IconlyBold.show : IconlyLight.show),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
                validator: (value) => value!.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: strengthColor(passwordStrength).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: passwordStrength == 'Strong'
                        ? 1
                        : passwordStrength == 'Medium'
                            ? 0.6
                            : 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: strengthColor(passwordStrength),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              Text(passwordStrength, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth/forgot'),
                  child: Text(strings.t('login.forgot')),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacementNamed(context, '/shell');
                  }
                },
                child: Center(child: Text(strings.t('login.title'))),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/shell'),
                child: Center(child: Text(strings.t('login.guest'))),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/auth/signup'),
                child: Text(strings.t('login.signup')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
