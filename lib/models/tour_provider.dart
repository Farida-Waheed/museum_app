import 'dart:async';

import 'package:flutter/material.dart';
import '../core/notifications/notification_trigger_service.dart';
import '../core/notifications/notification_models.dart';
import '../core/notifications/notification_service.dart';
import '../core/notifications/notification_types.dart';
import '../app/router.dart';
import '../widgets/dialogs/branded_permission_dialog.dart';
import '../models/user_preferences.dart';
import 'tour_session.dart';
import 'package:provider/provider.dart';
import '../services/tour_session_repository.dart';

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

enum RobotConnectionState { disconnected, connecting, connected }

enum TourLifecycleState { notStarted, active, paused, completed }

enum FollowModeState { off, on }

enum ProximityState { near, medium, far }

class TourProvider with ChangeNotifier {
  final TourSessionRepository _tourSessionRepository;
  StreamSubscription<TourSession?>? _tourSessionSubscription;

  TourProvider({TourSessionRepository? tourSessionRepository})
    : _tourSessionRepository =
          tourSessionRepository ?? TourSessionRepository() {
    // Don't auto-connect anymore. Connection happens via AppSessionProvider
    // when user explicitly starts a tour after viewing EntryModeScreen.
    // Initialize state as disconnected and not started.
    _connectionState = RobotConnectionState.disconnected;
    _tourLifecycleState = TourLifecycleState.notStarted;
  }

  String? _currentExhibitId;
  String? _activeSessionId;
  String? _connectedRobotId;
  String? _restoredUserId;
  bool _isRestoringSession = false;
  double _progress = 0.0;
  final List<String> _visitedExhibitIds = [];
  final List<String> _selectedExhibitIds = [];

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
  String? get activeSessionId => _activeSessionId;
  String? get connectedRobotId => _connectedRobotId;
  String? get nextExhibitId => _nextExhibitId;
  double get progress => _progress;
  List<String> get visitedExhibitIds => _visitedExhibitIds;
  List<String> get selectedExhibitIds => List.unmodifiable(_selectedExhibitIds);
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
        return lang == 'ar'
            ? 'جارٍ الاتصال بحوروس...'
            : 'Connecting to Horus-Bot...';
      case RobotConnectionState.connected:
        return lang == 'ar' ? 'متصل بحوروس' : 'Connected to Horus-Bot';
    }
  }

  String getTourStateText(String lang) {
    switch (_tourLifecycleState) {
      case TourLifecycleState.notStarted:
        return lang == 'ar'
            ? 'حوروس جاهز للإرشاد'
            : 'Horus-Bot is ready to guide';
      case TourLifecycleState.active:
        return lang == 'ar' ? 'حوروس يوجه الجولة' : 'Horus-Bot is guiding';
      case TourLifecycleState.paused:
        return lang == 'ar' ? 'تم إيقاف حوروس مؤقتاً' : 'Horus-Bot paused';
      case TourLifecycleState.completed:
        return lang == 'ar'
            ? 'أنهى حوروس الجولة'
            : 'Horus-Bot finished the tour';
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
        return lang == 'ar' ? 'أنت قريب من حوروس' : 'You are near Horus-Bot';
      case ProximityState.medium:
        return lang == 'ar'
            ? 'أنت على بُعد متوسط من الدليل'
            : 'You are a short distance from the guide';
      case ProximityState.far:
        final distanceText = lang == 'ar'
            ? 'أنت بعيد عن الدليل'
            : 'You are far from the guide';
        return '$distanceText • ${_distanceMeters.toStringAsFixed(0)} ${lang == 'ar' ? 'م' : 'm'}';
    }
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
    } else if (state == RobotConnectionState.connected &&
        _robotState == RobotState.disconnected) {
      setRobotState(
        RobotState.idle,
        msgEn: 'Connected to Horus-Bot',
        msgAr: 'تم الاتصال بحوروس',
      );
    }
    notifyListeners();
  }

  void preparePairedRobotTour({
    required String robotId,
    required String sessionId,
    required List<String> selectedExhibitIds,
    String? nextExhibitId,
  }) {
    _connectedRobotId = robotId;
    _activeSessionId = sessionId;
    _selectedExhibitIds
      ..clear()
      ..addAll(selectedExhibitIds);
    _nextExhibitId = nextExhibitId;
    _connectionState = RobotConnectionState.connected;
    _tourLifecycleState = TourLifecycleState.notStarted;
    _listenToActiveTourSession();
    setRobotState(
      RobotState.waiting,
      msgEn: 'Horus-Bot is paired and waiting',
      msgAr: 'Horus-Bot جاهز وينتظر',
    );
    notifyListeners();
  }

  Future<TourSession?> restoreActiveSessionForUser(String userId) async {
    if (userId.isEmpty) return null;
    if (_isRestoringSession) return null;
    if (_restoredUserId == userId &&
        _activeSessionId != null &&
        _tourLifecycleState != TourLifecycleState.completed) {
      return null;
    }

    _isRestoringSession = true;
    try {
      final session = await _tourSessionRepository.findLatestRestorableSession(
        userId,
      );
      _restoredUserId = userId;
      if (session == null) return null;
      _applyTourSession(session);
      _listenToActiveTourSession();
      return session;
    } finally {
      _isRestoringSession = false;
    }
  }

  void _listenToActiveTourSession() {
    final sessionId = _activeSessionId;
    if (sessionId == null || sessionId.isEmpty) return;
    _tourSessionSubscription?.cancel();
    _tourSessionSubscription = _tourSessionRepository
        .watchSession(sessionId)
        .listen((tourSession) {
          if (tourSession == null) return;
          _applyTourSession(tourSession);
        });
  }

  void _applyTourSession(TourSession session) {
    _activeSessionId = session.sessionId;
    _connectedRobotId = session.robotId;
    _currentExhibitId = session.currentExhibitId;
    _nextExhibitId = session.nextExhibitId;
    _selectedExhibitIds
      ..clear()
      ..addAll(session.selectedExhibitIds);
    _visitedExhibitIds
      ..clear()
      ..addAll(session.visitedExhibitIds);
    _progress = _selectedExhibitIds.isEmpty
        ? 0
        : (_visitedExhibitIds.length / _selectedExhibitIds.length).clamp(
            0.0,
            1.0,
          );
    if (session.userDistanceFromRobot != null) {
      updateDistanceMeters(session.userDistanceFromRobot!);
    }

    _connectionState =
        session.status == 'completed' || session.status == 'cancelled'
        ? RobotConnectionState.disconnected
        : RobotConnectionState.connected;
    _tourLifecycleState = _tourLifecycleFromSession(session.status);
    _robotState = _robotStateFromSession(session.robotState);
    notifyListeners();
  }

  TourLifecycleState _tourLifecycleFromSession(String status) {
    switch (status) {
      case 'active':
        return TourLifecycleState.active;
      case 'paused':
        return TourLifecycleState.paused;
      case 'completed':
        _stopTourSessionListener();
        return TourLifecycleState.completed;
      case 'cancelled':
        _stopTourSessionListener();
        return TourLifecycleState.completed;
      case 'ready':
      default:
        return TourLifecycleState.notStarted;
    }
  }

  RobotState _robotStateFromSession(String robotState) {
    switch (robotState) {
      case 'moving':
        return RobotState.moving;
      case 'speaking':
        return RobotState.speaking;
      case 'error':
        return RobotState.disconnected;
      case 'waiting':
      default:
        return RobotState.waiting;
    }
  }

  void _stopTourSessionListener() {
    _tourSessionSubscription?.cancel();
    _tourSessionSubscription = null;
  }

  void setTourLifecycleState(
    TourLifecycleState state, {
    BuildContext? context,
  }) {
    _tourLifecycleState = state;
    if (_activeSessionId != null) {
      notifyListeners();
      return;
    }
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
          );
        }
      });
    } else if (state == TourLifecycleState.paused) {
      setRobotState(
        RobotState.waiting,
        msgEn: 'Horus-Bot paused. Resume when ready',
        msgAr: 'تم إيقاف الجولة مؤقتاً. استأنف عندما تكون جاهزاً',
        context: context,
      );
    } else if (state == TourLifecycleState.completed) {
      setRobotState(
        RobotState.idle,
        msgEn: 'Horus-Bot completed the tour. Great job!',
        msgAr: 'اكتملت الجولة. عمل رائع!',
        context: context,
      );
    }
    notifyListeners();
  }

  void setFollowMode(FollowModeState mode, {BuildContext? context}) {
    _followMode = mode;
    // Notification system removed during cleanup
    notifyListeners();
  }

  void updateDistanceMeters(double meters, {BuildContext? context}) {
    _distanceMeters = meters;
    final newState = meters < 5
        ? ProximityState.near
        : meters <= 15
        ? ProximityState.medium
        : ProximityState.far;
    _proximityState = newState;
    // Notification system removed during cleanup
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
      NotificationService().showNotification(
        ImmediateNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          type: NotificationType.mapHelpReminder,
          title: 'Find Horus-Bot',
          body: 'The map is centering on the robot so you can recover quickly.',
          priority: NotificationPriority.medium,
          category: NotificationCategory.guideReminders,
          payload: NotificationPayload(
            type: NotificationType.mapHelpReminder,
            targetRoute: AppRoutes.map,
          ),
        ),
      );
    }
  }

  void startTour({
    BuildContext? context,
    String? initialExhibitId,
    String? nextExhibitId,
  }) {
    if (_tourLifecycleState == TourLifecycleState.active) return;
    if (initialExhibitId != null) {
      _currentExhibitId = initialExhibitId;
      if (!_visitedExhibitIds.contains(initialExhibitId)) {
        _visitedExhibitIds.add(initialExhibitId);
      }
    }
    if (nextExhibitId != null) {
      _nextExhibitId = nextExhibitId;
    }
    setTourLifecycleState(TourLifecycleState.active, context: context);
    setConnectionState(RobotConnectionState.connected);
  }

  void pauseTour({BuildContext? context}) {
    if (_tourLifecycleState != TourLifecycleState.active) return;
    setTourLifecycleState(TourLifecycleState.paused, context: context);
  }

  void resumeTour({BuildContext? context}) {
    if (_tourLifecycleState != TourLifecycleState.paused) return;
    setTourLifecycleState(TourLifecycleState.active, context: context);
    if (_activeSessionId != null) return;
    setRobotState(
      RobotState.moving,
      msgEn: 'Resuming the tour with Horus-Bot',
      msgAr: 'استئناف الجولة مع حوروس',
      context: context,
    );
  }

  void completeTour({BuildContext? context}) {
    setTourLifecycleState(TourLifecycleState.completed, context: context);
    if (_activeSessionId != null) {
      _stopTourSessionListener();
      _connectionState = RobotConnectionState.disconnected;
      notifyListeners();
      return;
    }
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
    NotificationService().showNotification(
      ImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: NotificationType.tourStarted,
        title: "Tour Starting",
        body: "Your guided tour is starting. Follow Horus-Bot.",
        priority: NotificationPriority.high,
        category: NotificationCategory.tourUpdates,
        payload: NotificationPayload(
          type: NotificationType.tourStarted,
          targetRoute: AppRoutes.liveTour,
        ),
      ),
    );

    // System notification (tray)
    NotificationTriggerService().triggerTourStarted(
      title: "Tour Starting",
      body: "Your guided tour is starting. Follow Horus-Bot.",
    );
  }

  void _triggerNextExhibitNotification(BuildContext context) {
    NotificationService().showNotification(
      ImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: NotificationType.nextExhibit,
        title: "Next Exhibit Ahead",
        body: "You are approaching the next exhibit.",
        priority: NotificationPriority.high,
        category: NotificationCategory.exhibitReminders,
        payload: NotificationPayload(
          type: NotificationType.nextExhibit,
          targetRoute: AppRoutes.liveTour,
        ),
      ),
    );

    // System notification
    NotificationTriggerService().triggerNextExhibit(
      title: "Next Exhibit Ahead",
      body: "You are approaching the next exhibit.",
    );
  }

  void triggerRobotNearby(BuildContext context) {
    NotificationService().showNotification(
      ImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: NotificationType.horusNearby,
        title: "Horus-Bot is nearby",
        body: "Follow the robot to continue your tour.",
        priority: NotificationPriority.high,
        category: NotificationCategory.guideReminders,
        payload: NotificationPayload(
          type: NotificationType.horusNearby,
          targetRoute: AppRoutes.map,
        ),
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
    NotificationService().showNotification(
      ImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: NotificationType.quizAvailable,
        title: "Test What You Learned",
        body:
            "Horus-Bot prepared a short quiz for this exhibit. Would you like to take it now or save it until after the tour?",
        priority: NotificationPriority.medium,
        category: NotificationCategory.quizReminders,
        payload: NotificationPayload(
          type: NotificationType.quizAvailable,
          targetRoute: AppRoutes.quiz,
          exhibitId: exhibitId,
          customData: {
            'location': location,
            'topics': topics ?? ["History", "Symbolism", "Fun Facts"],
          },
        ),
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
    NotificationService().showNotification(
      ImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: NotificationType.didYouKnow,
        title: title,
        body: message,
        priority: NotificationPriority.low,
        category: NotificationCategory.museumNews,
        payload: NotificationPayload(type: NotificationType.didYouKnow),
      ),
    );

    // System notification
    NotificationTriggerService().triggerDidYouKnow(title: title, body: message);
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

  @override
  void dispose() {
    _stopTourSessionListener();
    super.dispose();
  }
}
