import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.read<AuthProvider>();

    if (_emailController.text.isEmpty) {
      _showError(l10n.emailRequired);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError(l10n.passwordRequired);
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
    } else {
      _showError(authProvider.errorMessage ?? l10n.loginFailed);
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                center: const Alignment(0, -0.10),
                opacity: 0.10,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration:
                            AppDecorations.premiumGlassCard(
                              radius: 30,
                              opacity: 0.76,
                            ).copyWith(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.40),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: AppColors.softGlow(0.10),
                                  blurRadius: 32,
                                ),
                              ],
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/ankh.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'HORUS-BOT',
                                    style: AppTextStyles.premiumBrandTitle(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    l10n.welcomeBack,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.premiumHero(context)
                                        .copyWith(
                                          fontSize: isArabic ? 34 : 32,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.52,
                                              ),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    isArabic
                                        ? 'سجل الدخول لمتابعة تجربة حورس-بوت داخل المتحف.'
                                        : 'Log in to continue your Horus-Bot museum experience.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.premiumBody(context)
                                        .copyWith(
                                          color: AppColors.whiteTitle
                                              .withValues(alpha: 0.76),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            _GlassField(
                              controller: _emailController,
                              label: l10n.email,
                              hintText: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              icon: Icons.email_outlined,
                              isArabic: isArabic,
                            ),
                            const SizedBox(height: 16),
                            _GlassField(
                              controller: _passwordController,
                              label: l10n.password,
                              hintText: l10n.passwordHint,
                              obscureText: _obscurePassword,
                              icon: Icons.lock_outline_rounded,
                              isArabic: isArabic,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.softGold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: AppDecorations.primaryButton().copyWith(
                                  shape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _isLoading
                                      ? '${l10n.loggingIn}...'
                                      : l10n.login,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.premiumMutedBody(
                                    context,
                                  ).copyWith(color: AppColors.bodyText),
                                  children: [
                                    TextSpan(text: '${l10n.noAccount} '),
                                    TextSpan(
                                      text: l10n.createAccount,
                                      style: AppTextStyles.premiumButtonLabel(
                                        context,
                                      ).copyWith(color: AppColors.primaryGold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthProvider>().continueAsGuest();
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.mainHome,
                                );
                              },
                              child: Text(
                                l10n.continueAsGuest,
                                style: AppTextStyles.premiumMutedBody(
                                  context,
                                ).copyWith(color: AppColors.bodyText),
                              ),
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
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.isArabic,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.icon,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isArabic;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? icon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      style: AppTextStyles.premiumBody(
        context,
      ).copyWith(color: AppColors.whiteTitle),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyles.premiumMutedBody(
          context,
        ).copyWith(color: AppColors.bodyText),
        hintStyle: AppTextStyles.premiumMutedBody(
          context,
        ).copyWith(color: AppColors.bodyText.withValues(alpha: 0.70)),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.softGold, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.panelGlassBase.withValues(alpha: 0.74),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.goldBorder(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.goldBorder(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryGold,
            width: 1.1,
          ),
        ),
      ),
    );
  }
}
