enum RobotCommandType {
  startTour('start_tour'),
  pause('pause'),
  resume('resume'),
  skip('skip'),
  endTour('end_tour'),
  findRobot('find_robot'),
  takePhoto('take_photo'),
  appQuestion('app_question');

  const RobotCommandType(this.wireName);

  final String wireName;

  static RobotCommandType fromWireName(String value) {
    return RobotCommandType.values.firstWhere(
      (type) => type.wireName == value,
      orElse: () => RobotCommandType.startTour,
    );
  }
}

class RobotCommand {
  static const String flutterSource = 'flutter_app';

  final String commandId;
  final RobotCommandType type;
  final String sessionId;
  final String robotId;
  final String userId;
  final DateTime sentAt;
  final String source;
  final Map<String, dynamic> payload;

  RobotCommand({
    String? commandId,
    required this.type,
    required this.sessionId,
    required this.robotId,
    required this.userId,
    DateTime? sentAt,
    this.source = flutterSource,
    this.payload = const <String, dynamic>{},
  }) : commandId = commandId ?? _generatedCommandId(),
       sentAt = sentAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() {
    return {
      'commandId': commandId,
      'type': type.wireName,
      'sessionId': sessionId,
      'robotId': robotId,
      'userId': userId,
      'sentAt': sentAt.toIso8601String(),
      'source': source,
      'payload': payload,
    };
  }

  factory RobotCommand.fromJson(Map<String, dynamic> json) {
    return RobotCommand(
      commandId: _stringValue(json['commandId']),
      type: RobotCommandType.fromWireName(_stringValue(json['type']) ?? ''),
      sessionId: _stringValue(json['sessionId']) ?? '',
      robotId: _stringValue(json['robotId']) ?? '',
      userId: _stringValue(json['userId']) ?? '',
      sentAt: _dateValue(json['sentAt']),
      source: _stringValue(json['source']) ?? flutterSource,
      payload: _mapValue(json['payload']),
    );
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

  static String _generatedCommandId() {
    return 'cmd_${DateTime.now().microsecondsSinceEpoch}';
  }
}
