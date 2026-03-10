import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/primary_button.dart';

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

  PopupMenuItem<String> _buildLanguageItem({
    required String code,
    required String name,
    required String flag,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check, color: Color(0xFFE6C068), size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // --- Onboarding pages (short text, Horus-Bot + app modes) ---
    final List<Map<String, String>> pages = [
      {
        "title": isArabic ? "استكشف المتاحف" : "Explore Museums",
        "desc": isArabic
            ? "استكشف المتاحف المصرية مع حوروس."
            : "Explore Egyptian museums with Horus-Bot.",
        "image": "assets/images/GEM.jpg",
        "iconPath": "assets/icons/pyramid.png",
      },
      {
        "title": isArabic ? "مرشدك الذكي" : "Your Smart Guide",
        "desc": isArabic
            ? "تنقل بين المعروضات، اتبع الروبوت، واكتشف القصص المخفية."
            : "Navigate exhibits, follow the robot, and discover hidden stories.",
        "image": "assets/images/museum_interior.jpg",
        "iconPath": "assets/icons/pharaoh.png",
      },
      {
        "title": isArabic ? "خريطة تفاعلية" : "Interactive Map",
        "desc": isArabic
            ? "اعثر على طريقك بسهولة وشاهد موقع حوروس في الوقت الفعلي."
            : "Find your way easily and see Horus-Bot's location in real-time.",
        "image": "assets/images/Grand Hall.jpg",
        "iconPath": "assets/icons/map.png",
      },
      {
        "title": isArabic ? "تعلم وتفاعل" : "Learn & Interact",
        "desc": isArabic
            ? "اسأل حوروس عن أي قطعة وشارك في اختبارات ممتعة."
            : "Ask Horus-Bot about any artifact and take fun quizzes.",
        "image": "assets/images/Pharaonic Coffin Mask.jpg",
        "iconPath": "assets/icons/scarab.png",
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // --- 1. Animated Background ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: Image.asset(
              pages[_currentPage]["image"]!,
              key: ValueKey<int>(_currentPage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (c, e, s) => Container(color: const Color(0xFF0F172A)),
            ),
          ),

          // --- 2. Cinematic gradient overlay ---
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Animated Floating Icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOutSine,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * (1.0 - (2 * value - 1.0).abs())),
                                child: child,
                              );
                            },
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFE6C068), // Gold accent
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                pages[index]["iconPath"]!,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              pages[index]["desc"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Dots + "Start with Horus" button ---
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
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFE6C068) // Gold
                                : const Color(0xFF666666), // Gray
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // "Start with Horus-Bot"
                    PrimaryButton(
                      label: isArabic ? "ابدأ الاستكشاف" : "Start Exploring",
                      backgroundColor: const Color(0xFFE6C068), // Theme Gold
                      foregroundColor: const Color(0xFF1E1912), // Dark Brown
                      onPressed: () {
                        prefs.setCompletedOnboarding(true);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.mainHome,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- 4. Language switcher (top-right) ---
          Positioned(
            top: 60,
            right: 24,
            child: SafeArea(
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: const Color(0xE61E1912), // rgba(30, 25, 18, 0.9)
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6C068), width: 0.5),
                  ),
                  onSelected: (lang) => prefs.setLanguage(lang),
                  itemBuilder: (context) => [
                    _buildLanguageItem(
                      code: 'en',
                      name: 'English',
                      flag: '🇺🇸',
                      isSelected: prefs.language == 'en',
                    ),
                    _buildLanguageItem(
                      code: 'ar',
                      name: 'العربية',
                      flag: '🇪🇬',
                      isSelected: prefs.language == 'ar',
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? "العربية" : "English",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                      ],
                    ),
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
