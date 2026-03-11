import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_preferences.dart';
import '../../app/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
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
    prefs.setCompletedOnboarding(true);
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.mainHome,
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- REUSABLE DESIGN MATERIALS ---

    // Material A - Glass Surface (Controls)
    final glassSurfaceDecoration = BoxDecoration(
      color: Colors.black.withOpacity(0.25),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFD4AF37).withOpacity(0.35),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    // Material B - Primary CTA Surface
    final primaryCtaButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE6C068),
      foregroundColor: const Color(0xFF1E1912),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6C068), width: 1.5),
      ),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.25),
      padding: const EdgeInsets.symmetric(vertical: 16),
      // To match shadow spec exactly if possible, though elevation is standard.
      // spec: blurRadius: 12, offset: Offset(0, 6)
    );

    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final List<Map<String, dynamic>> pages = [
      {
        "title": l10n.onboarding1Title,
        "desc": l10n.onboarding1Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/pyramid.png",
        "iconSize": 82.0,
        "iconScale": 1.0,
        "useShadow": false, // Already has strong outlines
      },
      {
        "title": l10n.onboarding2Title,
        "desc": l10n.onboarding2Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/pharaoh.png",
        "iconSize": 82.0,
        "iconScale": 1.0, // Visual Benchmark
        "useShadow": false,
      },
      {
        "title": l10n.onboarding3Title,
        "desc": l10n.onboarding3Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/map.png",
        "iconSize": 82.0,
        "iconScale": 0.82, // Map is a solid block, needs to be smaller to match visual weight
        "useShadow": true, // Needs shadow to match the "strength" of outline icons
      },
      {
        "title": l10n.onboarding4Title,
        "desc": l10n.onboarding4Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/scarab.png",
        "iconSize": 82.0,
        "iconScale": 1.1, // Wide and airy, needs slight upscale
        "useShadow": false,
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // --- 1. Background image (per page) ---
          Positioned.fill(
            child: Image.asset(
              pages[_currentPage]["image"]!,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.blueGrey),
            ),
          ),

          // --- 2. Cinematic Gradient overlay ---
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // --- 3. Main content (pages + dots + button) ---
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Lifted up
                        children: [
                          const SizedBox(height: 40), // Top spacing adjustment
                          // Unified Icon treatment
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              final double floatOffset = 8 * math.sin(_floatController.value * 2 * math.pi);
                              return Transform.translate(
                                offset: Offset(0, floatOffset),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFE6C068).withOpacity(0.12),
                                    const Color(0xFFE6C068).withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scale: pages[index]["iconScale"] ?? 1.0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Optional shadow layer to unify different icon styles
                                      if (pages[index]["useShadow"] == true)
                                        Transform.translate(
                                          offset: const Offset(0, 2),
                                          child: Image.asset(
                                            pages[index]["iconPath"]!,
                                            width: pages[index]["iconSize"] ?? 82.0,
                                            height: pages[index]["iconSize"] ?? 82.0,
                                            fit: BoxFit.contain,
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                        ),
                                      // Main Icon
                                      Image.asset(
                                        pages[index]["iconPath"]!,
                                        width: pages[index]["iconSize"] ?? 82.0,
                                        height: pages[index]["iconSize"] ?? 82.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Dots + Primary button ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: Column(
                  children: [
                    // Premium Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        final bool active = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: active ? 26 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFFE6C068) : const Color(0xFF666666),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              if (active)
                                BoxShadow(
                                  color: const Color(0xFFE6C068).withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Primary CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _completeOnboarding(prefs),
                        style: primaryCtaButtonStyle,
                        child: Text(
                          l10n.startExploring.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- 4. Language selector (Top Start) ---
          Positioned(
            top: 48,
            left: isArabic ? null : 24,
            right: isArabic ? 24 : null,
            child: SafeArea(
              child: PopupMenuButton<String>(
                onSelected: (lang) => prefs.setLanguage(lang),
                offset: const Offset(0, 48),
                color: const Color(0xFF1E1912).withOpacity(0.9), // Keep dark for legibility
                elevation: 8,
                constraints: const BoxConstraints(minWidth: 160),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFFE6C068).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🇺🇸 ", style: TextStyle(fontSize: 18)),
                        const Flexible(
                          child: Text(
                            "English",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (prefs.language == 'en')
                          const Icon(Icons.check, size: 16, color: Colors.white70),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🇪🇬 ", style: TextStyle(fontSize: 18)),
                        const Flexible(
                          child: Text(
                            "العربية",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (prefs.language == 'ar')
                          const Icon(Icons.check, size: 16, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: glassSurfaceDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.language,
                        style: const TextStyle(
                          color: Colors.white,
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
  }
}
