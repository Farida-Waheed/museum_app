import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _tempLanguage = 'en';
  bool _tempLanguageInitialized = false;
  bool _isCompleting = false;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _completeOnboarding(UserPreferencesModel prefs) {
    if (_isCompleting) return;
    _isCompleting = true;

    prefs.setLanguage(_tempLanguage);
    prefs.setCompletedOnboarding(true);
    Navigator.pushReplacementNamed(context, AppRoutes.entryMode);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final prefs = Provider.of<UserPreferencesModel>(context);
    if (!_tempLanguageInitialized) {
      _tempLanguage = prefs.hasCompletedOnboarding ? prefs.language : 'en';
      _tempLanguageInitialized = true;
    }
    final isArabic = _tempLanguage == 'ar';

    final glassSurfaceDecoration = BoxDecoration(
      color: AppColors.cardGlass(0.58),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.goldBorder(0.22), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.32),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(color: AppColors.softGlow(0.06), blurRadius: 18),
      ],
    );

    final primaryCtaButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.darkInk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.softGold.withValues(alpha: 0.92),
          width: 1,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    return Localizations.override(
      context: context,
      locale: Locale(_tempLanguage),
      delegates: AppLocalizations.localizationsDelegates,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          final List<Map<String, dynamic>> pages = [
            {
              'title': l10n.onboarding1Title,
              'desc': l10n.onboarding1Desc,
              'image': 'assets/images/Onboarding.jpg',
              'iconPath': 'assets/icons/pyramid.png',
              'iconSize': 82.0,
              'iconScale': 1.0,
              'useShadow': true,
            },
            {
              'title': l10n.onboarding2Title,
              'desc': l10n.onboarding2Desc,
              'image': 'assets/images/Onboarding.jpg',
              'iconPath': 'assets/icons/pharaoh.png',
              'iconSize': 82.0,
              'iconScale': 1.0,
              'useShadow': true,
            },
            {
              'title': l10n.onboarding3Title,
              'desc': l10n.onboarding3Desc,
              'image': 'assets/images/Onboarding.jpg',
              'iconPath': 'assets/icons/map.png',
              'iconSize': 82.0,
              'iconScale': 1.0,
              'useShadow': true,
            },
            {
              'title': l10n.onboarding4Title,
              'desc': l10n.onboarding4Desc,
              'image': 'assets/images/Onboarding.jpg',
              'iconPath': 'assets/icons/scarab.png',
              'iconSize': 82.0,
              'iconScale': 1.0,
              'useShadow': true,
            },
          ];

          return Scaffold(
            backgroundColor: AppColors.backgroundBase,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/Onboarding.jpg', fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.18),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGold.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 7,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pages.length,
                        onPageChanged: (value) {
                          setState(() => _currentPage = value);
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) {
                                    final offset =
                                        math.sin(
                                          _floatController.value * math.pi,
                                        ) *
                                        8;
                                    return Transform.translate(
                                      offset: Offset(0, -offset),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.softGlow(0.10),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.primaryGold.withValues(
                                            alpha: 0.10,
                                          ),
                                          AppColors.primaryGold.withValues(
                                            alpha: 0.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Transform.scale(
                                        scale: pages[index]['iconScale'] ?? 1.0,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (pages[index]['useShadow'] ==
                                                true)
                                              Transform.translate(
                                                offset: const Offset(0, 2),
                                                child: Image.asset(
                                                  pages[index]['iconPath']!,
                                                  width:
                                                      pages[index]['iconSize'] ??
                                                      82.0,
                                                  height:
                                                      pages[index]['iconSize'] ??
                                                      82.0,
                                                  fit: BoxFit.contain,
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                            Image.asset(
                                              pages[index]['iconPath']!,
                                              width:
                                                  pages[index]['iconSize'] ??
                                                  82.0,
                                              height:
                                                  pages[index]['iconSize'] ??
                                                  82.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: math.min(screenWidth - 56, 420),
                                  ),
                                  child: Text(
                                    pages[index]['title']!,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heroTitle(context)
                                        .copyWith(
                                          fontSize: isArabic ? 30 : 29,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.whiteTitle,
                                          letterSpacing: isArabic ? 0 : 0.5,
                                          height: isArabic ? 1.22 : 1.16,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: math.min(screenWidth - 72, 380),
                                  ),
                                  child: Text(
                                    pages[index]['desc']!,
                                    textAlign: TextAlign.center,
                                    style:
                                        AppTextStyles.premiumMutedBody(
                                          context,
                                        ).copyWith(
                                          color: AppColors.bodyText.withValues(
                                            alpha: 0.76,
                                          ),
                                          fontSize: 14,
                                          height: 1.46,
                                          letterSpacing: isArabic ? 0 : 0.15,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(pages.length, (index) {
                              final active = _currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                width: active ? 26 : 8,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primaryGold
                                      : AppColors.mutedText.withValues(
                                          alpha: 0.38,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    if (active)
                                      BoxShadow(
                                        color: AppColors.softGlow(0.26),
                                        blurRadius: 8,
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.30),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: AppColors.softGlow(0.14),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _completeOnboarding(prefs),
                                style: primaryCtaButtonStyle,
                                child: Text(
                                  l10n.startExploring,
                                  style:
                                      AppTextStyles.premiumButtonLabel(
                                        context,
                                      ).copyWith(
                                        fontSize: 15,
                                        color: AppColors.darkInk,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: isArabic ? 0 : 0.3,
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
                Positioned(
                  top: 48,
                  left: isArabic ? null : 24,
                  right: isArabic ? 24 : null,
                  child: SafeArea(
                    child: PopupMenuButton<String>(
                      onSelected: (lang) {
                        setState(() {
                          _tempLanguage = lang;
                        });
                      },
                      offset: const Offset(0, 48),
                      color: AppColors.cinematicElevated.withValues(
                        alpha: 0.96,
                      ),
                      elevation: 8,
                      constraints: const BoxConstraints(minWidth: 160),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.goldBorder(0.28),
                          width: 1,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'en',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.translate_rounded,
                                size: 18,
                                color: AppColors.softGold,
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    color: AppColors.whiteTitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_tempLanguage == 'en')
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.softGold,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'ar',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.translate_rounded,
                                size: 18,
                                color: AppColors.softGold,
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text(
                                  'العربية',
                                  style: TextStyle(
                                    color: AppColors.whiteTitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_tempLanguage == 'ar')
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.softGold,
                                ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: glassSurfaceDecoration,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              size: 17,
                              color: AppColors.softGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.language,
                              style: AppTextStyles.premiumMutedBody(context)
                                  .copyWith(
                                    color: AppColors.whiteTitle,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
