import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

// =============================================================
// Chat Screen (Supports Popup Floating Chat Window)
// =============================================================
class ChatScreen extends StatefulWidget {
  final bool isPopup;
  const ChatScreen({super.key, this.isPopup = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// =============================================================
// Message Entry Animator (Slide + Fade)
// =============================================================
class MessageEntryAnimator extends StatefulWidget {
  final Widget child;
  final bool isUser;
  const MessageEntryAnimator({super.key, required this.child, required this.isUser});

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: widget.isUser ? const Offset(0.3, 0) : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// =============================================================
// Typing Indicator (3 animated dots)
// =============================================================
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

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
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)
      ..repeat();

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
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Robot is typing...", style: TextStyle(color: Colors.grey)),
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
                color: Colors.grey.shade600.withAlpha((ani.value * 255).round()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// Chat Message Bubble
// =============================================================
class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isTyping;

  const ChatMessage({super.key, required this.msg, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    final isUser = msg['isUser'];
    final text = msg['text'];

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue.shade600 : null,
        gradient: !isUser
            ? LinearGradient(
          colors: [Colors.blue.shade50.withAlpha(220), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 18),
        ),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          if (!isUser)
            BoxShadow(
              color: Colors.blue.withAlpha(isTyping ? 150 : 50),
              blurRadius: isTyping ? 14 : 8,
            ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
      ),
    );

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser ? Colors.blue.shade100 : Colors.blueGrey.shade100,
      child: Icon(isUser ? Icons.person : Icons.smart_toy, size: 16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: isUser
            ? [bubble, const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), bubble],
      ),
    );
  }
}

// =============================================================
// MAIN CHAT SCREEN
// =============================================================
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _showScrollBtn = false;

  late AnimationController _popupAnim;

  @override
  void initState() {
    super.initState();

    _popupAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();

    _scroll.addListener(_scrollChecker);

    Future.delayed(const Duration(milliseconds: 400), () {
      _add(false, "Hello! I am your AI Guide. Ask me anything about the museum!");
    });
  }

  void _scrollChecker() {
    final atBottom = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200;
    if (_showScrollBtn == atBottom) setState(() => _showScrollBtn = !atBottom);
  }

  void _scrollToBottom() {
    _scroll.animateTo(_scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _add(bool isUser, String text) {
    setState(() {
      _messages.add({"text": text, "isUser": isUser, "timestamp": DateTime.now()});
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_showScrollBtn) _scrollToBottom();
    });
  }

  String _reply(String q) {
    final t = q.toLowerCase();
    if (t.contains("bathroom") || t.contains("toilet")) {
      return "🚻 Restrooms are on the ground floor near the entrance.";
    }
    if (t.contains("ticket") || t.contains("price")) {
      return "🎟 Tickets cost 15\$ for adults and free for children under 12.";
    }
    if (t.contains("open") || t.contains("time")) {
      return "🕒 We are open daily from 9 AM to 6 PM.";
    }
    if (t.contains("cafe") || t.contains("food")) {
      return "☕ The museum café is on the 2nd floor!";
    }
    return "I'm not totally sure, but I can help with tickets, maps, hours, or exhibits!";
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    _add(true, text);
    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() => _isTyping = false);
      _add(false, _reply(text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == "ar";

    return Scaffold(
      backgroundColor: widget.isPopup ? Colors.transparent : Colors.white,

      // ------------------------------------------------------
      // TOP BAR
      // ------------------------------------------------------
      appBar: widget.isPopup
          ? null
          : AppBar(
        title: const Text("Ask Robot"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),

      // ------------------------------------------------------
      // BODY (scaled popup)
      // ------------------------------------------------------
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: _popupAnim, curve: Curves.easeOutBack),
          ),
          child: Container(
            width: widget.isPopup ? MediaQuery.of(context).size.width * 0.9 : double.infinity,
            height: widget.isPopup ? MediaQuery.of(context).size.height * 0.78 : double.infinity,
            decoration: widget.isPopup
                ? BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(.20),
                  blurRadius: 28,
                  spreadRadius: 4,
                )
              ],
            )
                : null,
            child: ClipRRect(
              borderRadius: widget.isPopup ? BorderRadius.circular(22) : BorderRadius.zero,
              child: Stack(
                children: [
                  // Frosted background
                  BackdropFilter(
                    filter:
                    widget.isPopup ? ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ImageFilter.blur(),
                    child: Column(
                      children: [
                        // Messages
                        Expanded(
                          child: ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, i) =>
                                MessageEntryAnimator(
                                  isUser: _messages[i]['isUser'],
                                  child: ChatMessage(
                                    msg: _messages[i],
                                    isTyping: _isTyping,
                                  ),
                                ),
                          ),
                        ),

                        if (_isTyping)
                          const Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 6),
                            child: _TypingIndicator(),
                          ),

                        const SizedBox(height: 70),
                      ],
                    ),
                  ),

                  // Close button ONLY for popup
                  if (widget.isPopup)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.15),
                                blurRadius: 10,
                              )
                            ],
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

      // ------------------------------------------------------
      // INPUT AREA
      // ------------------------------------------------------
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
                  hintText: isArabic ? "اكتب سؤالك..." : "Type your question...",
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                onPressed: () => _submit(_controller.text),
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation only if NOT popup
      bottomNavigationBar: widget.isPopup ? null : const BottomNav(currentIndex: 0),

      // Scroll-to-bottom floating button
      floatingActionButton: _showScrollBtn
          ? FloatingActionButton(
        mini: true,
        onPressed: _scrollToBottom,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_downward),
      )
          : null,
    );
  }
}
