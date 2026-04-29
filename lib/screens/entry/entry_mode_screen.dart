import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_session_provider.dart';
import '../../models/auth_provider.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';

class EntryModeScreen extends StatefulWidget {
  const EntryModeScreen({super.key});

  @override
  State<EntryModeScreen> createState() => _EntryModeScreenState();
}

class _EntryModeScreenState extends State<EntryModeScreen> {
  int _hoveredCardIndex = -1;

  void _setHoveredCard(int index, bool hovered) {
    setState(() {
      _hoveredCardIndex = hovered ? index : -1;
    });
  }

  bool _isHovered(int index) => _hoveredCardIndex == index;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final sessionProvider = context.watch<AppSessionProvider>();

    return AppMenuShell(
      showChatButton: false,
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            localizations?.welcomeToHorusBot ?? 'Welcome to Horus-Bot',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFC6A96B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontFamily: 'Cinzel',
                ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E0E),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  localizations?.welcomeToHorusBot ?? 'Welcome to Horus-Bot',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cinzel',
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.howAreYouUsingTheAppToday ??
                      'How are you using the app today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFB8B8B8),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildModeCard(
                  context: context,
                  title: localizations?.planMyVisit ?? 'Plan My Visit',
                  description: localizations?.planMyVisitDescription ??
                      'Explore the museum, buy tickets, and prepare your visit.',
                  icon: Icons.explore,
                  onTap: () {
                    sessionProvider.startPlanning();
                    Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
                  },
                  index: 0,
                ),
                const SizedBox(height: 20),
                _buildModeCard(
                  context: context,
                  title: localizations?.startMyTour ?? 'Start My Tour',
                  description: localizations?.startMyTourDescription ??
                      'Use your tickets, connect to Horus-Bot, and begin the guided experience.',
                  icon: Icons.play_arrow,
                  onTap: () {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.isLoggedIn) {
                      sessionProvider.startVisiting();
                      if (sessionProvider.canStartRobotTour) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.tourCustomization,
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.tickets,
                        );
                      }
                    } else {
                      _showAccountRequiredDialog(context);
                    }
                  },
                  index: 1,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
  }) {
    final isHovered = _isHovered(index);
    return MouseRegion(
      onEnter: (_) => _setHoveredCard(index, true),
      onExit: (_) => _setHoveredCard(index, false),
      child: AnimatedScale(
        scale: isHovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFC6A96B).withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  splashColor: const Color(0xFFE6C98F).withOpacity(0.12),
                  highlightColor: Colors.white.withOpacity(0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: const Color(0xFFC6A96B).withOpacity(0.2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC6A96B).withOpacity(0.16),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 28,
                            color: const Color(0xFFC6A96B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style:
                                    Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: const Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          fontFamily: 'Cinzel',
                                        ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFFB8B8B8),
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFB8B8B8),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountRequiredDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountRequired),
        content: Text(
          l10n.createOrLoginToPreserve,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.continueAsGuest),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(l10n.login),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.register);
            },
            child: Text(l10n.createAccount),
          ),
        ],
      ),
    );
  }
}
