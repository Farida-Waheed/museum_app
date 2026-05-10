import 'dart:async';

import 'package:flutter/material.dart';
import 'quiz.dart';
import 'tour_session.dart';
import 'tour_memory.dart';
import 'tour_preferences.dart';
import '../services/tour_session_repository.dart';

/// App usage mode - where the user is in their journey
enum AppUsageMode {
  planning, // User is exploring app before museum visit
  visiting, // User is at/about to be at the museum
}

/// Authentication state
enum AuthState { guest, loggedOut, loggedIn }

/// Museum entry ticket state
enum MuseumTicketState { none, available, active, expired }

/// Robot tour ticket state
enum RobotTourTicketState { none, available, active, used, expired }

/// Robot connection state
enum RobotConnectionState { disconnected, connecting, connected, failed }

/// Tour lifecycle state
enum TourLifecycleState {
  notStarted,
  readyToStart,
  active,
  paused,
  completed,
  cancelled,
}

/// Follow mode state
enum FollowModeState { off, on }

/// Proximity state
enum ProximityState { unknown, near, medium, far }

/// Robot activity state
enum RobotActivityState {
  unavailable,
  idle,
  waiting,
  moving,
  explaining,
  takingPhoto,
  nextStopReady,
}

/// Global app session provider
/// Single source of truth for user's current state in the app
class AppSessionProvider with ChangeNotifier {
  final TourSessionRepository _tourSessionRepository;
  StreamSubscription<TourSession?>? _tourSessionSubscription;

  AppSessionProvider({TourSessionRepository? tourSessionRepository})
    : _tourSessionRepository = tourSessionRepository ?? TourSessionRepository();

  // App usage mode
  AppUsageMode _appUsageMode = AppUsageMode.planning;

  // Authentication
  AuthState _authState = AuthState.guest;

  // Tickets
  MuseumTicketState _museumTicketState = MuseumTicketState.none;
  RobotTourTicketState _robotTourTicketState = RobotTourTicketState.none;

  // Robot connection
  RobotConnectionState _robotConnectionState =
      RobotConnectionState.disconnected;

  // Tour lifecycle
  TourLifecycleState _tourLifecycleState = TourLifecycleState.notStarted;

  // Tour preferences
  TourPreferences? _tourPreferences;

  // Follow mode
  FollowModeState _followMode = FollowModeState.off;

  // Proximity
  ProximityState _proximityState = ProximityState.unknown;
  double _distanceMeters = 0.0;

  // Robot activity
  RobotActivityState _robotActivityState = RobotActivityState.unavailable;

  // Current exhibit (used when in active tour)
  String? _currentExhibitId;
  String? _nextExhibitId;

  // Tour session ID for organizing memories
  String? _currentTourSessionId;
  String? _connectedRobotId;
  final List<String> _selectedExhibitIds = [];
  final List<String> _visitedExhibitIds = [];

  // Mock tour stops for demo
  final List<String> mockTourStops = [
    'Tutankhamun Gallery',
    'Royal Mummies Hall',
    'Ancient Tools Section',
    'Grand Statue Atrium',
  ];

  // Tour memories
  final List<TourMemory> _tourMemories = [];

  // Quiz / reward state
  final List<QuizResult> _quizResults = [];
  int _rewardPoints = 0;
  final List<String> _earnedBadges = [];

  // ========================
  // GETTERS
  // ========================

  AppUsageMode get appUsageMode => _appUsageMode;
  AuthState get authState => _authState;
  MuseumTicketState get museumTicketState => _museumTicketState;
  RobotTourTicketState get robotTourTicketState => _robotTourTicketState;
  RobotConnectionState get robotConnectionState => _robotConnectionState;
  TourLifecycleState get tourLifecycleState => _tourLifecycleState;
  FollowModeState get followMode => _followMode;
  ProximityState get proximityState => _proximityState;
  double get distanceMeters => _distanceMeters;
  RobotActivityState get robotActivityState => _robotActivityState;
  String? get currentExhibitId => _currentExhibitId;
  String? get nextExhibitId => _nextExhibitId;
  String? get currentTourSessionId => _currentTourSessionId;
  String? get activeSessionId => _currentTourSessionId;
  String? get connectedRobotId => _connectedRobotId;
  List<String> get selectedExhibitIds => List.unmodifiable(_selectedExhibitIds);
  List<String> get visitedExhibitIds => List.unmodifiable(_visitedExhibitIds);
  TourPreferences? get tourPreferences => _tourPreferences;
  List<TourMemory> get tourMemories => List.unmodifiable(_tourMemories);
  List<QuizResult> get quizResults => List.unmodifiable(_quizResults);
  int get rewardPoints => _rewardPoints;
  List<String> get earnedBadges => List.unmodifiable(_earnedBadges);

  bool get canTakeQuiz =>
      _tourLifecycleState == TourLifecycleState.active ||
      _tourLifecycleState == TourLifecycleState.completed ||
      _tourLifecycleState == TourLifecycleState.paused;

  // ========================
  // COMPUTED BOOLEAN GETTERS
  // ========================

  /// User has a valid museum entry ticket
  bool get hasMuseumEntryTicket =>
      _museumTicketState == MuseumTicketState.available ||
      _museumTicketState == MuseumTicketState.active;

  /// User has a valid robot tour ticket
  bool get hasRobotTourTicket =>
      _robotTourTicketState == RobotTourTicketState.available ||
      _robotTourTicketState == RobotTourTicketState.active;

  /// User can start a robot tour
  /// True only if they have both tickets or mock/demo mode is enabled
  bool get canStartRobotTour => hasMuseumEntryTicket && hasRobotTourTicket;

  /// Is the app waiting for robot connection to complete
  bool get isConnectingToRobot =>
      _robotConnectionState == RobotConnectionState.connecting;

  /// Robot is connected and ready
  bool get isRobotConnected =>
      _robotConnectionState == RobotConnectionState.connected;

  /// Tour is currently active with robot connected
  bool get isInActiveTour =>
      _tourLifecycleState == TourLifecycleState.active &&
      _robotConnectionState == RobotConnectionState.connected;

  /// Tour is paused
  bool get isTourPaused => _tourLifecycleState == TourLifecycleState.paused;

  bool get isTourCompleted =>
      _tourLifecycleState == TourLifecycleState.completed;

  bool get isTourReadyToStart =>
      _tourLifecycleState == TourLifecycleState.readyToStart &&
      _robotConnectionState == RobotConnectionState.connected;

  bool get hasActiveOrPausedTour =>
      _robotConnectionState == RobotConnectionState.connected &&
      (_tourLifecycleState == TourLifecycleState.active ||
          _tourLifecycleState == TourLifecycleState.paused);

  /// Should show robot on map
  /// Only show if connected and in active/paused tour
  bool get shouldShowRobotOnMap =>
      _robotConnectionState == RobotConnectionState.connected &&
      (_tourLifecycleState == TourLifecycleState.active ||
          _tourLifecycleState == TourLifecycleState.paused);

  /// Should show robot path on map
  /// Only show if connected, active tour, and follow mode is on
  bool get shouldShowRobotPath =>
      _robotConnectionState == RobotConnectionState.connected &&
      _tourLifecycleState == TourLifecycleState.active &&
      _followMode == FollowModeState.on;

  /// Should show follow controls (pause, skip, follow button)
  /// Only show if robot is connected and tour is active
  bool get shouldShowFollowControls =>
      _robotConnectionState == RobotConnectionState.connected &&
      _tourLifecycleState == TourLifecycleState.active;

  /// Should show current stop information
  /// Show if tour is active, paused, or completed
  bool get shouldShowCurrentStop =>
      _tourLifecycleState == TourLifecycleState.active ||
      _tourLifecycleState == TourLifecycleState.paused ||
      _tourLifecycleState == TourLifecycleState.completed;

  /// Should show Ask Guide button
  /// This is controlled per-screen via showChatButton parameter in AppMenuShell
  /// Default is false; enabled only on Map and Live Tour screens
  bool get shouldShowAskButton => false; // Per-screen control is preferred

  bool get hasTourPreferences => _tourPreferences != null;

  // ========================
  // SETTERS / STATE UPDATES
  // ========================

  void setAppUsageMode(AppUsageMode mode) {
    if (_appUsageMode != mode) {
      _appUsageMode = mode;
      notifyListeners();
    }
  }

  void setAuthState(AuthState state) {
    if (_authState != state) {
      _authState = state;
      notifyListeners();
    }
  }

  void setMuseumTicketState(MuseumTicketState state) {
    if (_museumTicketState != state) {
      _museumTicketState = state;
      notifyListeners();
    }
  }

  void setRobotTourTicketState(RobotTourTicketState state) {
    if (_robotTourTicketState != state) {
      _robotTourTicketState = state;
      notifyListeners();
    }
  }

  void setRobotConnectionState(RobotConnectionState state) {
    if (_robotConnectionState != state) {
      _robotConnectionState = state;
      notifyListeners();
    }
  }

  void startRobotConnection() {
    _appUsageMode = AppUsageMode.visiting;
    _robotConnectionState = RobotConnectionState.connecting;
    _tourLifecycleState = TourLifecycleState.readyToStart;
    notifyListeners();
  }

  void cancelRobotConnection() {
    _robotConnectionState = RobotConnectionState.disconnected;
    if (_tourLifecycleState == TourLifecycleState.readyToStart) {
      // preserve ready state when canceled before connection
    } else {
      _tourLifecycleState = TourLifecycleState.notStarted;
    }
    notifyListeners();
  }

  void completeRobotConnection({
    String? robotId,
    String? sessionId,
    String? nextExhibitId,
    List<String> selectedExhibitIds = const [],
  }) {
    _robotConnectionState = RobotConnectionState.connected;
    _tourLifecycleState = TourLifecycleState.readyToStart;
    _robotActivityState = RobotActivityState.waiting;
    _followMode = FollowModeState.on;
    _connectedRobotId = robotId ?? _connectedRobotId;
    _currentTourSessionId = sessionId ?? _currentTourSessionId;
    _nextExhibitId = nextExhibitId ?? _nextExhibitId;
    if (selectedExhibitIds.isNotEmpty) {
      _selectedExhibitIds
        ..clear()
        ..addAll(selectedExhibitIds);
    }
    _listenToActiveTourSession();
    notifyListeners();
  }

  void startActiveTour({
    required String currentExhibitId,
    String? nextExhibitId,
  }) {
    _appUsageMode = AppUsageMode.visiting;
    _robotConnectionState = RobotConnectionState.connected;
    _tourLifecycleState = TourLifecycleState.active;
    _robotActivityState = RobotActivityState.moving;
    _followMode = FollowModeState.on;
    _currentExhibitId = currentExhibitId;
    _nextExhibitId = nextExhibitId;
    _currentTourSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    if (!_visitedExhibitIds.contains(currentExhibitId)) {
      _visitedExhibitIds.add(currentExhibitId);
    }
    notifyListeners();
  }

  void failRobotConnection() {
    _robotConnectionState = RobotConnectionState.failed;
    notifyListeners();
  }

  /// Confirm ticket purchase and set ticket states.
  void setTicketStates({
    MuseumTicketState museumState = MuseumTicketState.available,
    RobotTourTicketState robotState = RobotTourTicketState.none,
  }) {
    _museumTicketState = museumState;
    _robotTourTicketState = robotState;
    notifyListeners();
  }

  void setTourLifecycleState(TourLifecycleState state) {
    if (_tourLifecycleState != state) {
      _tourLifecycleState = state;
      notifyListeners();
    }
  }

  void setFollowMode(FollowModeState mode) {
    if (_followMode != mode) {
      _followMode = mode;
      notifyListeners();
    }
  }

  void setProximityState(ProximityState state, {double distanceMeters = 0.0}) {
    bool changed =
        _proximityState != state || _distanceMeters != distanceMeters;
    if (changed) {
      _proximityState = state;
      _distanceMeters = distanceMeters;
      notifyListeners();
    }
  }

  void setRobotActivityState(RobotActivityState state) {
    if (_robotActivityState != state) {
      _robotActivityState = state;
      notifyListeners();
    }
  }

  void setCurrentExhibit(String? exhibitId) {
    if (_currentExhibitId != exhibitId) {
      _currentExhibitId = exhibitId;
      if (exhibitId != null && !_visitedExhibitIds.contains(exhibitId)) {
        _visitedExhibitIds.add(exhibitId);
      }
      notifyListeners();
    }
  }

  void setNextExhibit(String? exhibitId) {
    if (_nextExhibitId != exhibitId) {
      _nextExhibitId = exhibitId;
      notifyListeners();
    }
  }

  void setTourPreferences(TourPreferences? preferences) {
    _tourPreferences = preferences;
    notifyListeners();
  }

  // ========================
  // TOUR CONTROL METHODS
  // ========================

  void pauseTour() {
    if (_robotConnectionState == RobotConnectionState.connected &&
        _tourLifecycleState == TourLifecycleState.active) {
      _tourLifecycleState = TourLifecycleState.paused;
      _robotActivityState = RobotActivityState.waiting;
      notifyListeners();
    }
  }

  void resumeTour() {
    if (_robotConnectionState == RobotConnectionState.connected &&
        _tourLifecycleState == TourLifecycleState.paused) {
      _tourLifecycleState = TourLifecycleState.active;
      _robotActivityState = RobotActivityState.moving;
      notifyListeners();
    }
  }

  void endTour() {
    if (_tourLifecycleState == TourLifecycleState.active ||
        _tourLifecycleState == TourLifecycleState.paused) {
      _tourLifecycleState = TourLifecycleState.completed;
      _robotConnectionState = RobotConnectionState.disconnected;
      _followMode = FollowModeState.off;
      // Keep session ID so memories can still be accessed
      _stopTourSessionListener();
      notifyListeners();
    }
  }

  // ========================
  // TOUR MEMORY METHODS
  // ========================

  void addMemory(TourMemory memory) {
    _tourMemories.add(memory);
    notifyListeners();
  }

  void clearMemories() {
    _tourMemories.clear();
    notifyListeners();
  }

  void deleteMemory(String memoryId) {
    _tourMemories.removeWhere((memory) => memory.id == memoryId);
    notifyListeners();
  }

  void updateMemoryNote(String memoryId, String? note) {
    final index = _tourMemories.indexWhere((memory) => memory.id == memoryId);
    if (index != -1) {
      _tourMemories[index] = _tourMemories[index].copyWith(note: note);
      notifyListeners();
    }
  }

  void addQuizResult(QuizResult result) {
    final existingIndex = _quizResults.indexWhere(
      (item) => item.id == result.id,
    );
    if (existingIndex != -1) {
      _rewardPoints -= _quizResults[existingIndex].pointsEarned;
      _quizResults[existingIndex] = result;
    } else {
      _quizResults.add(result);
    }
    _rewardPoints += result.pointsEarned;
    for (final badge in result.earnedBadges) {
      if (!_earnedBadges.contains(badge)) {
        _earnedBadges.add(badge);
      }
    }
    notifyListeners();
  }

  void clearQuizRewards() {
    _quizResults.clear();
    _rewardPoints = 0;
    _earnedBadges.clear();
    notifyListeners();
  }

  // ========================
  // STATE TRANSITION HELPERS
  // ========================

  /// Transition to planning mode
  /// User wants to explore without connecting to robot
  void startPlanning() {
    _appUsageMode = AppUsageMode.planning;
    _robotConnectionState = RobotConnectionState.disconnected;
    _tourLifecycleState = TourLifecycleState.notStarted;
    _followMode = FollowModeState.off;
    _robotActivityState = RobotActivityState.unavailable;
    notifyListeners();
  }

  /// Transition to visiting mode and ready to connect
  /// User has tickets or is preparing for tour
  void startVisiting() {
    _appUsageMode = AppUsageMode.visiting;
    _tourLifecycleState = TourLifecycleState.readyToStart;
    notifyListeners();
  }

  /// Simulate robot connection (for demo/prototype)
  /// Sets state as if robot QR was successfully scanned
  void simulateRobotConnection() {
    _robotConnectionState = RobotConnectionState.connected;
    _tourLifecycleState = TourLifecycleState.active;
    _robotActivityState = RobotActivityState.waiting;
    _followMode = FollowModeState.on;
    notifyListeners();
  }

  /// Reset to initial state
  /// Useful for logout or tour cancellation
  void resetSession() {
    _appUsageMode = AppUsageMode.planning;
    _authState = AuthState.guest;
    _museumTicketState = MuseumTicketState.none;
    _robotTourTicketState = RobotTourTicketState.none;
    _robotConnectionState = RobotConnectionState.disconnected;
    _tourLifecycleState = TourLifecycleState.notStarted;
    _tourPreferences = null;
    _followMode = FollowModeState.off;
    _proximityState = ProximityState.unknown;
    _distanceMeters = 0.0;
    _robotActivityState = RobotActivityState.unavailable;
    _currentExhibitId = null;
    _nextExhibitId = null;
    _currentTourSessionId = null;
    _connectedRobotId = null;
    _selectedExhibitIds.clear();
    _visitedExhibitIds.clear();
    _stopTourSessionListener();
    _quizResults.clear();
    _rewardPoints = 0;
    _earnedBadges.clear();
    notifyListeners();
  }

  void _listenToActiveTourSession() {
    final sessionId = _currentTourSessionId;
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
    _currentTourSessionId = session.sessionId;
    _connectedRobotId = session.robotId;
    _currentExhibitId = session.currentExhibitId;
    _nextExhibitId = session.nextExhibitId;
    _selectedExhibitIds
      ..clear()
      ..addAll(session.selectedExhibitIds);
    _visitedExhibitIds
      ..clear()
      ..addAll(session.visitedExhibitIds);
    if (session.userDistanceFromRobot != null) {
      _distanceMeters = session.userDistanceFromRobot!;
      _proximityState = _distanceMeters < 5
          ? ProximityState.near
          : _distanceMeters <= 15
          ? ProximityState.medium
          : ProximityState.far;
    }

    switch (session.status) {
      case 'active':
        _tourLifecycleState = TourLifecycleState.active;
        _robotConnectionState = RobotConnectionState.connected;
        break;
      case 'paused':
        _tourLifecycleState = TourLifecycleState.paused;
        _robotConnectionState = RobotConnectionState.connected;
        break;
      case 'completed':
        _tourLifecycleState = TourLifecycleState.completed;
        _robotConnectionState = RobotConnectionState.disconnected;
        _stopTourSessionListener();
        break;
      case 'cancelled':
        _tourLifecycleState = TourLifecycleState.cancelled;
        _robotConnectionState = RobotConnectionState.disconnected;
        _stopTourSessionListener();
        break;
      case 'ready':
      default:
        _tourLifecycleState = TourLifecycleState.readyToStart;
        _robotConnectionState = RobotConnectionState.connected;
        break;
    }

    switch (session.robotState) {
      case 'moving':
        _robotActivityState = RobotActivityState.moving;
        break;
      case 'speaking':
        _robotActivityState = RobotActivityState.explaining;
        break;
      case 'error':
        _robotActivityState = RobotActivityState.unavailable;
        break;
      case 'waiting':
      default:
        _robotActivityState = RobotActivityState.waiting;
        break;
    }
    notifyListeners();
  }

  void _stopTourSessionListener() {
    _tourSessionSubscription?.cancel();
    _tourSessionSubscription = null;
  }

  @override
  void dispose() {
    _stopTourSessionListener();
    super.dispose();
  }

  // ========================
  // HELPER TEXT METHODS
  // ========================

  String getConnectionStatusText(String lang) {
    switch (_robotConnectionState) {
      case RobotConnectionState.disconnected:
        return lang == 'ar'
            ? 'لم يتم الاتصال بحوروس-بوت'
            : 'Not connected to Horus-Bot';
      case RobotConnectionState.connecting:
        return lang == 'ar'
            ? 'جاري الاتصال بحوروس-بوت...'
            : 'Connecting to Horus-Bot...';
      case RobotConnectionState.connected:
        return lang == 'ar' ? 'متصل بحوروس-بوت' : 'Connected to Horus-Bot';
      case RobotConnectionState.failed:
        return lang == 'ar' ? 'فشل الاتصال بحوروس-بوت' : 'Connection failed';
    }
  }

  String getTourLifecycleText(String lang) {
    switch (_tourLifecycleState) {
      case TourLifecycleState.notStarted:
        return lang == 'ar' ? 'لم تبدأ الجولة' : 'Tour not started';
      case TourLifecycleState.readyToStart:
        return lang == 'ar' ? 'جاهز للبدء' : 'Ready to start';
      case TourLifecycleState.active:
        return lang == 'ar' ? 'حوروس يوجه الجولة' : 'Horus-Bot is guiding';
      case TourLifecycleState.paused:
        return lang == 'ar' ? 'تم إيقاف الجولة مؤقتاً' : 'Tour paused';
      case TourLifecycleState.completed:
        return lang == 'ar' ? 'اكتملت الجولة' : 'Tour completed';
      case TourLifecycleState.cancelled:
        return lang == 'ar' ? 'تم إلغاء الجولة' : 'Tour cancelled';
    }
  }
}
