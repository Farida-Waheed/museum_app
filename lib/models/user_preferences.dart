import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  static const String _kLanguage = 'language';
  static const String _kIsHighContrast = 'isHighContrast';
  static const String _kFontScale = 'fontScale';
  static const String _kIsFirstLaunch = 'isFirstLaunch';
  static const String _kHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _kHasSeenPermissionsPrompt = 'hasSeenPermissionsPrompt';
  static const String _kHasSeenLocationPrompt = 'hasSeenLocationPrompt';
  static const String _kThemeMode = 'themeMode';

  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _isFirstLaunch = true;
  bool _hasCompletedOnboarding = false;
  bool _hasSeenPermissionsPrompt = false;
  bool _hasSeenLocationPrompt = false;
  String _themeMode = 'dark';

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenPermissionsPrompt => _hasSeenPermissionsPrompt;
  bool get hasSeenLocationPrompt => _hasSeenLocationPrompt;
  String get themeMode => _themeMode;

  UserPreferencesModel({
    String initialLanguage = 'en',
    bool initialOnboardingCompleted = false,
    bool initialIsHighContrast = false,
    double initialFontScale = 1.0,
    bool initialIsFirstLaunch = true,
    String initialThemeMode = 'dark',
    bool initialHasSeenPermissionsPrompt = false,
    bool initialHasSeenLocationPrompt = false,
    bool skipLoad = false,
  }) {
    _language = initialLanguage;
    _hasCompletedOnboarding = initialOnboardingCompleted;
    _isHighContrast = initialIsHighContrast;
    _fontScale = initialFontScale;
    _isFirstLaunch = initialIsFirstLaunch;
    _themeMode = initialThemeMode;
    _hasSeenPermissionsPrompt = initialHasSeenPermissionsPrompt;
    _hasSeenLocationPrompt = initialHasSeenLocationPrompt;

    if (!skipLoad) {
      _loadFromPrefs();
    }
  }

  static Future<Map<String, dynamic>> getInitialPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_kIsFirstLaunch) ?? true;

    return {
      'language': isFirstLaunch ? 'en' : (prefs.getString(_kLanguage) ?? 'en'),
      'isFirstLaunch': isFirstLaunch,
      'hasCompletedOnboarding':
          prefs.getBool(_kHasCompletedOnboarding) ?? false,
      'isHighContrast': prefs.getBool(_kIsHighContrast) ?? false,
      'fontScale': prefs.getDouble(_kFontScale) ?? 1.0,
      'themeMode': prefs.getString(_kThemeMode) ?? 'dark',
      'hasSeenPermissionsPrompt':
          prefs.getBool(_kHasSeenPermissionsPrompt) ?? false,
      'hasSeenLocationPrompt': prefs.getBool(_kHasSeenLocationPrompt) ?? false,
    };
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool(_kIsFirstLaunch) ?? true;
    _language = _isFirstLaunch ? 'en' : (prefs.getString(_kLanguage) ?? 'en');
    _isHighContrast = prefs.getBool(_kIsHighContrast) ?? false;
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _hasCompletedOnboarding = prefs.getBool(_kHasCompletedOnboarding) ?? false;
    _hasSeenPermissionsPrompt =
        prefs.getBool(_kHasSeenPermissionsPrompt) ?? false;
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

  Future<void> setIsFirstLaunch(bool value) async {
    if (_isFirstLaunch != value) {
      _isFirstLaunch = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsFirstLaunch, value);
      notifyListeners();
    }
  }

  Future<void> setHasSeenPermissionsPrompt(bool value) async {
    if (_hasSeenPermissionsPrompt != value) {
      _hasSeenPermissionsPrompt = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasSeenPermissionsPrompt, value);
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
