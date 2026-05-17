import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/support_message.dart';
import '../../models/support_request.dart';
import '../../services/support_request_service.dart';
import '../../widgets/app_menu_shell.dart';

class SupportConversationScreen extends StatefulWidget {
  const SupportConversationScreen({super.key, this.requestId});

  final String? requestId;

  @override
  State<SupportConversationScreen> createState() =>
      _SupportConversationScreenState();
}

class _SupportConversationScreenState extends State<SupportConversationScreen> {
  final _service = SupportRequestService();
  final _controller = TextEditingController();

  SupportRequest? get _request =>
      widget.requestId == null ? null : _service.getRequest(widget.requestId!);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _controller.text.trim();
    if (text.isEmpty || _request == null) return;
    _service.addHumanReply(requestId: _request!.id, replyText: text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final request = _request;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppMenuShell(
      title: l10n.supportConversationTitle.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: request == null
              ? _MissingRequestState(message: l10n.supportRequestNotFound)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          20,
                          16,
                          16,
                        ),
                        children: [
                          _RequestSummaryCard(request: request),
                          const SizedBox(height: 16),
                          ...request.messages.map(
                            (message) => _SupportChatBubble(
                              message: message,
                              isArabic: isArabic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ReplyBar(controller: _controller, onSend: _sendReply),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MissingRequestState extends StatelessWidget {
  const _MissingRequestState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.premiumGlassCard(radius: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyPrimary(
            context,
          ).copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({required this.request});

  final SupportRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.premiumGlassCard(radius: 20),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            request.requesterName,
            textAlign: TextAlign.start,
            style: AppTextStyles.titleMedium(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _SummaryLine(label: l10n.supportRequestFrom, value: request.screen),
          const SizedBox(height: 8),
          _SummaryLine(
            label: l10n.supportRequestStatus,
            value: request.status == SupportRequestStatus.pending
                ? l10n.supportStatusPending
                : request.status == SupportRequestStatus.inProgress
                ? l10n.supportStatusInProgress
                : l10n.supportStatusResolved,
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: l10n.supportRequestCreatedAt,
            value: request.createdAt.toLocal().toString(),
          ),
          const SizedBox(height: 16),
          Text(
            request.contextSummary,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: Directionality.of(context),
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.metadata(
            context,
          ).copyWith(color: Colors.white70),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SupportChatBubble extends StatelessWidget {
  const _SupportChatBubble({required this.message, required this.isArabic});

  final SupportMessage message;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == SupportSender.user;
    final bubbleColor = isUser ? AppColors.primaryGold : AppColors.darkSurface;
    final textColor = isUser ? AppColors.darkInk : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        textDirection: Directionality.of(context),
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) _BubbleAvatar(icon: Icons.support_agent_outlined),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(20),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.goldBorder(0.10)),
              ),
              child: Text(
                message.text,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: textColor, height: 1.5),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser) _BubbleAvatar(icon: Icons.person_outline),
        ],
      ),
    );
  }
}

class _BubbleAvatar extends StatelessWidget {
  const _BubbleAvatar({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
      child: Icon(icon, size: 16, color: AppColors.primaryGold),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 20),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.supportReplyHint,
                hintStyle: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: Colors.white38),
                filled: true,
                fillColor: AppColors.cinematicCard,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.goldBorder(0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryGold,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.send_rounded,
                size: 20,
                color: AppColors.darkInk,
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
