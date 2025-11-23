import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart'; // To get exhibits data
import '../../app/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Simulation State for the "Live" feel
  late List<Exhibit> exhibits;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;
  
  // Robot Mock Position for the MiniMap
  double robotX = 100;
  double robotY = 100;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    
    // Start a fake timer to make the dashboard feel "Alive"
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Move robot randomly on mini-map
          robotX = (robotX + 20) % 300;
          robotY = (robotY + 10) % 200;
          // Increment duration occasionally
          if (timer.tick % 20 == 0) durationMinutes++;
        });
      }
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      // Custom App Bar for Home
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("🤖", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isArabic ? "روبوت المتحف" : "Museum Guide", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(isArabic ? "جولة تفاعلية" : "Interactive Tour", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Chip(
              label: Text(prefs.language.toUpperCase()),
              avatar: const Icon(Icons.language, size: 16),
              backgroundColor: Colors.grey[100],
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Welcome Card ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "مرحباً بكم في المتحف" : "Welcome to the Museum",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic 
                      ? "اتبع دليلنا الآلي للحصول على جولة تفاعلية. تتبع تقدمك وتعلم بالسرعة التي تناسبك."
                      : "Follow our AI-powered robot guide for an interactive tour experience. Track your progress and learn at your own pace.",
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                        icon: const Icon(Icons.map, color: Colors.blue),
                        label: Text(isArabic ? "الخريطة" : "View Map"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.exhibits),
                        icon: const Icon(Icons.list),
                        label: Text(isArabic ? "المعروضات" : "Exhibits"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // --- 2. Quick Stats ---
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.map, "${exhibits.length}", isArabic ? "المعروضات" : "Total Exhibits", Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(Icons.trending_up, "$visitedCount", isArabic ? "تمت زيارتها" : "Visited", Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(Icons.timer, "${durationMinutes}m", isArabic ? "المدة" : "Duration", Colors.purple)),
              ],
            ),

            const SizedBox(height: 16),

            // --- 3. Map Preview ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? "معاينة الخريطة" : "Map Preview", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                          child: Text(isArabic ? "عرض كامل" : "Full View"),
                        )
                      ],
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildMiniMap(),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 4. Navigation Grid ---
            Text(
              isArabic ? "اكتشف الميزات" : "Explore Features",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildNavButton(context, AppRoutes.map, Icons.map, isArabic ? "الخريطة" : "Map", Colors.blue),
                _buildNavButton(context, AppRoutes.exhibits, Icons.search, isArabic ? "بحث" : "Search", Colors.orange),
                _buildNavButton(context, AppRoutes.chat, Icons.chat, isArabic ? "المحادثة" : "Chat", Colors.green),
                _buildNavButton(context, AppRoutes.quiz, Icons.school, isArabic ? "اختبار" : "Quiz", Colors.red), // Placeholder route
                _buildNavButton(context, AppRoutes.settings, Icons.settings, isArabic ? "الإعدادات" : "Settings", Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String route, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: Colors.blueGrey[800], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Exhibits Dots
            ...exhibits.map((e) {
              double dx = (e.x / 400) * constraints.maxWidth; // Scale mock coords to fit box
              double dy = (e.y / 600) * constraints.maxHeight;
              return Positioned(
                left: dx.clamp(0, constraints.maxWidth - 20),
                top: dy.clamp(0, constraints.maxHeight - 20),
                child: const Icon(Icons.circle, color: Colors.redAccent, size: 8),
              );
            }),
            // Animated Robot
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: (robotX / 400) * constraints.maxWidth,
              top: (robotY / 600) * constraints.maxHeight,
              child: const Icon(Icons.smart_toy, color: Colors.blue, size: 24),
            )
          ],
        );
      }
    );
  }
}