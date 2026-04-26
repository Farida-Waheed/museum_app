import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
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
      _showError(l10n.emailRequired ?? 'Email is required');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError(l10n.passwordRequired ?? 'Password is required');
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
    } else {
      _showError(
        authProvider.errorMessage ?? (l10n.loginFailed ?? 'Login failed'),
      );
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
      appBar: AppBar(title: Text(l10n.login ?? 'Login'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                l10n.welcomeBack,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Email field
            _buildTextField(
              controller: _emailController,
              label: l10n.email ?? 'Email',
              hintText: l10n.emailHint ?? 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              isArabic: isArabic,
            ),
            const SizedBox(height: 20),

            // Password field
            _buildTextField(
              controller: _passwordController,
              label: l10n.password ?? 'Password',
              hintText: l10n.passwordHint ?? 'Enter your password',
              obscureText: _obscurePassword,
              icon: Icons.lock_outlined,
              suffixIcon: _buildPasswordToggle(),
              isArabic: isArabic,
            ),
            const SizedBox(height: 32),

            // Login button
            PrimaryButton(
              label: _isLoading ? '${l10n.loggingIn}...' : l10n.login,
              onPressed: _isLoading ? null : _handleLogin,
              loading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.noAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.register);
                  },
                  child: Text(l10n.createAccount),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Continue as guest
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().continueAsGuest();
                Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
              },
              child: Text(l10n.continueAsGuest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
    required bool isArabic,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
      onPressed: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
    );
  }
}
