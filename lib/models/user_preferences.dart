import 'package:flutter/material.dart';

class UserPreferencesModel extends ChangeNotifier {
  String _language = 'en';
  bool _isHighContrast = false;
  double _fontScale = 1.0;

  String get language => _language;
  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;

  void setLanguage(String lang) {
    _language = lang;
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
}