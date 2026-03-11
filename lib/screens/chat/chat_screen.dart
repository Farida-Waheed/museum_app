import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

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
  final String text;
  final String? cardTitle;
  final List<String>? cardItems;

  ChatMessageModel.text({required this.id, required this.isUser, required this.timestamp, required this.text})
      : kind = MessageKind.text, cardTitle = null, cardItems = null;

  ChatMessageModel.card({required this.id, required this.isUser, required this.timestamp, required this.cardTitle, required this.cardItems})
      : kind = MessageKind.infoCard, text = '';
}

// ================== Message Entry Animator ====================
class MessageEntryAnimator extends StatefulWidget {
  final Widget child;
  final bool isUser;
  const MessageEntryAnimator({super.key, required this.child, required this.isUser});

  @override
  State<MessageEntryAnimator> createState() => _MessageEntryAnimatorState();
}

class _MessageEntryAnimatorState extends State<MessageEntryAnimator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.isUser ? const Offset(0.08, 0) : const Offset(-0.08, 0), end: Offset.zero).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

// ===================== Typing Indicator =======================
class _TypingIndicator extends StatefulWidget {
  final bool isArabic;
  const _TypingIndicator({required this.isArabic});
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _dots;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();
    _dots = List.generate(3, (i) => Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(0.2 * i, 0.5 + 0.2 * i, curve: Curves.easeInOut))));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final text = widget.isArabic ? "حوروس يكتب..." : "Horus-Bot is typing...";
    return Row(
      children: [
        Text(text, style: TextStyle(color: AppColors.neutralMedium, fontSize: 11, fontStyle: FontStyle.italic)),
        const SizedBox(width: 6),
        ..._dots.map((ani) => AnimatedBuilder(animation: ani, builder: (_, __) => Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGold.withAlpha((ani.value * 255).round()))))),
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
    final bubbleColor = isUser ? AppColors.primaryGold : AppColors.darkSurface;
    final textColor = isUser ? AppColors.darkInk : const Color(0xFFF5F1E8);
    final msgIsArabic = msg.kind == MessageKind.text ? _hasArabic(msg.text) : isArabicUI;
    final dir = msgIsArabic ? TextDirection.rtl : TextDirection.ltr;

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: isUser ? AppColors.primaryGold.withOpacity(0.1) : AppColors.darkSurface,
      child: isUser ? const Icon(Icons.person_outline, size: 16, color: AppColors.primaryGold) : const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.primaryGold),
    );

    Widget content = msg.kind == MessageKind.infoCard
        ? _InfoCardBubble(title: msg.cardTitle ?? '', items: msg.cardItems ?? const [], isUser: isUser, isArabic: msgIsArabic)
        : Text(msg.text, textDirection: dir, style: TextStyle(color: textColor, fontSize: 15, height: 1.5, fontWeight: isUser ? FontWeight.w900 : FontWeight.normal));

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Directionality(textDirection: dir, child: content),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser ? [bubble, const SizedBox(width: 8), avatar] : [avatar, const SizedBox(width: 8), bubble],
      ),
    );
  }
}

class _InfoCardBubble extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isUser;
  final bool isArabic;
  const _InfoCardBubble({required this.title, required this.items, required this.isUser, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontWeight: FontWeight.w900, color: isUser ? AppColors.darkInk : AppColors.primaryGold, fontSize: 15);
    final itemStyle = TextStyle(color: isUser ? AppColors.darkInk.withOpacity(0.9) : const Color(0xFFF5F1E8).withOpacity(0.82), fontSize: 14, height: 1.5);
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(Icons.info_outline, size: 16, color: isUser ? AppColors.darkInk : AppColors.primaryGold), const SizedBox(width: 8), Expanded(child: Text(title, style: titleStyle))]),
        const SizedBox(height: 12),
        ...items.map((it) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("• ", style: itemStyle.copyWith(fontWeight: FontWeight.bold)), Expanded(child: Text(it, style: itemStyle))]))),
      ],
    );
  }
}

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
    _popupAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _scroll.addListener(_scrollChecker);
    _controller.addListener(() { final ok = _controller.text.trim().isNotEmpty; if (ok != _canSend) setState(() => _canSend = ok); });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final isArabic = Provider.of<UserPreferencesModel>(context, listen: false).language == 'ar';
      _addMessage(ChatMessageModel.text(id: _id(), isUser: false, timestamp: DateTime.now(), text: isArabic ? "مرحباً! أنا حوروس، كيف يمكنني مساعدتك؟" : "Welcome! I’m Horus, how can I help you today?"));
    });
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  void _scrollChecker() { if (!_scroll.hasClients) return; final atBottom = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200; if (_showScrollBtn == atBottom) setState(() => _showScrollBtn = !atBottom); }
  void _scrollToBottom() { if (!_scroll.hasClients) return; _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic); }
  void _addMessage(ChatMessageModel m) { setState(() => _messages.add(m)); Future.delayed(const Duration(milliseconds: 100), () { if (!_showScrollBtn) _scrollToBottom(); }); }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.selectionClick();
    _controller.clear();
    _addMessage(ChatMessageModel.text(id: _id(), isUser: true, timestamp: DateTime.now(), text: trimmed));
    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _typeBotMessage("I am processing your request about: $trimmed");
    });
  }

  void _typeBotMessage(String fullText) {
    _typeTimer?.cancel();
    final botMsg = ChatMessageModel.text(id: _id(), isUser: false, timestamp: DateTime.now(), text: '');
    _addMessage(botMsg);
    int index = 0;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (!mounted || index >= fullText.length) { t.cancel(); return; }
      setState(() { final last = _messages.last; if (last.id == botMsg.id) _messages[_messages.length - 1] = ChatMessageModel.text(id: last.id, isUser: false, timestamp: last.timestamp, text: (last.text + fullText[index])); });
      index++;
    });
  }

  @override
  void dispose() { _typeTimer?.cancel(); _controller.dispose(); _scroll.dispose(); _popupAnim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<UserPreferencesModel>(context).language == "ar";
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: widget.isPopup ? Colors.transparent : AppColors.darkBackground,
      appBar: widget.isPopup ? null : AppBar(title: Text(l10n.talkToHorusBot, style: AppTextStyles.screenTitle(context).copyWith(fontSize: 18)), backgroundColor: AppColors.darkBackground, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _popupAnim, curve: Curves.easeOutCubic)),
          child: Container(
            width: widget.isPopup ? MediaQuery.of(context).size.width * 0.92 : double.infinity,
            height: widget.isPopup ? MediaQuery.of(context).size.height * 0.82 : double.infinity,
            decoration: widget.isPopup ? BoxDecoration(borderRadius: BorderRadius.circular(24), color: AppColors.darkSurface, border: Border.all(color: AppColors.primaryGold, width: 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))]) : null,
            child: ClipRRect(
              borderRadius: widget.isPopup ? BorderRadius.circular(24) : BorderRadius.zero,
              child: Column(
                children: [
                  if (widget.isPopup) Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Row(children: [const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGold, size: 24), const SizedBox(width: 12), Text(l10n.talkToHorusBot, style: AppTextStyles.cardTitle(context).copyWith(fontSize: 18)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: AppColors.neutralMedium))])),
                  _QuickChips(isArabic: isArabic, onSubmit: _submit),
                  Expanded(child: ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (context, i) => MessageEntryAnimator(isUser: _messages[i].isUser, child: ChatBubble(msg: _messages[i], isArabicUI: isArabic)))),
                  if (_isTyping) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: Align(alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft, child: _TypingIndicator(isArabic: isArabic))),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.darkSurface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
                    child: SafeArea(top: false, child: Row(children: [
                      Expanded(child: TextField(controller: _controller, textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr, onSubmitted: _submit, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: isArabic ? "اسأل حوروس..." : "Ask Horus...", hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), fillColor: AppColors.darkBackground, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.2))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.2))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.primaryGold)), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)))),
                      const SizedBox(width: 12),
                      AnimatedScale(scale: _canSend ? 1.0 : 0.9, duration: const Duration(milliseconds: 200), child: CircleAvatar(backgroundColor: _canSend ? AppColors.primaryGold : AppColors.darkBackground, radius: 24, child: IconButton(onPressed: _canSend ? () => _submit(_controller.text) : null, icon: Icon(Icons.send_rounded, color: _canSend ? AppColors.darkInk : AppColors.neutralMedium, size: 20))))
                    ])),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  final bool isArabic;
  final Function(String) onSubmit;
  const _QuickChips({required this.isArabic, required this.onSubmit});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.darkSurface, border: Border(bottom: BorderSide(color: AppColors.primaryGold.withOpacity(0.1)))),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        _Chip(label: isArabic ? "التذاكر 🎟️" : "Tickets 🎟️", onTap: () => onSubmit("ticket prices")),
        _Chip(label: isArabic ? "المواعيد ⏰" : "Hours ⏰", onTap: () => onSubmit("opening hours")),
        _Chip(label: isArabic ? "الفعاليات 🎭" : "Events 🎭", onTap: () => onSubmit("upcoming events")),
      ])),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(onPressed: onTap, label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: AppColors.darkBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)))));
  }
}

class RoboGuideEntry extends StatelessWidget {
  const RoboGuideEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () { showDialog(context: context, barrierColor: Colors.black54, builder: (_) => const ChatScreen(isPopup: true)); },
      icon: const Icon(Icons.smart_toy_rounded),
      label: Text(l10n.talkToHorusBot, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.darkInk,
      elevation: 8,
    );
  }
}
