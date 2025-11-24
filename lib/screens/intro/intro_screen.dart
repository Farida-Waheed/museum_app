import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../models/user_preferences.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';
  
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final prefs = Provider.of<UserPreferencesModel>(context, listen: false); 
        final nextRoute = prefs.hasCompletedOnboarding 
            ? AppRoutes.mainHome
            : AppRoutes.onboarding;
        Navigator.pushReplacementNamed(context, nextRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define shared text styles for clarity
    const String fontFamily = 'Playfair Display'; 

    // --- Style for "The" (Smaller, Lighter) ---
    const TextStyle smallTheStyle = TextStyle(
      color: Colors.white,
      fontSize: 30, // Smaller size for "The"
      fontWeight: FontWeight.w300, 
      fontFamily: fontFamily, 
      letterSpacing: 0.5, 
    );

    // --- Style for "Egyptian Museums" (Bigger, Main Focus) ---
    const TextStyle mainTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 44, // Main focus size
      fontWeight: FontWeight.w300, 
      fontFamily: fontFamily,
      letterSpacing: 1.5,
      height: 1.1, 
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
                  child: Icon(Icons.broken_image, size: 80, color: Colors.white),
                ),
              );
            },
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Text Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 50, 
            left: 20, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. "The Egyptian" on one line using RichText
                // The RichText widget allows multiple TextSpans (with different styles)
                // to appear seamlessly on the same line.
                RichText(
                  text: TextSpan(
                    // We need a non-null style for RichText, so we use the mainTitleStyle
                    style: mainTitleStyle.copyWith(height: 1.0), // Use height 1.0 for better alignment
                    children: const <TextSpan>[
                      // "The" (Small style)
                      TextSpan(
                        text: 'The ', 
                        style: smallTheStyle,
                      ),
                      // "Egyptian" (Main style)
                      TextSpan(
                        text: 'Egyptian',
                        // We use the full mainTitleStyle here
                      ),
                    ],
                  ),
                ),
                // 2. "Museums" on the second line (Main style)
                const Text(
                  'Museums',
                  style: mainTitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}