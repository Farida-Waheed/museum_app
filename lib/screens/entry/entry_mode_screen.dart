import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_session_provider.dart';
import '../../models/auth_provider.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';

class EntryModeScreen extends StatelessWidget {
  const EntryModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final sessionProvider = context.watch<AppSessionProvider>();

    return AppMenuShell(
      showChatButton: false,
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations?.welcomeToHorusBot ?? 'Welcome to Horus-Bot',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations?.welcomeToHorusBot ?? 'Welcome to Horus-Bot',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                localizations?.howAreYouUsingTheAppToday ??
                    'How are you using the app today?',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildModeCard(
                context: context,
                title: localizations?.planMyVisit ?? 'Plan My Visit',
                description:
                    localizations?.planMyVisitDescription ??
                    'Explore the museum, buy tickets, and prepare your visit.',
                icon: Icons.explore,
                onTap: () {
                  sessionProvider.startPlanning();
                  Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
                },
              ),
              const SizedBox(height: 24),
              _buildModeCard(
                context: context,
                title: localizations?.startMyTour ?? 'Start My Tour',
                description:
                    localizations?.startMyTourDescription ??
                    'Use your tickets, connect to Horus-Bot, and begin the guided experience.',
                icon: Icons.play_arrow,
                onTap: () {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.isLoggedIn) {
                    sessionProvider.startVisiting();
                    if (sessionProvider.canStartRobotTour) {
                      Navigator.pushReplacementNamed(context, AppRoutes.qrScan);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.tickets,
                      );
                    }
                  } else {
                    // Show account required prompt
                    _showAccountRequiredDialog(context);
                  }
                },
              ),
            ],
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
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
        title: Text(l10n.accountRequired ?? 'Account Required'),
        content: Text(
          l10n.createOrLoginToPreserve ??
              'Create an account or log in to save your tickets, payments, and robot tour access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.continueAsGuest ?? 'Continue as Guest'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(l10n.login ?? 'Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.register);
            },
            child: Text(l10n.createAccount ?? 'Create Account'),
          ),
        ],
      ),
    );
  }
}
