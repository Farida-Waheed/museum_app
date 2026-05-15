class QuizQuestion {
  final String id;
  final String exhibitId;
  final String exhibitNameEn;
  final String exhibitNameAr;
  final String questionEn;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctAnswerIndex;
  final String explanationEn;
  final String explanationAr;

  QuizQuestion({
    required this.id,
    required this.exhibitId,
    required this.exhibitNameEn,
    required this.exhibitNameAr,
    required this.questionEn,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctAnswerIndex,
    required this.explanationEn,
    required this.explanationAr,
  });

  // Helpers to get localized text
  String getQuestion(String lang) => lang == 'ar' ? questionAr : questionEn;
  List<String> getOptions(String lang) => lang == 'ar' ? optionsAr : optionsEn;
  String getExplanation(String lang) =>
      lang == 'ar' ? explanationAr : explanationEn;
  String getExhibitName(String lang) =>
      lang == 'ar' ? exhibitNameAr : exhibitNameEn;

  QuizQuestion copyWith({
    String? id,
    String? exhibitId,
    String? exhibitNameEn,
    String? exhibitNameAr,
    String? questionEn,
    String? questionAr,
    List<String>? optionsEn,
    List<String>? optionsAr,
    int? correctAnswerIndex,
    String? explanationEn,
    String? explanationAr,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      exhibitId: exhibitId ?? this.exhibitId,
      exhibitNameEn: exhibitNameEn ?? this.exhibitNameEn,
      exhibitNameAr: exhibitNameAr ?? this.exhibitNameAr,
      questionEn: questionEn ?? this.questionEn,
      questionAr: questionAr ?? this.questionAr,
      optionsEn: optionsEn ?? this.optionsEn,
      optionsAr: optionsAr ?? this.optionsAr,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanationEn: explanationEn ?? this.explanationEn,
      explanationAr: explanationAr ?? this.explanationAr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exhibitId': exhibitId,
      'exhibitNameEn': exhibitNameEn,
      'exhibitNameAr': exhibitNameAr,
      'questionEn': questionEn,
      'questionAr': questionAr,
      'optionsEn': optionsEn,
      'optionsAr': optionsAr,
      'correctAnswerIndex': correctAnswerIndex,
      'explanationEn': explanationEn,
      'explanationAr': explanationAr,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      exhibitId: json['exhibitId'] as String,
      exhibitNameEn: json['exhibitNameEn'] as String,
      exhibitNameAr: json['exhibitNameAr'] as String,
      questionEn: json['questionEn'] as String,
      questionAr: json['questionAr'] as String,
      optionsEn: List<String>.from(json['optionsEn'] as List<dynamic>),
      optionsAr: List<String>.from(json['optionsAr'] as List<dynamic>),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanationEn: json['explanationEn'] as String,
      explanationAr: json['explanationAr'] as String,
    );
  }
}

class QuizResult {
  final String id;
  final String exhibitId;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int pointsEarned;
  final List<String> earnedBadges;

  QuizResult({
    required this.id,
    required this.exhibitId,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.pointsEarned,
    required this.earnedBadges,
  });

  QuizResult copyWith({
    String? id,
    String? exhibitId,
    DateTime? completedAt,
    int? totalQuestions,
    int? correctAnswers,
    int? pointsEarned,
    List<String>? earnedBadges,
  }) {
    return QuizResult(
      id: id ?? this.id,
      exhibitId: exhibitId ?? this.exhibitId,
      completedAt: completedAt ?? this.completedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exhibitId': exhibitId,
      'completedAt': completedAt.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
      'earnedBadges': earnedBadges,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      exhibitId: json['exhibitId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      pointsEarned: json['pointsEarned'] as int,
      earnedBadges: List<String>.from(json['earnedBadges'] as List<dynamic>),
    );
  }
}
