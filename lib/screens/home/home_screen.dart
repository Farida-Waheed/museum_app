import 'dart:async';
import 'dart:math';
import 'dart:ui';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Exhibit> exhibits;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;

  double robotX = 100;
  double robotY = 100;

  int pageIndex = 0;
  final _pageCtrl = PageController(viewportFraction: .9);

  late final AnimationController _grad =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔔 Alert: Tour starting in Hall A in 5 mins!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    });

    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        robotX = (robotX + 20) % 300;
        robotY = (robotY + 10) % 200;
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Privacy & Permissions"),
        content: const Text(
          "We use Bluetooth and Location to guide you.\n\n"
          "• Data is anonymous.\n"
          "• Heatmaps are used for analytics.\n\n"
          "Do you allow us to use your location?"
        ),
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

    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: _RoboFab(
        label: isArabic ? "تحدث مع الروبوت" : "Talk to Robo-Guide",
        onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
      ),

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
                Text(
                  isArabic ? "روبوت المتحف" : "Museum Guide",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  isArabic ? "جولة تفاعلية" : "Interactive Tour",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          ],
        ),
        actions: [
          // --- QR Scanner Shortcut (For Staff/Testing) ---
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black54),
            tooltip: "Scan Ticket",
            onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            tooltip: isArabic ? "الإعدادات" : "Settings",
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Chip(
              label: Text(prefs.language.toUpperCase()),
              avatar: const Icon(Icons.language, size: 16),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 240,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(color: Colors.grey.shade300, child: const Icon(Icons.image, size: 50, color: Colors.grey)), 
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
                          Text(
                            isArabic
                                ? "جولات ذكية • واقع معزز • مسارات آمنة"
                                : "Smart tours • AR overlays • Safe routes",
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: const [
                              _GlassChip(label: "AR Ready", icon: "assets/icons/scarab.png"),
                              _GlassChip(label: "Bilingual", icon: "assets/icons/ankh.png"),
                              _GlassChip(label: "Live Map"),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.map, "${exhibits.length}", isArabic ? "المعروضات" : "Exhibits", Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard(Icons.trending_up, "$visitedCount", isArabic ? "تمت زيارتها" : "Visited", Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard(Icons.timer, "${durationMinutes}m", isArabic ? "المدة" : "Duration", Colors.purple)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(isArabic ? "معروضات اليوم" : "Today’s Highlights",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 180,
                    child: PageView(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: const [
                        _HighlightCard(title: "Tutankhamun Mask", image: "assets/images/pharaoh_head.jpg"),
                        _HighlightCard(title: "Golden Hieroglyphs", image: "assets/images/hieroglyphs.jpg"),
                        _HighlightCard(title: "Canopic Jars", image: "assets/images/canopic_jars.jpg"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Dots(count: 3, index: pageIndex),

                  const SizedBox(height: 24),

                  // --- Main Navigation Grid ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      // 1. Tour Progress
                      _MiniActionCard(
                        icon: "assets/icons/pyramid.png",
                        title: isArabic ? "تقدم الجولة" : "Tour Progress",
                        caption: isArabic ? "تابع تقدمك" : "Check Status",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.progress),
                      ),
                      // 2. Map
                      _MiniActionCard(
                        icon: "assets/icons/maps.png",
                        title: isArabic ? "الخريطة" : "Map",
                        caption: isArabic ? "تتبع الروبوت" : "Track Robot",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                      ),
                      // 3. AR Scan (LINKED)
                      _MiniActionCard(
                        icon: "assets/icons/pharaoh.png",
                        title: isArabic ? "ماسح AR" : "AR Scan",
                        caption: isArabic ? "كشف القصص" : "Reveal Stories",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.arView),
                      ),
                      // 4. Buy Tickets
                      _MiniActionCard(
                        icon: "assets/icons/ticket.png",
                        title: isArabic ? "التذاكر" : "Buy Tickets",
                        caption: isArabic ? "تخطي الطابور" : "Skip Queue",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.tickets),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Map Preview Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? "معاينة الخريطة" : "Map Preview",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
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

                  // --- Secondary Features Grid ---
                  Text(
                    isArabic ? "اكتشف الميزات" : "More Features",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildNavButton(context, AppRoutes.search, Icons.search, isArabic ? "بحث" : "Search", Colors.orange),
                      _buildNavButton(context, AppRoutes.chat, Icons.chat, isArabic ? "المحادثة" : "Chat", Colors.green),
                      _buildNavButton(context, AppRoutes.quiz, Icons.school, isArabic ? "اختبار" : "Quiz", Colors.red),
                      _buildNavButton(context, AppRoutes.feedback, Icons.feedback, isArabic ? "رأيك" : "Feedback", Colors.purple),
                      _buildNavButton(context, AppRoutes.language, Icons.language, isArabic ? "اللغة" : "Language", Colors.indigo),
                      _buildNavButton(context, AppRoutes.liveTour, Icons.radio_button_checked, isArabic ? "جولة حية" : "Live Tour", Colors.redAccent),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Separate Settings Area
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
                                  isArabic ? "خيارات إضافية للتخصيص" : "Additional customization options",
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

                  const SizedBox(height: 80),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
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
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
      builder: (context, c) {
        return Stack(
          children: [
            ...exhibits.map((e) {
              double dx = (e.x / 400) * c.maxWidth;
              double dy = (e.y / 600) * c.maxHeight;
              return Positioned(
                left: dx.clamp(0, c.maxWidth - 5),
                top: dy.clamp(0, c.maxHeight - 5),
                child: const Icon(Icons.circle, size: 8, color: Colors.redAccent),
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
      },
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final String? icon;
  const _GlassChip({required this.label, this.icon});

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
            children: [
              if (icon != null) ...[
                Image.asset(icon!, width: 16, height: 16, errorBuilder: (c,e,s)=>const Icon(Icons.star, size: 16)),
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

class _MiniActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  const _MiniActionCard({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: [
                    cs.secondary.withOpacity(.2),
                    cs.tertiary.withOpacity(.15),
                  ]),
                ),
                // Fallback to icon if asset missing
                child: Image.asset(icon, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.extension)),
              ),
              const Spacer(),
              Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                caption,
                style: t.bodySmall?.copyWith(color: cs.onSurface.withOpacity(.7)),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(color: Colors.grey))),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(.45), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 12,
              child: Text(
                title,
                style: t.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}