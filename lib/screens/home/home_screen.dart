import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';
import '../../models/user_preferences.dart';

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
  final PageController _pageCtrl = PageController(viewportFraction: .85);

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(begin: 1.0, end: 1.08).animate(
    CurvedAnimation(parent: _robotPulseCtrl, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

        if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
          final status = await Permission.locationWhenInUse.status;
          if (!status.isGranted) {
            _showPrivacyDialog();
          } else {
            prefs.setHasSeenLocationPrompt(true);
          }
        }
      }
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
    _robotPulseCtrl.dispose();
    super.dispose();
  }

  void _showPrivacyDialog() {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) => LocationPermissionDialog(
        isHighContrast: prefs.isHighContrast,
        onAllow: () async {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
          await Permission.locationWhenInUse.request();
        },
        onDeny: () {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppMenuShell(
      hideDefaultAppBar: true,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: _HorusFab(onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), label: l10n.talkToHorusBot),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 64.0,
              toolbarHeight: 64.0,
              floating: false,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              backgroundColor: AppColors.darkHeader,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGold, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    l10n.appTitle,
                    style: AppTextStyles.screenTitle(context).copyWith(fontSize: 20),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: () => AppMenuShell.of(context)?.openMenu(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            // A. Welcome Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isArabic ? "أهلاً بك في المتحف" : "Welcome to the Museum", style: AppTextStyles.screenTitle(context)),
                    const SizedBox(height: 4),
                    Text(isArabic ? "اكتشف عجائب مصر القديمة" : "Discover the wonders of Ancient Egypt", style: AppTextStyles.helper(context)),
                  ],
                ),
              ),
            ),

            // B. Hero Header / Horus-Bot Status Card
            SliverToBoxAdapter(
              child: Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(isArabic ? "حوروس-بوت متصل" : "Horus-Bot Online", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(isArabic ? "الموقع الحالي: قاعة توت عنخ آمون" : "Current: Tutankhamun Hall", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.darkInk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                              child: Text(isArabic ? "انضم للجولة" : "Join Tour", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // C. Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _QuickActionCard(icon: Icons.route_outlined, label: isArabic ? "جولة موجهة" : "Guided Tour", onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour)),
                    const SizedBox(width: 12),
                    _QuickActionCard(icon: Icons.map_outlined, label: isArabic ? "الخريطة" : "Explore Map", onTap: () => Navigator.pushNamed(context, AppRoutes.map)),
                    const SizedBox(width: 12),
                    _QuickActionCard(icon: Icons.qr_code_scanner, label: isArabic ? "مسح التذكرة" : "Scan Ticket", onTap: () => Navigator.pushNamed(context, AppRoutes.qrScan)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // D. Tour Progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isArabic ? "تقدم الجولة" : "TOUR PROGRESS", style: AppTextStyles.sectionTitle(context)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkDivider)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? "٣ من ١٠ مقتنيات" : "3 of 10 exhibits completed", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              const Text("30%", style: TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.3, minHeight: 6, backgroundColor: AppColors.darkBackground, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // E. Nearby Exhibits
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(isArabic ? "مقتنيات قريبة" : "NEARBY EXHIBITS", style: AppTextStyles.sectionTitle(context))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exhibits.length,
                      itemBuilder: (context, i) => _NearbyExhibitCard(exhibit: exhibits[i], isArabic: isArabic),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // G. Learning / Discovery Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isArabic ? "اكتشف مقتنيات" : "DISCOVER ARTIFACTS", style: AppTextStyles.sectionTitle(context)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PageView(
                        controller: _pageCtrl,
                        onPageChanged: (i) => setState(() => pageIndex = i),
                        children: const [
                          _HighlightCard(title: "Tutankhamun Mask", subtitle: "Golden Hall • Recommended now", image: "assets/images/pharaoh_head.jpg"),
                          _HighlightCard(title: "Golden Hieroglyphs", subtitle: "Gallery 3 • New Kingdom", image: "assets/images/hieroglyphs.jpg"),
                          _HighlightCard(title: "Canopic Jars", subtitle: "West Wing • Ritual Artifacts", image: "assets/images/canopic_jars.jpg"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Dots(count: 3, index: pageIndex),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Did You Know Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkDivider)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.primaryGold, size: 24),
                        const SizedBox(width: 12),
                        Text(l10n.didYouKnow, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.didYouKnowFact, style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkDivider)),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 24),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyExhibitCard extends StatelessWidget {
  final Exhibit exhibit;
  final bool isArabic;
  const _NearbyExhibitCard({required this.exhibit, required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkDivider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(19)), child: Image.asset(exhibit.imageAsset, fit: BoxFit.cover, width: double.infinity))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exhibit.getName(isArabic ? 'ar' : 'en'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(isArabic ? "على بعد ٥٠م" : "50m away", style: AppTextStyles.helper(context).copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStopBadge extends StatelessWidget {
  final String label;
  final String location;
  final String time;
  final VoidCallback onTap;

  const _NextStopBadge({required this.label, required this.location, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cinematicElevated.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.neutralDark, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.route, color: AppColors.primaryGold, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.cinematicCard,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          image: DecorationImage(
            image: const AssetImage('assets/images/hieroglyphs.jpg'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGold.withOpacity(0.8), size: 24),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.darkMutedText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  const _HighlightCard({required this.title, required this.subtitle, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGold : AppColors.neutralDark.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label;
  const _LiveBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.alertRed),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.alertRed, letterSpacing: 0.5),
          ),
        ],
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
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkMutedText)),
      ],
    );
  }
}

class _HorusFab extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _HorusFab({required this.label, required this.onPressed});
  @override
  State<_HorusFab> createState() => _HorusFabState();
}

class _HorusFabState extends State<_HorusFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cinematicElevated,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primaryGold, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.15),
                blurRadius: 12,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  Text(
                    AppLocalizations.of(context)!.onlineStatus,
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
