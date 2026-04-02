import '../services/chat_context_builder.dart';
import '../models/exhibit.dart';
import '../core/services/mock_data.dart';
import 'conversation_memory_service.dart';
import 'museum_knowledge_service.dart';

class ChatAssistantService {
  final MuseumKnowledgeService _knowledge;
  final ConversationMemoryService _memory;

  ChatAssistantService({MuseumKnowledgeService? knowledge, ConversationMemoryService? memory})
      : _knowledge = knowledge ?? MuseumKnowledgeService(),
        _memory = memory ?? ConversationMemoryService();

  String _buildSystemPrompt(ChatContext context) {
    if (context.language == 'ar') {
      return 'أنت دليل متحف ذكي، أنيق، ودافئ. استخدم نهج قصصي ومعلوماتي. اجعله مختصراً ومفيداً. لا تكرر السؤال. لا تقول \'جاري المعالجة\'.';
    }
    return 'You are a smart museum guide assistant. Answer elegantly, helpfully and with storytelling style. Avoid generic phrases and don’t repeat the user question.';
  }

  String _pickExhibitResponse(Exhibit exhibit, String question, String language) {
    final title = exhibit.getName(language);
    final description = exhibit.getDescription(language);

    if (question.toLowerCase().contains('more') || question.toLowerCase().contains('tell me')) {
      return language == 'ar'
          ? 'هذا $title. $description' : 'The $title is an outstanding piece. $description';
    }
    return language == 'ar'
        ? '$title هو أحد المعروضات المهمة. $description'
        : '$title is one of the highlights. $description';
  }

  String _normalize(String input) => input.toLowerCase().replaceAll(RegExp(r'[\W_]'), ' ');

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
      return RegExp(r'\b(مرحبا|السلام|اهلا|كيف|صباح|مساء|هاي|ها)\b').hasMatch(normalized);
    }
    return RegExp(r'\b(hi|hello|hey|howdy|greetings|good morning|good afternoon|good evening)\b').hasMatch(normalized);
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

    // FAST PATH: Tickets
    if (normalized.contains('ticket') || normalized.contains('تذاكر') || 
        normalized.contains('price') || normalized.contains('سعر') || 
        normalized.contains('admission') || normalized.contains('الدخول')) {
      final answer = _knowledge.getTicketInfo(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Opening hours
    if (normalized.contains('hour') || normalized.contains('ساعات') || 
        normalized.contains('open') || normalized.contains('مفتوح') || 
        normalized.contains('timing') || normalized.contains('مواعيد')) {
      final answer = _knowledge.getMuseumHours(language: language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // FAST PATH: Events
    if (normalized.contains('event') || normalized.contains('فعاليات') || 
        normalized.contains('what is on') || normalized.contains('current')) {
      final event = MockDataService.getAllEvents().first;
      final answer = language == 'ar'
          ? 'الحدث القادم: ${event.titleAr}. ${event.descriptionAr} الساعة ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')} في ${event.locationAr}.'
          : 'Next event: ${event.titleEn}. ${event.descriptionEn} at ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')} in ${event.locationEn}.';
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
    if (matchedExhibit != null && (normalized.contains('tell') || normalized.contains('explain') || 
        normalized.contains('حدثني') || normalized.contains('اشرح'))) {
      final answer = _pickExhibitResponse(matchedExhibit, question, language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // Tour-aware: next stop
    if ((normalized.contains('next') || normalized.contains('التالي')) && tour?.nextExhibitId != null) {
      final nextExhibit = _knowledge.findExhibitById(tour!.nextExhibitId!);
      if (nextExhibit != null) {
        final answer = language == 'ar'
            ? 'المحطة التالية هي ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}'
            : 'Next stop is ${nextExhibit.getName(language)}. ${nextExhibit.getDescription(language)}';
        _memory.addAssistantMessage(answer);
        return answer;
      }
    }

    // If user is currently viewing an exhibit
    if (matchedExhibit != null) {
      final answer = _pickExhibitResponse(matchedExhibit, question, language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    // General fallback
    final fallback = language == 'ar'
        ? 'يمكنني مساعدتك في استكشاف المعروضات والفعاليات وساعات العمل والتذاكر. ماذا تود أن تعرف؟'
        : 'I can help you explore exhibits, events, hours, and tickets. What else can I help you with?';

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

