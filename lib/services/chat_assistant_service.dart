import '../services/chat_context_builder.dart';
import '../models/exhibit.dart';
import 'conversation_memory_service.dart';
import 'museum_knowledge_service.dart';

class ChatAssistantService {
  final MuseumKnowledgeService _knowledge;
  final ConversationMemoryService _memory;

  ChatAssistantService({
    MuseumKnowledgeService? knowledge,
    ConversationMemoryService? memory,
  }) : _knowledge = knowledge ?? MuseumKnowledgeService(),
       _memory = memory ?? ConversationMemoryService();

  String _buildSystemPrompt(ChatContext context) {
    if (context.language == 'ar') {
      return 'أنت دليل متحف ذكي، أنيق، ودافئ. استخدم نهج قصصي ومعلوماتي. اجعله مختصراً ومفيداً. لا تكرر السؤال. لا تقول \'جاري المعالجة\'.';
    }
    return 'You are a smart museum guide assistant. Answer elegantly, helpfully and with storytelling style. Avoid generic phrases and don’t repeat the user question.';
  }

  String _pickExhibitResponse(
    Exhibit exhibit,
    String question,
    String language,
  ) {
    final title = exhibit.getName(language);
    final description = exhibit.getDescription(language);

    if (question.toLowerCase().contains('more') ||
        question.toLowerCase().contains('tell me')) {
      return language == 'ar'
          ? 'هذا $title. $description'
          : 'The $title is an outstanding piece. $description';
    }
    return language == 'ar'
        ? '$title هو أحد المعروضات المهمة. $description'
        : '$title is one of the highlights. $description';
  }

  String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'[\W_]'), ' ');

  String _mapToArabic(String key) {
    final mapping = {
      'tickets': 'تذاكر',
      'hours': 'ساعات',
      'events': 'فعاليات',
      'duration': 'المدة',
      'next': 'التالي',
      'where': 'أين',
    };
    return mapping[key] ?? key;
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

  bool _isHumanSupportRequest(String normalized) {
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

  String _fallbackResponse(String language) {
    return language == 'ar'
        ? 'يمكنني مساعدتك في التذاكر، المواعيد، المعروضات، الفعاليات، والاتجاهات داخل تجربة المتحف. جرّب أن تسأل عن أحد هذه الأمور.'
        : 'I can help with tickets, hours, exhibits, events, and directions inside the museum experience. Try asking about one of these.';
  }

  String _greetingResponse(String language) {
    if (language == 'ar') {
      return 'مرحباً! أنا دليلك في المتحف. يمكنني مساعدتك في معرفة التذاكر والمواعيد والفعاليات والمعروضات. ماذا تود أن تستكشف؟';
    }
    return 'Hello! I am your museum guide. I can help you with tickets, hours, events, and exhibits. What would you like to explore?';
  }

  String generateAnswer({
    required String question,
    required ChatContext context,
  }) {
    final language = context.language;
    final normalized = _normalize(question);
    final exhibit = context.exhibit;
    final tour = context.tourState;

    _memory.addUserMessage(question);

    // FAST PATH: Greeting detection (highest priority)
    if (_isGreeting(normalized, language)) {
      final answer = _greetingResponse(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // Human support request (higher than general fallback)
    if (_isHumanSupportRequest(normalized)) {
      final answer = language == 'ar'
          ? 'تم تسجيل طلب الدعم البشري ضمن هذا المسار التجريبي. في النسخة الإنتاجية، سيتم إشعار فريق دعم المتحف.'
          : 'A live support request has been recorded in this demo flow. In production, this would notify the museum support team.';
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Tickets
    if (normalized.contains('ticket') ||
        normalized.contains('تذاكر') ||
        normalized.contains('price') ||
        normalized.contains('سعر') ||
        normalized.contains('admission') ||
        normalized.contains('الدخول')) {
      final answer = _knowledge.getTicketInfo(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Opening hours
    if (normalized.contains('hour') ||
        normalized.contains('ساعات') ||
        normalized.contains('open') ||
        normalized.contains('مفتوح') ||
        normalized.contains('timing') ||
        normalized.contains('مواعيد')) {
      final answer = _knowledge.getMuseumHours(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Events
    if (normalized.contains('event') ||
        normalized.contains('فعاليات') ||
        normalized.contains('what is on') ||
        normalized.contains('current')) {
      final answer = _knowledge.getEventHighlights(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Visit duration
    if (normalized.contains('duration') ||
        normalized.contains('المدة') ||
        normalized.contains('long') ||
        normalized.contains('time') ||
        normalized.contains('تستغرق') ||
        normalized.contains('ساعات')) {
      final answer = _knowledge.getVisitDuration(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // SLOWER PATH: Exhibit-specific questions
    Exhibit? matchedExhibit = exhibit;
    if (matchedExhibit == null) {
      final byName = _knowledge.searchExhibits(question);
      if (byName.isNotEmpty) {
        matchedExhibit = byName.first;
      }
    }

    // Explicit "tell me about" or "explain" with exhibit context
    if (matchedExhibit != null &&
        (normalized.contains('tell') ||
            normalized.contains('explain') ||
            normalized.contains('حدثني') ||
            normalized.contains('اشرح'))) {
      final answer = _pickExhibitResponse(matchedExhibit, question, language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // Context-aware where questions
    if (_isWhereIntent(normalized) && matchedExhibit != null) {
      final answer = language == 'ar'
          ? 'المعرض موجود في المسار الرئيسي. توجه نحو ${matchedExhibit.getName(language)} وستجده قريبًا.'
          : '${matchedExhibit.getName(language)} is located in the main hall route; follow the signs to reach it.';
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // Tour-aware: next stop
    if ((normalized.contains('next') || normalized.contains('التالي')) &&
        tour?.nextExhibitId != null) {
      final nextExhibit = _knowledge.findExhibitById(tour!.nextExhibitId!);
      if (nextExhibit != null) {
        final answer = language == 'ar'
            ? 'المحطة التالية هي ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}'
            : 'Next stop is ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}';
        _memory.addAssistantMessage(answer);
        return answer;
      }
    }

    // If generic next stop intent but no tour in progress
    if (_isTourNextIntent(normalized) && tour?.nextExhibitId == null) {
      final answer = language == 'ar'
          ? 'سأوصيك بأن تبدأ من قاعة توت عنخ آمون ثم تتجه إلى معروضات الأسرار الملكية.'
          : 'A great next step is Tutankhamun Hall, then move towards the Royal Secrets exhibits.';
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // If user is currently viewing an exhibit
    if (matchedExhibit != null) {
      final answer = _pickExhibitResponse(matchedExhibit, question, language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // General fallback
    final fallback = _fallbackResponse(language);

    _memory.addAssistantMessage(fallback);
    return fallback;
  }

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
