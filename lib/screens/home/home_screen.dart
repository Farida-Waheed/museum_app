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
import '../chat/chat_screen.dart'; // gives us RoboGuideEntry

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

    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      final prefs =
          Provider.of<UserPreferencesModel>(context, listen: false);
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

    const Color lightGreyBG = Colors.white; // PURE WHITE BACKGROUND

    return Scaffold(
      backgroundColor: lightGreyBG,
      bottomNavigationBar: const BottomNav(currentIndex: 0),

      // ✅ Reusable Robo-Guide bubble (comes from chat_screen.dart)
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
              // WHITE BACKGROUND
              Container(color: lightGreyBG),

              // SIDE MENU
              Transform.translate(
                offset: Offset(-(size.width * 0.30 * (1 - v)), 0),
                child: const _SideMenuWrapper(),
              ),

              // MAIN CARD
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
                              const Text("🤖", style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Text(
                                isArabic ? "روبوت المتحف" : "Museum Guide",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner,
                                  color: Colors.black),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.qrScan),
                            ),
                          ],
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),

                        body: CustomScrollView(
                          slivers: [
                            // HEADER
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isArabic
                                                  ? "استكشف مصر مع الدليل الآلي"
                                                  : "Explore Egypt with Robo-Guide",
                                              style:
                                                  t.headlineSmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              children: [
                                                _GlassChip(
                                                  label: isArabic
                                                      ? "جاهز للواقع المعزز"
                                                      : "AR Ready",
                                                  icon:
                                                      "assets/icons/scarab.png",
                                                  isArabic: isArabic,
                                                ),
                                                _GlassChip(
                                                  label: isArabic
                                                      ? "بلغتان"
                                                      : "Bilingual",
                                                  icon:
                                                      "assets/icons/ankh.png",
                                                  isArabic: isArabic,
                                                ),
                                                _GlassChip(
                                                  label: isArabic
                                                      ? "خريطة مباشرة"
                                                      : "Live Map",
                                                  icon:
                                                      "assets/icons/maps.png",
                                                  isArabic: isArabic,
                                                ),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            Icons.map,
                                            "${exhibits.length}",
                                            isArabic ? "المعروضات" : "Exhibits",
                                            Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            Icons.trending_up,
                                            "$visitedCount",
                                            isArabic
                                                ? "تمت زيارتها"
                                                : "Visited",
                                            Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            Icons.timer,
                                            "${durationMinutes}m",
                                            isArabic ? "المدة" : "Duration",
                                            Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

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
                                                Text(
                                                  isArabic
                                                      ? "معاينة الخريطة (موقع الروبوت)"
                                                      : "Map Preview (Robot Location)",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold,
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
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
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
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: (robotX / 400) * c.maxWidth,
              top: (robotY / 600) * c.maxHeight,
              child: const Icon(Icons.smart_toy,
                  size: 24, color: Colors.blue),
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
          color: Colors.white,
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
                          _MenuItem(
                            icon: Icons.radio_button_checked,
                            label: isArabic ? "جولة حية" : "Live Tour",
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.liveTour),
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

class _GlassChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isArabic;

  const _GlassChip({
    required this.label,
    this.icon,
    required this.isArabic,
  });

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
                Image.asset(icon!, width: 16, height: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
