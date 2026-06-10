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
        backgroundColor: AppColors.resolvedCard,
        content: Text(
          isBookmarked ? l10n.addedToBookmarks : l10n.removedFromBookmarks,
          style: AppTextStyles.bodyPrimary(
            context,
          ).copyWith(color: AppColors.resolvedTitleText),
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
              tooltip: isBookmarked
                  ? l10n.removedFromBookmarks
                  : l10n.addToMyRoute,
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primaryGold,
              ),
              onPressed: () => _toggleBookmark(exhibit, l10n, exhibitProvider),
            ),
          ),
      ],
      body: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.resolvedBackground),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 144),
          children: [
            _ExhibitHero(exhibit: exhibit),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalCompact,
                0,
                AppSpacing.screenHorizontalCompact,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExhibitDetailsPanel(
                    exhibit: exhibit,
                    language: prefs.language,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhibitHero extends StatelessWidget {
  const _ExhibitHero({required this.exhibit});

  final Exhibit exhibit;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.sizeOf(context).height * 0.50;
    return SizedBox(
      height: heroHeight.clamp(340.0, 460.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (exhibit.imageUrl.trim().isNotEmpty)
            Image.network(
              exhibit.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _ExhibitImageFallback(imageAsset: exhibit.imageAsset),
            )
          else
            _ExhibitImageFallback(imageAsset: exhibit.imageAsset),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.heroImageOverlay),
          ),
          PositionedDirectional(
            start: AppSpacing.screenHorizontalCompact,
            bottom: 24,
            child: Text(
              'Grand Egyptian Museum',
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.primaryGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExhibitDetailsPanel extends StatelessWidget {
  const _ExhibitDetailsPanel({required this.exhibit, required this.language});

  final Exhibit exhibit;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <_DetailRowData>[
      _DetailRowData(l10n.gallery, exhibit.floor),
      _DetailRowData(l10n.period, exhibit.category),
      _DetailRowData(
        'Recommended time',
        exhibit.recommendedDurationMin == null
            ? ''
            : '${exhibit.recommendedDurationMin} min',
      ),
      _DetailRowData('Photo spot', exhibit.photoSpot ? 'Yes' : ''),
    ].where((row) => row.value.trim().isNotEmpty).toList();
    final description = exhibit.getDescription(language).trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
            decoration: AppDecorations.secondaryGlassCard(radius: 22),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) _DetailRow(data: rows[i]),
              ],
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.description.toUpperCase(),
            style: AppTextStyles.premiumSectionLabel(
              context,
            ).copyWith(color: AppColors.softGold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
            decoration: AppDecorations.secondaryGlassCard(radius: 22),
            child: Text(
              description,
              style: AppTextStyles.premiumBody(
                context,
              ).copyWith(height: 1.58, color: AppColors.resolvedBodyText),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExhibitImageFallback extends StatelessWidget {
  const _ExhibitImageFallback({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageAsset.isNotEmpty ? imageAsset : 'assets/images/museum_interior.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.resolvedCard,
        child: const Center(
          child: Icon(
            Icons.museum_outlined,
            color: AppColors.primaryGold,
            size: 42,
          ),
        ),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              data.label.toUpperCase(),
              textAlign: TextAlign.start,
              style: AppTextStyles.premiumSectionLabel(
                context,
              ).copyWith(fontSize: 10, color: AppColors.softGold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              data.value,
              textAlign: TextAlign.start,
              style: AppTextStyles.premiumBody(
                context,
              ).copyWith(color: AppColors.resolvedTitleText, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
