import '../services/chat_context_builder.dart';

class RobotSuggestionService {
  String appendRobotSuggestion(
    String answer,
    ChatContext context, {
    required bool isExhibitAnswer,
  }) {
    if (!isExhibitAnswer) {
      return answer;
    }

    final suggestion = _buildSuggestion(context);
    if (suggestion.isEmpty) {
      return answer;
    }

    return '$answer $suggestion';
  }

  String _buildSuggestion(ChatContext context) {
    final language = context.language;
    if (context.exhibit != null || context.screen == 'exhibit_details') {
      return language == 'ar'
          ? 'يمكنك سؤال الروبوت القريب للحصول على القصة الكاملة.'
          : 'You can ask the robot nearby for the full story.';
    }

    if (context.screen == 'home') {
      return language == 'ar'
          ? 'يمكنك سؤال روبوت المتحف خلال زيارتك للحصول على المزيد من التفاصيل.'
          : 'You can ask the museum robot during your visit.';
    }

    if (context.screen == 'tour' || context.tourState != null) {
      return language == 'ar'
          ? 'سيشرح دليل الروبوت هذا الأمر بالتفصيل.'
          : 'The robot guide will explain this in detail.';
    }

    return language == 'ar'
        ? 'للحصول على قصة أعمق، اسأل دليل الروبوت في المتحف.'
        : 'For a richer experience, try the museum robot.';
  }
}
