import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibits = MockDataService.getAllExhibits();
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isArabic ? "المعروضات" : "Exhibits",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: exhibits.length,
        itemBuilder: (context, index) {
          final exhibit = exhibits[index];
          return _ExhibitListTile(
            exhibit: exhibit,
            prefs: prefs,
            isArabic: isArabic,
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
  final bool isArabic;
  final VoidCallback onTap;

  const _ExhibitListTile({
    required this.exhibit,
    required this.prefs,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Thumbnail (placeholder – replace with real asset later)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: cs.primary.withOpacity(0.08),
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 30,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? "المعرض الرئيسي"
                          : "Main exhibition gallery",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
