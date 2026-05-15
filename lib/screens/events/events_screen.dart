import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_card.dart';
import '../../core/services/mock_data.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

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
      title: l10n.events.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.happeningNow.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            const SizedBox(height: 16),
            if (liveEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.noEvents,
                      style: AppTextStyles.bodyPrimary(context),
                    ),
                  ],
                ),
              )
            else
              ...liveEvents.map(
                (e) => _buildEventCard(
                  context,
                  e.getTitle(lang),
                  "${e.getLocation(lang)} • ${l10n.live}",
                  Icons.sensors,
                  isLive: true,
                ),
              ),
            const SizedBox(height: 32),
            Text(
              l10n.upcomingEvents.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            const SizedBox(height: 16),
            ...upcomingEvents.map(
              (e) => _buildEventCard(
                context,
                e.getTitle(lang),
                "${e.getLocation(lang)} • ${e.dateTime.hour}:${e.dateTime.minute.toString().padLeft(2, '0')}",
                Icons.event,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon, {
    bool isLive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLive
              ? AppColors.primaryGold.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primaryGold),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.metadata(context)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.neutralDark),
        ],
      ),
    );
  }
}
