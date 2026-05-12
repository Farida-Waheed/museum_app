import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tour_question.dart';

class QuestionRepository {
  QuestionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _questions =>
      _firestore.collection('questions');

  Future<TourQuestion> createAppQuestion({
    required String userId,
    required String question,
    required String language,
    String? sessionId,
    String? robotId,
    String? exhibitId,
  }) async {
    if (userId.trim().isEmpty) {
      throw const QuestionRepositoryException('Please sign in to ask Horus.');
    }
    if (question.trim().isEmpty) {
      throw const QuestionRepositoryException('Question cannot be empty.');
    }

    final doc = _questions.doc();
    final tourQuestion = TourQuestion(
      questionId: doc.id,
      userId: userId,
      sessionId: _nullableString(sessionId),
      robotId: _nullableString(robotId),
      exhibitId: _nullableString(exhibitId),
      question: question.trim(),
      answer: null,
      source: TourQuestionSource.app,
      language: language.trim().isEmpty ? 'en' : language.trim(),
      status: TourQuestionStatus.pending,
      createdAt: null,
      answeredAt: null,
    );

    try {
      await doc.set(tourQuestion.toCreateFirestore());
      return tourQuestion;
    } on FirebaseException catch (e) {
      throw QuestionRepositoryException(_friendlyError(e));
    }
  }

  Stream<TourQuestion?> watchQuestion(String questionId) {
    return _questions.doc(questionId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return TourQuestion.fromFirestore(snapshot.id, data);
    });
  }

  String? _nullableString(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _friendlyError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Firestore rules blocked this question. Please check question create/read permissions.';
    }
    if (e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed') {
      return 'Network error. Your local chat still works.';
    }
    return 'Unable to send this question to Horus right now.';
  }
}

class QuestionRepositoryException implements Exception {
  final String message;

  const QuestionRepositoryException(this.message);

  @override
  String toString() => message;
}
