class RobotEvent {
  final String eventId;
  final String type;
  final String sessionId;
  final String robotId;
  final DateTime? occurredAt;
  final Map<String, dynamic> payload;

  const RobotEvent({
    required this.eventId,
    required this.type,
    required this.sessionId,
    required this.robotId,
    required this.occurredAt,
    required this.payload,
  });

  factory RobotEvent.fromJson(Map<String, dynamic> json) {
    return RobotEvent(
      eventId: _stringValue(json['eventId']) ?? '',
      type: _stringValue(json['type']) ?? '',
      sessionId: _stringValue(json['sessionId']) ?? '',
      robotId: _stringValue(json['robotId']) ?? '',
      occurredAt: _dateValue(json['occurredAt']),
      payload: _mapValue(json['payload']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'type': type,
      'sessionId': sessionId,
      'robotId': robotId,
      'occurredAt': occurredAt?.toIso8601String(),
      'payload': payload,
    };
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static DateTime? _dateValue(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }
}
