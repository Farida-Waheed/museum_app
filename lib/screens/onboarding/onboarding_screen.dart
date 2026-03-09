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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Icon with glow
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.15),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                pages[index]["iconPath"]!,
                                width: 106,
                                height: 106,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Dots + Primary button ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                child: Column(
                  children: [
                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        final bool active = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: active ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Navigation Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding(prefs);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == pages.length - 1
                              ? l10n.startExploring
                              : l10n.next,
                          style: const TextStyle(
                            fontSize: 18,
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

          // --- 4. Language switcher (top-left/right) ---
          Positioned(
            top: 60,
            left: isArabic ? 20 : null,
            right: isArabic ? null : 20,
            child: SafeArea(
              child: TextButton(
                onPressed: () {
                  prefs.setLanguage(isArabic ? 'en' : 'ar');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "العربية / English",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 5. Skip button (top-right/left) ---
          Positioned(
            top: 60,
            left: isArabic ? null : 20,
            right: isArabic ? 20 : null,
            child: SafeArea(
              child: TextButton(
                onPressed: () => _completeOnboarding(prefs),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.7),
                ),
                child: Text(
                  l10n.skip,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
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
