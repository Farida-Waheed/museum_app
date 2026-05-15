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

    return AppMenuShell(
      title: l10n.exhibits.toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: exhibitProvider.isLoading && exhibits.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: exhibits.length,
              itemBuilder: (context, index) {
                final exhibit = exhibits[index];
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
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkDivider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 72,
                  height: 72,
                  color: AppColors.primaryGold.withOpacity(0.05),
                  child: Icon(
                    Icons.museum_outlined,
                    size: 32,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: AppTextStyles.displayArtifactTitle(
                        context,
                      ).copyWith(fontSize: 16),
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
                          style: AppTextStyles.metadata(context),
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
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
