import 'package:flutter/material.dart';
import '../../models/support_request.dart';
import '../../services/support_request_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class SupportInboxScreen extends StatefulWidget {
  const SupportInboxScreen({super.key});

  @override
  State<SupportInboxScreen> createState() => _SupportInboxScreenState();
}

class _SupportInboxScreenState extends State<SupportInboxScreen> {
  final _service = SupportRequestService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requests = _service.requests;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return AppMenuShell(
      title: l10n.supportInboxTitle.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: requests.isEmpty
              ? _EmptySupportState(message: l10n.supportNoRequests)
              : ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    20,
                    24,
                    20,
                    120,
                  ),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _SupportRequestCard(
                      request: request,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.supportConversation,
                          arguments: request.id,
                        ).then((_) => setState(() {}));
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _EmptySupportState extends StatelessWidget {
  const _EmptySupportState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: AppDecorations.premiumGlassCard(radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.support_agent_outlined,
                color: AppColors.primaryGold,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportRequestCard extends StatelessWidget {
  final SupportRequest request;
  final VoidCallback onTap;

  const _SupportRequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.secondaryGlassCard(radius: 18),
          child: Column(
            crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Text(
                      request.requesterName,
                      style: AppTextStyles.titleMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      request.status == SupportRequestStatus.pending
                          ? AppLocalizations.of(context)!.supportStatusPending
                          : request.status == SupportRequestStatus.inProgress
                          ? AppLocalizations.of(
                              context,
                            )!.supportStatusInProgress
                          : AppLocalizations.of(context)!.supportStatusResolved,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.primaryGold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.latestMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                textDirection: Directionality.of(context),
                children: [
                  const Icon(
                    Icons.place_outlined,
                    color: AppColors.primaryGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.screen,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.helperText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
