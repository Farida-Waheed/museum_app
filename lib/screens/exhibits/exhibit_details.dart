import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit_provider.dart';
import '../../models/auth_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/app_session_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class ExhibitDetailScreen extends StatefulWidget {
  const ExhibitDetailScreen({super.key, required this.exhibit});

  final Exhibit exhibit;

  @override
  State<ExhibitDetailScreen> createState() => _ExhibitDetailScreenState();
}

class _ExhibitDetailScreenState extends State<ExhibitDetailScreen> {
  void _toggleBookmark(
    Exhibit exhibit,
    AppLocalizations l10n,
    ExhibitProvider provider,
  ) {
    provider.toggleBookmark(exhibit.id);
    final isBookmarked = provider.isBookmarked(exhibit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cinematicCard,
        content: Text(
          isBookmarked ? l10n.addedToBookmarks : l10n.removedFromBookmarks,
          style: AppTextStyles.bodyPrimary(
            context,
          ).copyWith(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exhibit = widget.exhibit;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final exhibitProvider = Provider.of<ExhibitProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBookmarked = exhibitProvider.isBookmarked(exhibit.id);

    // Mark as visited when viewing details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppSessionProvider>(
        context,
        listen: false,
      ).setCurrentExhibit(exhibit.id);
    });

    return AppMenuShell(
      title: exhibit.getName(prefs.language).toUpperCase(),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      showChatButton: true,
      actions: [
        if (authProvider.isLoggedIn)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: IconButton(
              tooltip: isBookmarked ? l10n.removedFromBookmarks : l10n.addToMyRoute,
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primaryGold,
              ),
              onPressed: () => _toggleBookmark(exhibit, l10n, exhibitProvider),
            ),
          ),
      ],
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.screenBackground),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 144),
          children: [
            _ExhibitHero(exhibit: exhibit, language: prefs.language),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalCompact,
                24,
                AppSpacing.screenHorizontalCompact,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFactChips(exhibit, l10n),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text(
                    l10n.description.toUpperCase(),
                    style: AppTextStyles.premiumSectionLabel(
                      context,
                    ).copyWith(color: AppColors.softGold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      AppSpacing.cardPaddingCompact,
                    ),
                    decoration: AppDecorations.secondaryGlassCard(
                      radius: 22,
                      opacity: 0.52,
                    ),
                    child: Text(
                      exhibit.getDescription(prefs.language),
                      style: AppTextStyles.premiumBody(context).copyWith(
                        height: 1.58,
                        color: isDark ? AppColors.bodyText : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- FACT CHIPS ----------

  Widget _buildFactChips(
    Exhibit exhibit,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final facts = <Map<String, dynamic>>[
      {'icon': Icons.public, 'label': l10n.origin, 'value': 'Ancient Egypt'},
      {
        'icon': Icons.calendar_today,
        'label': l10n.period,
        'value': 'New Kingdom',
      },
      {'icon': Icons.location_on, 'label': l10n.gallery, 'value': 'Hall A'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: facts.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: AppDecorations.secondaryGlassCard(
            radius: 16,
            opacity: 0.46,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                f['icon'] as IconData,
                size: 16,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 7),
              Text(
                '${f['label']}: ${f['value']}',
                style: AppTextStyles.premiumMutedBody(context).copyWith(
                  color: isDark ? AppColors.bodyText : Colors.black87,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExhibitHero extends StatelessWidget {
  const _ExhibitHero({required this.exhibit, required this.language});

  final Exhibit exhibit;
  final String language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            exhibit.imageAsset.isNotEmpty
                ? exhibit.imageAsset
                : 'assets/images/museum_interior.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cinematicSection,
              child: const Center(
                child: Icon(
                  Icons.museum_outlined,
                  color: AppColors.primaryGold,
                  size: 42,
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xE6000000),
                  Color(0x66000000),
                  Color(0x16000000),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            start: AppSpacing.screenHorizontalCompact,
            end: AppSpacing.screenHorizontalCompact,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exhibit.getName(language),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayArtifactTitle(context).copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.72),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grand Egyptian Museum',
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.primaryGold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
