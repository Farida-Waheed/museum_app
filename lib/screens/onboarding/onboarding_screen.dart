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
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: true);
    final isArabic = prefs.language == 'ar';

    // Onboarding Data
    final List<Map<String, String>> pages = [
      {
        "title": isArabic ? "مرحباً بكم في المستقبل" : "Welcome to the Future",
        "desc": isArabic
            ? "استمتع بتجربة متحف ذكية مع دليلنا الآلي."
            : "Experience a smart museum tour with our AI Robot Guide.",
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/ankh.png",
      },
      {
        "title": isArabic ? "تتبع موقعك" : "Track Your Location",
        "desc": isArabic
            ? "شاهد موقعك وموقع الروبوت على الخريطة التفاعلية."
            : "See your live location and the robot on the interactive map.",
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/map.png",
      },
      {
        "title": isArabic ? "تعلم واكتشف" : "Learn & Explore",
        "desc": isArabic
            ? "استمع للشرح الصوتي، شارك في الاختبارات، واسأل الروبوت."
            : "Listen to audio guides, take quizzes, and chat with the robot.",
        "image": "assets/images/Onboarding.jpg",
        "iconPath": "assets/icons/scarab.png",
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // --- 1. Background Image (Onboarding.jpg) ---
          Positioned.fill(
            child: Image.asset(
              pages[_currentPage]["image"]!,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.blueGrey),
            ),
          ),

          // --- 2. Gradient Overlay ---
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. Content ---
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
                          // ICON IMAGE INSTEAD OF EMOJI
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Controls (Dots & Button) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  children: [
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // optional: mark onboarding as completed
                          // prefs.setCompletedOnboarding(true);

                          // Always go directly to Home
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.mainHome,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          isArabic ? "ابدأ الرحلة" : "Get Started",
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

          // --- 4. Language Switcher ---
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
