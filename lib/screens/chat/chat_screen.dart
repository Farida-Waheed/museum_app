import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/chat_message.dart';
import '../../models/chat_provider.dart';
import '../../models/app_session_provider.dart' as session;
import '../../models/auth_provider.dart';
import '../../models/tour_provider.dart';
import '../../models/tour_question.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs/premium_dialog.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../services/conversation_memory_service.dart';
import '../../services/chat_assistant_service.dart';
import '../../services/museum_knowledge_service.dart';
import '../../services/support_request_service.dart';
import '../../models/support_message.dart';
import '../../services/chat_context_builder.dart';
import '../../services/question_repository.dart';
import '../../services/robot_mqtt_service.dart';
import '../../models/robot_command.dart';

// ======================= Chat Screen ==========================
class ChatScreen extends StatefulWidget {
  final bool isPopup;
  final String screen;
  final String? currentExhibitId;
  const ChatScreen({
    super.key,
    this.isPopup = false,
    this.screen = 'home',
    this.currentExhibitId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// ================== Message Entry Animator ====================
class MessageEntryAnimator extends StatefulWidget {
  final Widget child;
  final bool isUser;
  const MessageEntryAnimator({
    super.key,
    required this.child,
    required this.isUser,
  });
  @override
  State<MessageEntryAnimator> createState() => _MessageEntryAnimatorState();
}

class _MessageEntryAnimatorState extends State<MessageEntryAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.isUser ? const Offset(0.08, 0) : const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SuggestionChipsCard extends StatelessWidget {
  final List<String> suggestions;
  final bool isArabic;
  final ValueChanged<String> onSuggestion;

  const _SuggestionChipsCard({
    required this.suggestions,
    required this.isArabic,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
      children: suggestions.map((s) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 150),
          child: OutlinedButton(
            style:
                TextButton.styleFrom(
                  backgroundColor: AppColors.primaryGold.withValues(
                    alpha: 0.16,
                  ),
                  foregroundColor: AppColors.resolvedTitleText,
                  side: BorderSide(
                    color: AppColors.primaryGold.withValues(alpha: 0.85),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    AppColors.primaryGold.withValues(alpha: 0.24),
                  ),
                ),
            onPressed: () {
              String query;
              if (isArabic) {
                switch (s) {
                  case var value when value == l10n.chatSuggestionTickets:
                    query = l10n.chatSuggestionTicketsQuery;
                    break;
                  case var value when value == l10n.chatSuggestionHours:
                    query = l10n.chatSuggestionHoursQuery;
                    break;
                  case var value when value == l10n.chatSuggestionEvents:
                    query = l10n.chatSuggestionEventsQuery;
                    break;
                  case var value when value == l10n.chatSuggestionDuration:
                    query = l10n.chatSuggestionDurationQuery;
                    break;
                  default:
                    query = s;
                }
              } else {
                switch (s) {
                  case var value when value == l10n.chatSuggestionTickets:
                    query = l10n.chatSuggestionTicketsQuery;
                    break;
                  case var value when value == l10n.chatSuggestionHours:
                    query = l10n.chatSuggestionHoursQuery;
                    break;
                  case var value when value == l10n.chatSuggestionEvents:
                    query = l10n.chatSuggestionEventsQuery;
                    break;
                  case var value when value == l10n.chatSuggestionDuration:
                    query = l10n.chatSuggestionDurationQuery;
                    break;
                  default:
                    query = s;
                }
              }
              onSuggestion(query);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                s,
                style: AppTextStyles.bodyPrimary(context).copyWith(
                  color: AppColors.resolvedTitleText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===================== Typing Indicator =======================
class _TypingIndicator extends StatefulWidget {
  final bool isArabic;
  const _TypingIndicator({required this.isArabic});
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _dots;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _dots = List.generate(
      3,
      (i) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.2 * i, 0.5 + 0.2 * i, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          l10n.chatLoading,
          style: AppTextStyles.metadata(context).copyWith(
            color: AppColors.resolvedMutedText,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 6),
        ..._dots.map(
          (ani) => AnimatedBuilder(
            animation: ani,
            builder: (_, __) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withAlpha(
                  (ani.value * 255).round(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== Bubbles ================================
class ChatBubble extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isArabicUI;

  const ChatBubble({super.key, required this.msg, required this.isArabicUI});

  bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = isUser
        ? AppColors.primaryGold
        : (isDark
              ? AppColors.darkSurfaceSecondary
              : AppColors.websiteLightPopover);
    final textColor = isUser
        ? AppColors.darkInk
        : (isDark ? AppColors.whiteTitle : AppColors.resolvedTitleText);

    final msgIsArabic = msg.kind == MessageKind.text
        ? _hasArabic(msg.text)
        : isArabicUI;
    final dir = msgIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser
          ? AppColors.primaryGold.withValues(alpha: 0.14)
          : (isDark
                ? AppColors.whiteTitle.withValues(alpha: 0.10)
                : AppColors.cardGlass(0.80)),
      child: isUser
          ? const Icon(
              Icons.person_outline,
              size: 16,
              color: AppColors.primaryGold,
            )
          : Image.asset(
              "assets/icons/horus_eye.png",
              width: 16,
              height: 16,
              color: isDark
                  ? AppColors.whiteTitle.withValues(alpha: 0.70)
                  : AppColors.resolvedMutedText,
            ),
    );

    Widget content = msg.kind == MessageKind.infoCard
        ? _InfoCardBubble(
            title: msg.cardTitle ?? '',
            items: msg.cardItems ?? const [],
            isUser: isUser,
            isArabic: msgIsArabic,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.isHumanSupport)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    AppLocalizations.of(context)!.humanSupport,
                    style: AppTextStyles.metadata(context).copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              Text(
                msg.text,
                textDirection: dir,
                style: AppTextStyles.bodyPrimary(context).copyWith(
                  color: textColor,
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: isUser ? FontWeight.w900 : FontWeight.normal,
                ),
              ),
            ],
          );

    final bubble = LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = constraints.maxWidth * (isUser ? 0.66 : 0.72);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 6),
                bottomRight: Radius.circular(isUser ? 6 : 20),
              ),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceShadow(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Directionality(textDirection: dir, child: content),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [Flexible(child: bubble), const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), Flexible(child: bubble)],
      ),
    );
  }
}

class _InfoCardBubble extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isUser;
  final bool isArabic;
  const _InfoCardBubble({
    required this.title,
    required this.items,
    required this.isUser,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = AppTextStyles.titleMedium(context).copyWith(
      fontWeight: FontWeight.w900,
      color: isUser
          ? AppColors.darkInk
          : (isDark ? AppColors.whiteTitle : AppColors.resolvedTitleText),
      fontSize: 15,
      letterSpacing: 0.2,
    );

    final itemStyle = AppTextStyles.bodyPrimary(context).copyWith(
      color: isUser
          ? AppColors.darkInk.withValues(alpha: 0.8)
          : (isDark
                ? AppColors.whiteTitle.withValues(alpha: 0.9)
                : AppColors.resolvedBodyText),
      fontSize: 14,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: isUser ? AppColors.darkInk : AppColors.primaryGold,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: titleStyle)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (it) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "- ",
                  style: itemStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                Expanded(child: Text(it, style: itemStyle)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final LayerLink _infoLink = LayerLink();
  bool _isTyping = false;
  bool _showScrollBtn = false;
  bool _canSend = false;
  bool _showHelperPanel = false;
  late final ChatProvider _chatProvider;
  late final ConversationMemoryService _conversationMemory;
  late final ChatAiService _assistantService;
  late final SupportRequestService _supportService;
  late final QuestionRepository _questionRepository;

  late final StreamSubscription _supportSubscription;
  final List<StreamSubscription<TourQuestion?>> _questionSubscriptions = [];
  final Set<String> _answeredQuestionIds = {};

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.clear(); // reset on each popup open for Ask Horus fallback.
    _conversationMemory = ConversationMemoryService();
    _assistantService = LocalMuseumChatService(
      knowledge: MuseumKnowledgeService(),
      memory: _conversationMemory,
    );
    _supportService = SupportRequestService();
    _questionRepository = QuestionRepository();
    _scroll.addListener(_scrollChecker);
    _controller.addListener(() {
      final ok = _controller.text.trim().isNotEmpty;
      if (ok != _canSend) setState(() => _canSend = ok);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _chatProvider.ensureGreeting(_modeGreeting(l10n));
      // Ensure we scroll to bottom once the greeting message is added.
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        _scrollToBottom();
      });
    });

    _supportSubscription = _supportService.onReply.listen((message) {
      if (!mounted) return;
      _chatProvider.addMessage(
        ChatMessageModel.humanSupport(
          id: message.id,
          timestamp: message.timestamp,
          text: message.text,
        ),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    });
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  AskHorusMode _askHorusMode({
    AuthProvider? authProvider,
    session.AppSessionProvider? sessionProvider,
    TourProvider? tourProvider,
  }) {
    final auth =
        authProvider ?? Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) return AskHorusMode.guest;

    final appSession =
        sessionProvider ??
        Provider.of<session.AppSessionProvider>(context, listen: false);
    final tour =
        tourProvider ?? Provider.of<TourProvider>(context, listen: false);

    final activeTour =
        appSession.tourLifecycleState == session.TourLifecycleState.active ||
        appSession.tourLifecycleState == session.TourLifecycleState.paused ||
        tour.tourLifecycleState == TourLifecycleState.active ||
        tour.tourLifecycleState == TourLifecycleState.paused;
    if (activeTour) return AskHorusMode.activeTour;

    final completedTour =
        appSession.tourLifecycleState ==
            session.TourLifecycleState.completed ||
        tour.tourLifecycleState == TourLifecycleState.completed;
    if (completedTour) return AskHorusMode.completedTour;

    return AskHorusMode.loggedIn;
  }

  String _modeTitle(AskHorusMode mode) {
    switch (mode) {
      case AskHorusMode.guest:
        return 'Ask Horus Preview';
      case AskHorusMode.activeTour:
        return 'Ask the Robot Guide';
      case AskHorusMode.completedTour:
      case AskHorusMode.loggedIn:
        return 'Ask Horus';
    }
  }

  String _modeSubtitle(AskHorusMode mode) {
    switch (mode) {
      case AskHorusMode.guest:
        return 'Ask about the museum, tickets, and how the app works.';
      case AskHorusMode.loggedIn:
        return 'Ask about tickets, booking, facilities, exhibits, and app help.';
      case AskHorusMode.activeTour:
        return 'Ask about the current exhibit, next stop, or your tour.';
      case AskHorusMode.completedTour:
        return 'Ask about your visit summary, memories, or booking another tour.';
    }
  }

  bool _isRobotQuestion(String text) {
    final lower = text.toLowerCase();
    return lower.contains('current exhibit') ||
        lower.contains('next exhibit') ||
        lower.contains('next stop') ||
        lower.contains('this artifact') ||
        lower.contains('this exhibit') ||
        lower.contains('explain') ||
        lower.contains('tell me about') ||
        lower.contains('story') ||
        lower.contains('history') ||
        lower.contains('المعرض الحالي') ||
        lower.contains('المحطة التالية') ||
        lower.contains('اشرح') ||
        lower.contains('حدثني') ||
        lower.contains('قصة');
  }

  String _robotUnavailableMessage() {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? 'تعذر الوصول إلى دليل الروبوت الآن، لكن يمكنني مساعدتك بمعلومات عامة عن المتحف والتطبيق.'
        : 'I could not reach the robot guide right now, but I can still help with general museum and app information.';
  }

  String _askingRobotMessage() {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? 'سأسأل دليل الروبوت عن ذلك.'
        : 'Let me ask the robot guide about this.';
  }

  String _modeGreeting(AppLocalizations l10n) {
    final mode = _askHorusMode();
    if (Localizations.localeOf(context).languageCode != 'ar') {
      return mode == AskHorusMode.activeTour
          ? 'Tour mode: Ask Horus about this exhibit, the next stop, or the robot guide.'
          : 'Ask Horus about tickets, prices, facilities, exhibits, and app help.';
    }
    return mode == AskHorusMode.activeTour
        ? 'وضع الجولة: اسأل حورس عن المعروض الحالي، المحطة التالية، أو دليل الروبوت.'
        : 'اسأل حورس عن التذاكر، الأسعار، المرافق، المعروضات، واستخدام التطبيق.';

    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final isTourMode =
        widget.currentExhibitId != null ||
        sessionProvider.hasRestorableTourSession ||
        (tourProvider.activeSessionId != null &&
            tourProvider.tourLifecycleState != TourLifecycleState.completed);

    if (prefs.language == 'ar') {
      return isTourMode
          ? 'وضع الجولة: اسأل حورس عن المعروض الحالي، المحطة التالية، أو دليل الروبوت.'
          : 'اسأل حورس عن التذاكر، الأسعار، المرافق، المعروضات، واستخدام التطبيق.';
    }
    return isTourMode
        ? 'Tour mode: Ask Horus about this exhibit, the next stop, or the robot guide.'
        : 'Ask Horus about tickets, prices, facilities, exhibits, and app help.';
  }

  void _scrollChecker() {
    if (!_scroll.hasClients) return;
    final atBottom =
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200;
    if (_showScrollBtn == atBottom) setState(() => _showScrollBtn = !atBottom);
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _addMessage(ChatMessageModel m) {
    _chatProvider.addMessage(m);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_showScrollBtn) _scrollToBottom();
    });
  }

  void _requestHumanSupport({String userQuestion = ''}) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _typeBotMessage(
        Localizations.localeOf(context).languageCode == 'ar'
            ? 'سجل الدخول للتواصل مع دعم المتحف ومتابعة محادثاتك.'
            : 'Sign in to contact museum support and track your conversations.',
      );
      return;
    }

    final requestName = l10n.guestUser;
    final contextData = ChatContextBuilder.build(
      context,
      screen: widget.screen,
      exhibitId: widget.currentExhibitId,
      userQuestion: userQuestion,
    );
    final initialMessages = _chatProvider.messages.map((message) {
      final sender = message.isUser
          ? SupportSender.user
          : SupportSender.assistant;
      final text = message.kind == MessageKind.text
          ? message.text
          : message.cardTitle ?? '';
      return SupportMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: sender,
        text: text,
        timestamp: message.timestamp,
      );
    }).toList();

    _supportService.createRequest(
      requesterId: 'visitor_${DateTime.now().millisecondsSinceEpoch}',
      requesterName: requestName,
      screen: widget.screen,
      contextSummary: contextData.toString(),
      initialMessages: initialMessages,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.humanSupportAck),
          backgroundColor: AppColors.primaryGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _addMessage(
      ChatMessageModel.card(
        id: _id(),
        isUser: false,
        timestamp: DateTime.now(),
        cardTitle: l10n.humanSupportRequested,
        cardItems: [l10n.humanSupportRequestPending],
      ),
    );
  }

  void _submitQuickQuestion(String query) {
    _showHelperPanel = false;
    _submit(query);
  }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.selectionClick();
    _controller.clear();
    _addMessage(
      ChatMessageModel.text(
        id: _id(),
        isUser: true,
        timestamp: DateTime.now(),
        text: trimmed,
      ),
    );

    final isSupportRequest = _assistantService.isHumanSupportRequest(trimmed);
    setState(() {
      _canSend = false;
      _isTyping = isSupportRequest;
      _showHelperPanel = false;
    });

    if (isSupportRequest) {
      _requestHumanSupport(userQuestion: trimmed);
      setState(() => _isTyping = false);
      return;
    }

    final mode = _askHorusMode();
    if (_isGuestPersonalQuestion(trimmed)) {
      setState(() => _isTyping = false);
      _typeBotMessage(
        Localizations.localeOf(context).languageCode == 'ar'
            ? 'سجل الدخول وابدأ جولة حتى أستطيع مساعدتك في تذاكرك ومسارك وذكرياتك وتقدم جولتك المباشر.'
            : 'Please log in to view or manage your tickets and bookings.',
      );
      return;
    }

    if (mode == AskHorusMode.activeTour && _isRobotQuestion(trimmed)) {
      unawaited(
        _sendSessionQuestionToFirestore(trimmed).then((sent) {
          if (!mounted) return;
          setState(() => _isTyping = false);
          _typeBotMessage(
            sent ? _askingRobotMessage() : _robotUnavailableMessage(),
          );
        }),
      );
      return;
    }

    final contextData = ChatContextBuilder.build(
      context,
      screen: widget.screen,
      exhibitId: widget.currentExhibitId,
      userQuestion: trimmed,
    );

    Future.microtask(() async {
      if (!mounted) return;
      final response = await _assistantService.generateAnswer(
        question: trimmed,
        context: contextData,
        mode: mode,
      );
      if (!mounted) return;
      setState(() => _isTyping = false);
      _typeBotMessage(response);
    });
  }

  bool _isGuestPersonalQuestion(String text) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) return false;
    final lower = text.toLowerCase();
    final asksPersonal =
        lower.contains('my ticket') ||
        lower.contains('my payment') ||
        lower.contains('payment status') ||
        lower.contains('continue my tour') ||
        lower.contains('resume my') ||
        lower.contains('my robot') ||
        lower.contains('where is horus') ||
        lower.contains('where is my robot') ||
        lower.contains('my memories') ||
        lower.contains('my photos') ||
        lower.contains('my next exhibit') ||
        lower.contains('my route') ||
        lower.contains('my session');
    final asksArabicPersonal =
        text.contains('تذكرتي') ||
        text.contains('تذاكري') ||
        text.contains('دفعي') ||
        text.contains('مساري') ||
        text.contains('جولتي') ||
        text.contains('روبوتي') ||
        text.contains('ذكرياتي') ||
        text.contains('صوري') ||
        text.contains('موقعي') ||
        text.contains('أين حورس');
    return asksPersonal || asksArabicPersonal;
  }

  void _typeBotMessage(String fullText) {
    final botMsg = ChatMessageModel.text(
      id: _id(),
      isUser: false,
      timestamp: DateTime.now(),
      text: fullText,
    );
    _addMessage(botMsg);
  }

  Future<bool> _sendSessionQuestionToFirestore(String question) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    final userId = authProvider.currentUser?.id;
    final sessionId =
        sessionProvider.activeSessionId ?? tourProvider.activeSessionId;
    final robotId =
        sessionProvider.connectedRobotId ?? tourProvider.connectedRobotId;
    final hasQuestionSession =
        sessionProvider.hasRestorableTourSession ||
        (tourProvider.activeSessionId != null &&
            tourProvider.tourLifecycleState != TourLifecycleState.completed);
    if (!authProvider.isLoggedIn ||
        userId == null ||
        sessionId == null ||
        !hasQuestionSession) {
      return false;
    }

    final isActiveTour =
        sessionProvider.tourLifecycleState == session.TourLifecycleState.active ||
        sessionProvider.tourLifecycleState == session.TourLifecycleState.paused ||
        tourProvider.tourLifecycleState == TourLifecycleState.active ||
        tourProvider.tourLifecycleState == TourLifecycleState.paused;
    if (!isActiveTour) return false;
    if (robotId == null || robotId.isEmpty) return false;

    try {
      final createdQuestion = await _questionRepository.createAppQuestion(
        userId: userId,
        sessionId: sessionId,
        robotId: robotId,
        exhibitId:
            widget.currentExhibitId ??
            sessionProvider.currentExhibitId ??
            tourProvider.currentExhibitId,
        question: question,
        language: prefs.language,
      );
      _listenForQuestionAnswer(createdQuestion.questionId);
      return _sendAppQuestionToRobotBridge(
        question: question,
        sessionId: sessionId,
        userId: userId,
        robotId: robotId,
      );
    } on QuestionRepositoryException catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  Future<bool> _sendAppQuestionToRobotBridge({
    required String question,
    required String sessionId,
    required String userId,
    required String? robotId,
  }) async {
    if (kIsWeb || robotId == null || robotId.isEmpty) return false;
    final command = RobotCommand(
      type: RobotCommandType.appQuestion,
      sessionId: sessionId,
      robotId: robotId,
      userId: userId,
      payload: {'text': question.trim()},
    );
    final published = await context.read<RobotMqttService>().publishCommand(
      command,
    );
    if (!published) {
      debugPrint('MQTT app_question publish skipped or failed.');
    }
    return published;
  }

  void _listenForQuestionAnswer(String questionId) {
    final subscription = _questionRepository.watchQuestion(questionId).listen((
      question,
    ) {
      if (!mounted || question == null) return;
      final answer = question.answer?.trim();
      if (question.status != TourQuestionStatus.answered ||
          answer == null ||
          answer.isEmpty ||
          _answeredQuestionIds.contains(question.questionId)) {
        return;
      }
      _answeredQuestionIds.add(question.questionId);
      _addMessage(
        ChatMessageModel.text(
          id: question.questionId,
          isUser: false,
          timestamp: question.answeredAt ?? DateTime.now(),
          text: answer,
        ),
      );
    });
    _questionSubscriptions.add(subscription);
  }

  @override
  void dispose() {
    _supportSubscription.cancel();
    for (final subscription in _questionSubscriptions) {
      subscription.cancel();
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<UserPreferencesModel>(context).language == "ar";
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final tourProvider = Provider.of<TourProvider>(context);
    final mode = _askHorusMode(
      authProvider: authProvider,
      sessionProvider: sessionProvider,
      tourProvider: tourProvider,
    );
    final modeTitle = _modeTitle(mode);
    final modeSubtitle = _modeSubtitle(mode);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    modeSubtitle,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.resolvedMutedText),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    final messages = chat.messages;
                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        if (!m.isUser &&
                            m.kind == MessageKind.infoCard &&
                            m.cardTitle?.toLowerCase().contains('quick') ==
                                true) {
                          return MessageEntryAnimator(
                            isUser: m.isUser,
                            child: _SuggestionChipsCard(
                              suggestions: m.cardItems ?? [],
                              isArabic: isArabic,
                              onSuggestion: (value) => _submit(value),
                            ),
                          );
                        }
                        return MessageEntryAnimator(
                          isUser: m.isUser,
                          child: ChatBubble(msg: m, isArabicUI: isArabic),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _TypingIndicator(isArabic: isArabic),
                  ),
                ),

              // INPUT AREA
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        onSubmitted: _submit,
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          color: isDark
                              ? AppColors.whiteTitle
                              : AppColors.darkInk,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.chatInputHint,
                          hintStyle: AppTextStyles.bodyPrimary(context)
                              .copyWith(
                                color: isDark
                                    ? AppColors.whiteTitle.withValues(
                                        alpha: 0.54,
                                      )
                                    : AppColors.resolvedMutedText,
                              ),
                          fillColor: isDark
                              ? AppColors.whiteTitle.withValues(alpha: 0.06)
                              : AppColors.websiteLightPopover,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedScale(
                      scale: _canSend ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 200),
                      child: CircleAvatar(
                        backgroundColor: _canSend
                            ? AppColors.primaryGold
                            : (isDark
                                  ? AppColors.whiteTitle.withValues(alpha: 0.10)
                                  : AppColors.websiteLightBackground),
                        radius: 22,
                        child: IconButton(
                          onPressed: _canSend
                              ? () => _submit(_controller.text)
                              : null,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _canSend
                                ? AppColors.darkInk
                                : AppColors.resolvedMutedText,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  children: [
                    CompositedTransformTarget(
                      link: _infoLink,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.primaryGold,
                            ),
                            onPressed: () => setState(
                              () => _showHelperPanel = !_showHelperPanel,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.moreInfo,
                            style: AppTextStyles.metadata(context).copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.support_agent_outlined,
                          size: 18,
                        ),
                        label: Flexible(
                          child: Text(
                            l10n.humanSupportLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.metadata(
                              context,
                            ).copyWith(color: AppColors.primaryGold),
                          ),
                        ),
                        onPressed: () => _requestHumanSupport(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          foregroundColor: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

    final helperItems = {
      l10n.chatSuggestionTickets: l10n.chatSuggestionTicketsQuery,
      l10n.chatSuggestionHours: l10n.chatSuggestionHoursQuery,
      l10n.chatSuggestionEvents: l10n.chatSuggestionEventsQuery,
      l10n.chatSuggestionDuration: l10n.chatSuggestionDurationQuery,
      l10n.chatSuggestionDirections: l10n.chatSuggestionDirectionsQuery,
      l10n.chatSuggestionAccessibility: l10n.chatSuggestionAccessibilityQuery,
    };

    final contentWithFloatingHelper = Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        if (_showHelperPanel)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _showHelperPanel = false),
              child: const SizedBox.shrink(),
            ),
          ),
        if (_showHelperPanel)
          CompositedTransformFollower(
            link: _infoLink,
            showWhenUnlinked: false,
            targetAnchor: AlignmentDirectional.topStart.resolve(
              Directionality.of(context),
            ),
            followerAnchor: isArabic
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            offset: const Offset(0, -12),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: math.min(
                      MediaQuery.of(context).size.width * 0.72,
                      280,
                    ),
                    decoration: AppDecorations.secondaryGlassCard(
                      radius: 22,
                      opacity: 0.72,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.quickHelpTopics,
                          style: AppTextStyles.premiumSectionLabel(
                            context,
                          ).copyWith(color: AppColors.softGold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: isArabic
                              ? WrapAlignment.end
                              : WrapAlignment.start,
                          children: helperItems.entries.map((entry) {
                            return InkWell(
                              onTap: () => _submitQuickQuestion(entry.value),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardGlass(0.42),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.goldBorder(0.34),
                                  ),
                                ),
                                child: Text(
                                  entry.key,
                                  style: AppTextStyles.bodyPrimary(context)
                                      .copyWith(
                                        color: AppColors.resolvedTitleText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.isPopup) {
      return PremiumDialog(
        title: modeTitle,
        icon: Image.asset("assets/icons/horus_eye.png", width: 24, height: 24),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: contentWithFloatingHelper,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.resolvedBackground,
      appBar: AppBar(
        title: Text(
          modeTitle.toUpperCase(),
          style: AppTextStyles.displayScreenTitle(context).copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.resolvedTitleText,
          ),
        ),
        backgroundColor: AppColors.resolvedBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.resolvedTitleText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: contentWithFloatingHelper,
      ),
      floatingActionButton: _showScrollBtn
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkInk,
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }
}
