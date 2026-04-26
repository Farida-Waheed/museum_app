import '../models/exhibit.dart';
import '../services/chat_context_builder.dart';
import 'conversation_memory_service.dart';
import 'museum_knowledge_service.dart';
import 'robot_suggestion_service.dart';

abstract class ChatAiService {
  Future<String> generateAnswer({
    required String question,
    required ChatContext context,
  });

  String buildPrompt({required ChatContext context});

  bool isHumanSupportRequest(String question);
}

class LocalMuseumChatService implements ChatAiService {
  final MuseumKnowledgeService _knowledge;
  final ConversationMemoryService _memory;
  final RobotSuggestionService _robotSuggestion;

  LocalMuseumChatService({
    MuseumKnowledgeService? knowledge,
    ConversationMemoryService? memory,
    RobotSuggestionService? robotSuggestion,
  }) : _knowledge = knowledge ?? MuseumKnowledgeService(),
       _memory = memory ?? ConversationMemoryService(),
       _robotSuggestion = robotSuggestion ?? RobotSuggestionService();

  String _buildSystemPrompt(ChatContext context) {
    if (context.language == 'ar') {
      return 'أنت مساعد متحف عملي ومباشر. أجب باختصار ووضوح. ركز على المساعدة العملية مثل التذاكر والمواعيد والإرشادات. لا تكن قصصياً أو تعليمياً. إذا سئل عن معروضات، أعد توجيه إلى الروبوت.';
    }
    return 'You are a practical museum assistant. Answer briefly and clearly. Focus on operational help like tickets, hours, and directions. Do not be storytelling or educational. If asked about exhibits, redirect to the robot.';
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[\W_]'), ' ').trim();
  }

  bool _isGreeting(String normalized, String language) {
    if (language == 'ar') {
      return RegExp(
        r'\b(مرحبا|السلام|اهلا|كيف|صباح|مساء|هاي|ها)\b',
      ).hasMatch(normalized);
    }
    return RegExp(
      r'\b(hi|hello|hey|howdy|greetings|good morning|good afternoon|good evening)\b',
    ).hasMatch(normalized);
  }

  @override
  bool isHumanSupportRequest(String question) {
    final normalized = _normalize(question);
    return normalized.contains('support') ||
        normalized.contains('human') ||
        normalized.contains('دعم') ||
        normalized.contains('بشري');
  }

  bool _isWhereIntent(String normalized) {
    return normalized.contains('where') ||
        normalized.contains('أين') ||
        normalized.contains('location') ||
        normalized.contains('موقع');
  }

  bool _isTourNextIntent(String normalized) {
    return normalized.contains('next') ||
        normalized.contains('التالي') ||
        normalized.contains('بعد');
  }

  bool _isTicketIntent(String normalized) {
    return normalized.contains('ticket') ||
        normalized.contains('تذاكر') ||
        normalized.contains('price') ||
        normalized.contains('سعر') ||
        normalized.contains('admission') ||
        normalized.contains('الدخول');
  }

  bool _isHoursIntent(String normalized) {
    return normalized.contains('hour') ||
        normalized.contains('ساعات') ||
        normalized.contains('open') ||
        normalized.contains('مفتوح') ||
        normalized.contains('timing') ||
        normalized.contains('مواعيد');
  }

  bool _isEventIntent(String normalized) {
    return normalized.contains('event') ||
        normalized.contains('فعاليات') ||
        normalized.contains('what is on') ||
        normalized.contains('current');
  }

  bool _isDurationIntent(String normalized) {
    return normalized.contains('duration') ||
        normalized.contains('المدة') ||
        normalized.contains('long') ||
        normalized.contains('time') ||
        normalized.contains('تستغرق') ||
        normalized.contains('ساعات');
  }

  String _greetingResponse(String language) {
    if (language == 'ar') {
      return 'مرحباً! أنا هنا لمساعدتك في التذاكر والمواعيد والإرشادات. ماذا تحتاج؟';
    }
    return 'Hello! I can help with tickets, hours, and directions. What do you need?';
  }

  String _fallbackResponse(String language) {
    return language == 'ar'
        ? 'لم أفهم تماماً. يمكنني المساعدة في التذاكر، المواعيد، الإرشادات، أو الفعاليات. جرّب سؤالاً مثل "أسعار التذاكر" أو "أين دورة المياه".'
        : 'I didn\'t catch that. I can help with tickets, hours, directions, or events. Try asking about "ticket prices" or "where is the restroom".';
  }

  String _composeShortExhibitAnswer(
    Exhibit exhibit,
    String question,
    String language,
  ) {
    final title = exhibit.getName(language);
    if (_isWhereIntent(_normalize(question))) {
      return language == 'ar'
          ? '$title موجود في القاعة الرئيسية. اتبع لافتات المتحف لتجده سريعًا.'
          : '$title is in the main hall route. Follow museum signs to find it quickly.';
    }

    // For any explanation requests, redirect to robot
    final normalized = _normalize(question);
    if (normalized.contains('tell') ||
        normalized.contains('explain') ||
        normalized.contains('more') ||
        normalized.contains('حدثني') ||
        normalized.contains('اشرح') ||
        normalized.contains('story') ||
        normalized.contains('قصة') ||
        normalized.contains('history') ||
        normalized.contains('تاريخ')) {
      if (language == 'ar') {
        return 'للقصة الكاملة، اسأل روبوت المتحف في القاعة.';
      }
      return 'For the full story, ask the museum robot in the hall.';
    }

    // Short acknowledgment only
    if (language == 'ar') {
      return '$title معروض في المتحف. للمزيد من المعلومات، اسأل الروبوت.';
    }
    return '$title is on display. For more information, ask the robot.';
  }

  String _composeCorrectionResponse(
    Exhibit exhibit,
    String query,
    String language,
  ) {
    final exhibitName = exhibit.getName(language);
    if (language == 'ar') {
      return 'لم أجد "$query" بدقة. هل تقصد $exhibitName؟ للقصة الكاملة، اسأل الروبوت.';
    }
    return 'I couldn\'t find "$query" exactly. Did you mean $exhibitName? For the full story, ask the robot.';
  }

  String _composeNearMatchResponse(List<Exhibit> suggestions, String language) {
    if (suggestions.isEmpty) {
      return _fallbackResponse(language);
    }
    final first = suggestions.first.getName(language);
    if (language == 'ar') {
      return 'لم أجد تطابقًا دقيقًا، لكن $first قد يكون ما تقصده. للمزيد من التفاصيل، اسأل الروبوت.';
    }
    return 'I didn\'t find an exact match, but $first may be what you mean. For more details, ask the robot.';
  }

  Exhibit? _rememberRecentExhibit() {
    for (final item in _memory.history.reversed) {
      if (item.role == 'user') {
        final candidate = _knowledge.findBestExhibitMatch(item.content);
        if (candidate != null) {
          return candidate;
        }
      }
    }
    return null;
  }

  @override
  Future<String> generateAnswer({
    required String question,
    required ChatContext context,
  }) async {
    final language = context.language;
    final normalized = _normalize(question);
    final exhibitContext = context.exhibit;
    final tour = context.tourState;

    _memory.addUserMessage(question);

    if (_isGreeting(normalized, language)) {
      final answer = _greetingResponse(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (isHumanSupportRequest(question)) {
      final answer = language == 'ar'
          ? 'تم تسجيل طلب الدعم البشري. سيصل إليك ممثل قريبًا.'
          : 'Your live human support request has been sent. A representative will join shortly.';
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isTicketIntent(normalized)) {
      final answer = _knowledge.getTicketInfo(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isHoursIntent(normalized)) {
      final answer = _knowledge.getMuseumHours(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isEventIntent(normalized)) {
      final answer = _knowledge.getEventHighlights(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isDurationIntent(normalized)) {
      final answer = _knowledge.getVisitDuration(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    Exhibit? matchedExhibit = exhibitContext ?? _rememberRecentExhibit();
    matchedExhibit ??= _knowledge.findBestExhibitMatch(question);

    if (matchedExhibit != null &&
        (normalized.contains('tell') ||
            normalized.contains('explain') ||
            normalized.contains('more') ||
            normalized.contains('حدثني') ||
            normalized.contains('اشرح'))) {
      final answer = _composeExhibitResponse(
        matchedExhibit,
        question,
        language,
      );
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isWhereIntent(normalized) && matchedExhibit != null) {
      final answer = _composeExhibitResponse(
        matchedExhibit,
        question,
        language,
      );
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isTourNextIntent(normalized) && tour?.nextExhibitId != null) {
      final nextExhibit = _knowledge.findExhibitById(tour!.nextExhibitId!);
      if (nextExhibit != null) {
        final answer = language == 'ar'
            ? 'المحطة التالية هي ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}'
            : 'Next stop is ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}';
        _memory.addAssistantMessage(answer);
        return answer;
      }
    }

    if (matchedExhibit != null) {
      final answer = _composeShortExhibitAnswer(
        matchedExhibit,
        question,
        language,
      );
      final finalAnswer = _robotSuggestion.appendRobotSuggestion(
        answer,
        context,
        isExhibitAnswer: true,
      );
      _memory.addAssistantMessage(finalAnswer);
      return finalAnswer;
    }

    final closestMatches = _knowledge.findClosestMatches(question);
    if (closestMatches.isNotEmpty) {
      final answer = _composeCorrectionResponse(
        closestMatches.first,
        question,
        language,
      );
      final finalAnswer = _robotSuggestion.appendRobotSuggestion(
        answer,
        context,
        isExhibitAnswer: true,
      );
      _memory.addAssistantMessage(finalAnswer);
      return finalAnswer;
    }

    final answer = _composeNearMatchResponse(closestMatches, language);
    _memory.addAssistantMessage(answer);
    return answer;
  }

  @override
  String buildPrompt({required ChatContext context}) {
    final memory = _memory.conversationSummary;
    final prefix = _buildSystemPrompt(context);

    return '''$prefix

Context:
${_knowledge.buildRetrievalSnippet(exhibit: context.exhibit, tour: context.tourState, language: context.language)}

Conversation so far:
$memory

User question:
${context.question}
''';
  }

  String _composeExhibitResponse(
    Exhibit exhibit,
    String question,
    String language,
  ) {
    final normalized = _normalize(question);
    final title = exhibit.getName(language);

    if (_isWhereIntent(normalized)) {
      if (language == 'ar') {
        return '$title موجود في القاعة الرئيسية. اتبع لافتات المتحف للوصول إليه.';
      }
      return '$title is located in the main hall. Follow museum signs to find it.';
    }

    // For any deep explanation requests, redirect to robot
    if (normalized.contains('tell') ||
        normalized.contains('explain') ||
        normalized.contains('more') ||
        normalized.contains('حدثني') ||
        normalized.contains('اشرح') ||
        normalized.contains('story') ||
        normalized.contains('قصة') ||
        normalized.contains('history') ||
        normalized.contains('تاريخ')) {
      if (language == 'ar') {
        return 'للحصول على القصة الكاملة والتفاصيل التاريخية، اسأل روبوت المتحف الموجود في القاعة.';
      }
      return 'For the full story and historical details, ask the museum robot in the hall.';
    }

    // Short acknowledgment for basic exhibit mentions
    if (language == 'ar') {
      return '$title هو معروض مهم في المتحف. للمزيد من التفاصيل، اسأل الروبوت.';
    }
    return '$title is a key exhibit in the museum. For more details, ask the robot.';
  }
}
