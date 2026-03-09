import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';

class TourPlannerScreen extends StatelessWidget {
  const TourPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppMenuShell(
      title: l10n.tourPlanner,
      bottomNavigationBar: const BottomNav(currentIndex: 2), // Planner index
      body: Center(child: Text(l10n.tourPlanner)),
    );
  }
}
