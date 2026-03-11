import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../../l10n/app_localizations.dart';

// ======================= Chat Screen ==========================
class ChatScreen extends StatefulWidget {
  final bool isPopup;
  const ChatScreen({super.key, this.isPopup = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// ======================= Models ===============================
enum MessageKind { text, infoCard }

class ChatMessageModel {
  final String id;
  final bool isUser;
  final DateTime timestamp;
  final MessageKind kind;

  // for text
  final String text;

  // for card
  final String? cardTitle;
  final List<String>? cardItems;

  ChatMessageModel.text({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.text,
  })  : kind = MessageKind.text,
        cardTitle = null,
        cardItems = null;

  ChatMessageModel.card({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.cardTitle,
    required this.cardItems,
  })  : kind = MessageKind.infoCard,
        text = '';
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
    final text = widget.isArabic ? "حوروس يكتب..." : "Horus-Bot is typing...";

    return Row(
      children: [
        Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontStyle: FontStyle.italic)),
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
                color: Colors.grey.shade400.withAlpha(
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
    final theme = Theme.of(context);
    final isUser = msg.isUser;

    final bubbleColor = isUser ? const Color(0xFFE6C068) : const Color(0xFF1E1912);
    final textColor = isUser ? const Color(0xFF1E1912) : const Color(0xFFF5F1E8);

    final msgIsArabic = msg.kind == MessageKind.text ? _hasArabic(msg.text) : isArabicUI;
    final dir = msgIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser
          ? const Color(0xFFE6C068).withOpacity(0.1)
          : const Color(0xFF1E1912),
      child: isUser
          ? const Icon(Icons.person_outline, size: 16, color: Color(0xFFE6C068))
          : const Icon(Icons.smart_toy_rounded, size: 16, color: Color(0xFFE6C068)),
    );

    Widget content;
    if (msg.kind == MessageKind.infoCard) {
      content = _InfoCardBubble(
        title: msg.cardTitle ?? '',
        items: msg.cardItems ?? const [],
        isUser: isUser,
        isArabic: msgIsArabic,
      );
    } else {
      content = Text(
        msg.text,
        textDirection: dir,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          height: 1.5,
          fontWeight: isUser ? FontWeight.w900 : FontWeight.normal,
        ),
      );
    }

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: msg.kind == MessageKind.infoCard
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        border: Border.all(color: const Color(0xFFE6C068).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Directionality(textDirection: dir, child: content),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w900,
      color: isUser ? const Color(0xFF1E1912) : const Color(0xFFE6C068),
      fontSize: 15,
      letterSpacing: 0.2,
    );

    final itemStyle = TextStyle(
      color: isUser ? const Color(0xFF1E1912).withOpacity(0.9) : const Color(0xFFF5F1E8).withOpacity(0.82),
      fontSize: 14,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: isUser ? Colors.white70 : Colors.black45),
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
                Text("• ", style: itemStyle.copyWith(fontWeight: FontWeight.bold)),
                Expanded(child: Text(it, style: itemStyle)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ======================== MAIN CHAT ==========================
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<ChatMessageModel> _messages = [];

  bool _isTyping = false;
  bool _showScrollBtn = false;
  bool _canSend = false;

  late final AnimationController _popupAnim;

  Timer? _typeTimer;

  @override
  void initState() {
    super.initState();

    _popupAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _scroll.addListener(_scrollChecker);

    _controller.addListener(() {
      final ok = _controller.text.trim().isNotEmpty;
      if (ok != _canSend) setState(() => _canSend = ok);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      final isArabic = prefs.language == 'ar';

      _addMessage(
        ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: isArabic
              ? "مرحباً بك في متحفنا! أنا حوروس، مساعدك الذكي. كيف يمكنني مساعدتك في زيارتك اليوم؟"
              : "Welcome to our museum! I’m Horus, your smart assistant. How can I help you with your visit today?",
        ),
      );
    });
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void _scrollChecker() {
    if (!_scroll.hasClients) return;
    final atBottom = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200;
    if (_showScrollBtn == atBottom) {
      setState(() => _showScrollBtn = !atBottom);
    }
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
    setState(() => _messages.add(m));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_showScrollBtn) _scrollToBottom();
    });
  }

  // ---------- Reply Engine ----------
  ChatMessageModel _reply(String q, bool isArabic) {
    final input = q.toLowerCase().trim();
    bool has(RegExp r) => r.hasMatch(input);

    if (!isArabic) {
      if (has(RegExp(r'(ticket|price|cost|how\s+much|buy.*ticket)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "Ticket Prices",
          cardItems: const [
            "Adult: \$20",
            "Student (with ID): \$15",
            "Child (under 12): \$10",
            "Senior (65+): \$15",
            "Buy in-app or at the main entrance.",
          ],
        );
      }

      if (has(RegExp(r'(open|hours|time|schedule|operating\s+hours)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "Opening Hours",
          cardItems: const [
            "Daily: 9:00 AM → 6:00 PM",
            "Last entry: 5:00 PM",
            "Closed on major holidays",
          ],
        );
      }

      if (has(RegExp(r'(duration|how\s+long|time\s+to\s+visit)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "Visit Duration",
          cardItems: const [
            "Quick visit: 60–90 minutes",
            "Typical: 1–2 hours",
            "Deep explore: 3–4 hours",
          ],
        );
      }

      if (has(RegExp(r'(event|tour|workshop|upcoming|what.*happening)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "Upcoming Events",
          cardItems: const [
            "Guided Tour: Ancient Egypt — 2:00 PM",
            "Workshop: Hieroglyphs — Tomorrow 3:00 PM",
            "Talk: Secrets of Mummification — 1:00 PM",
          ],
        );
      }

      if (has(RegExp(r'(hi|hello|hey|good\s+morning)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "Hello! 😊 I can help you with ticket prices, opening hours, events, or exhibit info. What would you like to know?",
        );
      }

      return ChatMessageModel.text(
        id: _id(),
        isUser: false,
        timestamp: DateTime.now(),
        text: "I’m here to help with tickets, hours, events, and exhibits. Could you please specify your question?",
      );
    } else {
      // Arabic replies... (omitted for brevity but kept consistent)
       if (has(RegExp(r'(تذكرة|تذاكر|سعر|كم\s+السعر|شراء.*تذكرة)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "أسعار التذاكر",
          cardItems: const [
            "بالغ: 20 دولار",
            "طالب (ببطاقة): 15 دولار",
            "طفل (تحت 12): 10 دولار",
            "كبار السن (65+): 15 دولار",
            "الشراء من التطبيق أو من المدخل الرئيسي.",
          ],
        );
      }

      if (has(RegExp(r'(مواعيد|فتح|إغلاق|ساعات|ساعات.*عمل)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "مواعيد العمل",
          cardItems: const [
            "يومياً: 9:00 ص → 6:00 م",
            "آخر دخول: 5:00 م",
          ],
        );
      }

      if (has(RegExp(r'(مرحبا|أهلا|هاي)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "أهلاً بك! 😊 يمكنني مساعدتك في معرفة أسعار التذاكر، مواعيد العمل، الفعاليات، أو معلومات عن المعروضات. ماذا تفضل أن تعرف؟",
        );
      }

      return ChatMessageModel.text(
        id: _id(),
        isUser: false,
        timestamp: DateTime.now(),
        text: "أنا هنا للمساعدة في التذاكر، المواعيد، الفعاليات، والقطع الأثرية. هل يمكنك تحديد سؤالك؟",
      );
    }
  }

  void _typeBotMessage(String fullText, {int startDelayMs = 400}) {
    _typeTimer?.cancel();
    final botMsg = ChatMessageModel.text(id: _id(), isUser: false, timestamp: DateTime.now(), text: '');
    _addMessage(botMsg);

    int index = 0;
    Future.delayed(Duration(milliseconds: startDelayMs), () {
      if (!mounted) return;
      _typeTimer = Timer.periodic(const Duration(milliseconds: 15), (t) {
        if (!mounted) return;
        if (index >= fullText.length) {
          t.cancel();
          return;
        }
        setState(() {
          final last = _messages.last;
          if (last.id == botMsg.id) {
            _messages[_messages.length - 1] = ChatMessageModel.text(
              id: last.id, isUser: false, timestamp: last.timestamp, text: (last.text + fullText[index]),
            );
          }
        });
        index++;
        if (!_showScrollBtn) _scrollToBottom();
      });
    });
  }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.selectionClick();
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final isArabic = prefs.language == 'ar';

    _controller.clear();
    _addMessage(ChatMessageModel.text(id: _id(), isUser: true, timestamp: DateTime.now(), text: trimmed));

    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      final replyMsg = _reply(trimmed, isArabic);
      if (replyMsg.kind == MessageKind.infoCard) {
        _addMessage(replyMsg);
      } else {
        _typeBotMessage(replyMsg.text);
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _controller.dispose();
    _scroll.removeListener(_scrollChecker);
    _scroll.dispose();
    _popupAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == "ar";
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    final quickChips = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1912),
        border: Border(bottom: BorderSide(color: const Color(0xFFE6C068).withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _QuickChip(label: isArabic ? "التذاكر 🎟️" : "Tickets 🎟️", onTap: () => _submit(isArabic ? "أسعار التذاكر" : "ticket prices")),
            _QuickChip(label: isArabic ? "المواعيد ⏰" : "Hours ⏰", onTap: () => _submit(isArabic ? "مواعيد العمل" : "opening hours")),
            _QuickChip(label: isArabic ? "الفعاليات 🎭" : "Events 🎭", onTap: () => _submit(isArabic ? "الفعاليات القادمة" : "upcoming events")),
            _QuickChip(label: isArabic ? "المدة ⌛" : "Duration ⌛", onTap: () => _submit(isArabic ? "مدة الزيارة" : "visit duration")),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: widget.isPopup ? Colors.transparent : const Color(0xFF121212),
      appBar: widget.isPopup
          ? null
          : AppBar(
              title: Text(l10n.talkToHorusBot, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFF5F1E8))),
              backgroundColor: const Color(0xFF121212),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFF5F1E8)),
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
            ),

      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _popupAnim, curve: Curves.easeOutCubic)),
          child: Container(
            width: widget.isPopup ? MediaQuery.of(context).size.width * 0.92 : double.infinity,
            height: widget.isPopup ? MediaQuery.of(context).size.height * 0.82 : double.infinity,
            decoration: widget.isPopup
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF1E1912),
                    border: Border.all(color: const Color(0xFFE6C068), width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
                  )
                : null,
            child: ClipRRect(
              borderRadius: widget.isPopup ? BorderRadius.circular(24) : BorderRadius.zero,
              child: Column(
                children: [
                  if (widget.isPopup)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded, color: Color(0xFFE6C068), size: 24),
                          const SizedBox(width: 12),
                          Text(l10n.talkToHorusBot, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFF5F1E8))),
                          const Spacer(),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: Colors.grey),
                        ],
                      ),
                    ),
                  quickChips,
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        return MessageEntryAnimator(isUser: m.isUser, child: ChatBubble(msg: m, isArabicUI: isArabic));
                      },
                    ),
                  ),
                  if (_isTyping)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Align(alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft, child: _TypingIndicator(isArabic: isArabic)),
                    ),

                  // INPUT AREA
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1912),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                              onSubmitted: _submit,
                              style: const TextStyle(color: Color(0xFFF5F1E8)),
                              decoration: InputDecoration(
                                hintText: isArabic ? "اسأل حوروس عن أي شيء..." : "Ask Horus about anything...",
                                hintStyle: TextStyle(color: const Color(0xFFF5F1E8).withOpacity(0.4)),
                                fillColor: const Color(0xFF121212),
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: const Color(0xFFE6C068).withOpacity(0.2))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: const Color(0xFFE6C068).withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFE6C068))),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedScale(
                            scale: _canSend ? 1.0 : 0.9,
                            duration: const Duration(milliseconds: 200),
                            child: CircleAvatar(
                              backgroundColor: _canSend ? const Color(0xFFE6C068) : const Color(0xFF121212),
                              radius: 24,
                              child: IconButton(
                                onPressed: _canSend ? () => _submit(_controller.text) : null,
                                icon: Icon(Icons.send_rounded, color: _canSend ? const Color(0xFF1E1912) : Colors.grey, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _showScrollBtn && !widget.isPopup
          ? FloatingActionButton.small(onPressed: _scrollToBottom, backgroundColor: primary, child: const Icon(Icons.arrow_downward))
          : null,
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF5F1E8))),
        backgroundColor: const Color(0xFF121212),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: const Color(0xFFE6C068).withOpacity(0.3))),
      ),
    );
  }
}

class RoboGuideEntry extends StatelessWidget {
  const RoboGuideEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (_) => const ChatScreen(isPopup: true),
        );
      },
      icon: const Icon(Icons.smart_toy_rounded),
      label: Text(l10n.talkToHorusBot, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
    );
  }
}
