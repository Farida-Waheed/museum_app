import 'package:flutter/material.dart';

class TourProvider with ChangeNotifier {
  String? _currentExhibitId;
  double _progress = 0.0;
  final List<String> _visitedExhibitIds = [];

  String? get currentExhibitId => _currentExhibitId;
  double get progress => _progress;
  List<String> get visitedExhibitIds => _visitedExhibitIds;

  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setCurrentExhibit(String? id) {
    _currentExhibitId = id;
    if (id != null && !_visitedExhibitIds.contains(id)) {
      _visitedExhibitIds.add(id);
    }
    notifyListeners();
  }

  bool hasVisited(String id) => _visitedExhibitIds.contains(id);
}
