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
          ? 'اسأل الروبوت الآن للحصول على القصة الكاملة.'
          : 'Ask the robot now for the full story.';
    }

    if (context.screen == 'home') {
      return language == 'ar'
          ? 'ابدأ الجولة لتجربة تفاعلية مع الروبوت.'
          : 'Start your tour for an interactive experience with the robot.';
    }

    if (context.screen == 'tour' || context.tourState != null) {
      return language == 'ar'
          ? 'الروبوت جاهز ليشرح هذا بالتفصيل.'
          : 'The robot is ready to explain this in detail.';
    }

    return language == 'ar'
        ? 'للحصول على تجربة أعمق، ابدأ جولة مع الروبوت.'
        : 'For a richer experience, start a tour with the robot.';
  }
}
