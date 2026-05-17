import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';
    final allEvents = MockDataService.getAllEvents();
    final liveEvents = allEvents.where((e) => e.isLive).toList();
    final upcomingEvents = allEvents.where((e) => !e.isLive).toList();

    return AppMenuShell(
      title: l10n.events.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _SectionTitle(l10n.happeningNow),
                const SizedBox(height: 16),
                if (liveEvents.isEmpty)
                  _EmptyEventCard(message: l10n.noEvents)
                else
                  ...liveEvents.map(
                    (event) => _EventCard(
                      title: event.getTitle(lang),
                      description: '${event.getLocation(lang)} • ${l10n.live}',
                      icon: Icons.sensors,
                      isLive: true,
                    ),
                  ),
                const SizedBox(height: 32),
                _SectionTitle(l10n.upcomingEvents),
                const SizedBox(height: 16),
                ...upcomingEvents.map(
                  (event) => _EventCard(
                    title: event.getTitle(lang),
                    description:
                        '${event.getLocation(lang)} • ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                    icon: Icons.event_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      textAlign: TextAlign.start,
      style: AppTextStyles.displaySectionTitle(
        context,
      ).copyWith(color: AppColors.softGold),
    );
  }
}

class _EmptyEventCard extends StatelessWidget {
  const _EmptyEventCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassCard(radius: 24),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryGold),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: AppTextStyles.bodyPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.description,
    required this.icon,
    this.isLive = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: isLive
          ? AppDecorations.premiumGlassCard(radius: 22, highlighted: true)
          : AppDecorations.secondaryGlassCard(radius: 22),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Icon(icon, size: 28, color: AppColors.primaryGold),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.metadata(context),
                ),
              ],
            ),
          ),
          Icon(
            isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            color: AppColors.neutralDark,
          ),
        ],
      ),
    );
  }
}
