import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController({SharedPreferences? preferences}) {
    _init(preferences);
  }

  static const _themeKey = 'theme_mode';
  static const _colorKey = 'primary_color';
  static const _localeKey = 'locale';
  static const _alertsKey = 'alerts_enabled';
  static const _tabKey = 'last_tab';
  static const _textScaleKey = 'text_scale';

  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF909D92);
  Locale _locale = const Locale('en');
  bool _initialized = false;
  bool _alertsEnabled = true;
  int _lastTabIndex = 0;
  double _textScaleFactor = 1.0;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get initialized => _initialized;
  bool get alertsEnabled => _alertsEnabled;
  int get lastTabIndex => _lastTabIndex;
  double get textScaleFactor => _textScaleFactor;

  Future<void> _init(SharedPreferences? preferences) async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = preferences ?? await SharedPreferences.getInstance();
    _themeMode =
        ThemeMode.values[_prefs!.getInt(_themeKey) ?? ThemeMode.system.index];
    final colorValue = _prefs!.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    final localeCode = _prefs!.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _alertsEnabled = _prefs!.getBool(_alertsKey) ?? true;
    _lastTabIndex = _prefs!.getInt(_tabKey) ?? 0;
    _textScaleFactor = _prefs!.getDouble(_textScaleKey) ?? 1.0;
    _initialized = true;
    notifyListeners();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> updateTheme(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setInt(_themeKey, value.index);
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setInt(_colorKey, color.value);
  }

  Future<void> updateLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> updateAlerts(bool value) async {
    _alertsEnabled = value;
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setBool(_alertsKey, value);
  }

  Future<void> updateLastTab(int index) async {
    _lastTabIndex = index;
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setInt(_tabKey, index);
  }

  Future<void> updateTextScale(double factor) async {
    _textScaleFactor = factor.clamp(0.9, 1.3);
    notifyListeners();
    final prefs = await _ensurePrefs();
    await prefs.setDouble(_textScaleKey, _textScaleFactor);
  }

  Future<void> clearPreferences() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_themeKey);
    await prefs.remove(_colorKey);
    await prefs.remove(_localeKey);
    await prefs.remove(_alertsKey);
    await prefs.remove(_tabKey);
    await prefs.remove(_textScaleKey);
    _themeMode = ThemeMode.system;
    _primaryColor = const Color(0xFF909D92);
    _locale = const Locale('en');
    _alertsEnabled = true;
    _lastTabIndex = 0;
    _textScaleFactor = 1.0;
    notifyListeners();
  }
}
