import 'package:flutter/material.dart';

class UserPreferencesModel extends ChangeNotifier {
  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _hasCompletedOnboarding = false;
  String themeMode = 'system';

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setThemeMode(String value) {
    themeMode = value;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    _isHighContrast = value;
    notifyListeners();
  }
  
  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }
  void setCompletedOnboarding(bool value) { // <<< NEW METHOD
    if (_hasCompletedOnboarding != value) {
      _hasCompletedOnboarding = value;
      notifyListeners();
    }
  }
}