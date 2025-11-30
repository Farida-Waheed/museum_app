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
import '../../widgets/tour_alert.dart'; 

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

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
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

  // side menu animation
  late final AnimationController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    exhibits = MockDataService.getAllExhibits();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    // Privacy dialog (currently every app open – can later make it "once only")
    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    // 🔔 Use shared tour-alert widget (only shows once per app session)
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final prefs =
          Provider.of<UserPreferencesModel>(context, listen: false);
      final isArabic = prefs.language == 'ar';

      showTourAlertOnce(
        context,
        isArabic: isArabic,
        hallNameEn: 'Hall A',
        hallNameAr: 'القاعة (أ)',
        minutes: 5,
        onViewMap: () =>
            Navigator.pushNamed(context, AppRoutes.map),
      );
    });

    // Simple simulation: robot + stats move over time
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
    _menuController.dispose();
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
              ? "أنخو يستخدم البلوتوث والموقع لمرافقتك داخل المتحف.\n\n• البيانات مجهولة الهوية.\n• تُستخدم خرائط الحركة لأغراض التحليل فقط.\n\nهل تسمح باستخدام موقعك؟"
              : "Ankhu uses Bluetooth and Location to walk with you inside the museum.\n\n• Data is anonymous.\n• Movement heatmaps are only for analytics.\n\nDo you allow us to use your location?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? "رفض" : "Deny"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: store acceptance in UserPreferencesModel if needed
              Navigator.pop(context);
            },
            child: Text(isArabic ? "سماح" : "Allow"),
          ),
        ],
      ),
    );
  }

  // toggle side menu
  void _toggleMenu() {
    if (_isMenuOpen) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    const Color lightGreyBG = Colors.white; // pure white background

    return Scaffold(
      backgroundColor: lightGreyBG,
      bottomNavigationBar: const BottomNav(currentIndex: 0),

      // Ankhu chat entry on Home
      floatingActionButton: const RoboGuideEntry(),

      body: AnimatedBuilder(
        animation: _menuController,
        builder: (context, _) {
          final double v = _menuController.value;
          final double scale = 1 - 0.18 * v;
          final double radius = 32 * v;
          final double dx = (isArabic ? -1 : 1) * size.width * 0.62 * v;

          return Stack(
            children: [
              // Background behind the card
              Container(color: lightGreyBG),

              // SIDE MENU
              Transform.translate(
                offset: Offset(-(size.width * 0.30 * (1 - v)), 0),
                child: const _SideMenuWrapper(),
              ),

              // MAIN CONTENT CARD (slides & scales when menu opens)
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.22),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Scaffold(
                        backgroundColor: Colors.white,
                        appBar: AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black),
                            onPressed: _toggleMenu,
                          ),
                          title: Row(
                            children: [
                              // flat Ankhu icon
                              Image.asset(
                                "assets/icons/ankh.png",
                                width: 26,
                                height: 26,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isArabic
                                    ? "أنخو"
                                    : "Ankhu",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.qrScan),
                            ),
                          ],
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),

                        body: CustomScrollView(
                          slivers: [
                            // ===== HERO HEADER =====
                            SliverToBoxAdapter(
                              child: Container(
                                height: 240,
                                margin:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        'assets/images/museum_interior.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                      // Animated gradient wash
                                      AnimatedBuilder(
                                        animation: _grad,
                                        builder: (_, __) {
                                          final gv = _grad.value;
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                transform: GradientRotation(
                                                    pi * (.05 + .15 * gv)),
                                                colors: [
                                                  cs.secondary.withOpacity(
                                                      .12 + .10 * gv),
                                                  cs.primary.withOpacity(
                                                      .14 - .06 * gv),
                                                  cs.tertiary.withOpacity(
                                                      .10 + .06 * gv),
                                                  Colors.black.withOpacity(.55),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isArabic
                                                  ? "استكشف مصر مع أنخو"
                                                  : "Explore Egypt with Ankhu",
                                              style:
                                                  t.headlineSmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // === NEXT STOP CARD ===
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              onTap: () => Navigator.pushNamed(
                                                context,
                                                AppRoutes.progress,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  color: Colors.black
                                                      .withOpacity(0.30),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.route,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        isArabic
                                                            ? "المحطة التالية: قاعة توت عنخ آمون خلال ٥ دقائق"
                                                            : "Next stop: Tutankhamun Hall in 5 min",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ===== BODY CONTENT =====
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // --- STATS ROW ---
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.map,
                                            value: "${exhibits.length}",
                                            label: isArabic
                                                ? "المعروضات"
                                                : "Exhibits",
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.trending_up,
                                            value: "$visitedCount",
                                            label: isArabic
                                                ? "تمت زيارتها"
                                                : "Visited",
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.timer,
                                            value: "${durationMinutes}m",
                                            label: isArabic
                                                ? "المدة"
                                                : "Duration",
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // --- TODAY'S HIGHLIGHTS ---
                                    Text(
                                      isArabic
                                          ? "معروضات اليوم"
                                          : "Today’s Highlights",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    SizedBox(
                                      height: 180,
                                      child: PageView(
                                        controller: _pageCtrl,
                                        onPageChanged: (i) =>
                                            setState(() => pageIndex = i),
                                        children: [
                                          _HighlightCard(
                                            title: isArabic
                                                ? _highlightTitlesAr[
                                                    "Tutankhamun Mask"]!
                                                : "Tutankhamun Mask",
                                            image:
                                                "assets/images/pharaoh_head.jpg",
                                          ),
                                          _HighlightCard(
                                            title: isArabic
                                                ? _highlightTitlesAr[
                                                    "Golden Hieroglyphs"]!
                                                : "Golden Hieroglyphs",
                                            image:
                                                "assets/images/hieroglyphs.jpg",
                                          ),
                                          _HighlightCard(
                                            title: isArabic
                                                ? _highlightTitlesAr[
                                                    "Canopic Jars"]!
                                                : "Canopic Jars",
                                            image:
                                                "assets/images/canopic_jars.jpg",
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    _Dots(count: 3, index: pageIndex),
                                    const SizedBox(height: 24),

                                    // --- MAP PREVIEW CARD ---
                                    Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    isArabic
                                                        ? "معاينة الخريطة (موقع أنخو)"
                                                        : "Map Preview (Ankhu’s Location)",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pushNamed(
                                                          context,
                                                          AppRoutes.map),
                                                  child: Text(
                                                    isArabic
                                                        ? "عرض كامل"
                                                        : "Full View",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 180,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: _buildMiniMap(),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _LegendDot(
                                                  color: Colors.blue,
                                                  label: isArabic
                                                      ? "أنخو"
                                                      : "Ankhu",
                                                ),
                                                _LegendDot(
                                                  color: Colors.orange,
                                                  label: isArabic
                                                      ? "أنت"
                                                      : "You",
                                                ),
                                                _LegendDot(
                                                  color: Colors.redAccent,
                                                  label: isArabic
                                                      ? "معروض"
                                                      : "Exhibit",
                                                ),
                                              ],
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
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===== SMALL WIDGETS =====

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Optional: navigate based on label (Exhibits / Visited / Duration)
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(.10),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            // Exhibits
            ...exhibits.map((e) {
              double dx = (e.x / 400) * c.maxWidth;
              double dy = (e.y / 600) * c.maxHeight;

              return Positioned(
                left: dx.clamp(0, c.maxWidth - 5),
                top: dy.clamp(0, c.maxHeight - 5),
                child: const Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.redAccent,
                ),
              );
            }),
            // User static example marker (center-ish)
            Positioned(
              left: c.maxWidth * 0.5,
              top: c.maxHeight * 0.7,
              child: const Icon(
                Icons.circle,
                size: 10,
                color: Colors.orange,
              ),
            ),
            // Ankhu (robot) animated position
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: (robotX / 400) * c.maxWidth,
              top: (robotY / 600) * c.maxHeight,
              child: const Icon(
                Icons.smart_toy,
                size: 24,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ========== SIDE MENU WRAPPER ==========
class _SideMenuWrapper extends StatelessWidget {
  const _SideMenuWrapper();

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final isArabic = prefs.language == 'ar';
    return _SideMenu(isArabic: isArabic);
  }
}

// ========== SIDE MENU ==========
class _SideMenu extends StatelessWidget {
  final bool isArabic;
  const _SideMenu({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width * 0.70;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF3F6FB),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/icons/ankh.png",
                      width: 90,
                      height: 90,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "استكشف" : "Explore",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _MenuItem(
                            icon: Icons.map_rounded,
                            label: isArabic ? "الخريطة" : "Map",
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.map),
                          ),
                          _MenuItem(
                            icon: Icons.museum_outlined,
                            label: isArabic ? "المعارض" : "Exhibits",
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.search),
                          ),
                          _MenuItem(
                            icon: Icons.quiz_outlined,
                            label: isArabic ? "الاختبار" : "Quiz",
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.quiz),
                          ),
                          _MenuItem(
                            icon: Icons.radio_button_checked,
                            label: isArabic ? "جولة حية" : "Live Tour",
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.liveTour),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isArabic ? "الإعدادات" : "Settings",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _MenuItem(
                            icon: Icons.language,
                            label: isArabic ? "اللغة" : "Language",
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.language),
                          ),
                          _MenuItem(
                            icon: Icons.feedback_outlined,
                            label: isArabic ? "رأيك" : "Feedback",
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.feedback),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== UI COMPONENTS ==========

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
                      Colors.transparent,
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
