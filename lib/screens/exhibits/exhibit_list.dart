import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibits = MockDataService.getAllExhibits();
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return AppMenuShell(
      title: l10n.exhibits,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView.builder(
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                  color: cs.primary.withOpacity(0.05),
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 32,
                    color: Colors.black54,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          l10n.mainGallery,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
