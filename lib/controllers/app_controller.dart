import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _init();
  }

  static const _themeKey = 'theme_mode';
  static const _colorKey = 'primary_color';
  static const _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF909D92);
  Locale _locale = const Locale('en');
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get initialized => _initialized;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index];
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> updateTheme(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, value.index);
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
  }

  Future<void> updateLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
