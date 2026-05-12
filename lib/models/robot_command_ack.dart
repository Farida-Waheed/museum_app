class RobotCommandAck {
  final String commandId;
  final String type;
  final String commandType;
  final String sessionId;
  final String robotId;
  final String status;
  final String? message;
  final DateTime? receivedAt;
  final DateTime? completedAt;
  final String? errorCode;

  const RobotCommandAck({
    required this.commandId,
    required this.type,
    required this.commandType,
    required this.sessionId,
    required this.robotId,
    required this.status,
    required this.message,
    required this.receivedAt,
    required this.completedAt,
    required this.errorCode,
  });

  factory RobotCommandAck.fromJson(Map<String, dynamic> json) {
    return RobotCommandAck(
      commandId: _stringValue(json['commandId']) ?? '',
      type: _stringValue(json['type']) ?? 'command_ack',
      commandType: _stringValue(json['commandType']) ?? '',
      sessionId: _stringValue(json['sessionId']) ?? '',
      robotId: _stringValue(json['robotId']) ?? '',
      status: _stringValue(json['status']) ?? 'unknown',
      message: _stringValue(json['message']),
      receivedAt: _dateValue(json['receivedAt']),
      completedAt: _dateValue(json['completedAt']),
      errorCode: _stringValue(json['errorCode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commandId': commandId,
      'type': type,
      'commandType': commandType,
      'sessionId': sessionId,
      'robotId': robotId,
      'status': status,
      'message': message,
      'receivedAt': receivedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'errorCode': errorCode,
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
}
