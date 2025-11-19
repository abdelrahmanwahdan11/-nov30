import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const _localizedStrings = {
    'en': {
      'app.name': 'WaterPod',
      'dashboard.title': 'Dashboard',
      'catalog.title': 'Catalog',
      'comparison.title': 'Comparison',
      'schedule.title': 'Schedule',
      'logs.title': 'Logs',
      'analytics.title': 'Analytics',
      'settings.title': 'Settings',
      'onboarding.skip': 'Skip',
      'onboarding.next': 'Next',
      'login.title': 'Login',
      'login.email': 'Email or phone',
      'login.password': 'Password',
      'login.forgot': 'Forgot?',
      'login.signup': 'Create account',
      'login.guest': 'Login as Guest',
      'ai.button': 'AI info',
      'ai.tooltip': 'AI explanation coming soon',
      'ai.dialog': 'AI explanation coming soon',
      'search.hint': 'Search pods',
      'filters.title': 'Filters',
      'settings.language': 'Language',
      'settings.theme': 'Theme',
      'settings.color': 'Primary color',
      'settings.clear': 'Clear local data',
    },
    'ar': {
      'app.name': 'ووتر بود',
      'dashboard.title': 'لوحة التحكم',
      'catalog.title': 'الفهرس',
      'comparison.title': 'المقارنة',
      'schedule.title': 'الجدولة',
      'logs.title': 'السجلات',
      'analytics.title': 'التحليلات',
      'settings.title': 'الإعدادات',
      'onboarding.skip': 'تخطي',
      'onboarding.next': 'التالي',
      'login.title': 'تسجيل الدخول',
      'login.email': 'البريد أو الهاتف',
      'login.password': 'كلمة المرور',
      'login.forgot': 'نسيت؟',
      'login.signup': 'إنشاء حساب',
      'login.guest': 'دخول كضيف',
      'ai.button': 'زر الذكاء الاصطناعي',
      'ai.tooltip': 'شرح قريباً',
      'ai.dialog': 'سيضاف شرح الذكاء الاصطناعي قريباً',
      'search.hint': 'ابحث عن الحافظات',
      'filters.title': 'المرشحات',
      'settings.language': 'اللغة',
      'settings.theme': 'الوضع',
      'settings.color': 'اللون الأساسي',
      'settings.clear': 'مسح البيانات المحلية',
    }
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']![key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
