import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
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
import '../../models/tour_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Exhibit> exhibits;
  late List<MockNews> news;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;

  double robotX = 140;
  double robotY = 80;

  int pageIndex = 0;
  final PageController _pageCtrl = PageController(viewportFraction: .85);

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(begin: 1.0, end: 1.15).animate(
    CurvedAnimation(parent: _robotPulseCtrl, curve: Curves.easeInOut),
  );

  late final AnimationController _fabPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final Animation<double> _fabScale = Tween<double>(begin: 1.0, end: 1.05).animate(
    CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    news = MockDataService.getAllNews();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

        if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
          if (kIsWeb) {
            prefs.setHasSeenLocationPrompt(true);
            return;
          }
          final status = await Permission.locationWhenInUse.status;
          if (!status.isGranted) {
            _showPrivacyDialog();
          } else {
            prefs.setHasSeenLocationPrompt(true);
          }
        }
      }
    });

    _simTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        final r = Random();
        robotX = 100 + r.nextDouble() * 100;
        robotY = 60 + r.nextDouble() * 60;
        if (timer.tick % 15 == 0) visitedCount++;
      });
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _pageCtrl.dispose();
    _robotPulseCtrl.dispose();
    _fabPulseCtrl.dispose();
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: _HorusFab(onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), label: l10n.talkToHorusBot),
      body: Container(
        color: AppColors.cinematicBackground,
        child: CustomScrollView(
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: _HorusFab(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
          label: l10n.talkToHorusBot,
        ),
      ),
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
              backgroundColor: isDark ? AppColors.darkHeader : AppColors.warmSurface,
              shape: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : const Color(0xFFE5E0D5), width: 1)),
              title: Image.asset("assets/icons/ankh.png", width: 32, height: 32),
              leading: IconButton(
                padding: const EdgeInsets.all(16),
                icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                onPressed: () => AppMenuShell.of(context)?.openMenu(),
              ),
              actions: [
                IconButton(
                  padding: const EdgeInsets.all(16),
                  icon: Icon(Icons.qr_code_scanner, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            // 1. Cinematic Hero Section
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 460,
                    width: double.infinity,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.0),
                          AppColors.cinematicBackground.withOpacity(0.8),
                          AppColors.cinematicBackground,
                        ],
                        stops: const [0.0, 0.25, 0.8, 1.0],
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/museum_interior.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                              onPressed: () => AppMenuShell.of(context)?.openMenu(),
                            ),
                            const Spacer(),
                            const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGold, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.appTitle.toUpperCase(),
                              style: AppTextStyles.screenTitle(context).copyWith(
                                fontSize: 18,
                                letterSpacing: 2,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                            ),
                          ],
                        ),
                      ),
                    ),
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
            SliverToBoxAdapter(
              child: Container(
                height: 320,
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? "استكشف مصر مع حوروس" : "Explore Egypt with Horus-Bot",
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isArabic ? "اتبع حوروس واكتشف مصر القديمة" : "Follow Horus-Bot and discover ancient Egypt.",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: _NextStopBadge(
                          location: "Tutankhamun Hall",
                          time: isArabic ? "خلال ٥ دقائق" : "in 5 minutes",
                          label: l10n.nextStopLabel,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exploreEgypt,
                          style: AppTextStyles.heroTitle(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.followAndDiscover,
                          style: AppTextStyles.heroSubtitle(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Next Stop (Primary Action)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: _NextStopBadge(
                  label: l10n.nextStopLabel.toUpperCase(),
                location: l10n.tutankhamunHall,
                time: l10n.fiveMinutesAway,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                ),
              ),
            ),

            // 3. Quick Features Grid
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: _RobotStatusCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: _TourProgressTracker()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.exhibits.toUpperCase(), style: AppTextStyles.sectionTitle(context)),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _FeatureCard(
                          icon: Icons.map_outlined,
                          title: l10n.map,
                          subtitle: l10n.mapSub,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                        ),
                        _FeatureCard(
                          icon: Icons.auto_awesome_mosaic_outlined,
                          title: l10n.exhibits,
                          subtitle: l10n.exhibitsSub,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                        ),
                        _FeatureCard(
                          icon: Icons.quiz_outlined,
                          title: l10n.quiz,
                          subtitle: l10n.quizSub,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
                        ),
                        _FeatureCard(
                          icon: Icons.route_outlined,
                          title: l10n.liveTour,
                          subtitle: l10n.liveTourSub,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 4. Discovery Carousel
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(l10n.recommendedForYou.toUpperCase(), style: AppTextStyles.sectionTitle(context)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 240,
                    child: PageView(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: [
                        _HighlightCard(
                          title: l10n.tutankhamunMask,
                          subtitle: l10n.goldenHallRecommended,
                          image: "assets/images/pharaoh_head.jpg",
                        ),
                        _HighlightCard(
                          title: l10n.ancientPapyrus,
                          subtitle: l10n.westWingStory,
                          image: "assets/images/hieroglyphs.jpg",
                        ),
                        _HighlightCard(
                          title: l10n.canopicJars,
                          subtitle: l10n.southHallMummification,
                          image: "assets/images/canopic_jars.jpg",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Dots(count: 3, index: pageIndex),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 5. Map Preview
            // ===== MUSEUM NEWS =====
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Museum News",
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...news.map((item) => _NewsCard(news: item)),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.mapPreview.toUpperCase(), style: AppTextStyles.sectionTitle(context)),
                        _LiveBadge(label: l10n.live),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 260,
                        decoration: BoxDecoration(
                          color: AppColors.cinematicSection,
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Stack(
                          children: [
                            // Grid Background
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GridPainter(gridColor: Colors.white.withOpacity(0.025)),
                              ),
                            ),
                            // Map Content (Simplified)
                            Center(
                              child: Opacity(
                                opacity: 0.15,
                                child: Icon(Icons.museum, size: 140, color: Colors.white),
                              ),
                            ),
                            // Robot Marker
                            AnimatedPositioned(
                              duration: const Duration(seconds: 4),
                              curve: Curves.easeInOut,
                              left: robotX,
                              top: robotY,
                              child: ScaleTransition(
                                scale: _robotScale,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGold.withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.smart_toy, color: AppColors.darkInk, size: 16),
                                ),
                              ),
                            ),
                            // Map Overlay Info
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Row(
                                children: [
                                  _LegendDot(color: AppColors.primaryGold, label: l10n.horusBot),
                                  const SizedBox(width: 20),
                                  _LegendDot(color: Colors.blueAccent, label: l10n.you),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                                    child: Text(l10n.fullView, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 6. Storytelling Element (Did You Know)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.cinematicSection,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.didYouKnow.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.didYouKnowFact,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cinematicElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.near_me_rounded, color: AppColors.primaryGold, size: 32),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(color: AppColors.neutralMedium, fontSize: 14),
                  ),
                ],
              ),
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1912).withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$label: $location $time",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neutralDark, size: 20),
          ],
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.cinematicCard,
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          image: const DecorationImage(
            image: AssetImage('assets/images/hieroglyphs.jpg'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.neutralMedium),
              maxLines: 2,
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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
                    colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGold : AppColors.neutralDark.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertRed.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: AppColors.alertRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.alertRed, letterSpacing: 1.5),
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
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.neutralMedium)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;
  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
class _RobotStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final isOnline = tourProvider.robotState != RobotState.disconnected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.primaryGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Horus-Bot Status", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? "Online • At Ancient Jewelry Gallery" : "Offline",
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Next Tour", style: TextStyle(color: AppColors.helperText, fontSize: 11)),
              Text("2:00 PM", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourProgressTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tour Progress", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("3 / 10 exhibits", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final MockNews news;
  const _NewsCard({required this.news});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(news.image, height: 120, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(news.source, style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                      const Text("Nov 24", style: TextStyle(color: AppColors.helperText, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(news.title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    news.description,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _HorusFab extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _HorusFab({required this.label, required this.onPressed});
  @override
  State<_HorusFab> createState() => _HorusFabState();
}

class _HorusFabState extends State<_HorusFab> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
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
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.6 + (_glowCtrl.value * 0.4)), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.15 + (_glowCtrl.value * 0.25)),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.onlineStatus.replaceAll('● ', ''),
                            style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
