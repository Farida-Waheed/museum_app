import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';

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

    final visited =
        _allExhibits.where((e) => _visitedExhibitIds.contains(e.id)).toList();
    final unvisited =
        _allExhibits.where((e) => !_visitedExhibitIds.contains(e.id)).toList();

    final progress = _allExhibits.isEmpty
        ? 0.0
        : _visitedExhibitIds.length / _allExhibits.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      appBar: AppBar(
        title: Text(
          isArabic ? "تقدم الجولة" : "Tour progress",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // overview
            Card(
              elevation: 1,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "الجولة الحالية" : "Current tour",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? "التقدم" : "Progress",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "${visited.length} / ${_allExhibits.length} "
                          "${isArabic ? 'معروضات' : 'exhibits'}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _statItem(
                            icon: Icons.access_time,
                            color: cs.primary,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
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
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.exhibitDetails,
            arguments: exhibit,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: visited
                      ? Colors.green.withOpacity(0.08)
                      : cs.primary.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visited ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: visited ? Colors.green : cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visited
                          ? (isArabic ? "تمت الزيارة" : "Visited")
                          : (isArabic ? "لم تُزر بعد" : "Not visited yet"),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
