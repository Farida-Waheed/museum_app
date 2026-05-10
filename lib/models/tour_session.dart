import 'package:cloud_firestore/cloud_firestore.dart';

class TourSession {
  final String sessionId;
  final String userId;
  final String robotId;
  final String museumTicketId;
  final String robotTourTicketId;
  final List<String> selectedExhibitIds;
  final String? currentExhibitId;
  final String? nextExhibitId;
  final List<String> visitedExhibitIds;
  final String status;
  final String robotState;
  final double? userDistanceFromRobot;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const TourSession({
    required this.sessionId,
    required this.userId,
    required this.robotId,
    required this.museumTicketId,
    required this.robotTourTicketId,
    required this.selectedExhibitIds,
    required this.currentExhibitId,
    required this.nextExhibitId,
    required this.visitedExhibitIds,
    required this.status,
    required this.robotState,
    required this.userDistanceFromRobot,
    required this.startedAt,
    required this.updatedAt,
    required this.completedAt,
  });

  factory TourSession.fromFirestore(String docId, Map<String, dynamic> data) {
    return TourSession(
      sessionId: _stringValue(data['sessionId']) ?? docId,
      userId: _stringValue(data['userId']) ?? '',
      robotId: _stringValue(data['robotId']) ?? '',
      museumTicketId: _stringValue(data['museumTicketId']) ?? '',
      robotTourTicketId: _stringValue(data['robotTourTicketId']) ?? '',
      selectedExhibitIds: _stringList(data['selectedExhibitIds']),
      currentExhibitId: _stringValue(data['currentExhibitId']),
      nextExhibitId: _stringValue(data['nextExhibitId']),
      visitedExhibitIds: _stringList(data['visitedExhibitIds']),
      status: _stringValue(data['status']) ?? 'ready',
      robotState: _stringValue(data['robotState']) ?? 'waiting',
      userDistanceFromRobot: _doubleValue(data['userDistanceFromRobot']),
      startedAt: _dateValue(data['startedAt']),
      updatedAt: _dateValue(data['updatedAt']),
      completedAt: _dateValue(data['completedAt']),
    );
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

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
