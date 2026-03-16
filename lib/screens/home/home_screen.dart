import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final List<Exhibit> exhibits;
  late final List<MockNews> news;

  double robotX = 140;
  double robotY = 80;

  int pageIndex = 0;
  final PageController _pageCtrl = PageController(viewportFraction: 0.85);

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(
    begin: 1.0,
    end: 1.15,
  ).animate(CurvedAnimation(parent: _robotPulseCtrl, curve: Curves.easeInOut));

  late final AnimationController _fabPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final Animation<double> _fabScale = Tween<double>(
    begin: 1.0,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    news = MockDataService.getAllNews();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
        await _requestInitialPermissions(context);
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _robotPulseCtrl.dispose();
    _fabPulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions(BuildContext context) async {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (kIsWeb) {
      prefs.setHasSeenLocationPrompt(true);
      return;
    }

    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.notifications_none_rounded,
          title: l10n.notificationPermissionTitle,
          description: l10n.notificationPermissionDesc,
          isHighContrast: prefs.isHighContrast,
          onAllow: () async {
            Navigator.pop(context);
            await Permission.notification.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    }

    final locStatus = await Permission.locationWhenInUse.status;
    if (!locStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.location_on_outlined,
          title: l10n.locationPermissionTitle,
          description: l10n.locationPermissionDesc,
          helperText: l10n.dataReassurance,
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
    } else {
      prefs.setHasSeenLocationPrompt(true);
    }
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandStyle = AppTextStyles.brandTitle(context, isDark: isDark);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 560,
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.18),
                Colors.transparent,
                Colors.black.withOpacity(0.70),
              ],
              stops: const [0.0, 0.32, 1.0],
            ),
          ),
          child: Image.asset(
            'assets/images/museum_interior.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => AppMenuShell.of(context)?.toggleMenu(),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.smart_toy,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HORUS-BOT',
                          style: brandStyle.copyWith(
                            color: AppColors.primaryGold,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                              "Explore Egypt\nwith Horus-Bot",
                style: AppTextStyles.displayHero(context),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.followAndDiscover,
                style: AppTextStyles.bodySecondary(context),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -40,
          child: _buildNextStopCard(context, l10n),
        ),
      ],
    );
  }

  Widget _buildNextStopCard(BuildContext context, AppLocalizations l10n) {
    return _NextStopBadge(
      label: l10n.nextStopLabel.toUpperCase(),
      location: l10n.tutankhamunHall,
      time: l10n.fiveMinutesAway,
      onTap: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.liveTour,
        (r) => false,
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline_rounded,
              value: '1',
              label: l10n.visited,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.account_balance_outlined,
              value: '${exhibits.length}',
              label: l10n.exhibits,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.timer_outlined,
              value: '5 min',
              label: l10n.duration,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const ChatScreen(isPopup: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: _HorusFab(
          onPressed: () => _openChat(context),
          label: l10n.askTheGuide,
        ),
      ),
      body: Builder(
        builder: (innerContext) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection(innerContext, l10n)),
            const SliverToBoxAdapter(child: SizedBox(height: 72)),
            SliverToBoxAdapter(child: _buildSummaryStats(innerContext, l10n)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exhibits.toUpperCase(),
                      style: AppTextStyles.displaySectionTitle(innerContext),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.map_outlined,
                            title: l10n.map,
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                              innerContext,
                              AppRoutes.map,
                              (r) => false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.qr_code_scanner,
                            title: l10n.scanTicket,
                            isHighlighted: true,
                            onTap: () => Navigator.pushNamed(
                              innerContext,
                              AppRoutes.qrScan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.recommendedForYou.toUpperCase(),
                        style: AppTextStyles.displaySectionTitle(innerContext),
                    ),
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
                          image: 'assets/images/pharaoh_head.jpg',
                          onTap: () {
                            if (exhibits.isNotEmpty) {
                              Navigator.pushNamed(
                                innerContext,
                                AppRoutes.exhibitDetails,
                                arguments: exhibits.first,
                              );
                            }
                          },
                        ),
                        _HighlightCard(
                          title: l10n.ancientPapyrus,
                          subtitle: l10n.westWingStory,
                          image: 'assets/images/hieroglyphs.jpg',
                          onTap: () {
                            if (exhibits.length > 1) {
                              Navigator.pushNamed(
                                innerContext,
                                AppRoutes.exhibitDetails,
                                arguments: exhibits[1],
                              );
                            }
                          },
                        ),
                        _HighlightCard(
                          title: l10n.canopicJars,
                          subtitle: l10n.southHallMummification,
                          image: 'assets/images/canopic_jars.jpg',
                          onTap: () {
                            if (exhibits.length > 2) {
                              Navigator.pushNamed(
                                innerContext,
                                AppRoutes.exhibitDetails,
                                arguments: exhibits[2],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Dots(count: 3, index: pageIndex),
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
                        Text(
                          l10n.mapPreview.toUpperCase(),
                          style: AppTextStyles.displaySectionTitle(innerContext),
                        ),
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GridPainter(
                                  gridColor: Colors.white.withOpacity(0.025),
                                ),
                              ),
                            ),
                            const Center(
                              child: Opacity(
                                opacity: 0.15,
                                child: Icon(
                                  Icons.museum,
                                  size: 140,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
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
                                        color: AppColors.primaryGold
                                            .withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy,
                                    color: AppColors.darkInk,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Row(
                                children: [
                                  _LegendDot(
                                    color: AppColors.primaryGold,
                                    label: l10n.horusBot,
                                  ),
                                  const SizedBox(width: 20),
                                  _LegendDot(
                                    color: Colors.blueAccent,
                                    label: l10n.you,
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pushNamedAndRemoveUntil(
                                          innerContext,
                                          AppRoutes.map,
                                          (r) => false,
                                        ),
                                    child: Text(
                                      l10n.fullView,
                                        style: AppTextStyles.buttonLabel(context)
                                          .copyWith(
                                            color: AppColors.primaryGold,
                                            fontSize: 13,
                                          ),
                                    ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.museumNews.toUpperCase(),
                        style: AppTextStyles.displaySectionTitle(innerContext),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final item = news[index];
                        return _NewsCard(item: item);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.didYouKnow.toUpperCase(),
                          style: AppTextStyles.displaySectionTitle(innerContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.didYouKnowFact,
                      style: AppTextStyles.bodyPrimary(innerContext).copyWith(
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
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _NextStopBadge extends StatefulWidget {
  final String label;
  final String location;
  final String time;
  final VoidCallback onTap;

  const _NextStopBadge({
    required this.label,
    required this.location,
    required this.time,
    required this.onTap,
  });

  @override
  State<_NextStopBadge> createState() => _NextStopBadgeState();
}

class _NextStopBadgeState extends State<_NextStopBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cinematicElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(
                  _isHovered ? 0.25 : 0.15,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
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
                  child: const Icon(
                    Icons.near_me_rounded,
                    color: AppColors.primaryGold,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: AppTextStyles.displaySectionTitle(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.location,
                        style: AppTextStyles.titleMedium(context),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.time, style: AppTextStyles.bodyPrimary(context)),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.neutralDark,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

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
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.cinematicCard,
                  border: Border.all(
                    color: widget.isHighlighted
                        ? AppColors.primaryGold.withOpacity(
                            0.35 + (_glowCtrl.value * 0.35),
                          )
                        : (_isHovered
                              ? Colors.white.withOpacity(0.16)
                              : Colors.white.withOpacity(0.05)),
                    width: (widget.isHighlighted || _isHovered) ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (widget.isHighlighted || _isHovered)
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(
                          0.10 + (_glowCtrl.value * 0.12),
                        ),
                        blurRadius: _isHovered ? 20 : 15,
                        spreadRadius: _isHovered ? 3 : 2,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(widget.icon, color: AppColors.primaryGold, size: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: AppTextStyles.titleMedium(
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HighlightCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback? onTap;

  const _HighlightCard({
    required this.title,
    required this.subtitle,
    required this.image,
    this.onTap,
  });

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.image, fit: BoxFit.cover),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.95),
                            Colors.transparent,
                          ],
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
                          widget.title,
                          style: AppTextStyles.displayArtifactTitle(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.bodySecondary(
                            context,
                          ),
                        ),
                      ],
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

class _NewsCard extends StatelessWidget {
  final MockNews item;

  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(item.title)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.source.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: AppTextStyles.titleMedium(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Read More',
                  style: AppTextStyles.buttonLabel(
                    context,
                  ).copyWith(color: AppColors.primaryGold, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryGold,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 24),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLarge(
              context,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyPrimary(context)),
        ],
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
            color: active
                ? AppColors.primaryGold
                : AppColors.neutralDark.withOpacity(0.4),
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
            decoration: const BoxDecoration(
              color: AppColors.alertRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.sectionTitle(context).copyWith(
              fontSize: 11,
              color: AppColors.alertRed,
              letterSpacing: 1.5,
            ),
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
        Text(label, style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 13)),
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
}

class _HorusFab extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _HorusFab({required this.label, required this.onPressed});

  @override
  State<_HorusFab> createState() => _HorusFabState();
}

class _HorusFabState extends State<_HorusFab>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _isHovered = false;

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
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppColors.cinematicElevated,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(
                      0.6 + (_glowCtrl.value * 0.4),
                    ),
                    width: _isHovered ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(
                        0.15 + (_glowCtrl.value * 0.25),
                      ),
                      blurRadius: _isHovered ? 25 : 18,
                      spreadRadius: _isHovered ? 5 : 3,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primaryGold,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: AppTextStyles.buttonLabel(context).copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.alwaysAvailable,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
