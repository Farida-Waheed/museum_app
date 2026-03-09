import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tour_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/primary_button.dart';

class VisitSummaryScreen extends StatelessWidget {
  const VisitSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tourProvider = Provider.of<TourProvider>(context);
    final visitedCount = tourProvider.visitedExhibitIds.length;

    return AppMenuShell(
      title: l10n.visitSummary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(l10n.congrats, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.visitComplete, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              _buildStatRow(l10n.exhibitsVisited, "$visitedCount"),
              const SizedBox(height: 16),
              _buildStatRow(l10n.totalTime, "45 min"),
              const SizedBox(height: 48),
              PrimaryButton(
                label: l10n.shareVisit,
                onPressed: () {},
                icon: Icons.share,
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: Text(l10n.done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}
