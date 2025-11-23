class QuizQuestion {
  final String id;
  final String questionEn;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.questionEn,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctAnswerIndex,
  });

  // Helpers to get localized text
  String getQuestion(String lang) => lang == 'ar' ? questionAr : questionEn;
  List<String> getOptions(String lang) => lang == 'ar' ? optionsAr : optionsEn;
}