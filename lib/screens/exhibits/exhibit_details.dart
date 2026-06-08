import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final isBookmarked = exhibitProvider.isBookmarked(exhibit.id);

    // Mark as visited when viewing details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppSessionProvider>(
        context,
        listen: false,
      ).setCurrentExhibit(exhibit.id);
    });

    return AppMenuShell(
      subHeader: const RobotStatusBanner(),
      showChatButton: true,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(
            exhibit,
            prefs.language,
            cs,
            l10n,
            isBookmarked,
            exhibitProvider,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalCompact,
                24,
                AppSpacing.screenHorizontalCompact,
                44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFactChips(exhibit, l10n, cs),
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
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------

  Widget _buildSliverAppBar(
    Exhibit exhibit,
    String language,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isBookmarked,
    ExhibitProvider exhibitProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: cs.surface,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () => _toggleBookmark(exhibit, l10n, exhibitProvider),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          exhibit.getName(language),
          style: AppTextStyles.displayArtifactTitle(
            context,
          ).copyWith(color: Colors.white, fontSize: 18),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
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
    ColorScheme cs,
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
