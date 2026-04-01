import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_preferences.dart';
import '../../l10n/app_localizations.dart';
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
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Base styles for title composition
    final TextStyle baseHeroStyle = AppTextStyles.heroTitle(context);
    final TextStyle smallTitleStyle = baseHeroStyle.copyWith(
      fontSize: isArabic ? 28 : 32,
      fontWeight: isArabic ? FontWeight.normal : FontWeight.w200,
    );
    final TextStyle mainTitleStyle = baseHeroStyle.copyWith(
      fontSize: isArabic ? 40 : 44,
    );
    final TextStyle secondaryTitleStyle = baseHeroStyle.copyWith(
      fontSize: isArabic ? 36 : 40,
      fontWeight: isArabic ? FontWeight.w600 : FontWeight.w400,
    );

    final TextStyle taglineStyle = AppTextStyles.body(
      context,
    ).copyWith(color: Colors.white70);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/GEM.jpg'),
                fit: BoxFit.cover,
              ),
            ),
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

          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 50,
            start: 20,
            end: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isArabic)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'المتاحف\n',
                              style: smallTitleStyle,
                            ),
                            TextSpan(
                              text: 'المصرية',
                              style: mainTitleStyle,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                        textDirection: TextDirection.rtl,
                      )
                    else
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'The ',
                              style: smallTitleStyle,
                            ),
                            TextSpan(
                              text: 'Egyptian\n',
                              style: mainTitleStyle,
                            ),
                            TextSpan(
                              text: 'Museums',
                              style: secondaryTitleStyle,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                      ),
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
