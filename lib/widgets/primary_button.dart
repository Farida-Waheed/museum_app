import 'package:flutter/material.dart';
import '../core/constants/sizes.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.darkInk,
            ),
          )
        else ...[
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label, style: AppTextStyles.buttonLabel(context)),
        ],
      ],
    );

    final buttonStyle = AppDecorations.primaryButton().copyWith(
      backgroundColor: color == null ? null : WidgetStatePropertyAll(color),
      minimumSize: WidgetStatePropertyAll(
        fullWidth
            ? const Size(double.infinity, AppSizes.buttonHeight)
            : const Size(0, AppSizes.buttonHeight),
      ),
    );

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}
