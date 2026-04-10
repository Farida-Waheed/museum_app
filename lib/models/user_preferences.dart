import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  static const String _kLanguage = 'language';
  static const String _kIsHighContrast = 'isHighContrast';
  static const String _kFontScale = 'fontScale';
  static const String _kHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _kHasSeenPermissionsPrompt = 'hasSeenPermissionsPrompt';
  static const String _kHasSeenLocationPrompt = 'hasSeenLocationPrompt';
  static const String _kThemeMode = 'themeMode';
  static const String _kHasSeenNotificationPermissionPrompt =
      'hasSeenNotificationPermissionPrompt';
  static const String _kNotificationsEnabled = 'notificationsEnabled';

  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _hasCompletedOnboarding = false;
  bool _hasSeenPermissionsPrompt = false;
  bool _hasSeenLocationPrompt = false;
  String _themeMode = 'dark';
  bool _hasSeenNotificationPermissionPrompt = false;
  bool _notificationsEnabled = true;

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenPermissionsPrompt => _hasSeenPermissionsPrompt;
  bool get hasSeenLocationPrompt => _hasSeenLocationPrompt;
  String get themeMode => _themeMode;
  bool get hasSeenNotificationPermissionPrompt =>
      _hasSeenNotificationPermissionPrompt;
  bool get notificationsEnabled => _notificationsEnabled;

  UserPreferencesModel({
    String initialLanguage = 'en',
    bool initialOnboardingCompleted = false,
    bool initialIsHighContrast = false,
    double initialFontScale = 1.0,
    String initialThemeMode = 'dark',
    bool initialHasSeenPermissionsPrompt = false,
    bool initialHasSeenLocationPrompt = false,
    bool initialHasSeenNotificationPermissionPrompt = false,
    bool initialNotificationsEnabled = true,
    bool skipLoad = false,
  }) {
    _language = initialLanguage;
    _hasCompletedOnboarding = initialOnboardingCompleted;
    _isHighContrast = initialIsHighContrast;
    _fontScale = initialFontScale;
    _themeMode = initialThemeMode;
    _hasSeenPermissionsPrompt = initialHasSeenPermissionsPrompt;
    _hasSeenLocationPrompt = initialHasSeenLocationPrompt;
    _hasSeenNotificationPermissionPrompt =
        initialHasSeenNotificationPermissionPrompt;
    _notificationsEnabled = initialNotificationsEnabled;

    if (!skipLoad) {
      _loadFromPrefs();
    }
  }

  static Future<Map<String, dynamic>> getInitialPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language': prefs.getString(_kLanguage) ?? 'en',
      'hasCompletedOnboarding':
          prefs.getBool(_kHasCompletedOnboarding) ?? false,
      'isHighContrast': prefs.getBool(_kIsHighContrast) ?? false,
      'fontScale': prefs.getDouble(_kFontScale) ?? 1.0,
      'themeMode': prefs.getString(_kThemeMode) ?? 'dark',
      'hasSeenPermissionsPrompt':
          prefs.getBool(_kHasSeenPermissionsPrompt) ?? false,
      'hasSeenLocationPrompt': prefs.getBool(_kHasSeenLocationPrompt) ?? false,
      'hasSeenNotificationPermissionPrompt':
          prefs.getBool(_kHasSeenNotificationPermissionPrompt) ?? false,
      'notificationsEnabled': prefs.getBool(_kNotificationsEnabled) ?? true,
    };
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_kLanguage) ?? 'en';
    _isHighContrast = prefs.getBool(_kIsHighContrast) ?? false;
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _hasCompletedOnboarding = prefs.getBool(_kHasCompletedOnboarding) ?? false;
    _hasSeenPermissionsPrompt =
        prefs.getBool(_kHasSeenPermissionsPrompt) ?? false;
    _hasSeenLocationPrompt = prefs.getBool(_kHasSeenLocationPrompt) ?? false;
    _themeMode = prefs.getString(_kThemeMode) ?? 'dark';
    _hasSeenNotificationPermissionPrompt =
        prefs.getBool(_kHasSeenNotificationPermissionPrompt) ?? false;
    _notificationsEnabled = prefs.getBool(_kNotificationsEnabled) ?? true;
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

  Future<void> setHasSeenNotificationPermissionPrompt(bool value) async {
    if (_hasSeenNotificationPermissionPrompt != value) {
      _hasSeenNotificationPermissionPrompt = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasSeenNotificationPermissionPrompt, value);
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled != value) {
      _notificationsEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotificationsEnabled, value);
      notifyListeners();
    }
  }
}
