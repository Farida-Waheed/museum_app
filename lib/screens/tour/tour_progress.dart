import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class TourProgressScreen extends StatefulWidget {
  const TourProgressScreen({super.key});

  @override
  State<TourProgressScreen> createState() => _TourProgressScreenState();
}

class _TourProgressScreenState extends State<TourProgressScreen> {
  late List<Exhibit> _allExhibits;

  final List<String> _visitedExhibitIds = ['1', '2'];
  final int _durationMinutes = 45;

  @override
  void initState() {
    super.initState();
    _allExhibits = MockDataService.getAllExhibits();
  }

  String _formatDuration(int minutes) {
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    if (hours > 0) return "${hours}h ${mins}m";
    return "${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final cs = Theme.of(context).colorScheme;

    final visited = _allExhibits
        .where((e) => _visitedExhibitIds.contains(e.id))
        .toList();
    final unvisited = _allExhibits
        .where((e) => !_visitedExhibitIds.contains(e.id))
        .toList();

    final progress = _allExhibits.isEmpty
        ? 0.0
        : _visitedExhibitIds.length / _allExhibits.length;

    return AppMenuShell(
      title: (isArabic ? "تقدم الجولة" : "Tour Progress").toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // overview
            Container(
              decoration: BoxDecoration(
                color: AppColors.cinematicCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      (isArabic ? "الجولة الحالية" : "Current tour")
                          .toUpperCase(),
                      style: AppTextStyles.displaySectionTitle(context),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? "التقدم" : "Progress",
                          style: AppTextStyles.metadata(
                            context,
                          ).copyWith(color: Colors.white70),
                        ),
                        Text(
                          "${visited.length} / ${_allExhibits.length} "
                          "${isArabic ? 'معروضات' : 'exhibits'}",
                          style: AppTextStyles.metadata(context).copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withOpacity(0.05)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _statItem(
                            icon: Icons.access_time,
                            color: AppColors.primaryGold,
                            label: isArabic ? "المدة" : "Duration",
                            value: _formatDuration(_durationMinutes),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statItem(
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                            label: isArabic ? "مكتمل" : "Completed",
                            value: "${visited.length}",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (visited.isNotEmpty) ...[
              _sectionHeader(
                icon: Icons.check_circle,
                color: Colors.green,
                title: isArabic
                    ? "تمت زيارتها (${visited.length})"
                    : "Visited (${visited.length})",
              ),
              const SizedBox(height: 10),
              ...visited.map(
                (e) => _exhibitRow(
                  context,
                  exhibit: e,
                  prefs: prefs,
                  isArabic: isArabic,
                  visited: true,
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (unvisited.isNotEmpty) ...[
              _sectionHeader(
                icon: Icons.location_on_outlined,
                color: Colors.grey,
                title: isArabic
                    ? "لم تتم زيارتها (${unvisited.length})"
                    : "Not visited (${unvisited.length})",
              ),
              const SizedBox(height: 10),
              ...unvisited.map(
                (e) => _exhibitRow(
                  context,
                  exhibit: e,
                  prefs: prefs,
                  isArabic: isArabic,
                  visited: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.metadata(context).copyWith(fontSize: 11),
            ),
            Text(
              value,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.displaySectionTitle(
            context,
          ).copyWith(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _exhibitRow(
    BuildContext context, {
    required Exhibit exhibit,
    required UserPreferencesModel prefs,
    required bool isArabic,
    required bool visited,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.exhibitDetails,
            arguments: exhibit,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: visited
                      ? Colors.green.withOpacity(0.12)
                      : AppColors.primaryGold.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visited ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: visited ? Colors.green : AppColors.primaryGold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: AppTextStyles.bodyPrimary(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visited
                          ? (isArabic ? "تمت الزيارة" : "Visited")
                          : (isArabic ? "لم تُزر بعد" : "Not visited yet"),
                      style: AppTextStyles.metadata(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.neutralMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
