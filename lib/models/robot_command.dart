import 'dart:math';

enum RobotCommandType {
  startTour('start_tour'),
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
  static final RegExp uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  final String commandId;
  final RobotCommandType type;
  final String sessionId;
  final String robotId;
  final String userId;
  final DateTime sentAt;
  final Map<String, dynamic> payload;

  RobotCommand({
    String? commandId,
    required this.type,
    required this.sessionId,
    required this.robotId,
    required this.userId,
    DateTime? sentAt,
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
      'sentAt': sentAt.toUtc().toIso8601String(),
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
      payload: _mapValue(json['payload']),
    );
  }

  bool get hasValidCommandId => uuidPattern.hasMatch(commandId);

  bool isStale({DateTime? now}) {
    final referenceTime = (now ?? DateTime.now()).toUtc();
    return referenceTime.difference(sentAt.toUtc()).inSeconds > 120;
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
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final chars = bytes.map(hex).join();
    return '${chars.substring(0, 8)}-'
        '${chars.substring(8, 12)}-'
        '${chars.substring(12, 16)}-'
        '${chars.substring(16, 20)}-'
        '${chars.substring(20)}';
  }
}
