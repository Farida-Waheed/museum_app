import 'dart:async';
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
    final text = widget.isArabic ? "الدليل يكتب..." : "The Guide is typing...";
    return Row(
      children: [
        Text(
          text,
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
        : Text(
            msg.text,
            textDirection: dir,
            style: AppTextStyles.bodyPrimary(context).copyWith(
              color: textColor,
              fontSize: 15,
              height: 1.5,
              fontWeight: isUser ? FontWeight.w900 : FontWeight.normal,
            ),
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
  bool _isTyping = false;
  bool _showScrollBtn = false;
  bool _canSend = false;
  late final AnimationController _popupAnim;
  Timer? _typeTimer;
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
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
    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _typeBotMessage("I am processing your request about: $trimmed");
    });
  }

  void _typeBotMessage(String fullText) {
    _typeTimer?.cancel();
    final botMsg = ChatMessageModel.text(
      id: _id(),
      isUser: false,
      timestamp: DateTime.now(),
      text: '',
    );
    _addMessage(botMsg);
    int index = 0;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (!mounted || index >= fullText.length) {
        t.cancel();
        return;
      }
      final last = _chatProvider.lastMessage;
      if (last != null && last.id == botMsg.id) {
        _chatProvider.updateLastMessage(
          ChatMessageModel.text(
            id: last.id,
            isUser: false,
            timestamp: last.timestamp,
            text: last.text + fullText[index],
          ),
        );
      }
      index++;
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _popupAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<UserPreferencesModel>(context).language == "ar";
    final l10n = AppLocalizations.of(context)!;

    final quickChips = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _QuickChip(
              label: isArabic ? "التذاكر 🎟️" : "Tickets 🎟️",
              onTap: () =>
                  _submit(isArabic ? "أسعار التذاكر" : "ticket prices"),
            ),
            _QuickChip(
              label: isArabic ? "المواعيد ⏰" : "Hours ⏰",
              onTap: () => _submit(isArabic ? "مواعيد العمل" : "opening hours"),
            ),
            _QuickChip(
              label: isArabic ? "الفعاليات 🎭" : "Events 🎭",
              onTap: () =>
                  _submit(isArabic ? "الفعاليات القادمة" : "upcoming events"),
            ),
            _QuickChip(
              label: isArabic ? "المدة ⌛" : "Duration ⌛",
              onTap: () => _submit(isArabic ? "مدة الزيارة" : "visit duration"),
            ),
          ],
        ),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Column(
      children: [
        quickChips,
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
              IconButton(
                onPressed: () async {
                  if (kIsWeb) return;
                  final status = await Permission.microphone.status;
                  if (!status.isGranted && mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => BrandedPermissionDialog(
                        icon: Icons.mic_none_rounded,
                        title: l10n.micPermissionTitle,
                        description: l10n.micPermissionDesc,
                        onAllow: () async {
                          Navigator.pop(context);
                          await Permission.microphone.request();
                        },
                        onDeny: () => Navigator.pop(context),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.primaryGold,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onSubmitted: _submit,
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    color: isDark ? Colors.white : AppColors.darkInk,
                  ),
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? "اسأل الدليل عن أي شيء..."
                        : "Ask the Guide about anything...",
                    hintStyle: AppTextStyles.bodyPrimary(context).copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
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
      ],
    );

    if (widget.isPopup) {
      return PremiumDialog(
        title: l10n.askTheGuide,
        icon: Image.asset("assets/icons/ankh.png", width: 24, height: 24),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.askTheGuide.toUpperCase(),
          style: AppTextStyles.displayScreenTitle(context).copyWith(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkHeader : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: content),
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

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(
          label,
          style: AppTextStyles.metadata(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkInk,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.cinematicElevated
            : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class RoboGuideEntry extends StatelessWidget {
  const RoboGuideEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () async {
        await showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (_) => const ChatScreen(isPopup: true),
        );
        final last = Provider.of<ChatProvider>(
          context,
          listen: false,
        ).lastMessage;
        if (last == null) return;
        final snippet = last.text.length > 80
            ? '${last.text.substring(0, 80)}…'
            : last.text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snippet),
            action: SnackBarAction(
              label: l10n.talkToHorusBot,
              onPressed: () => showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (_) => const ChatScreen(isPopup: true),
              ),
            ),
          ),
        );
      },
      icon: const Icon(Icons.smart_toy_rounded),
      label: Text(
        l10n.talkToHorusBot,
        style: AppTextStyles.buttonLabel(context).copyWith(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.darkInk,
      elevation: 8,
    );
  }
}
