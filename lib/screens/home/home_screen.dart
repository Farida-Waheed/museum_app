import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Exhibit> exhibits;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;
  double robotX = 100;
  double robotY = 100;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    
    // Privacy Check
    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    // Notification Simulation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔔 Alert: Tour starting in Hall A in 5 mins!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueAccent,
          )
        );
      }
    });
    
    // Animation Timer
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          robotX = (robotX + 20) % 300;
          robotY = (robotY + 10) % 200;
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Privacy & Permissions"),
        content: const Text("We use Bluetooth and Location for guidance.\nData is anonymous."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Deny")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Allow")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
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
          // --- NEW: Settings Button in AppBar ---
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            tooltip: isArabic ? "الإعدادات" : "Settings",
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
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
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "مرحباً بكم" : "Welcome Back",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? "استمتع بجولتك مع الدليل الذكي" : "Enjoy your interactive tour with our AI Guide.",
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
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.map, "${exhibits.length}", isArabic ? "المعروضات" : "Exhibits", Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(Icons.trending_up, "$visitedCount", isArabic ? "تمت زيارتها" : "Visited", Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(Icons.timer, "${durationMinutes}m", isArabic ? "المدة" : "Time", Colors.purple)),
              ],
            ),

            const SizedBox(height: 16),

            // Map Preview
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

            // Grid Menu
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
                _buildNavButton(context, AppRoutes.search, Icons.search, isArabic ? "بحث" : "Search", Colors.orange),
                _buildNavButton(context, AppRoutes.chat, Icons.chat, isArabic ? "المحادثة" : "Chat", Colors.green),
                _buildNavButton(context, AppRoutes.quiz, Icons.school, isArabic ? "اختبار" : "Quiz", Colors.red),
                _buildNavButton(context, AppRoutes.feedback, Icons.feedback, isArabic ? "رأيك" : "Feedback", Colors.purple),
                _buildNavButton(context, AppRoutes.progress, Icons.trending_up, isArabic ? "التقدم" : "Progress", Colors.teal),
                // Removed Settings from here
              ],
            ),

            const SizedBox(height: 24),

            // --- NEW: Separate Settings Area ---
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.settings, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "الإعدادات وسهولة الوصول" : "Settings & Accessibility",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            isArabic ? "اللغة، التباين، وحجم الخط" : "Language, High Contrast, Font Size",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Sub-widgets helpers (Same as before)
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
          CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 18)),
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
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
            ...exhibits.map((e) {
              double dx = (e.x / 400) * constraints.maxWidth; 
              double dy = (e.y / 600) * constraints.maxHeight;
              return Positioned(
                left: dx.clamp(0, constraints.maxWidth - 20),
                top: dy.clamp(0, constraints.maxHeight - 20),
                child: const Icon(Icons.circle, color: Colors.redAccent, size: 8),
              );
            }),
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