import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import 'app_notification.dart';

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

  // Quiz state
  final Map<String, int> _quizScores = {}; // exhibitId -> score
  final Set<String> _skippedQuizzes = {}; // exhibitIds

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

  Map<String, int> get quizScores => _quizScores;
  Set<String> get skippedQuizzes => _skippedQuizzes;

  String getStatusMessage(String lang) => lang == 'ar' ? _statusMessageAr : _statusMessageEn;

  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setRobotState(RobotState state, {String? msgEn, String? msgAr, BuildContext? context}) {
    final oldState = _robotState;
    _robotState = state;
    if (msgEn != null) _statusMessageEn = msgEn;
    if (msgAr != null) _statusMessageAr = msgAr;

    // Trigger notifications if context is provided
    if (context != null && oldState != state) {
      if (state == RobotState.syncing && oldState == RobotState.idle) {
        _triggerTourStartNotification(context);
      } else if (state == RobotState.approaching) {
        _triggerNextExhibitNotification(context);
      }
    }

    notifyListeners();
  }

  void _triggerTourStartNotification(BuildContext context) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'tour_start_${DateTime.now().millisecondsSinceEpoch}',
        title: "Tour Starting",
        message: "Your guided tour is starting. Follow Horus-Bot.",
        type: AppNotificationType.tourStart,
        priority: AppNotificationPriority.high,
        icon: Icons.play_circle_filled_rounded,
      ),
    );
  }

  void _triggerNextExhibitNotification(BuildContext context) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'next_exhibit_${DateTime.now().millisecondsSinceEpoch}',
        title: "Next Exhibit Ahead",
        message: "You are approaching the next exhibit.",
        type: AppNotificationType.nextExhibit,
        priority: AppNotificationPriority.high,
        icon: Icons.location_on_rounded,
      ),
    );
  }

  void triggerRobotNearby(BuildContext context) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'robot_nearby_${DateTime.now().millisecondsSinceEpoch}',
        title: "Horus-Bot is nearby",
        message: "Follow the robot to continue your tour.",
        type: AppNotificationType.robotNearby,
        priority: AppNotificationPriority.high,
        icon: Icons.smart_toy_rounded,
      ),
    );
  }

  void triggerQuizAvailable(BuildContext context, String location) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
        title: "Quiz Available",
        message: "Test what you learned about $location.",
        type: AppNotificationType.quizAvailable,
        priority: AppNotificationPriority.medium,
        icon: Icons.quiz_rounded,
        onTap: () {
          // Logic to navigate to quiz
          print("Navigating to quiz for $location");
        },
      ),
    );
  }

  void triggerSmartTip(BuildContext context, String title, String message) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        type: AppNotificationType.smartTip,
        priority: AppNotificationPriority.low,
        icon: Icons.lightbulb_outline_rounded,
      ),
    );
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

  void recordQuizResult(String exhibitId, int score) {
    _quizScores[exhibitId] = score;
    _skippedQuizzes.remove(exhibitId);
    notifyListeners();
  }

  void skipQuiz(String exhibitId) {
    if (!_quizScores.containsKey(exhibitId)) {
      _skippedQuizzes.add(exhibitId);
      notifyListeners();
    }
  }
}
