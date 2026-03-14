import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../../l10n/app_localizations.dart';

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();

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

  void _startTimer() async {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    await prefs.ready;
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (prefs.hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
      } else {
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
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroStyle = AppTextStyles.heroTitle(context);

    final TextStyle smallTheStyle = heroStyle.copyWith(
      fontSize: 30,
      letterSpacing: 0.5,
    );

    final TextStyle mainTitleStyle = heroStyle;

    final TextStyle taglineStyle = AppTextStyles.body(context).copyWith(
      color: Colors.white70,
    );

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.70),
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
                      text: TextSpan(
                        style: mainTitleStyle,
                        children: <TextSpan>[
                          TextSpan(
                            text: l10n.introTitlePrefix,
                            style: smallTheStyle,
                          ),
                          TextSpan(text: l10n.introTitleMain),
                        ],
                      ),
                    ),
                    Text(l10n.introTitleSuffix, style: mainTitleStyle),
                    const SizedBox(height: 12),
                    Text(l10n.introSubtitle, style: taglineStyle),
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
