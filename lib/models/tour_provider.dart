import 'package:flutter/material.dart';

enum RobotState {
  idle,
  moving,
  approaching,
  speaking,
  listening,
  thinking,
  disconnected,
  syncing,
}

class TourProvider with ChangeNotifier {
  String? _currentExhibitId;
  double _progress = 0.0;
  final List<String> _visitedExhibitIds = [];

  // New state fields
  RobotState _robotState = RobotState.idle;
  String _statusMessageEn = "Horus-Bot is ready";
  String _statusMessageAr = "حوروس جاهز";

  // Navigation info
  String? _nextExhibitId;
  double _estimatedTimeToNext = 0; // in seconds

  String? get currentExhibitId => _currentExhibitId;
  String? get nextExhibitId => _nextExhibitId;
  double get progress => _progress;
  List<String> get visitedExhibitIds => _visitedExhibitIds;
  RobotState get robotState => _robotState;
  double get estimatedTimeToNext => _estimatedTimeToNext;

  String getStatusMessage(String lang) => lang == 'ar' ? _statusMessageAr : _statusMessageEn;

  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setRobotState(RobotState state, {String? msgEn, String? msgAr}) {
    _robotState = state;
    if (msgEn != null) _statusMessageEn = msgEn;
    if (msgAr != null) _statusMessageAr = msgAr;
    notifyListeners();
  }

  void setCurrentExhibit(String? id) {
    _currentExhibitId = id;
    if (id != null && !_visitedExhibitIds.contains(id)) {
      _visitedExhibitIds.add(id);
    }
    notifyListeners();
  }

  void setNextDestination(String? id, double seconds) {
    _nextExhibitId = id;
    _estimatedTimeToNext = seconds;
    notifyListeners();
  }

  bool hasVisited(String id) => _visitedExhibitIds.contains(id);
}
