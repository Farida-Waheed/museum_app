import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  static const String _kLanguage = 'language';
  static const String _kIsHighContrast = 'isHighContrast';
  static const String _kFontScale = 'fontScale';
  static const String _kHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _kHasSeenLocationPermissionDialog = 'hasSeenLocationPermissionDialog';
  static const String _kThemeMode = 'themeMode';

  // Museum Experience
  static const String _kAutoFollowRobot = 'autoFollowRobot';
  static const String _kShowNearbyExhibits = 'showNearbyExhibits';
  static const String _kEnableExhibitExplanations = 'enableExhibitExplanations';
  static const String _kEnableVoiceInteraction = 'enableVoiceInteraction';

  // Additional Accessibility
  static const String _kAudioGuideMode = 'audioGuideMode';
  static const String _kReduceAnimations = 'reduceAnimations';
  static const String _kSimpleMode = 'simpleMode';

  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _hasCompletedOnboarding = false;
  bool _hasSeenLocationPermissionDialog = false;
  String _themeMode = 'dark';

  bool _autoFollowRobot = false;
  bool _showNearbyExhibits = true;
  bool _enableExhibitExplanations = true;
  bool _enableVoiceInteraction = false;

  bool _audioGuideMode = false;
  bool _reduceAnimations = false;
  bool _simpleMode = false;

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSeenLocationPrompt => _hasSeenLocationPermissionDialog;
  String get themeMode => _themeMode;

  bool get autoFollowRobot => _autoFollowRobot;
  bool get showNearbyExhibits => _showNearbyExhibits;
  bool get enableExhibitExplanations => _enableExhibitExplanations;
  bool get enableVoiceInteraction => _enableVoiceInteraction;

  bool get audioGuideMode => _audioGuideMode;
  bool get reduceAnimations => _reduceAnimations;
  bool get simpleMode => _simpleMode;

  UserPreferencesModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_kLanguage) ?? 'en';
    _isHighContrast = prefs.getBool(_kIsHighContrast) ?? false;
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _hasCompletedOnboarding = prefs.getBool(_kHasCompletedOnboarding) ?? false;
    _hasSeenLocationPermissionDialog = prefs.getBool(_kHasSeenLocationPermissionDialog) ?? false;
    _themeMode = prefs.getString(_kThemeMode) ?? 'dark';

    _autoFollowRobot = prefs.getBool(_kAutoFollowRobot) ?? false;
    _showNearbyExhibits = prefs.getBool(_kShowNearbyExhibits) ?? true;
    _enableExhibitExplanations = prefs.getBool(_kEnableExhibitExplanations) ?? true;
    _enableVoiceInteraction = prefs.getBool(_kEnableVoiceInteraction) ?? false;

    _audioGuideMode = prefs.getBool(_kAudioGuideMode) ?? false;
    _reduceAnimations = prefs.getBool(_kReduceAnimations) ?? false;
    _simpleMode = prefs.getBool(_kSimpleMode) ?? false;

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
    if (_hasSeenLocationPermissionDialog != value) {
      _hasSeenLocationPermissionDialog = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasSeenLocationPermissionDialog, value);
      notifyListeners();
    }
  }

  Future<void> setAutoFollowRobot(bool value) async {
    _autoFollowRobot = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoFollowRobot, value);
    notifyListeners();
  }

  Future<void> setShowNearbyExhibits(bool value) async {
    _showNearbyExhibits = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowNearbyExhibits, value);
    notifyListeners();
  }

  Future<void> setEnableExhibitExplanations(bool value) async {
    _enableExhibitExplanations = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnableExhibitExplanations, value);
    notifyListeners();
  }

  Future<void> setEnableVoiceInteraction(bool value) async {
    _enableVoiceInteraction = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnableVoiceInteraction, value);
    notifyListeners();
  }

  Future<void> setAudioGuideMode(bool value) async {
    _audioGuideMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAudioGuideMode, value);
    notifyListeners();
  }

  Future<void> setReduceAnimations(bool value) async {
    _reduceAnimations = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceAnimations, value);
    notifyListeners();
  }

  Future<void> setSimpleMode(bool value) async {
    _simpleMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSimpleMode, value);
    notifyListeners();
  }
}
