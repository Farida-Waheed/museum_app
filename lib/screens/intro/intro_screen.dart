import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../models/user_preferences.dart';
import '../onboarding/onboarding_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Simple intro animation for the title
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _startTimer();
  }

  void _startTimer() {
    // Show splash for ~2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

      if (prefs.hasCompletedOnboarding) {
        // Go directly to main home
        Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
      } else {
        // Fade into onboarding
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: AppRoutes.onboarding),
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(opacity: curved, child: child);
                },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shared text styles
    const String fontFamily = 'Playfair Display';

    const TextStyle smallTheStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w300,
      fontFamily: fontFamily,
      letterSpacing: 0.5,
    );

    const TextStyle mainTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 44,
      fontWeight: FontWeight.w300,
      fontFamily: fontFamily,
      letterSpacing: 1.5,
      height: 1.1,
    );

    const TextStyle taglineStyle = TextStyle(
      color: Colors.white70,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/GEM.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.70),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: mainTitleStyle,
                        children: <TextSpan>[
                          TextSpan(text: 'The ', style: smallTheStyle),
                          TextSpan(text: 'Egyptian'),
                        ],
                      ),
                    ),
                    const Text('Museums', style: mainTitleStyle),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore Egypt with your Horus-Bot and its app.',
                      style: taglineStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
