import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart' as app;
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/ticket_provider.dart';
import '../../models/tour_provider.dart';
import '../../models/user_preferences.dart';
import '../../screens/tickets/qr_scanner_screen.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/ask_the_guide_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import 'state/home_controller.dart';
import 'state/home_snapshot.dart';
import 'widgets/home_featured_artifact_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_info_card.dart';
import 'widgets/home_map_preview_card.dart';
import 'widgets/home_quick_actions_grid.dart';
import 'widgets/live_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _readyCardOverlap = 58;
  final HomeController _homeController = const HomeController();
  final ScrollController _scrollController = ScrollController();
  late final List<Exhibit> exhibits;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final prefs = context.read<UserPreferencesModel>();
      if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
        await _requestInitialPermissions(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions(BuildContext context) async {
    final prefs = context.read<UserPreferencesModel>();
    final l10n = AppLocalizations.of(context)!;

    if (kIsWeb) {
      prefs.setHasSeenLocationPrompt(true);
      return;
    }

    final notifStatus = await Permission.notification.status;
    if (!context.mounted) return;
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
      if (!context.mounted) return;
    }

    final locStatus = await Permission.locationWhenInUse.status;
    if (!context.mounted) return;
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
      if (!context.mounted) return;
    } else {
      prefs.setHasSeenLocationPrompt(true);
    }
  }

  HomeSnapshot _snapshot(BuildContext context) {
    return _homeController.buildSnapshot(
      authProvider: context.watch<AuthProvider>(),
      ticketProvider: context.watch<TicketProvider>(),
      sessionProvider: context.watch<app.AppSessionProvider>(),
      tourProvider: context.watch<TourProvider>(),
      exhibits: exhibits,
      lang: Localizations.localeOf(context).languageCode,
    );
  }

  void _openRobotPairing(BuildContext context) {
    final sessionProvider = context.read<app.AppSessionProvider>();
    sessionProvider.startVisiting();
    sessionProvider.startRobotConnection();
    Navigator.pushNamed(
      context,
      AppRoutes.qrScan,
      arguments: QRScanMode.robotConnection,
    );
  }

  void _openTickets(BuildContext context, HomeSnapshot snapshot) {
    Navigator.pushNamed(
      context,
      snapshot.hasAnyTicket ? AppRoutes.myTickets : AppRoutes.tickets,
    );
  }

  void _openTourFlow(BuildContext context, HomeSnapshot snapshot) {
    final sessionProvider = context.read<app.AppSessionProvider>();
    final tourProvider = context.read<TourProvider>();

    if (snapshot.isTourPaused) {
      sessionProvider.resumeTour();
      tourProvider.resumeTour(context: context);
      Navigator.pushNamed(context, AppRoutes.liveTour);
      return;
    }

    if (snapshot.hasActiveTour) {
      Navigator.pushNamed(context, AppRoutes.liveTour);
      return;
    }

    if (snapshot.robotStatus == HomeRobotStatus.error) {
      _openRobotPairing(context);
      return;
    }

    if (snapshot.hasValidMuseumTicket && !snapshot.isRobotConnected) {
      _openRobotPairing(context);
      return;
    }

    sessionProvider.startVisiting();
    Navigator.pushNamed(context, AppRoutes.tickets);
  }

  void _openMap(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.map, (route) => false);
  }

  void _openArtifactDetails(
    BuildContext context,
    HomeFeaturedArtifact artifact,
  ) {
    final exhibit = exhibits.firstWhere(
      (item) => item.id == artifact.id,
      orElse: () => exhibits.isNotEmpty
          ? exhibits.first
          : MockDataService.getAllExhibits().first,
    );
    Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit);
  }

  ({
    String label,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  })
  _statusModel(BuildContext context, HomeSnapshot snapshot, bool isArabic) {
    if (!snapshot.hasAnyTicket) {
      return (
        label: isArabic ? 'جاهز للاستكشاف؟' : 'READY TO EXPLORE?',
        title: isArabic ? 'جاهز للاستكشاف؟' : 'Ready to Explore?',
        subtitle: isArabic
            ? 'اشتر تذكرتك أو جهز جولتك الإرشادية.'
            : 'Buy your ticket or prepare your guided tour.',
        icon: Icons.explore_rounded,
        onTap: () => _openTickets(context, snapshot),
      );
    }

    if (snapshot.robotStatus == HomeRobotStatus.error) {
      return (
        label: isArabic ? 'فقد الاتصال' : 'CONNECTION LOST',
        title: isArabic ? 'أعد الاتصال بحورس-بوت' : 'Reconnect to Horus-Bot',
        subtitle: isArabic
            ? 'ابق قريبا من الروبوت أو امسح الرمز مرة أخرى.'
            : 'Stay close to the robot or scan again.',
        icon: Icons.wifi_off_rounded,
        onTap: () => _openRobotPairing(context),
      );
    }

    if (snapshot.isTourPaused) {
      return (
        label: isArabic ? 'الجولة متوقفة' : 'TOUR PAUSED',
        title: isArabic ? 'استأنف جولتك' : 'Resume Your Tour',
        subtitle: isArabic
            ? 'استأنف عندما تكون جاهزا.'
            : 'Resume when you are ready.',
        icon: Icons.pause_circle_outline_rounded,
        onTap: () => _openTourFlow(context, snapshot),
      );
    }

    if (snapshot.hasValidMuseumTicket && !snapshot.isRobotConnected) {
      return (
        label: isArabic ? 'اتصل بحورس-بوت' : 'CONNECT TO HORUS-BOT',
        title: isArabic ? 'اتصل بحورس-بوت' : 'Connect to Horus-Bot',
        subtitle: isArabic
            ? 'امسح رمز QR الخاص بالروبوت لبدء جولتك.'
            : 'Scan the robot QR code to begin your tour.',
        icon: Icons.qr_code_scanner_rounded,
        onTap: () => _openRobotPairing(context),
      );
    }

    if (snapshot.hasActiveTour &&
        snapshot.robotStatus == HomeRobotStatus.speaking) {
      return (
        label: isArabic ? 'حورس يتحدث' : 'HORUS IS SPEAKING',
        title:
            snapshot.currentExhibitName ??
            (isArabic ? 'المعروض الحالي' : 'Current Exhibit'),
        subtitle: isArabic
            ? 'استمع إلى الروبوت للحصول على القصة الكاملة.'
            : 'Listen to the robot for the full story.',
        icon: Icons.record_voice_over_rounded,
        onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
      );
    }

    if (snapshot.hasActiveTour &&
        snapshot.robotStatus == HomeRobotStatus.moving) {
      return (
        label: isArabic ? 'حورس يتحرك' : 'HORUS IS MOVING',
        title:
            snapshot.nextStopName ??
            (isArabic ? 'المحطة التالية' : 'Next Stop'),
        subtitle: isArabic
            ? 'ابق قريبا من دليلك.'
            : 'Stay close to your guide.',
        icon: Icons.route_rounded,
        onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
      );
    }

    return (
      label: isArabic ? 'المحطة التالية' : 'NEXT STOP',
      title:
          snapshot.nextStopName ??
          (isArabic ? 'قاعة توت عنخ آمون' : 'Tutankhamun Hall'),
      subtitle: isArabic
          ? '${snapshot.estimatedTimeToNextStop ?? 5} دقائق - ${snapshot.nextStopLocation ?? 'القاعة الذهبية'}'
          : '${snapshot.estimatedTimeToNextStop ?? 5} minutes away - ${snapshot.nextStopLocation ?? 'Golden Hall'}',
      icon: Icons.near_me_rounded,
      onTap: () => _openTourFlow(context, snapshot),
    );
  }

  String _primaryActionLabel(HomeSnapshot snapshot, bool isArabic) {
    if (snapshot.robotStatus == HomeRobotStatus.error) {
      return isArabic ? 'إعادة الاتصال' : 'Reconnect';
    }
    if (snapshot.isTourPaused) {
      return isArabic ? 'استئناف الجولة' : 'Resume Tour';
    }
    if (snapshot.hasActiveTour) {
      return isArabic ? 'متابعة الجولة' : 'Continue Tour';
    }
    if (snapshot.hasValidMuseumTicket && !snapshot.isRobotConnected) {
      return isArabic ? 'مسح QR للروبوت' : 'Scan Robot QR';
    }
    return isArabic ? 'ابدأ جولتي' : 'Start My Tour';
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesModel>();
    final isArabic = prefs.language == 'ar';
    final snapshot = _snapshot(context);
    final status = _statusModel(context, snapshot, isArabic);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.60;

    final quickActions = <HomeQuickActionItem>[
      HomeQuickActionItem(
        icon: Icons.map_outlined,
        label: isArabic ? 'الخريطة' : 'Map',
        subtitle: isArabic ? 'عرض المسار' : 'Full map',
        onTap: () => _openMap(context),
      ),
      HomeQuickActionItem(
        icon: Icons.qr_code_scanner_rounded,
        label: isArabic ? 'مسح QR للروبوت' : 'Scan Robot QR',
        subtitle: isArabic ? 'بدء الاقتران' : 'Pair with Horus',
        onTap: () => _openRobotPairing(context),
      ),
      HomeQuickActionItem(
        icon: Icons.confirmation_number_outlined,
        label: isArabic ? 'تذاكري' : 'My Tickets',
        subtitle: isArabic ? 'رموز الدخول' : 'Stored QR codes',
        onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
      ),
      HomeQuickActionItem(
        icon: Icons.photo_library_outlined,
        label: isArabic ? 'المعرض' : 'Gallery',
        subtitle: isArabic ? 'اكتشف المعروضات' : 'Explore artifacts',
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
      ),
    ];

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: AppColors.baseBlack,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      showChatButton: false,
      body: Builder(
        builder: (innerContext) => Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.screenBackground,
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 104),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: heroHeight + _readyCardOverlap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _HeroSection(
                              height: heroHeight,
                              title: isArabic
                                  ? 'استكشف مع حورس'
                                  : 'Explore With Horus',
                              subtitle: isArabic
                                  ? 'اتبع حورس داخل المتحف.'
                                  : 'Follow Horus through the museum.',
                              isArabic: isArabic,
                              scrollController: _scrollController,
                            ),
                            Positioned(
                              left: AppSpacing.screenHorizontal,
                              right: AppSpacing.screenHorizontal,
                              bottom: 0,
                              child: LiveStatusCard(
                                label: status.label,
                                title: status.title,
                                subtitle: status.subtitle,
                                icon: status.icon,
                                isArabic: isArabic,
                                trailingLabel: snapshot.isRobotConnected
                                    ? snapshot.robotStatusLabel
                                    : null,
                                onTap: status.onTap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: _PrimaryActionCard(
                          isArabic: isArabic,
                          title: isArabic
                              ? 'خطط زيارتك للمتحف'
                              : 'Plan Your Museum Visit',
                          subtitle: isArabic
                              ? 'اشتر التذاكر، حضر جولتك، أو ابدأ عند الوصول.'
                              : 'Buy tickets, prepare your tour, or start when you arrive.',
                          primaryLabel: isArabic
                              ? 'عرض التذاكر'
                              : 'View Tickets',
                          secondaryLabel: _primaryActionLabel(
                            snapshot,
                            isArabic,
                          ),
                          onPrimary: () => _openTickets(context, snapshot),
                          onSecondary: () => _openTourFlow(context, snapshot),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(
                        label: isArabic ? 'إجراءات سريعة' : 'QUICK ACTIONS',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeQuickActionsGrid(items: quickActions),
                      ),
                      const SizedBox(height: 26),
                      _SectionLabel(
                        label: isArabic
                            ? 'اكتشف المعروضات'
                            : 'DISCOVER ARTIFACTS',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeFeaturedArtifactCard(
                          artifact: snapshot.featuredArtifact,
                          onTap: () => _openArtifactDetails(
                            context,
                            snapshot.featuredArtifact,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _SectionLabel(
                        label: isArabic ? 'معاينة الخريطة' : 'MAP PREVIEW',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeMapPreviewCard(
                          data: snapshot.mapPreview,
                          legendHorus: 'Horus',
                          legendYou: isArabic ? 'أنت' : 'You',
                          fullViewLabel: isArabic ? 'عرض كامل' : 'Full View',
                          onTap: () => _openMap(context),
                          onFullView: () => _openMap(context),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeInfoCard(
                          title: isArabic ? 'هل تعلم؟' : 'DID YOU KNOW?',
                          body: snapshot.didYouKnowText,
                          icon: Icons.auto_awesome_rounded,
                          bodyColor: AppColors.whiteTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HomeHeader(
                  onMenu: () => AppMenuShell.of(innerContext)?.toggleMenu(),
                  onScanRobotQr: () => _openRobotPairing(innerContext),
                  scrollController: _scrollController,
                ),
              ),
              PositionedDirectional(
                end: 16,
                bottom: 70,
                child: AskTheGuideButton(
                  screen: 'home',
                  currentExhibitId: context
                      .watch<TourProvider>()
                      .currentExhibitId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.isArabic,
    required this.scrollController,
  });

  final double height;
  final String title;
  final String subtitle;
  final bool isArabic;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final opacity = (1.0 - (offset / 240)).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/colossal-statue-of-ramesses-ii.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x99000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 140,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xE6000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 106,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: AppTextStyles.premiumHero(context).copyWith(
                          fontSize: isArabic ? 30 : 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.66),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: AppTextStyles.premiumBody(context).copyWith(
                              fontSize: 14.5,
                              color: AppColors.whiteTitle.withValues(
                                alpha: 0.78,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        14,
      ),
      child: Text(
        label,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: AppTextStyles.premiumSectionLabel(
          context,
        ).copyWith(fontSize: 12),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.isArabic,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final bool isArabic;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.premiumGlassCard(
            radius: 28,
            opacity: 0.70,
          ),
          child: Column(
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: AppTextStyles.premiumScreenTitle(
                  context,
                ).copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: AppTextStyles.premiumBody(
                  context,
                ).copyWith(fontSize: 14, color: AppColors.bodyText),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackButtons = constraints.maxWidth < 330;
                  if (stackButtons) {
                    return Column(
                      children: [
                        _ActionButton.primary(
                          label: primaryLabel,
                          icon: Icons.confirmation_number_outlined,
                          onTap: onPrimary,
                        ),
                        const SizedBox(height: 12),
                        _ActionButton.secondary(
                          label: secondaryLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: onSecondary,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _ActionButton.primary(
                          label: primaryLabel,
                          icon: Icons.confirmation_number_outlined,
                          onTap: onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton.secondary(
                          label: secondaryLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: onSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton.primary({
    required this.label,
    required this.icon,
    required this.onTap,
  }) : primary = true;

  const _ActionButton.secondary({
    required this.label,
    required this.icon,
    required this.onTap,
  }) : primary = false;

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 48,
          decoration: primary
              ? BoxDecoration(
                  gradient: AppGradients.premiumGold,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldBorder(0.42)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : BoxDecoration(
                  color: AppColors.cardGlass(0.36),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldBorder(0.42),
                    width: 1.1,
                  ),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primary ? AppColors.darkInk : AppColors.primaryGold,
                size: 19,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.premiumButtonLabel(context).copyWith(
                    fontSize: 15,
                    color: primary ? AppColors.darkInk : AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
