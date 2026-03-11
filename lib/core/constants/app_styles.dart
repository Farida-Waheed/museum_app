import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  static final glassSurfaceDecoration = BoxDecoration(
    color: Colors.black.withOpacity(0.25),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: AppColors.primaryGold.withOpacity(0.35),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final primaryCtaButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGold,
    foregroundColor: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
    ),
    elevation: 6,
    shadowColor: Colors.black.withOpacity(0.25),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  static const double cardRadius = 24.0;
  static const double innerRadius = 18.0;

  static final cardDecoration = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: AppColors.primaryGold.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
