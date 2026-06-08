import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/constants/text_styles.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibitProvider = context.watch<ExhibitProvider>();
    final exhibits = exhibitProvider.exhibits;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return AppMenuShell(
      title: l10n.exhibits.toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      showChatButton: true,
      actions: [
        IconButton(
          tooltip: l10n.searchExhibits,
          icon: const Icon(Icons.search_rounded),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
      ],
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: exhibitProvider.isLoading && exhibits.isEmpty
            ? _ExhibitStateCard(
                isArabic: isArabic,
                title: isArabic
                    ? '\u062c\u0627\u0631\u064a \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0639\u0631\u0648\u0636\u0627\u062a...'
                    : 'Loading exhibits...',
                isLoading: true,
              )
            : exhibits.isEmpty
            ? _ExhibitStateCard(
                isArabic: isArabic,
                title: isArabic
                    ? '\u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0627\u0644\u0645\u0639\u0631\u0648\u0636\u0627\u062a \u063a\u064a\u0631 \u0645\u062a\u0627\u062d\u0629 \u062d\u0627\u0644\u064a\u0627\u064b.'
                    : 'Exhibit information is currently unavailable.',
                buttonLabel: isArabic
                    ? '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629'
                    : 'Try again',
                onPressed: () => context.read<ExhibitProvider>().loadExhibits(),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontalCompact,
                  18,
                  AppSpacing.screenHorizontalCompact,
                  128,
                ),
                itemCount:
                    exhibits.length + (exhibitProvider.error == null ? 0 : 1),
                itemBuilder: (context, index) {
                  if (exhibitProvider.error != null && index == 0) {
                    return _SavedContentBanner(isArabic: isArabic);
                  }
                  final exhibitIndex = exhibitProvider.error == null
                      ? index
                      : index - 1;
                  final exhibit = exhibits[exhibitIndex];
                  return _ExhibitListTile(
                    exhibit: exhibit,
                    prefs: prefs,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.exhibitDetails,
                        arguments: exhibit,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ExhibitListTile extends StatelessWidget {
  final Exhibit exhibit;
  final UserPreferencesModel prefs;
  final VoidCallback onTap;

  const _ExhibitListTile({
    required this.exhibit,
    required this.prefs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
          decoration: AppDecorations.secondaryGlassCard(
            radius: 22,
            opacity: 0.54,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: AppGradients.premiumGold,
                    border: Border.all(color: AppColors.goldBorder(0.22)),
                  ),
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 30,
                    color: AppColors.darkInk,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: AppTextStyles.premiumCardTitle(
                        context,
                      ).copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.helperText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.mainGallery,
                          style: AppTextStyles.premiumMutedBody(
                            context,
                          ).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.primaryGold.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExhibitStateCard extends StatelessWidget {
  const _ExhibitStateCard({
    required this.isArabic,
    required this.title,
    this.buttonLabel,
    this.onPressed,
    this.isLoading = false,
  });

  final bool isArabic;
  final String title;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: AppDecorations.premiumGlassCard(radius: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: Directionality.of(context),
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGold,
                      ),
                    )
                  else
                    const Icon(
                      Icons.museum_outlined,
                      color: AppColors.primaryGold,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      style: AppTextStyles.bodyPrimary(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (buttonLabel != null && onPressed != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedContentBanner extends StatelessWidget {
  const _SavedContentBanner({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.secondaryGlassCard(
          radius: 18,
          opacity: 0.46,
        ),
        child: Row(
          textDirection: Directionality.of(context),
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? '\u064a\u062a\u0645 \u0639\u0631\u0636 \u0627\u0644\u0645\u062d\u062a\u0648\u0649 \u0627\u0644\u0645\u062a\u0627\u062d \u0627\u0644\u0645\u062d\u0641\u0648\u0638.'
                    : 'Showing available saved content.',
                textAlign: TextAlign.start,
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: AppColors.neutralMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
