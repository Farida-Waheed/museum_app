import 'package:flutter/material.dart';
import '../core/notifications/notification_trigger_service.dart';
import '../core/services/notification_service.dart';
import 'app_notification.dart';
import '../app/router.dart';
import '../widgets/dialogs/branded_permission_dialog.dart';
import '../models/user_preferences.dart';
import 'package:provider/provider.dart';

enum RobotState {
  idle,
  moving,
  approaching,
  waiting,
  speaking,
  listening,
  thinking,
  disconnected,
  syncing,
}

enum RobotConnectionState {
  disconnected,
  connecting,
  connected,
}

enum TourLifecycleState {
  notStarted,
  active,
  paused,
  completed,
}

enum FollowModeState {
  off,
  on,
}

enum ProximityState {
  near,
  medium,
  far,
}

class TourProvider with ChangeNotifier {
  String? _currentExhibitId;
  double _progress = 0.0;
  final List<String> _visitedExhibitIds = [];

  // Quiz state
  final Map<String, int> _quizScores = {}; // exhibitId -> score
  final Set<String> _skippedQuizzes = {}; // exhibitIds
  final Set<String> _pendingQuizzes = {}; // exhibitIds for "Later"

  // New state fields
  RobotState _robotState = RobotState.idle;
  RobotConnectionState _connectionState = RobotConnectionState.disconnected;
  TourLifecycleState _tourLifecycleState = TourLifecycleState.notStarted;
  FollowModeState _followMode = FollowModeState.off;
  ProximityState _proximityState = ProximityState.medium;
  double _distanceMeters = 10.0;
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
  RobotConnectionState get connectionState => _connectionState;
  TourLifecycleState get tourLifecycleState => _tourLifecycleState;
  FollowModeState get followMode => _followMode;
  ProximityState get proximityState => _proximityState;
  double get distanceMeters => _distanceMeters;
  double get estimatedTimeToNext => _estimatedTimeToNext;

  Map<String, int> get quizScores => _quizScores;
  Set<String> get skippedQuizzes => _skippedQuizzes;
  Set<String> get pendingQuizzes => _pendingQuizzes;

  String getStatusMessage(String lang) {
    if (_connectionState != RobotConnectionState.connected) {
      return getConnectionText(lang);
    }
    return lang == 'ar' ? _statusMessageAr : _statusMessageEn;
  }

  String getConnectionText(String lang) {
    switch (_connectionState) {
      case RobotConnectionState.disconnected:
        return lang == 'ar' ? 'فقد الاتصال بحوروس' : 'Connection lost';
      case RobotConnectionState.connecting:
        return lang == 'ar' ? 'جارٍ الاتصال بحوروس...' : 'Connecting to Horus-Bot...';
      case RobotConnectionState.connected:
        return lang == 'ar' ? 'متصل بحوروس' : 'Connected to Horus-Bot';
    }
  }

  String getTourStateText(String lang) {
    switch (_tourLifecycleState) {
      case TourLifecycleState.notStarted:
        return lang == 'ar' ? 'الجولة جاهزة للبدء' : 'Tour ready to start';
      case TourLifecycleState.active:
        return lang == 'ar' ? 'الجولة الجارية' : 'Tour active';
      case TourLifecycleState.paused:
        return lang == 'ar' ? 'تم إيقاف الجولة مؤقتاً' : 'Tour paused';
      case TourLifecycleState.completed:
        return lang == 'ar' ? 'اكتملت الجولة' : 'Tour completed';
    }
  }

  String getFollowModeText(String lang) {
    return _followMode == FollowModeState.on
        ? (lang == 'ar' ? 'التتبع قيد التشغيل' : 'Follow mode on')
        : (lang == 'ar' ? 'التتبع متوقف' : 'Follow mode off');
  }

  String getProximityText(String lang) {
    if (_connectionState != RobotConnectionState.connected) {
      return getConnectionText(lang);
    }
    switch (_proximityState) {
      case ProximityState.near:
        return lang == 'ar'
            ? 'أنت قريب من حوروس' : 'You are near Horus-Bot';
      case ProximityState.medium:
        return lang == 'ar'
            ? 'أنت على بُعد متوسط من الدليل' : 'You are a short distance from the guide';
      case ProximityState.far:
        final distanceText = lang == 'ar'
            ? 'أنت بعيد عن الدليل' : 'You are far from the guide';
        return '$distanceText • ${_distanceMeters.toStringAsFixed(0)} ${lang == 'ar' ? 'م' : 'm'}';
    }
  }

  TourProvider() {
    _initRobotConnection();
  }

  void _initRobotConnection() async {
    setConnectionState(RobotConnectionState.connecting);
    await Future.delayed(const Duration(seconds: 2));
    setConnectionState(RobotConnectionState.connected);
    setRobotState(
      RobotState.idle,
      msgEn: 'Connected to Horus-Bot',
      msgAr: 'تم الاتصال بحوروس',
    );
    updateDistanceMeters(8.0);
  }

  void setConnectionState(RobotConnectionState state, {BuildContext? context}) {
    _connectionState = state;
    if (state == RobotConnectionState.disconnected) {
      setRobotState(
        RobotState.disconnected,
        msgEn: 'Connection lost',
        msgAr: 'فقد الاتصال',
      );
    } else if (state == RobotConnectionState.connecting) {
      setRobotState(
        RobotState.syncing,
        msgEn: 'Connecting to Horus-Bot...',
        msgAr: 'جارٍ الاتصال بحوروس...',
      );
    } else if (state == RobotConnectionState.connected && _robotState == RobotState.disconnected) {
      setRobotState(
        RobotState.idle,
        msgEn: 'Connected to Horus-Bot',
        msgAr: 'تم الاتصال بحوروس',
      );
    }
    notifyListeners();
  }

  void setTourLifecycleState(TourLifecycleState state, {BuildContext? context}) {
    _tourLifecycleState = state;
    if (state == TourLifecycleState.active) {
      setRobotState(
        RobotState.syncing,
        msgEn: 'Preparing your tour',
        msgAr: 'جارٍ تجهيز الجولة',
        context: context,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (_tourLifecycleState == TourLifecycleState.active) {
          setRobotState(
            RobotState.moving,
            msgEn: 'Horus is guiding you now',
            msgAr: 'حوروس يوجهك الآن',
            context: context,
          );
        }
      });
    } else if (state == TourLifecycleState.paused) {
      setRobotState(
        RobotState.waiting,
        msgEn: 'Tour paused. Resume when ready',
        msgAr: 'تم إيقاف الجولة مؤقتاً. استأنف عندما تكون جاهزاً',
        context: context,
      );
    } else if (state == TourLifecycleState.completed) {
      setRobotState(
        RobotState.idle,
        msgEn: 'Tour completed. Great job!',
        msgAr: 'اكتملت الجولة. عمل رائع!',
        context: context,
      );
    }
    notifyListeners();
  }

  void setFollowMode(FollowModeState mode, {BuildContext? context}) {
    _followMode = mode;
    if (mode == FollowModeState.on && context != null) {
      NotificationService.show(
        context,
        AppNotification(
          id: 'follow_mode_on_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Follow mode enabled',
          message: 'The map will now keep Horus-Bot in view.',
          type: AppNotificationType.smartTip,
          priority: AppNotificationPriority.medium,
          icon: Icons.navigation_rounded,
        ),
      );
    }
    notifyListeners();
  }

  void updateDistanceMeters(double meters, {BuildContext? context}) {
    _distanceMeters = meters;
    final newState = meters < 5
        ? ProximityState.near
        : meters <= 15
            ? ProximityState.medium
            : ProximityState.far;
    final previousState = _proximityState;
    _proximityState = newState;
    if (context != null && previousState != newState) {
      if (newState == ProximityState.far) {
        NotificationService.show(
          context,
          AppNotification(
            id: 'too_far_${DateTime.now().millisecondsSinceEpoch}',
            title: 'You are too far from Horus-Bot',
            message: 'Open the map and follow the robot to recover.',
            type: AppNotificationType.tourOffRoute,
            priority: AppNotificationPriority.high,
            icon: Icons.warning_amber_rounded,
          ),
        );
      } else if (newState == ProximityState.near) {
        NotificationService.show(
          context,
          AppNotification(
            id: 'robot_near_${DateTime.now().millisecondsSinceEpoch}',
            title: 'You are close to Horus-Bot',
            message: 'Great! Stay on the tour path to keep up with the guide.',
            type: AppNotificationType.tourRobotNearby,
            priority: AppNotificationPriority.medium,
            icon: Icons.check_circle_outline,
          ),
        );
      }
    }
    notifyListeners();
  }

  void requestRecovery(BuildContext context) {
    setFollowMode(FollowModeState.on, context: context);
    setRobotState(
      RobotState.approaching,
      msgEn: 'Finding Horus-Bot...',
      msgAr: 'جاري العثور على حوروس...',
      context: context,
    );
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != AppRoutes.map) {
      Navigator.pushNamed(context, AppRoutes.map);
    } else {
      NotificationService.show(
        context,
        AppNotification(
          id: 'recover_map_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Find Horus-Bot',
          message: 'The map is centering on the robot so you can recover quickly.',
          type: AppNotificationType.tourRobotNearby,
          priority: AppNotificationPriority.medium,
          icon: Icons.my_location_rounded,
        ),
      );
    }
  }

  void startTour({BuildContext? context}) {
    if (_tourLifecycleState == TourLifecycleState.active) return;
    setTourLifecycleState(TourLifecycleState.active, context: context);
    setConnectionState(RobotConnectionState.connected);
    if (_currentExhibitId == null) {
      // Keep current exhibit logic in the screen if needed.
    }
  }

  void pauseTour({BuildContext? context}) {
    if (_tourLifecycleState != TourLifecycleState.active) return;
    setTourLifecycleState(TourLifecycleState.paused, context: context);
  }

  void resumeTour({BuildContext? context}) {
    if (_tourLifecycleState != TourLifecycleState.paused) return;
    setTourLifecycleState(TourLifecycleState.active, context: context);
    setRobotState(
      RobotState.moving,
      msgEn: 'Resuming the tour with Horus-Bot',
      msgAr: 'استئناف الجولة مع حوروس',
      context: context,
    );
  }

  void completeTour({BuildContext? context}) {
    setTourLifecycleState(TourLifecycleState.completed, context: context);
    setRobotState(
      RobotState.idle,
      msgEn: 'Tour completed. See the summary below.',
      msgAr: 'اكتملت الجولة. راجع الملخص أدناه.',
      context: context,
    );
  }

  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setRobotState(
    RobotState state, {
    String? msgEn,
    String? msgAr,
    BuildContext? context,
  }) {
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
    // In-app notification (banner)
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

    // System notification (tray)
    NotificationTriggerService().triggerTourStarted(
      title: "Tour Starting",
      body: "Your guided tour is starting. Follow Horus-Bot.",
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

    // System notification
    NotificationTriggerService().triggerNextExhibit(
      title: "Next Exhibit Ahead",
      body: "You are approaching the next exhibit.",
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

    // System notification
    NotificationTriggerService().triggerHorusNearby(
      title: "Horus-Bot is nearby",
      body: "Follow the robot to continue your tour.",
    );
  }

  void triggerQuizAvailable(
    BuildContext context,
    String location, {
    String? exhibitId,
    List<String>? topics,
  }) {
    NotificationService.show(
      context,
      AppNotification(
        id: 'quiz_${exhibitId ?? DateTime.now().millisecondsSinceEpoch}',
        title: "Test What You Learned",
        message:
            "Horus-Bot prepared a short quiz for this exhibit. Would you like to take it now or save it until after the tour?",
        type: AppNotificationType.quizAvailable,
        priority: AppNotificationPriority.medium,
        icon: Icons.quiz_rounded,
        data: {
          'exhibitId': exhibitId,
          'location': location,
          'topics': topics ?? ["History", "Symbolism", "Fun Facts"],
        },
        onTap: () {
          // Logic to navigate to quiz screen
          print("Navigating to quiz for $location");
        },
      ),
    );

    // System notification
    NotificationTriggerService().triggerQuizAvailable(
      title: "Test What You Learned",
      body: "Horus-Bot prepared a short quiz for this exhibit.",
      exhibitId: exhibitId,
    );
  }

  void deferQuiz(String exhibitId) {
    _pendingQuizzes.add(exhibitId);
    _skippedQuizzes.remove(exhibitId);
    notifyListeners();
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

    // System notification
    NotificationTriggerService().triggerDidYouKnow(
      title: title,
      body: message,
    );
  }

  void setCurrentExhibit(String? id, {BuildContext? context}) {
    _currentExhibitId = id;
    if (id != null && !_visitedExhibitIds.contains(id)) {
      _visitedExhibitIds.add(id);
      if (context != null) {
        _showQuizPrompt(context, id);
      }
    }
    notifyListeners();
  }

  void _showQuizPrompt(BuildContext context, String exhibitId) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => BrandedPermissionDialog(
        icon: Icons.quiz_outlined,
        title: "Quiz Available",
        description: "Would you like to take a quick quiz for this exhibit?",
        onAllow: () {
          Navigator.pop(context);
          // Navigate to quiz
        },
        onDeny: () {
          Navigator.pop(context);
          postponeQuiz(exhibitId);
        },
        isHighContrast: prefs.isHighContrast,
      ),
    );
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

  void postponeQuiz(String exhibitId) {
    if (!_quizScores.containsKey(exhibitId) &&
        !_skippedQuizzes.contains(exhibitId)) {
      _pendingQuizzes.add(exhibitId);
      notifyListeners();
    }
  }
}
