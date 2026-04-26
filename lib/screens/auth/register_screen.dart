import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
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

    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError(l10n.nameRequired ?? 'Name is required');
      return;
    }

    if (_emailController.text.isEmpty) {
      _showError(l10n.emailRequired ?? 'Email is required');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError(
        l10n.passwordTooShort ?? 'Password must be at least 6 characters',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(l10n.passwordMismatch ?? 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
    } else {
      _showError(
        authProvider.errorMessage ??
            (l10n.registerFailed ?? 'Registration failed'),
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
      appBar: AppBar(
        title: Text(l10n.register ?? 'Create Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                l10n.signUp ?? 'Sign Up',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Name field
            _buildTextField(
              controller: _nameController,
              label: l10n.fullName ?? 'Full Name',
              hintText: l10n.fullNameHint ?? 'Enter your full name',
              icon: Icons.person_outline,
              isArabic: isArabic,
            ),
            const SizedBox(height: 20),

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

            // Phone field
            _buildTextField(
              controller: _phoneController,
              label: l10n.phone ?? 'Phone Number',
              hintText: l10n.phoneHint ?? 'Enter your phone number (optional)',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
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
              suffixIcon: _buildPasswordToggle(_obscurePassword, (value) {
                setState(() => _obscurePassword = value);
              }),
              isArabic: isArabic,
            ),
            const SizedBox(height: 20),

            // Confirm password field
            _buildTextField(
              controller: _confirmPasswordController,
              label: l10n.confirmPassword ?? 'Confirm Password',
              hintText: l10n.confirmPasswordHint ?? 'Re-enter your password',
              obscureText: _obscureConfirmPassword,
              icon: Icons.lock_outline,
              suffixIcon: _buildPasswordToggle(_obscureConfirmPassword, (
                value,
              ) {
                setState(() => _obscureConfirmPassword = value);
              }),
              isArabic: isArabic,
            ),
            const SizedBox(height: 32),

            // Register button
            PrimaryButton(
              label: _isLoading
                  ? '${l10n.signingUp ?? 'Creating account'}...'
                  : (l10n.createAccount ?? 'Create Account'),
              onPressed: _isLoading ? null : _handleRegister,
              loading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.alreadyHaveAccount ?? 'Already have an account?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: Text(l10n.login ?? 'Login'),
                ),
              ],
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

  Widget _buildPasswordToggle(bool obscure, Function(bool) onChanged) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
      onPressed: () => onChanged(!obscure),
    );
  }
}
