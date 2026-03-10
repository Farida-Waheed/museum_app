import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_card.dart';
import '../../core/services/mock_data.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final allEvents = MockDataService.getAllEvents();
    final liveEvents = allEvents.where((e) => e.isLive).toList();
    final upcomingEvents = allEvents.where((e) => !e.isLive).toList();

    return AppMenuShell(
      title: l10n.events,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.happeningNow, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            if (liveEvents.isEmpty)
              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(l10n.noEvents, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ...liveEvents.map((e) => _buildEventCard(
                    e.getTitle(lang),
                    "${e.getLocation(lang)} • ${l10n.live}",
                    Icons.sensors,
                    isLive: true,
                  )),
            const SizedBox(height: 24),
            Text(l10n.upcomingEvents, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...upcomingEvents.map((e) => _buildEventCard(
                  e.getTitle(lang),
                  "${e.getLocation(lang)} • ${e.dateTime.hour}:${e.dateTime.minute.toString().padLeft(2, '0')}",
                  Icons.event,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String desc, IconData icon, {bool isLive = false}) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
