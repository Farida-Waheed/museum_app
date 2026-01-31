import 'dart:ui';
import 'package:flutter/material.dart';
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
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: widget.isUser ? const Offset(0.1, 0) : const Offset(-0.1, 0),
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
  late AnimationController _controller;
  late List<Animation<double>> _dots;

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

// ===================== Chat Message Bubble ====================
class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isTyping;

  const ChatMessage({super.key, required this.msg, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    final isUser = msg['isUser'] as bool;
    final text = msg['text'] as String;
    final theme = Theme.of(context);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser
          ? theme.colorScheme.primary.withOpacity(0.1)
          : Colors.blueGrey.shade100,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: isUser ? theme.colorScheme.primary : Colors.black87,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: isUser
            ? [bubble, const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), bubble],
      ),
    );
  }
}

// ======================== MAIN CHAT ==========================
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _showScrollBtn = false;

  late AnimationController _popupAnim;

  // For context-aware replies
  String? _lastUserMessage;

  @override
  void initState() {
    super.initState();

    _popupAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();

    _scroll.addListener(_scrollChecker);

    // First welcome message from Horus-Bot (localized, randomized)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      final isArabic = prefs.language == 'ar';
      final greetings = isArabic
          ? [
              "مرحباً، أنا حوروس، مرشدك الرقمي داخل المتحف. كيف يمكنني مساعدتك اليوم؟",
              "أهلاً بك! أنا حوروس بوت، اسألني عن أي شيء في المتحف.",
              "مرحباً بك في المتحف! أنا هنا لمساعدتك في جولتك.",
            ]
          : [
              "Hi, I’m Horus-Bot, your digital guide. How can I help you today?",
              "Welcome! I’m Horus-Bot. Ask me anything about the museum.",
              "Hello! I’m here to help you explore the museum.",
            ];
      _add(false, (greetings..shuffle()).first);
    });
  }

  void _scrollChecker() {
    if (!_scroll.hasClients) return;
    final atBottom =
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200;
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

  void _add(bool isUser, String text) {
    setState(() {
      _messages.add({
        "text": text,
        "isUser": isUser,
        "timestamp": DateTime.now(),
      });
    });

    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_showScrollBtn) _scrollToBottom();
    });
  }

  String _reply(String q, bool isArabic) {
    // Context-aware, randomized, and more flexible AI-like responses
    final t = q.toLowerCase();
    _lastUserMessage = q;

    if (!isArabic) {
      if (t.contains("bathroom") ||
          t.contains("toilet") ||
          t.contains("restroom")) {
        final responses = [
          "Restrooms are on the ground floor near the main entrance.",
          "You’ll find the bathrooms by the main entrance on the ground floor.",
          "The nearest restroom is just past the main entrance.",
        ];
        return (responses..shuffle()).first;
      }
      if (t.contains("ticket") || t.contains("price")) {
        final responses = [
          "You can view ticket prices and buy tickets from the Tickets section in the app or at the main ticket desk.",
          "Ticket prices are available in the Tickets section. Would you like to see them now?",
          "You can purchase tickets in the app or at the museum’s main desk.",
        ];
        return (responses..shuffle()).first;
      }
      if (t.contains("open") || t.contains("time") || t.contains("hours")) {
        final responses = [
          "The museum is usually open from 9:00 AM to 6:00 PM. Please check the Tickets or Info section for today’s exact hours.",
          "We’re open daily from 9 AM to 6 PM. Let me know if you need more details!",
          "Opening hours are 9:00 AM to 6:00 PM, but check the app for special events.",
        ];
        return (responses..shuffle()).first;
      }
      if (t.contains("cafe") || t.contains("food")) {
        final responses = [
          "The museum café is located near the central hall. Look for the Café icon on the map.",
          "You can grab a snack at the café near the central hall.",
          "The café is close to the main exhibition area.",
        ];
        return (responses..shuffle()).first;
      }
      if (t.contains("hello") || t.contains("hi") || t.contains("hey")) {
        final responses = [
          "Hello! How can I assist you today?",
          "Hi there! Need help with anything in the museum?",
          "Hey! I’m here to answer your questions.",
        ];
        return (responses..shuffle()).first;
      }
      if (t.contains("thank")) {
        final responses = [
          "You’re welcome! Let me know if you have more questions.",
          "Happy to help!",
          "Anytime!",
        ];
        return (responses..shuffle()).first;
      }
      // Fallback: generic AI-like answer
      final generic = [
        "I’m Horus-Bot. I can help with directions, ticket information, opening hours, and exhibits. Try asking about a specific hall or artifact.",
        "I’m here to help you explore the museum. Ask me about exhibits, tickets, or anything else!",
        "If you need directions or info about the museum, just ask!",
      ];
      return (generic..shuffle()).first;
    } else {
      final lowerAr = q; // simple check, we won’t lowercase Arabic here.

      if (lowerAr.contains("حمام") || lowerAr.contains("دورة")) {
        final responses = [
          "دورات المياه موجودة في الدور الأرضي بجوار المدخل الرئيسي.",
          "ستجد الحمامات بجوار المدخل الرئيسي في الدور الأرضي.",
          "أقرب دورة مياه بعد المدخل الرئيسي مباشرة.",
        ];
        return (responses..shuffle()).first;
      }
      if (lowerAr.contains("تذكرة") ||
          lowerAr.contains("تذاكر") ||
          lowerAr.contains("سعر")) {
        final responses = [
          "يمكنك معرفة أسعار التذاكر وشرائها من قسم التذاكر في التطبيق أو من شباك التذاكر بالمتحف.",
          "أسعار التذاكر متوفرة في قسم التذاكر. هل ترغب في الاطلاع عليها الآن؟",
          "يمكنك شراء التذاكر من التطبيق أو من شباك المتحف الرئيسي.",
        ];
        return (responses..shuffle()).first;
      }
      if (lowerAr.contains("مواعيد") ||
          lowerAr.contains("فتح") ||
          lowerAr.contains("إغلاق")) {
        final responses = [
          "يعمل المتحف عادة من ٩ صباحاً حتى ٦ مساءً. من الأفضل التأكد من قسم التذاكر أو المعلومات لجدول اليوم.",
          "ساعات العمل من ٩ صباحاً حتى ٦ مساءً يومياً. إذا كنت بحاجة لمزيد من التفاصيل أخبرني!",
          "مواعيد الافتتاح من ٩ صباحاً حتى ٦ مساءً، ويمكنك التأكد من التطبيق في حالة وجود فعاليات خاصة.",
        ];
        return (responses..shuffle()).first;
      }
      if (lowerAr.contains("كافيه") ||
          lowerAr.contains("مطعم") ||
          lowerAr.contains("أكل")) {
        final responses = [
          "الكافيه موجود بالقرب من القاعة الرئيسية. يمكنك العثور عليه على الخريطة داخل التطبيق.",
          "يمكنك تناول وجبة خفيفة في الكافيه بجوار القاعة الرئيسية.",
          "الكافيه قريب من منطقة المعارض الرئيسية.",
        ];
        return (responses..shuffle()).first;
      }
      if (lowerAr.contains("مرحبا") ||
          lowerAr.contains("أهلاً") ||
          lowerAr.contains("السلام")) {
        final responses = [
          "مرحباً! كيف يمكنني مساعدتك اليوم؟",
          "أهلاً بك! هل تحتاج مساعدة في شيء بالمتحف؟",
          "مرحباً! أنا هنا للإجابة على أسئلتك.",
        ];
        return (responses..shuffle()).first;
      }
      if (lowerAr.contains("شكراً") || lowerAr.contains("شكر")) {
        final responses = [
          "على الرحب والسعة! إذا كان لديك أي سؤال آخر أخبرني.",
          "سعيد بمساعدتك!",
          "في أي وقت!",
        ];
        return (responses..shuffle()).first;
      }
      // Fallback: generic AI-like answer
      final generic = [
        "أنا حوروس بوت. أستطيع مساعدتك في الاتجاهات، معلومات التذاكر، مواعيد العمل والمعروضات. جرّب أن تسأل عن قاعة أو قطعة محددة.",
        "أنا هنا لمساعدتك في استكشاف المتحف. اسألني عن المعروضات أو التذاكر أو أي شيء آخر!",
        "إذا كنت بحاجة لمعلومات أو اتجاهات داخل المتحف فقط اسألني!",
      ];
      return (generic..shuffle()).first;
    }
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;

    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final isArabic = prefs.language == 'ar';

    _controller.clear();
    _add(true, text);
    setState(() => _isTyping = true);

    // Simulate AI "thinking" delay and streaming effect
    final aiReply = _reply(text, isArabic);
    Future.delayed(
      Duration(milliseconds: 700 + (aiReply.length * 8)),
      () async {
        if (!mounted) return;
        setState(() => _isTyping = false);

        // Simulate streaming: add one char at a time
        String display = "";
        for (int i = 0; i < aiReply.length; i++) {
          display += aiReply[i];
          if (i == 0 || i % 3 == 0 || i == aiReply.length - 1) {
            if (!mounted) return;
            setState(() {
              if (_messages.isNotEmpty && !_messages.last['isUser']) {
                _messages.removeLast();
              }
              _messages.add({
                "text": display,
                "isUser": false,
                "timestamp": DateTime.now(),
              });
            });
            await Future.delayed(const Duration(milliseconds: 12));
          }
        }
      },
    );
  }

  @override
  void dispose() {
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
    final Color primary = Theme.of(context).colorScheme.primary;

    final chatBody = Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, i) => MessageEntryAnimator(
              isUser: _messages[i]['isUser'] as bool,
              child: ChatMessage(msg: _messages[i], isTyping: _isTyping),
            ),
          ),
        ),
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: _TypingIndicator(isArabic: isArabic),
          ),
        const SizedBox(height: 70),
      ],
    );

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
            width: widget.isPopup
                ? MediaQuery.of(context).size.width * 0.9
                : double.infinity,
            height: widget.isPopup
                ? MediaQuery.of(context).size.height * 0.78
                : double.infinity,
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
              borderRadius: widget.isPopup
                  ? BorderRadius.circular(22)
                  : BorderRadius.zero,
              child: Stack(
                children: [
                  // For popup we already blur the background in RoboGuideEntry,
                  // so here we just show a normal white chat.
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 22,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Row(
          children: [
            Icon(Icons.mic_none, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _submit,
                decoration: InputDecoration(
                  hintText: isArabic
                      ? "اكتب سؤالك لآنخو..."
                      : "Ask Horus-Bot anything...",
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: primary,
              child: IconButton(
                onPressed: () => _submit(_controller.text),
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: widget.isPopup
          ? null
          : const BottomNav(currentIndex: 0),

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

// ================= RoboGuide Bubble & Entry ===================
class RoboGuideBubble extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const RoboGuideBubble({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: bubbleColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
