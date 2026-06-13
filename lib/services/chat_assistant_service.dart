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

  bool _containsAny(String normalized, List<String> terms) {
    return terms.any(normalized.contains);
  }

  bool _isBookingIntent(String normalized) {
    return _containsAny(normalized, [
      'book',
      'booking',
      'buy',
      'purchase',
      'reserve',
      'another ticket',
      'more tickets',
      'حجز',
      'احجز',
      'شراء',
    ]);
  }

  bool _isPaymentIntent(String normalized) {
    return _containsAny(normalized, [
      'payment',
      'pay',
      'counter',
      'cash',
      'paid',
      'pending',
      'دفع',
      'الشباك',
      'كاش',
    ]);
  }

  bool _isRulesIntent(String normalized) {
    return _containsAny(normalized, [
      'rule',
      'entry',
      'children',
      'child',
      'adult',
      'student',
      'id',
      'قواعد',
      'دخول',
      'أطفال',
      'طفل',
      'بالغ',
      'طالب',
    ]);
  }

  bool _isFacilityIntent(String normalized) {
    return _containsAny(normalized, [
      'toilet',
      'restroom',
      'bathroom',
      'wc',
      'facility',
      'facilities',
      'دورة',
      'حمام',
      'مرافق',
    ]);
  }

  bool _isAccessibilityIntent(String normalized) {
    return _containsAny(normalized, [
      'accessibility',
      'wheelchair',
      'disabled',
      'mobility',
      'accessible',
      'إتاحة',
      'كرسي',
      'احتياجات',
    ]);
  }

  bool _isQrIntent(String normalized) {
    return _containsAny(normalized, [
      'qr',
      'scan',
      'scanner',
      'code',
      'مسح',
      'رمز',
      'كود',
    ]);
  }

  bool _isRobotTourIntent(String normalized) {
    return _containsAny(normalized, [
      'robot',
      'horus',
      'tour',
      'start',
      'pair',
      'guide',
      'روبوت',
      'حورس',
      'جولة',
      'اقتران',
    ]);
  }

  bool _isAppHelpIntent(String normalized) {
    return _containsAny(normalized, [
      'app',
      'my tickets',
      'wallet',
      'profile',
      'how to use',
      'navigation',
      'تذاكري',
      'التطبيق',
      'استخدم',
    ]);
  }

  String _answerBooking(String language) {
    if (language == 'ar') {
      return 'للحجز: افتح شراء التذاكر، اختر عدد الزوار، اختر نوع جولة Horus-Bot، حدد التاريخ والوقت، ثم أكد الحجز. يمكنك حجز أكثر من زيارة مستقبلية، والتذاكر الحالية لا تمنع شراء تذاكر إضافية.';
    }
    return 'To book: open Buy Tickets, choose visitor quantities, choose the Horus-Bot tour type, select visit date and time, then confirm. You can book more than one future visit; existing tickets do not block extra tickets.';
  }

  String _answerTickets(String language) {
    if (language == 'ar') {
      return 'أسعار التذاكر: مصري بالغ 200 جنيه، مصري طالب أو طفل 100 جنيه، أجنبي بالغ 1450 جنيه، أجنبي طالب أو طفل 730 جنيه. جولة Horus-Bot القياسية 200 جنيه، والجولة المخصصة 350 جنيه.';
    }
    return 'Ticket prices: Egyptian Adult EGP 200, Egyptian Student/Child EGP 100, Foreigner Adult EGP 1450, Foreigner Student/Child EGP 730. Horus-Bot Standard Tour is EGP 200 and Personalized Tour is EGP 350.';
  }

  String _answerPayment(String language) {
    if (language == 'ar') {
      return 'الدفع الحالي عند شباك المتحف. ستظهر التذكرة كـ "بانتظار الدفع عند الشباك" حتى يؤكد الكاشير الدفع. بعد التأكيد تصبح التذكرة جاهزة للاستخدام.';
    }
    return 'Payment is currently at the museum counter. Your ticket stays "Pending payment at counter" until a cashier confirms it. After confirmation, it becomes ready to use.';
  }

  String _answerRules(String language) {
    if (language == 'ar') {
      return 'قواعد الدخول: اختر تاريخ ووقت الزيارة، والتزم بالحد الأقصى للزوار في الحجز. لا يمكن حجز تذاكر أطفال فقط؛ يجب أن يكون مع الأطفال تذكرة بالغ واحدة على الأقل. تذاكر الطلاب منفصلة وقد تتطلب بطاقة طالب.';
    }
    return 'Entry rules: choose a visit date and time and stay within the visitor limit. Child-only bookings are not allowed; children must be accompanied by at least one adult in the same booking. Student tickets are separate and may require student ID.';
  }

  String _answerFacilities(String language) {
    if (language == 'ar') {
      return 'دورات المياه والمرافق تكون عادة قرب المدخل والممرات الرئيسية. إذا كنت داخل المتحف، اتبع لافتات WC أو اسأل أحد موظفي القاعة عن أقرب دورة مياه.';
    }
    return 'Restrooms and facilities are usually near the entrance and main corridors. Inside the museum, follow WC signs or ask hall staff for the nearest restroom.';
  }

  String _answerAccessibility(String language) {
    if (language == 'ar') {
      return 'يمكنك ضبط اللغة والتباين وحجم النص من الإعدادات. إذا كانت لديك احتياجات وصول أثناء الجولة، أضفها في تخصيص الجولة أو اطلب مساعدة الموظفين عند الوصول.';
    }
    return 'You can adjust language, contrast, and text size in Settings. For tour accessibility needs, add them during tour customization or ask museum staff when you arrive.';
  }

  String _answerQr(String language) {
    if (language == 'ar') {
      return 'لاستخدام QR: ادفع عند الشباك أولاً حتى تصبح التذكرة جاهزة. بعد التأكيد افتح تذاكري واعرض QR دخول المتحف. لبدء جولة الروبوت امسح QR الفعلي الموجود على Horus-Bot.';
    }
    return 'To use QR: pay at the counter first so the ticket becomes ready. After confirmation, open My Tickets and show the Museum Entry QR. To start a robot tour, scan the physical QR on Horus-Bot.';
  }

  String _answerRobotTour(String language, ChatContext context) {
    final tour = context.tourState;
    final hasTourContext =
        tour?.currentExhibitId != null || tour?.nextExhibitId != null;
    if (language == 'ar') {
      return hasTourContext
          ? 'أنت في وضع الجولة. يمكنني مساعدتك في المعروض الحالي، المحطة التالية، وأسئلة استخدام الروبوت. إذا لم يتوفر اتصال الروبوت، سأعتمد على معلومات المتحف المحلية.'
          : 'لبدء جولة الروبوت: احجز تذكرة جولة، ادفع عند الشباك، ثم من التطبيق امسح QR الفعلي على Horus-Bot عند الوصول. بعد الاقتران افتح الجولة الحية.';
    }
    return hasTourContext
        ? 'You are in tour mode. I can help with the current exhibit, next stop, and robot-guide questions. If robot services are unavailable, I will fall back to local museum knowledge.'
        : 'To start a robot tour: book a robot tour ticket, pay at the counter, then scan the physical QR on Horus-Bot when you arrive. After pairing, open Live Tour.';
  }

  String _answerAppHelp(String language) {
    if (language == 'ar') {
      return 'استخدم تذاكري لمتابعة حالة الحجز، الدفع، تذكرة دخول المتحف، وتذكرة جولة الروبوت. استخدم شراء التذاكر لحجز زيارة أخرى في أي وقت.';
    }
    return 'Use My Tickets to track booking status, payment, the Museum Entry Ticket, and the Robot Tour Ticket. Use Buy Tickets any time to book another visit.';
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

    if (_isBookingIntent(normalized)) {
      final answer = _answerBooking(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isPaymentIntent(normalized)) {
      final answer = _answerPayment(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isTicketIntent(normalized)) {
      final answer = _answerTickets(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isRulesIntent(normalized)) {
      final answer = _answerRules(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isFacilityIntent(normalized)) {
      final answer = _answerFacilities(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isAccessibilityIntent(normalized)) {
      final answer = _answerAccessibility(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isQrIntent(normalized)) {
      final answer = _answerQr(language);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isRobotTourIntent(normalized)) {
      final answer = _answerRobotTour(language, context);
      _memory.addAssistantMessage(answer);
      return answer;
    }

    if (_isAppHelpIntent(normalized)) {
      final answer = _answerAppHelp(language);
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
