import 'package:cloud_firestore/cloud_firestore.dart';

class TourSession {
  final String sessionId;
  final String userId;
  final String robotId;
  final String museumTicketId;
  final String robotTourTicketId;
  final List<String> selectedExhibitIds;
  final String? currentExhibitId;
  final int currentExhibitIndex;
  final String? nextExhibitId;
  final List<String> visitedExhibitIds;
  final String status;
  final String? routeId;
  final String? routeTitleEn;
  final String? routeTitleAr;
  final String? preferredLanguage;
  final String? pace;
  final String robotState;
  final double? userDistanceFromRobot;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? commandStatus;
  final String? lastCommandId;
  final String? lastCommandType;
  final String? lastCommandError;
  final DateTime? lastCommandAt;
  final DateTime? lastAckAt;
  final Map<String, dynamic>? lastRobotEvent;
  final DateTime? lastRobotEventAt;
  final bool? mqttEnabled;
  final String? robotConnectionState;

  const TourSession({
    required this.sessionId,
    required this.userId,
    required this.robotId,
    required this.museumTicketId,
    required this.robotTourTicketId,
    required this.selectedExhibitIds,
    required this.currentExhibitId,
    required this.currentExhibitIndex,
    required this.nextExhibitId,
    required this.visitedExhibitIds,
    required this.status,
    required this.routeId,
    required this.routeTitleEn,
    required this.routeTitleAr,
    required this.preferredLanguage,
    required this.pace,
    required this.robotState,
    required this.userDistanceFromRobot,
    required this.startedAt,
    required this.updatedAt,
    required this.completedAt,
    this.commandStatus,
    this.lastCommandId,
    this.lastCommandType,
    this.lastCommandError,
    this.lastCommandAt,
    this.lastAckAt,
    this.lastRobotEvent,
    this.lastRobotEventAt,
    this.mqttEnabled,
    this.robotConnectionState,
  });

  factory TourSession.fromFirestore(String docId, Map<String, dynamic> data) {
    final selectedExhibits = _stringList(
      data['selectedExhibitIds'] ?? data['selected_exhibits'],
    );
    final currentExhibitId = _stringValue(
      data['currentExhibitId'] ?? data['current_exhibit_id'],
    );
    final currentExhibitIndex = _intValue(data['current_exhibit_index']) ?? 0;
    final inferredNextIndex = currentExhibitId == null
        ? currentExhibitIndex
        : currentExhibitIndex + 1;
    final inferredNextExhibitId =
        inferredNextIndex >= 0 && inferredNextIndex < selectedExhibits.length
        ? selectedExhibits[inferredNextIndex]
        : null;
    return TourSession(
      sessionId: _stringValue(data['sessionId'] ?? data['session_id']) ?? docId,
      userId: _stringValue(data['userId']) ?? '',
      robotId: _stringValue(data['robotId']) ?? '',
      museumTicketId:
          _stringValue(data['museumTicketId'] ?? data['museum_ticket_id']) ??
          '',
      robotTourTicketId:
          _stringValue(
            data['robotTourTicketId'] ?? data['robot_tour_ticket_id'],
          ) ??
          '',
      selectedExhibitIds: selectedExhibits,
      currentExhibitId: currentExhibitId,
      currentExhibitIndex: currentExhibitIndex,
      nextExhibitId:
          _stringValue(data['nextExhibitId'] ?? data['next_exhibit_id']) ??
          inferredNextExhibitId,
      visitedExhibitIds: _stringList(data['visitedExhibitIds']),
      status: _stringValue(data['status']) ?? 'ready',
      routeId: _stringValue(data['route_id']),
      routeTitleEn: _stringValue(data['route_title_en']),
      routeTitleAr: _stringValue(data['route_title_ar']),
      preferredLanguage: _stringValue(data['preferred_language']),
      pace: _stringValue(data['pace']),
      robotState: _stringValue(data['robotState']) ?? 'waiting',
      userDistanceFromRobot: _doubleValue(data['userDistanceFromRobot']),
      startedAt: _dateValue(data['startedAt'] ?? data['started_at']),
      updatedAt: _dateValue(data['updatedAt'] ?? data['updated_at']),
      completedAt: _dateValue(data['completedAt'] ?? data['completed_at']),
      commandStatus: _stringValue(data['commandStatus']),
      lastCommandId: _stringValue(data['lastCommandId']),
      lastCommandType: _stringValue(data['lastCommandType']),
      lastCommandError: _stringValue(data['lastCommandError']),
      lastCommandAt: _dateValue(data['lastCommandAt']),
      lastAckAt: _dateValue(data['lastAckAt']),
      lastRobotEvent: _mapValue(data['lastRobotEvent']),
      lastRobotEventAt: _dateValue(data['lastRobotEventAt']),
      mqttEnabled: _boolValue(data['mqttEnabled']),
      robotConnectionState: _stringValue(data['robotConnectionState']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'robotId': robotId,
      'museumTicketId': museumTicketId,
      'robotTourTicketId': robotTourTicketId,
      'selectedExhibitIds': selectedExhibitIds,
      'currentExhibitId': currentExhibitId,
      'currentExhibitIndex': currentExhibitIndex,
      'nextExhibitId': nextExhibitId,
      'visitedExhibitIds': visitedExhibitIds,
      'status': status,
      'routeId': routeId,
      'routeTitleEn': routeTitleEn,
      'routeTitleAr': routeTitleAr,
      'preferredLanguage': preferredLanguage,
      'pace': pace,
      'robotState': robotState,
      'userDistanceFromRobot': userDistanceFromRobot,
      'startedAt': _timestampValue(startedAt),
      'updatedAt': _timestampValue(updatedAt),
      'completedAt': _timestampValue(completedAt),
      'commandStatus': commandStatus,
      'lastCommandId': lastCommandId,
      'lastCommandType': lastCommandType,
      'lastCommandError': lastCommandError,
      'lastCommandAt': _timestampValue(lastCommandAt),
      'lastAckAt': _timestampValue(lastAckAt),
      'lastRobotEvent': lastRobotEvent,
      'lastRobotEventAt': _timestampValue(lastRobotEventAt),
      'mqttEnabled': mqttEnabled,
      'robotConnectionState': robotConnectionState,
    };
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }

  static double? _doubleValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  static Map<String, dynamic>? _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Timestamp? _timestampValue(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}
