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
      bottomNavigationBar: const BottomNav(currentIndex: 0),

      floatingActionButton: _RoboFab(
        label: isArabic ? "تحدث مع الروبوت" : "Talk to Robo-Guide",
        onTap: () => _showGuideDialog(),
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
                    Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),
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
                  _welcomeCard(isArabic),
                  const SizedBox(height: 16),

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

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _MiniActionCard(
                        icon: "assets/icons/pyramid.png",
                        title: isArabic ? "ابدأ الجولة" : "Start Tour",
                        caption: isArabic ? "مسار مخصص" : "Personal Route",
                        onTap: () {},
                      ),
                      _MiniActionCard(
                        icon: "assets/icons/maps.png",
                        title: isArabic ? "الخريطة" : "Map",
                        caption: isArabic ? "تتبع الروبوت" : "Track Robot",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                      ),
                      _MiniActionCard(
                        icon: "assets/icons/pharaoh.png",
                        title: isArabic ? "ماسح AR" : "AR Scan",
                        caption: isArabic ? "كشف القصص" : "Reveal Stories",
                        onTap: () {},
                      ),
                      _MiniActionCard(
                        icon: "assets/icons/ticket.png",
                        title: isArabic ? "التذاكر" : "Tickets",
                        caption: isArabic ? "تخطي الطابور" : "Skip Queue",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 80),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _welcomeCard(bool isArabic) {  
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(16),
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
                ? "اتبع دليلنا الآلي للحصول على جولة تفاعلية."
                : "Follow our AI-powered robot guide for an interactive experience.",
            style: const TextStyle(color: Colors.white70),
          ),
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
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

  void _showGuideDialog() {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, child) {
        final scale = Tween(begin: .96, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(colors: [
                              cs.secondary.withOpacity(.2),
                              cs.tertiary.withOpacity(.2),
                            ]),
                          ),
                          child: Image.asset("assets/icons/ankh.png"),
                        ),
                        const SizedBox(height: 12),
                        Text("Robo-Guide", style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          "Ask in Arabic or English. Live routes, tips, assistance.",
                          style: t.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(.7)),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                Image.asset(icon!, width: 16, height: 16),
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
                child: Image.asset(icon, fit: BoxFit.contain),
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
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
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
