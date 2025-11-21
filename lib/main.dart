import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/app_controller.dart';
import 'l10n/app_localizations.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/forgot_page.dart';
import 'pages/auth/verify_page.dart';
import 'pages/shell_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterPodApp());
}

class WaterPodApp extends StatefulWidget {
  const WaterPodApp({super.key});

  @override
  State<WaterPodApp> createState() => _WaterPodAppState();
}

class _WaterPodAppState extends State<WaterPodApp> {
  final AppController controller = AppController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.initialized) {
          return const MaterialApp(home: SizedBox());
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WaterPod',
          theme: buildLightTheme(controller.primaryColor),
          darkTheme: buildDarkTheme(controller.primaryColor),
          themeMode: controller.themeMode,
          locale: controller.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: controller.textScaleFactor),
              child: child ?? const SizedBox.shrink(),
            );
          },
          routes: {
            '/auth/login': (context) => LoginPage(controller: controller),
            '/auth/signup': (context) => const SignUpPage(),
            '/auth/forgot': (context) => const ForgotPasswordPage(),
            '/auth/verify': (context) => const VerifyAccountPage(),
            '/shell': (context) => ShellPage(appController: controller),
          },
          initialRoute: '/auth/login',
        );
      },
    );
  }
}
