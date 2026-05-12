import 'package:cloud_firestore/cloud_firestore.dart';

enum TourQuestionStatus { pending, answered, failed }

enum TourQuestionSource { app, robot }

class TourQuestion {
  final String questionId;
  final String userId;
  final String? sessionId;
  final String? robotId;
  final String? exhibitId;
  final String question;
  final String? answer;
  final TourQuestionSource source;
  final String reason;
  final String language;
  final TourQuestionStatus status;
  final DateTime? createdAt;
  final DateTime? answeredAt;

  const TourQuestion({
    required this.questionId,
    required this.userId,
    required this.sessionId,
    required this.robotId,
    required this.exhibitId,
    required this.question,
    required this.answer,
    required this.source,
    required this.reason,
    required this.language,
    required this.status,
    required this.createdAt,
    required this.answeredAt,
  });

  Map<String, dynamic> toCreateFirestore() {
    return {
      'questionId': questionId,
      'userId': userId,
      'sessionId': sessionId,
      'robotId': robotId,
      'exhibitId': exhibitId,
      'question': question,
      'answer': answer,
      'source': source.name,
      'reason': reason,
      'language': language,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'answeredAt': answeredAt,
    };
  }

  factory TourQuestion.fromFirestore(String docId, Map<String, dynamic> data) {
    return TourQuestion(
      questionId: _stringValue(data['questionId']) ?? docId,
      userId: _stringValue(data['userId']) ?? '',
      sessionId: _stringValue(data['sessionId']),
      robotId: _stringValue(data['robotId']),
      exhibitId: _stringValue(data['exhibitId']),
      question: _stringValue(data['question']) ?? '',
      answer: _stringValue(data['answer']),
      source: _sourceValue(data['source']),
      reason: _stringValue(data['reason']) ?? 'voice_noise_fallback',
      language: _stringValue(data['language']) ?? 'en',
      status: _statusValue(data['status']),
      createdAt: _dateValue(data['createdAt']),
      answeredAt: _dateValue(data['answeredAt']),
    );
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static TourQuestionSource _sourceValue(Object? value) {
    final source = value?.toString();
    return TourQuestionSource.values.firstWhere(
      (entry) => entry.name == source,
      orElse: () => TourQuestionSource.app,
    );
  }

  static TourQuestionStatus _statusValue(Object? value) {
    final status = value?.toString();
    return TourQuestionStatus.values.firstWhere(
      (entry) => entry.name == status,
      orElse: () => TourQuestionStatus.pending,
    );
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
