import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  static const String _kLanguage = 'language';
  static const String _kIsHighContrast = 'isHighContrast';
  static const String _kFontScale = 'fontScale';
  static const String _kHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _kHasSeenLocationPrompt = 'hasSeenLocationPrompt';
  static const String _kThemeMode = 'themeMode';

  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _hasCompletedOnboarding = false;
  bool _hasSeenLocationPrompt = false;
  String _themeMode = 'dark';

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenLocationPrompt => _hasSeenLocationPrompt;
  String get themeMode => _themeMode;

  UserPreferencesModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_kLanguage) ?? 'en';
    _isHighContrast = prefs.getBool(_kIsHighContrast) ?? false;
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _hasCompletedOnboarding = prefs.getBool(_kHasCompletedOnboarding) ?? false;
    _hasSeenLocationPrompt = prefs.getBool(_kHasSeenLocationPrompt) ?? false;
    _themeMode = prefs.getString(_kThemeMode) ?? 'dark';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
    notifyListeners();
  }

  Future<void> setThemeMode(String value) async {
    _themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, value);
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool value) async {
    _isHighContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsHighContrast, value);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
    notifyListeners();
  }

  Future<void> setCompletedOnboarding(bool value) async {
    if (_hasCompletedOnboarding != value) {
      _hasCompletedOnboarding = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasCompletedOnboarding, value);
      notifyListeners();
    }
  }

  Future<void> setHasSeenLocationPrompt(bool value) async {
    if (_hasSeenLocationPrompt != value) {
      _hasSeenLocationPrompt = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasSeenLocationPrompt, value);
      notifyListeners();
    }
  }
}
