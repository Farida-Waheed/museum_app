import 'package:flutter/material.dart';
import 'sizes.dart';
import 'colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Playfair Display';

  static TextStyle headline(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: _textColor(context),
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: _textColor(context),
      height: 1.25,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: _textColor(context),
      height: 1.5,
    );
  }

  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: _textSecondaryColor(context),
      height: 1.4,
    );
  }

  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  static Color _textColor(BuildContext context) {
    // prefer theme color if available
    final c = Theme.of(context).textTheme.bodyMedium?.color;
    return c ?? AppColors.textPrimary;
  }

  static Color _textSecondaryColor(BuildContext context) {
    final c = Theme.of(context).textTheme.bodySmall?.color;
    return c ?? AppColors.textSecondary;
  }
}

class AppPadding {
  static const EdgeInsets page = EdgeInsets.all(AppSizes.md);
  static const EdgeInsets card = EdgeInsets.all(AppSizes.md);
}
