import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/tour_provider.dart';
import '../../widgets/app_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tourProvider = Provider.of<TourProvider>(context);
    final visitedCount = tourProvider.visitedExhibitIds.length;

    return AppMenuShell(
      title: l10n.myJourney,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             AppCard(
               child: Row(
                 children: [
                   const Icon(Icons.stars, size: 48, color: Colors.amber),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(l10n.exhibitsFound, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                         Text("$visitedCount", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blue)),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 24),
             Text(l10n.achievements, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
             const SizedBox(height: 12),
             _buildAchievementTile(Icons.explore, l10n.pioneer, l10n.pioneerDesc, visitedCount >= 1),
             _buildAchievementTile(Icons.history_edu, l10n.scholar, l10n.scholarDesc, false),
             _buildAchievementTile(Icons.map, l10n.wayfinder, l10n.wayfinderDesc, false),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementTile(IconData icon, String title, String subtitle, bool isUnlocked) {
    return Card(
      elevation: 0,
      color: isUnlocked ? Colors.blue.withOpacity(0.05) : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isUnlocked ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: isUnlocked ? Colors.blue : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isUnlocked ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock_outline, size: 18),
      ),
    );
  }
}
