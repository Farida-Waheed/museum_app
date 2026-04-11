import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../models/user_preferences.dart';
import '../../models/chat_message.dart';
import '../../models/chat_provider.dart';
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

  late final StreamSubscription _supportSubscription;

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
    _supportSubscription.cancel();
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
                  backgroundColor: AppColors.primaryGold.withOpacity(0.16),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.primaryGold.withOpacity(0.85),
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
                    AppColors.primaryGold.withOpacity(0.24),
                  ),
                ),
            onPressed: () {
              String query;
              if (isArabic) {
                switch (s) {
                  case 'تذاكر':
                    query = 'ما أسعار التذاكر وأنواعها؟';
                    break;
                  case 'مواعيد':
                    query = 'ما مواعيد العمل اليوم؟';
                    break;
                  case 'فعاليات':
                    query = 'ما الفعاليات المتاحة اليوم؟';
                    break;
                  case 'المدة':
                    query = 'كم تستغرق الزيارة عادة؟';
                    break;
                  default:
                    query = s;
                }
              } else {
                switch (s) {
                  case 'Tickets':
                    query = 'Tell me about ticket prices and ticket types.';
                    break;
                  case 'Hours':
                    query = 'What are today\'s opening hours?';
                    break;
                  case 'Events':
                    query = 'What events are happening today?';
                    break;
                  case 'Duration':
                    query = 'How long does the visit usually take?';
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
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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

  late final StreamSubscription _supportSubscription;

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
    _supportSubscription.cancel();
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
            color: AppColors.neutralMedium,
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
        : (isDark ? AppColors.darkSurfaceSecondary : Colors.grey.shade100);
    final textColor = isUser
        ? AppColors.darkInk
        : (isDark ? Colors.white : Colors.black87);

    final msgIsArabic = msg.kind == MessageKind.text
        ? _hasArabic(msg.text)
        : isArabicUI;
    final dir = msgIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser
          ? AppColors.primaryGold.withOpacity(0.1)
          : (isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.shade50),
      child: isUser
          ? const Icon(
              Icons.person_outline,
              size: 16,
              color: AppColors.primaryGold,
            )
          : Image.asset(
              "assets/icons/ankh.png",
              width: 16,
              height: 16,
              color: isDark ? Colors.white70 : Colors.black54,
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
                    isArabicUI ? 'الدعم البشري' : 'Human Support',
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
                  height: 1.5,
                  fontWeight: isUser ? FontWeight.w900 : FontWeight.normal,
                ),
              ),
            ],
          );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Directionality(textDirection: dir, child: content),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [bubble, const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), bubble],
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
          : (isDark ? Colors.white : Colors.black),
      fontSize: 15,
      letterSpacing: 0.2,
    );

    final itemStyle = AppTextStyles.bodyPrimary(context).copyWith(
      color: isUser
          ? AppColors.darkInk.withOpacity(0.8)
          : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
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
                  "• ",
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
  Timer? _typeTimer;
  late final ChatProvider _chatProvider;
  late final ConversationMemoryService _conversationMemory;
  late final ChatAiService _assistantService;
  late final SupportRequestService _supportService;

  late final StreamSubscription _supportSubscription;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.clear(); // reset on each popup open, per new AskTheGuide UX.
    _conversationMemory = ConversationMemoryService();
    _assistantService = LocalMuseumChatService(
      knowledge: MuseumKnowledgeService(),
      memory: _conversationMemory,
    );
    _supportService = SupportRequestService();
    _scroll.addListener(_scrollChecker);
    _controller.addListener(() {
      final ok = _controller.text.trim().isNotEmpty;
      if (ok != _canSend) setState(() => _canSend = ok);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final isArabic =
          Provider.of<UserPreferencesModel>(context, listen: false).language ==
          'ar';
      _chatProvider.ensureGreeting(isArabic: isArabic);
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
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
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
      );
      if (!mounted) return;
      setState(() => _isTyping = false);
      _typeBotMessage(response);
    });
  }

  void _typeBotMessage(String fullText) {
    _typeTimer?.cancel();
    final botMsg = ChatMessageModel.text(
      id: _id(),
      isUser: false,
      timestamp: DateTime.now(),
      text: fullText,
    );
    _addMessage(botMsg);
  }

  @override
  void dispose() {
    _supportSubscription.cancel();
    _typeTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<UserPreferencesModel>(context).language == "ar";
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      children: [
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
                      m.cardTitle?.toLowerCase().contains('quick') == true) {
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
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: _TypingIndicator(isArabic: isArabic),
            ),
          ),

        // INPUT AREA
        Container(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onSubmitted: _submit,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: isDark ? Colors.white : AppColors.darkInk),
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
                    hintStyle: AppTextStyles.bodyPrimary(
                      context,
                    ).copyWith(color: isDark ? Colors.white38 : Colors.black38),
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade50,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedScale(
                scale: _canSend ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  backgroundColor: _canSend
                      ? AppColors.primaryGold
                      : (isDark ? Colors.white10 : Colors.grey.shade100),
                  radius: 22,
                  child: IconButton(
                    onPressed: _canSend
                        ? () => _submit(_controller.text)
                        : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: _canSend ? AppColors.darkInk : Colors.grey,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CompositedTransformTarget(
                  link: _infoLink,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
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
              ),
              Flexible(
                child: TextButton.icon(
                  icon: const Icon(Icons.support_agent_outlined, size: 18),
                  label: Text(
                    l10n.humanSupportLabel,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.primaryGold),
                  ),
                  onPressed: () => _requestHumanSupport(),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final helperItems = isArabic
        ? {
            'التذاكر': 'ما أسعار التذاكر وأنواعها؟',
            'المواعيد': 'ما هي أوقات عمل المتحف اليوم؟',
            'الفعاليات': 'ما الفعاليات المتاحة اليوم؟',
            'المدة': 'كم تستغرق الزيارة عادة؟',
            'الاتجاهات': 'كيف أصل إلى المعرض التالي؟',
            'إمكانية الوصول': 'هل هناك وسائل وصول لذوي الاحتياجات الخاصة؟',
          }
        : {
            'Tickets': 'Tell me about ticket prices and types.',
            'Hours': 'What are today\'s opening hours?',
            'Events': 'What events are happening today?',
            'Duration': 'How long does a visit usually take?',
            'Directions': 'How do I get to the next exhibit?',
            'Accessibility': 'What accessibility support is available?',
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
            targetAnchor: isArabic
                ? Alignment.topRight
                : Alignment.topLeft,
            followerAnchor: isArabic ? Alignment.bottomRight : Alignment.bottomLeft,
            offset: const Offset(0, -12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: math.min(MediaQuery.of(context).size.width * 0.72, 280),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                      style: AppTextStyles.titleMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
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
                              color: AppColors.primaryGold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              entry.key,
                              style: AppTextStyles.bodyPrimary(context)
                                  .copyWith(
                                    color: Colors.white,
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
      ],
    );

    if (widget.isPopup) {
      return PremiumDialog(
        title: l10n.askTheGuide,
        icon: Image.asset("assets/icons/ankh.png", width: 24, height: 24),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: contentWithFloatingHelper,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.askTheGuide.toUpperCase(),
          style: AppTextStyles.displayScreenTitle(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkHeader : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
