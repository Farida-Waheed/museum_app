import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart';

// --- ARABIC TRANSLATION MAPS ---
const Map<String, String> _highlightTitlesAr = {
  "Tutankhamun Mask": "قناع توت عنخ آمون",
  "Golden Hieroglyphs": "الهيروغليفية الذهبية",
  "Canopic Jars": "الأواني الكانوبية",
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Exhibit> exhibits;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;

  double robotX = 100;
  double robotY = 100;

  int pageIndex = 0;
  final PageController _pageCtrl = PageController(viewportFraction: .9);

  late final AnimationController _grad =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat(reverse: true);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    exhibits = MockDataService.getAllExhibits();

    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      final isArabic = prefs.language == 'ar';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "🔔 تنبيه: تبدأ الجولة في القاعة (أ) خلال 5 دقائق!"
                : "🔔 Alert: Tour starting in Hall A in 5 mins!",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blueAccent,
        ),
      );
    });

    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      setState(() {
        robotX = (robotX + 20) % 300;
        robotY = (robotY + 10) % 200;

        if (timer.tick % 20 == 0) visitedCount++;
        if (timer.tick % 20 == 0) durationMinutes++;
      });
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _pageCtrl.dispose();
    _grad.dispose();
    super.dispose();
  }

  void _showPrivacyDialog() {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final isArabic = prefs.language == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? "الخصوصية والأذونات" : "Privacy & Permissions"),
        content: Text(
          isArabic
              ? "نستخدم تقنيتي البلوتوث والموقع لتوجيهك.\n\n• البيانات مجهولة.\n• تُستخدم خرائط الحرارة لأغراض التحليل.\n\nهل تسمح لنا باستخدام موقعك؟"
              : "We use Bluetooth and Location to guide you.\n\n• Data is anonymous.\n• Heatmaps are for analytics.\n\nDo you allow us to use your location?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? "رفض" : "Deny"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? "سماح" : "Allow"),
          ),
        ],
      ),
    );
  }

  // POPUP CHAT
  void _openChatPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.80,
                child: const ChatScreen(isPopup: true),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================
  // NEW CLEAN DRAWER
  // ============================
  Drawer _buildDrawer(bool isArabic) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Clean Icon
              Center(
                child: Image.asset(
                  "assets/icons/ankh.png",
                  height: 70,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.account_balance, size: 60),
                ),
              ),

              const SizedBox(height: 40),

              _drawerItem(
                icon: Icons.search,
                label: isArabic ? "بحث" : "Search",
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              _drawerItem(
                icon: Icons.school,
                label: isArabic ? "الاختبار" : "Quiz",
                onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
              ),
              _drawerItem(
                icon: Icons.feedback,
                label: isArabic ? "رأيك" : "Feedback",
                onTap: () => Navigator.pushNamed(context, AppRoutes.feedback),
              ),
              _drawerItem(
                icon: Icons.language,
                label: isArabic ? "اللغة" : "Language",
                onTap: () => Navigator.pushNamed(context, AppRoutes.language),
              ),
              _drawerItem(
                icon: Icons.radio_button_checked,
                label: isArabic ? "جولة حية" : "Live Tour",
                onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
              ),

              const Spacer(),
              const Divider(),
              const SizedBox(height: 8),
              // ❌ version removed
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // ============================

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(isArabic),
      bottomNavigationBar: const BottomNav(currentIndex: 0),

      floatingActionButton: _RoboFab(
        label: isArabic ? "تحدث مع الروبوت" : "Talk to Robo-Guide",
        onTap: _openChatPopup,
      ),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            const Text("🤖", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              isArabic ? "روبوت المتحف" : "Museum Guide",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // ===============================
      // HOME CONTENT (unchanged)
      // ===============================
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverToBoxAdapter(
            child: Container(
              height: 240,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/museum_interior.jpg',
                      fit: BoxFit.cover,
                    ),
                    AnimatedBuilder(
                      animation: _grad,
                      builder: (_, __) {
                        final v = _grad.value;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              transform: GradientRotation(pi * (.05 + .15 * v)),
                              colors: [
                                cs.secondary.withOpacity(.12 + .10 * v),
                                cs.primary.withOpacity(.14 - .06 * v),
                                cs.tertiary.withOpacity(.10 + .06 * v),
                                Colors.black.withOpacity(.45),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? "استكشف مصر مع الدليل الآلي"
                                : "Explore Egypt with Robo-Guide",
                            style: t.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              _GlassChip(
                                  label:
                                      isArabic ? "جاهز للواقع المعزز" : "AR Ready",
                                  icon: "assets/icons/scarab.png",
                                  isArabic: isArabic),
                              _GlassChip(
                                  label: isArabic ? "بلغتان" : "Bilingual",
                                  icon: "assets/icons/ankh.png",
                                  isArabic: isArabic),
                              _GlassChip(
                                  label: isArabic ? "خريطة مباشرة" : "Live Map",
                                  icon: "assets/icons/maps.png",
                                  isArabic: isArabic),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(Icons.map, "${exhibits.length}",
                            isArabic ? "المعروضات" : "Exhibits", Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(Icons.trending_up, "$visitedCount",
                            isArabic ? "تمت زيارتها" : "Visited", Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(Icons.timer, "${durationMinutes}m",
                            isArabic ? "المدة" : "Duration", Colors.purple),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    isArabic ? "معروضات اليوم" : "Today’s Highlights",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 180,
                    child: PageView(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: [
                        _HighlightCard(
                            title: isArabic
                                ? _highlightTitlesAr["Tutankhamun Mask"]!
                                : "Tutankhamun Mask",
                            image: "assets/images/pharaoh_head.jpg"),
                        _HighlightCard(
                            title: isArabic
                                ? _highlightTitlesAr["Golden Hieroglyphs"]!
                                : "Golden Hieroglyphs",
                            image: "assets/images/hieroglyphs.jpg"),
                        _HighlightCard(
                            title: isArabic
                                ? _highlightTitlesAr["Canopic Jars"]!
                                : "Canopic Jars",
                            image: "assets/images/canopic_jars.jpg"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  _Dots(count: 3, index: pageIndex),

                  const SizedBox(height: 24),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isArabic
                                    ? "معاينة الخريطة (موقع الروبوت)"
                                    : "Map Preview (Robot Location)",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, AppRoutes.map),
                                child: Text(isArabic ? "عرض كامل" : "Full View"),
                              ),
                            ],
                          ),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildMiniMap(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SMALL WIDGETS

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return LayoutBuilder(builder: (context, c) {
      return Stack(
        children: [
          ...exhibits.map((e) {
            double dx = (e.x / 400) * c.maxWidth;
            double dy = (e.y / 600) * c.maxHeight;

            return Positioned(
              left: dx.clamp(0, c.maxWidth - 5),
              top: dy.clamp(0, c.maxHeight - 5),
              child:
                  const Icon(Icons.circle, size: 8, color: Colors.redAccent),
            );
          }),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            left: (robotX / 400) * c.maxWidth,
            top: (robotY / 600) * c.maxHeight,
            child: const Icon(Icons.smart_toy, size: 24, color: Colors.blue),
          ),
        ],
      );
    });
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isArabic;

  const _GlassChip({required this.label, this.icon, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              if (icon != null) ...[
                Image.asset(
                  icon!,
                  width: 16,
                  height: 16,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.star, size: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String image;
  const _HighlightCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(.45),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: isArabic ? null : 14,
              right: isArabic ? 14 : null,
              bottom: 12,
              child: Text(
                title,
                style: t.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.secondary : cs.onSurface.withOpacity(.3),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _RoboFab extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RoboFab({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8, right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [
            cs.tertiary.withOpacity(.9),
            cs.secondary.withOpacity(.9),
          ]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
