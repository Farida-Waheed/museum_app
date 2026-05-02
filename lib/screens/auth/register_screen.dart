import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.read<AuthProvider>();

    if (_nameController.text.trim().isEmpty) {
      _showError(l10n.nameRequired);
      return;
    }

    if (_emailController.text.isEmpty) {
      _showError(l10n.emailRequired);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError(l10n.passwordTooShort);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(l10n.passwordMismatch);
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
    } else {
      _showError(authProvider.errorMessage ?? l10n.registerFailed);
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.baseBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.screenBackground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.premiumGlassCard(
                        radius: 30,
                        opacity: 0.72,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Image.asset('assets/icons/ankh.png', width: 28, height: 28),
                                const SizedBox(height: 10),
                                Text(
                                  'HORUS-BOT',
                                  style: AppTextStyles.premiumBrandTitle(context),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  l10n.createAccount,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.premiumHero(context).copyWith(
                                    fontSize: isArabic ? 34 : 32,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isArabic
                                      ? 'احفظ التذاكر والتفضيلات ووصول جولتك مع حورس-بوت.'
                                      : 'Save tickets, preferences, and your Horus-Bot tour access.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.premiumBody(context).copyWith(
                                    color: AppColors.bodyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _GlassField(
                            controller: _nameController,
                            label: l10n.fullName,
                            hintText: l10n.fullNameHint,
                            icon: Icons.person_outline_rounded,
                            isArabic: isArabic,
                          ),
                          const SizedBox(height: 16),
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
                            controller: _phoneController,
                            label: l10n.phone,
                            hintText: l10n.phoneHint,
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone_outlined,
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
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.softGold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GlassField(
                            controller: _confirmPasswordController,
                            label: l10n.confirmPassword,
                            hintText: l10n.confirmPasswordHint,
                            obscureText: _obscureConfirmPassword,
                            icon: Icons.lock_outline_rounded,
                            isArabic: isArabic,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
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
                              onPressed: _isLoading ? null : _handleRegister,
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
                                    ? '${l10n.signingUp}...'
                                    : l10n.createAccount,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.login);
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.premiumMutedBody(context).copyWith(
                                  color: AppColors.bodyText,
                                ),
                                children: [
                                  TextSpan(text: '${l10n.alreadyHaveAccount} '),
                                  TextSpan(
                                    text: l10n.login,
                                    style: AppTextStyles.premiumButtonLabel(context).copyWith(
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
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
      style: AppTextStyles.premiumBody(context).copyWith(
        color: AppColors.whiteTitle,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyles.premiumMutedBody(context).copyWith(
          color: AppColors.bodyText,
        ),
        hintStyle: AppTextStyles.premiumMutedBody(context).copyWith(
          color: AppColors.bodyText.withValues(alpha: 0.70),
        ),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.softGold, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.panelGlassBase.withValues(alpha: 0.70),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.1),
        ),
      ),
    );
  }
}
