import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

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
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 4),
        ..._dots.map(
          (ani) => AnimatedBuilder(
            animation: ani,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade600.withAlpha(
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

    final bubbleColor = isUser ? theme.colorScheme.primary : Colors.grey.shade100;
    final textColor = isUser ? Colors.white : Colors.black87;

    // Decide direction per message content (better UX if user types English while UI Arabic)
    final msgIsArabic = msg.kind == MessageKind.text ? _hasArabic(msg.text) : isArabicUI;
    final dir = msgIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser
          ? theme.colorScheme.primary.withOpacity(0.12)
          : Colors.blueGrey.shade100,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: isUser ? theme.colorScheme.primary : Colors.black87,
      ),
    );

    Widget content;
    if (msg.kind == MessageKind.infoCard) {
      content = _InfoCardBubble(
        title: msg.cardTitle ?? '',
        items: msg.cardItems ?? const [],
        isUser: isUser,
      );
    } else {
      content = Text(
        msg.text,
        textDirection: dir,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.4,
        ),
      );
    }

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: msg.kind == MessageKind.infoCard
          ? const EdgeInsets.all(10)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 18),
        ),
      ),
      child: Directionality(textDirection: dir, child: content),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  const _InfoCardBubble({
    required this.title,
    required this.items,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: isUser ? Colors.white : Colors.black87,
      fontSize: 14,
    );

    final itemStyle = TextStyle(
      color: isUser ? Colors.white.withOpacity(0.95) : Colors.black87,
      fontSize: 13,
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        ...items.map(
          (it) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• ", style: itemStyle),
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
      duration: const Duration(milliseconds: 220),
    )..forward();

    _scroll.addListener(_scrollChecker);

    _controller.addListener(() {
      final ok = _controller.text.trim().isNotEmpty;
      if (ok != _canSend) setState(() => _canSend = ok);
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      final isArabic = prefs.language == 'ar';

      _addMessage(
        ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: isArabic
              ? "مرحباً! أنا حوروس-بوت. اسألني عن التذاكر، المواعيد، الفعاليات، أو أي معروض."
              : "Hi! I’m Horus-Bot. Ask me about tickets, hours, events, or any exhibit.",
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
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _addMessage(ChatMessageModel m) {
    setState(() => _messages.add(m));
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!_showScrollBtn) _scrollToBottom();
    });
  }

  // ---------- Reply Engine (now supports structured cards) ----------
  ChatMessageModel _reply(String q, bool isArabic) {
    final input = q.toLowerCase().trim();

    // Example: info cards for price/hours/duration/events/map
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
            "Deep explore: 3–4 hours (exhibits + events)",
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
            "Guided Tour: Ancient Egypt Highlights — Today 2:00 PM (Main Entrance)",
            "Kids Workshop: Build a Pyramid — Tomorrow 3:00 PM (Education Hall)",
            "Talk: Secrets of Mummification — In 4 days 1:00 PM (Auditorium)",
          ],
        );
      }

      if (has(RegExp(r'(map|navigate|where.*is|location|find)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text:
              "Open the Map section in the app to navigate halls and exhibits. Tell me what you want to find (e.g., “restroom”, “cafe”, “Ancient Vase”) and I’ll guide you.",
        );
      }

      // friendly basics
      if (has(RegExp(r'(hi|hello|hey|good\s+morning|good\s+evening)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "Hello! 😊 What do you want to know — tickets, hours, events, or a specific exhibit?",
        );
      }

      if (has(RegExp(r'(thank\s+you|thanks)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "You’re welcome! Want me to help you plan your visit?",
        );
      }

      return ChatMessageModel.text(
        id: _id(),
        isUser: false,
        timestamp: DateTime.now(),
        text:
            "I can help with ticket prices, opening hours, visit duration, events, directions, and exhibits. What do you need?",
      );
    } else {
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

      if (has(RegExp(r'(مواعيد|فتح|إغلاق|ساعات|ساعات.*عمل|متى\s+يفتح)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "مواعيد العمل",
          cardItems: const [
            "يومياً: 9:00 ص → 6:00 م",
            "آخر دخول: 5:00 م",
            "مغلق في العطلات الرسمية الكبرى",
          ],
        );
      }

      if (has(RegExp(r'(مدة|كم\s+وقت|كم\s+يستغرق|الزيارة)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "مدة الزيارة",
          cardItems: const [
            "زيارة سريعة: 60–90 دقيقة",
            "المتوسط: 1–2 ساعة",
            "استكشاف كامل: 3–4 ساعات (مع فعاليات)",
          ],
        );
      }

      if (has(RegExp(r'(فعالية|جولة|ورشة|محاضرة|قادمة|ايه.*النهاردة)', caseSensitive: false))) {
        return ChatMessageModel.card(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          cardTitle: "الفعاليات القادمة",
          cardItems: const [
            "جولة إرشادية: أبرز مصر القديمة — اليوم 2:00 م (المدخل الرئيسي)",
            "ورشة أطفال: بناء هرم — بكرة 3:00 م (قاعة التعليم)",
            "محاضرة: أسرار التحنيط — بعد 4 أيام 1:00 م (الأوديتوريوم)",
          ],
        );
      }

      if (has(RegExp(r'(خريطة|تنقل|أين|موقع|اقرب)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text:
              "افتح قسم الخريطة في التطبيق للتنقل. قولّي إنت عايز تروح فين (حمام/كافيه/معروض معيّن) وأنا أوجّهك.",
        );
      }

      if (has(RegExp(r'(مرحبا|أهلا|هاي)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "أهلاً! 😊 تحب تسأل عن التذاكر، المواعيد، الفعاليات، ولا معروض معيّن؟",
        );
      }

      if (has(RegExp(r'(شكرا|شكر)', caseSensitive: false))) {
        return ChatMessageModel.text(
          id: _id(),
          isUser: false,
          timestamp: DateTime.now(),
          text: "العفو! تحب أساعدك تخطط زيارتك؟",
        );
      }

      return ChatMessageModel.text(
        id: _id(),
        isUser: false,
        timestamp: DateTime.now(),
        text: "أقدر أساعدك في أسعار التذاكر، المواعيد، مدة الزيارة، الفعاليات، والخريطة. تحب تعرف إيه؟",
      );
    }
  }

  // ---------- Safe Typewriter (single timer) ----------
  void _typeBotMessage(String fullText, {int startDelayMs = 700}) {
    _typeTimer?.cancel();

    // create empty message first
    final botMsg = ChatMessageModel.text(
      id: _id(),
      isUser: false,
      timestamp: DateTime.now(),
      text: '',
    );
    _addMessage(botMsg);

    int index = 0;

    Future.delayed(Duration(milliseconds: startDelayMs), () {
      if (!mounted) return;

      _typeTimer = Timer.periodic(const Duration(milliseconds: 18), (t) {
        if (!mounted) return;
        if (index >= fullText.length) {
          t.cancel();
          return;
        }
        setState(() {
          // update last message text safely
          final last = _messages.last;
          if (last.id == botMsg.id && last.kind == MessageKind.text) {
            _messages[_messages.length - 1] = ChatMessageModel.text(
              id: last.id,
              isUser: last.isUser,
              timestamp: last.timestamp,
              text: (last.text + fullText[index]),
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
    _addMessage(
      ChatMessageModel.text(
        id: _id(),
        isUser: true,
        timestamp: DateTime.now(),
        text: trimmed,
      ),
    );

    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      setState(() => _isTyping = false);

      final replyMsg = _reply(trimmed, isArabic);

      // If it's a card, add instantly (no typewriter needed)
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

    final quickChips = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickChip(
              label: isArabic ? "التذاكر" : "Tickets",
              onTap: () => _submit(isArabic ? "أسعار التذاكر" : "ticket prices"),
            ),
            _QuickChip(
              label: isArabic ? "المواعيد" : "Hours",
              onTap: () => _submit(isArabic ? "مواعيد العمل" : "opening hours"),
            ),
            _QuickChip(
              label: isArabic ? "الفعاليات" : "Events",
              onTap: () => _submit(isArabic ? "الفعاليات القادمة" : "upcoming events"),
            ),
            _QuickChip(
              label: isArabic ? "المدة" : "Duration",
              onTap: () => _submit(isArabic ? "مدة الزيارة" : "visit duration"),
            ),
            _QuickChip(
              label: isArabic ? "الخريطة" : "Map",
              onTap: () => _submit(isArabic ? "الخريطة" : "map"),
            ),
          ],
        ),
      ),
    );

    final chatList = ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final bubble = ChatBubble(msg: m, isArabicUI: isArabic);

        // Animate only the newest message (prevents replaying animations on rebuilds)
        final isNewest = i == _messages.length - 1;
        if (!isNewest) return bubble;

        return MessageEntryAnimator(
          isUser: m.isUser,
          child: bubble,
        );
      },
    );

    final chatBody = Column(
      children: [
        quickChips,
        Expanded(child: chatList),
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TypingIndicator(isArabic: isArabic),
            ),
          ),
        const SizedBox(height: 78), // space for input
      ],
    );

    final inputDir = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: widget.isPopup ? Colors.transparent : Colors.white,

      appBar: widget.isPopup
          ? null
          : AppBar(
              title: Text(isArabic ? "اسأل حوروس" : "Ask Horus-Bot"),
              backgroundColor: Colors.white,
              elevation: 1,
              foregroundColor: Colors.black,
            ),

      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: _popupAnim, curve: Curves.easeOutBack),
          ),
          child: Container(
            width: widget.isPopup ? MediaQuery.of(context).size.width * 0.9 : double.infinity,
            height: widget.isPopup ? MediaQuery.of(context).size.height * 0.78 : double.infinity,
            decoration: widget.isPopup
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  )
                : null,
            child: ClipRRect(
              borderRadius: widget.isPopup ? BorderRadius.circular(22) : BorderRadius.zero,
              child: Stack(
                children: [
                  chatBody,
                  if (widget.isPopup)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.close, size: 22, color: Colors.black87),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      // SafeArea input
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.mic_none, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Directionality(
                  textDirection: inputDir,
                  child: TextField(
                    controller: _controller,
                    textDirection: inputDir,
                    onSubmitted: _submit,
                    decoration: InputDecoration(
                      hintText: isArabic ? "اكتب سؤالك لحوروس..." : "Ask Horus-Bot anything...",
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: _canSend ? primary : Colors.grey.shade400,
                child: IconButton(
                  onPressed: _canSend ? () => _submit(_controller.text) : null,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: widget.isPopup ? null : const BottomNav(currentIndex: 0),

      floatingActionButton: _showScrollBtn && !widget.isPopup
          ? FloatingActionButton(
              mini: true,
              onPressed: _scrollToBottom,
              backgroundColor: primary,
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }
}

// ================= Quick Chip =================
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
        label: Text(label),
      ),
    );
  }
}

// ================= RoboGuide Bubble & Entry ===================
class RoboGuideBubble extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const RoboGuideBubble({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: bubbleColor,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RoboGuideEntry extends StatelessWidget {
  const RoboGuideEntry({super.key});

  void _openChatPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.80,
                child: const ChatScreen(isPopup: true),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final label = isArabic ? "تحدث مع حوروس" : "Talk to Horus-Bot";

    return RoboGuideBubble(label: label, onTap: () => _openChatPopup(context));
  }
}
