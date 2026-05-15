import 'package:flutter/material.dart';
import '../../models/support_message.dart';
import '../../models/support_request.dart';
import '../../services/support_request_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
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

    return AppMenuShell(
      title: l10n.supportConversationTitle.toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      body: request == null
          ? Center(
              child: Text(
                l10n.supportRequestNotFound,
                style: AppTextStyles.bodyPrimary(context),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _RequestSummaryCard(request: request),
                      const SizedBox(height: 16),
                      ...request.messages.map(
                        (message) => _SupportChatBubble(
                          message: message,
                          isArabic:
                              Localizations.localeOf(context).languageCode ==
                              'ar',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: l10n.supportReplyHint,
                            hintStyle: AppTextStyles.bodyPrimary(
                              context,
                            ).copyWith(color: Colors.white38),
                            filled: true,
                            fillColor: AppColors.darkSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          style: AppTextStyles.bodyPrimary(
                            context,
                          ).copyWith(color: Colors.white),
                          onSubmitted: (_) => _sendReply(),
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
                          onPressed: _sendReply,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  final SupportRequest request;
  const _RequestSummaryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.requesterName,
            style: AppTextStyles.titleMedium(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${l10n.supportRequestFrom}: ',
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white70),
              ),
              Text(
                request.screen,
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${l10n.supportRequestStatus}: ',
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white70),
              ),
              Text(
                request.status == SupportRequestStatus.pending
                    ? l10n.supportStatusPending
                    : request.status == SupportRequestStatus.inProgress
                    ? l10n.supportStatusInProgress
                    : l10n.supportStatusResolved,
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${l10n.supportRequestCreatedAt}: ',
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white70),
              ),
              Text(
                request.createdAt.toLocal().toString(),
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.contextSummary,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SupportChatBubble extends StatelessWidget {
  final SupportMessage message;
  final bool isArabic;

  const _SupportChatBubble({required this.message, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == SupportSender.user;
    final bubbleColor = isUser ? AppColors.primaryGold : AppColors.darkSurface;
    final textColor = isUser ? AppColors.darkInk : Colors.white;
    final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryGold.withOpacity(0.15),
              child: const Icon(
                Icons.support_agent_outlined,
                size: 16,
                color: AppColors.primaryGold,
              ),
            ),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                textDirection: dir,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: textColor, height: 1.5),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryGold.withOpacity(0.15),
              child: const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.primaryGold,
              ),
            ),
        ],
      ),
    );
  }
}
