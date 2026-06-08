import 'package:flutter/material.dart';

import '../app/router.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class GuestPrompt extends StatelessWidget {
  const GuestPrompt({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.primaryLabel = 'Log In',
    this.secondaryLabel = 'Create Account',
    this.tertiaryLabel,
    this.onTertiary,
    this.bottom,
    this.bottomPadding = 112,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;
  final Widget? bottom;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(28, 28, 28, bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.iconCircle,
              height: AppSpacing.iconCircle,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.premiumGold,
              ),
              child: Icon(icon, color: AppColors.darkInk, size: 27),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.premiumScreenTitle(
                context,
              ).copyWith(color: AppColors.whiteTitle, fontSize: 24),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: AppColors.neutralMedium, height: 1.45),
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final stack = constraints.maxWidth < 340;
                final buttons = [
                  Expanded(
                    child: _PromptButton(
                      label: primaryLabel,
                      primary: true,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    ),
                  ),
                  const SizedBox(width: 12, height: 12),
                  Expanded(
                    child: _PromptButton(
                      label: secondaryLabel,
                      primary: false,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                    ),
                  ),
                ];
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PromptButton(
                        label: primaryLabel,
                        primary: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.login,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PromptButton(
                        label: secondaryLabel,
                        primary: false,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.register,
                        ),
                      ),
                    ],
                  );
                }
                return Row(children: buttons);
              },
            ),
            if (tertiaryLabel != null && onTertiary != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onTertiary,
                child: Text(
                  tertiaryLabel!,
                  style: AppTextStyles.buttonLabel(
                    context,
                  ).copyWith(color: AppColors.primaryGold),
                ),
              ),
            ],
            if (bottom != null) ...[const SizedBox(height: 28), bottom!],
          ],
        ),
      ),
    );
  }
}

class _PromptButton extends StatelessWidget {
  const _PromptButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: primary
          ? ElevatedButton(
              onPressed: onTap,
              style: AppDecorations.primaryButton().copyWith(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              child: Text(label, style: AppTextStyles.buttonLabel(context)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: AppDecorations.secondaryButton().copyWith(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.buttonLabel(
                  context,
                ).copyWith(color: AppColors.primaryGold),
              ),
            ),
    );
  }
}
