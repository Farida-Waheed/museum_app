import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart';
import '../../models/auth_provider.dart';
import '../../models/user_preferences.dart';

class EntryModeScreen extends StatefulWidget {
  const EntryModeScreen({super.key});

  @override
  State<EntryModeScreen> createState() => _EntryModeScreenState();
}

class _EntryModeScreenState extends State<EntryModeScreen> {
  int _pressedCardIndex = -1;

  void _setPressedCard(int index, bool pressed) {
    setState(() {
      _pressedCardIndex = pressed ? index : -1;
    });
  }

  bool _isPressed(int index) => _pressedCardIndex == index;

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<AppSessionProvider>();
    final prefs = context.watch<UserPreferencesModel>();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      backgroundColor: AppColors.baseBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/EGYPT_4.jpg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
          Container(color: Colors.black.withValues(alpha: 0.70)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.ambientGlow(
                center: const Alignment(0, -0.35),
                opacity: 0.12,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 14),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/ankh.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'HORUS-BOT',
                                  style: AppTextStyles.premiumBrandTitle(
                                    context,
                                  ).copyWith(fontSize: 20, letterSpacing: 1.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 54),
                            Text(
                              isArabic
                                  ? 'اختر تجربتك'
                                  : 'Choose Your Experience',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.premiumHero(context)
                                  .copyWith(
                                    fontSize: isArabic ? 34 : 32,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.52,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 360),
                              child: Text(
                                isArabic
                                    ? 'خطط لزيارتك أو ابدأ جولتك الإرشادية مع حورس-بوت.'
                                    : 'Plan your visit or begin your guided tour with Horus-Bot.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.premiumBody(context)
                                    .copyWith(
                                      color: AppColors.whiteTitle.withValues(
                                        alpha: 0.76,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 38),
                            _buildPremiumCard(
                              context: context,
                              title: l10n.planMyVisit,
                              description: l10n.planMyVisitDescription,
                              icon: Icons.explore_outlined,
                              onTap: () {
                                sessionProvider.startPlanning();
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.mainHome,
                                );
                              },
                              index: 0,
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumCard(
                              context: context,
                              title: l10n.startMyTour,
                              description: isArabic
                                  ? 'خصص مسارك واتصل بحورس-بوت.'
                                  : 'Customize your route and connect to Horus-Bot.',
                              icon: Icons.route_outlined,
                              onTap: () {
                                final authProvider = context
                                    .read<AuthProvider>();
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
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
    required bool isArabic,
  }) {
    final isPressed = _isPressed(index);

    return GestureDetector(
      onTapDown: (_) => _setPressedCard(index, true),
      onTapUp: (_) => _setPressedCard(index, false),
      onTapCancel: () => _setPressedCard(index, false),
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 132,
              decoration: AppDecorations.premiumGlassCard(
                radius: 26,
                highlighted: isPressed,
                opacity: isPressed ? 0.78 : 0.70,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGold.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.goldBorder(0.40)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.softGlow(isPressed ? 0.16 : 0.10),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 28, color: AppColors.primaryGold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: AppTextStyles.premiumCardTitle(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: AppTextStyles.premiumMutedBody(context)
                                .copyWith(
                                  color: AppColors.bodyText.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isArabic
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: AppColors.softGold.withValues(alpha: 0.72),
                    ),
                  ],
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
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.panelGlassBase.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.goldBorder(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountRequired,
                      style: AppTextStyles.premiumScreenTitle(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.createOrLoginToPreserve,
                      style: AppTextStyles.premiumMutedBody(
                        context,
                      ).copyWith(color: AppColors.bodyText),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        foregroundColor: AppColors.whiteTitle,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        l10n.continueAsGuest,
                        style: AppTextStyles.premiumButtonLabel(
                          context,
                        ).copyWith(color: AppColors.bodyText),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            style: AppDecorations.secondaryButton().copyWith(
                              minimumSize: const WidgetStatePropertyAll(
                                Size.fromHeight(48),
                              ),
                            ),
                            child: Text(l10n.login),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                            style: AppDecorations.primaryButton().copyWith(
                              minimumSize: const WidgetStatePropertyAll(
                                Size.fromHeight(48),
                              ),
                            ),
                            child: Text(l10n.createAccount),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
