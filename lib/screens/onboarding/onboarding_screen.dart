import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // --- Onboarding pages (short text, Ankhu + app modes) ---
    final List<Map<String, String>> pages = [
      {
        "title": isArabic ? "تعرف على آنخو" : "Meet Ankhu",
        "desc": isArabic
            ? "آنخو هو مرشدك الروبوتي، يعمل مع التطبيق قبل الجولة وأثناءها وبعدها."
            : "Ankhu is your Robo-Guide, working with the app before, during, and after the tour.",
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/ankh.png",
      },
      {
        "title": isArabic ? "وضع الجولة التلقائي" : "Automatic Tour Mode",
        "desc": isArabic
            ? "عند بدء الجولة، يبدأ وضع آنخو تلقائياً ويضيف مميزات خاصة بالجولة."
            : "When the tour starts, Ankhu mode turns on automatically with extra tour features.",
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/map.png",
      },
      {
        "title": isArabic ? "استكشف وتعلّم" : "Explore & Learn",
        "desc": isArabic
            ? "استمع للشرح، اسأل آنخو، وشارك في الاختبارات من خلال التطبيق."
            : "Listen to explanations, ask Ankhu questions, and take quizzes in the app.",
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
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.85),
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
                          // Icon instead of emoji
                          Image.asset(
                            pages[index]["iconPath"]!,
                            width: 96,
                            height: 96,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Dots + "Start with Ankhu" button ---
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
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // "Start with Ankhu" – always visible
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // mark onboarding as completed (if your model has this)
                          prefs.setCompletedOnboarding(true);
                          // go to main home
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.mainHome,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          isArabic ? "ابدأ مع آنخو" : "Start with Ankhu",
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

          // --- 4. Language switcher (top-right) ---
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () {
                  prefs.setLanguage(isArabic ? 'en' : 'ar');
                },
                icon: const Icon(Icons.language, size: 18),
                label: Text(isArabic ? "English" : "العربية"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
