import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/app_card.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibits = MockDataService.getAllExhibits();
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFF1F5F9),
                child: const Icon(
                  Icons.museum_outlined,
                  size: 28,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibit.getName(prefs.language),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? "المعرض الرئيسي" : "Main Gallery",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
