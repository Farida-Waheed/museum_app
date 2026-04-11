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
  })  : _knowledge = knowledge ?? MuseumKnowledgeService(),
        _memory = memory ?? ConversationMemoryService(),
        _robotSuggestion = robotSuggestion ?? RobotSuggestionService();

  String _buildSystemPrompt(ChatContext context) {
    if (context.language == 'ar') {
      return 'أنت دليل متحف ذكي، أنيق، ودافئ. استخدم نهج قصصي ومعلوماتي. اجعله مختصراً ومفيداً. لا تكرر السؤال. لا تقل \'جاري المعالجة\'.';
    }
    return 'You are a smart museum guide assistant. Answer elegantly, helpfully and with storytelling style. Avoid generic phrases and don’t repeat the user question.';
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[\W_]'), ' ').trim();
  }

  bool _isGreeting(String normalized, String language) {
    if (language == 'ar') {
      return RegExp(r'\b(مرحبا|السلام|اهلا|كيف|صباح|مساء|هاي|ها)\b').hasMatch(normalized);
    }
    return RegExp(r'\b(hi|hello|hey|howdy|greetings|good morning|good afternoon|good evening)\b').hasMatch(normalized);
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
      return 'مرحباً! أنا دليلك في المتحف. يمكنني مساعدتك في معرفة التذاكر والمواعيد والفعاليات والمعروضات. ماذا تود أن تستكشف؟';
    }
    return 'Hello! I am your museum guide. I can help you with tickets, hours, events, and exhibits. What would you like to explore?';
  }

  String _fallbackResponse(String language) {
    return language == 'ar'
        ? 'لم أتمكن من تحديد طلبك تمامًا، لكنني هنا لمساعدتك حول التذاكر والمواعيد والمعروضات والاتجاهات. جرّب سؤالاً مثل "التذاكر" أو "أين هو".'
        : 'I couldn’t match that exactly, but I can still help with tickets, hours, exhibits, events, or directions. Try asking about one of those topics.';
  }

  String _composeShortExhibitAnswer(Exhibit exhibit, String question, String language) {
    final title = exhibit.getName(language);
    final summary = _knowledge.getShortExhibitOverview(exhibit, language);
    if (_isWhereIntent(_normalize(question))) {
      return language == 'ar'
          ? '$title موجود في القاعة الرئيسية. اتبع لافتات المتحف لتجده سريعًا.'
          : '$title is in the main hall route. Follow museum signs to find it quickly.';
    }

    if (language == 'ar') {
      if (question.contains('من') || question.toLowerCase().contains('who')) {
        return '$title هو معروض مهم هنا. $summary';
      }
      return '$title هو عرض مميز. $summary';
    }

    if (question.toLowerCase().contains('who')) {
      return '$title is a key piece in the collection. $summary';
    }

    return '$title is a highlight of the museum. $summary';
  }

  String _composeCorrectionResponse(Exhibit exhibit, String query, String language) {
    final exhibitName = exhibit.getName(language);
    final shortOverview = _knowledge.getShortExhibitOverview(exhibit, language);
    if (language == 'ar') {
      return 'لم أجد شيئًا باسم "$query" ضمن معروضات المتحف. هل كنت تقصد $exhibitName؟ $shortOverview';
    }
    return 'I could not find anything named "$query" in the museum context. Did you mean $exhibitName? $shortOverview';
  }

  String _composeNearMatchResponse(List<Exhibit> suggestions, String language) {
    if (suggestions.isEmpty) {
      return _fallbackResponse(language);
    }
    final first = suggestions.first.getName(language);
    if (language == 'ar') {
      return 'لم أجد تطابقًا دقيقًا، لكن هذه القطعة قد تكون ما تقصده: $first. اسألني عنها أو عن أي معرض آخر.';
    }
    return 'I didn’t find an exact match, but this may be what you mean: $first. Ask me about it or another exhibit.';
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
    if (matchedExhibit == null) {
      matchedExhibit = _knowledge.findBestExhibitMatch(question);
    }

    if (matchedExhibit != null &&
        (normalized.contains('tell') ||
            normalized.contains('explain') ||
            normalized.contains('more') ||
            normalized.contains('حدثني') ||
            normalized.contains('اشرح'))) {
      final answer = _composeExhibitResponse(matchedExhibit, question, language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isWhereIntent(normalized) && matchedExhibit != null) {
      final answer = _composeExhibitResponse(matchedExhibit, question, language);
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
      final answer = _composeShortExhibitAnswer(matchedExhibit, question, language);
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
      final answer = _composeCorrectionResponse(closestMatches.first, question, language);
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
}
