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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
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
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final List<Map<String, dynamic>> pages = [
      {
        "title": l10n.onboarding1Title,
        "desc": l10n.onboarding1Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/pyramid.png",
      },
      {
        "title": l10n.onboarding2Title,
        "desc": l10n.onboarding2Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/pharaoh.png",
      },
      {
        "title": l10n.onboarding3Title,
        "desc": l10n.onboarding3Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/map.png",
      },
      {
        "title": l10n.onboarding4Title,
        "desc": l10n.onboarding4Desc,
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/scarab.png",
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

          // --- 2. Gradient overlay to improve readability ---
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
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
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Lifted up
                        children: [
                          const SizedBox(height: 40), // Top spacing adjustment
                          // Icon with very subtle glow - Balanced size
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 94,
                                height: 94,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.08),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                pages[index]["iconPath"]!,
                                width: 92,
                                height: 92,
                              ),
                            ],
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  children: [
                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        final bool active = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Navigation Button - Always "Start Exploring"
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _completeOnboarding(prefs),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.startExploring,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
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
                offset: const Offset(0, 45),
                color: Colors.black.withOpacity(0.8),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        const Text("🇺🇸 ", style: TextStyle(fontSize: 18)),
                        const Text("English", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        if (prefs.language == 'en') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Colors.white70),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Row(
                      children: [
                        const Text("🇪🇬 ", style: TextStyle(fontSize: 18)),
                        const Text("العربية", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        if (prefs.language == 'ar') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Colors.white70),
                        ],
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
