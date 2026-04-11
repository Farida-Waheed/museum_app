import 'package:flutter/material.dart';
import '../../models/support_request.dart';
import '../../services/support_request_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportInboxTitle),
        backgroundColor: AppColors.darkHeader,
        elevation: 0,
      ),
      backgroundColor: AppColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: requests.isEmpty
            ? Center(
                child: Text(
                  l10n.supportNoRequests,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge(context),
                ),
              )
            : ListView.separated(
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
    );
  }
}

class _SupportRequestCard extends StatelessWidget {
  final SupportRequest request;
  final VoidCallback onTap;

  const _SupportRequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cinematicCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      color: AppColors.primaryGold.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      request.status == SupportRequestStatus.pending
                          ? AppLocalizations.of(context)!.supportStatusPending
                          : request.status == SupportRequestStatus.inProgress
                              ? AppLocalizations.of(context)!.supportStatusInProgress
                              : AppLocalizations.of(context)!.supportStatusResolved,
                      style: AppTextStyles.metadata(context).copyWith(
                        color: AppColors.primaryGold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.latestMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyPrimary(context).copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.place_outlined, color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    request.screen,
                    style: AppTextStyles.metadata(context).copyWith(
                      color: AppColors.helperText,
                    ),
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
