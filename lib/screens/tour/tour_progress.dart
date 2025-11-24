import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';

class TourProgressScreen extends StatefulWidget {
  const TourProgressScreen({super.key});

  @override
  State<TourProgressScreen> createState() => _TourProgressScreenState();
}

class _TourProgressScreenState extends State<TourProgressScreen> {
  late List<Exhibit> _allExhibits;
  
  // Simulating progress data (In a real app, this comes from a Provider/Database)
  final List<String> _visitedExhibitIds = ['1', '2']; // Mocking that ID '1' and '2' are visited
  final int _durationMinutes = 45; // Mocking duration

  @override
  void initState() {
    super.initState();
    _allExhibits = MockDataService.getAllExhibits();
  }

  String _formatDuration(int minutes) {
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    if (hours > 0) {
      return "${hours}h ${mins}m";
    }
    return "${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // Filter Data
    final visitedExhibits = _allExhibits.where((e) => _visitedExhibitIds.contains(e.id)).toList();
    final unvisitedExhibits = _allExhibits.where((e) => !_visitedExhibitIds.contains(e.id)).toList();
    
    final double progressPercentage = _visitedExhibitIds.length / _allExhibits.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "تقدم الجولة" : "Tour Progress"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Overview Card ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "الجولة الحالية" : "Current Tour",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // Progress Label & Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? "التقدم" : "Progress", style: TextStyle(color: Colors.grey[600])),
                        Text("${visitedExhibits.length} / ${_allExhibits.length} ${isArabic ? 'معروضات' : 'exhibits'}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Stats Grid
                    Row(
                      children: [
                        // Duration Stat
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                                child: const Icon(Icons.access_time, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isArabic ? "المدة" : "Duration", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(_formatDuration(_durationMinutes), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Completed Stat
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isArabic ? "مكتمل" : "Completed", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text("${visitedExhibits.length} ${isArabic ? 'عنصر' : 'items'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. Visited Exhibits List ---
            if (visitedExhibits.isNotEmpty) ...[
              _buildSectionHeader(
                icon: Icons.check_circle, 
                color: Colors.green, 
                title: "${isArabic ? 'تمت زيارتها' : 'Visited'} (${visitedExhibits.length})"
              ),
              const SizedBox(height: 12),
              ...visitedExhibits.map((e) => _buildExhibitTile(context, e, isVisited: true, prefs: prefs)).toList(),
              const SizedBox(height: 24),
            ],

            // --- 3. Unvisited Exhibits List ---
            if (unvisitedExhibits.isNotEmpty) ...[
              _buildSectionHeader(
                icon: Icons.location_on, 
                color: Colors.grey, 
                title: "${isArabic ? 'لم تتم زيارتها' : 'Not Visited'} (${unvisitedExhibits.length})"
              ),
              const SizedBox(height: 12),
              ...unvisitedExhibits.map((e) => _buildExhibitTile(context, e, isVisited: false, prefs: prefs)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionHeader({required IconData icon, required Color color, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExhibitTile(BuildContext context, Exhibit exhibit, {required bool isVisited, required UserPreferencesModel prefs}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isVisited ? Colors.green[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isVisited ? Colors.green.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isVisited ? Colors.green.shade100 : Colors.grey.shade200),
                ),
                child: Icon(
                  isVisited ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: isVisited ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              
              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isVisited ? "Completed" : "Pending", // Could be replaced with category if available
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Badge or Button
              if (isVisited)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.check, size: 14, color: Colors.green),
                )
              else
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text("View", style: TextStyle(fontSize: 12, color: Colors.black87)),
                )
            ],
          ),
        ),
      ),
    );
  }
}