import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  // REMOVED: glassSurfaceDecoration - Replaced with solid surfaces
  // Old pattern: BackdropFilter blur + semi-transparent overlays = readability issues
  // New pattern: Solid layered surfaces with subtle borders

  static final solidCardDecoration = BoxDecoration(
    color: AppColors.cinematicCard,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.darkBorder, width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final primaryCtaButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGold,
    foregroundColor: AppColors.darkInk,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
    ),
    elevation: 2,
    shadowColor: AppColors.primaryGold.withOpacity(0.2),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  static const double cardRadius = 24.0;
  static const double innerRadius = 18.0;

  // Refined card decoration with better surface definition
  static final cardDecoration = BoxDecoration(
    color: AppColors.cinematicCard,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: AppColors.darkBorder, width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  // NEW: Elevated surface for modals/top-layer content
  static final elevatedSurfaceDecoration = BoxDecoration(
    color: AppColors.cinematicElevated,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.darkBorder.withOpacity(0.6),
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // NEW: Subtle surface for secondary content
  static final subtleSurfaceDecoration = BoxDecoration(
    color: AppColors.cinematicSection,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.darkBorder.withOpacity(0.3),
      width: 0.5,
    ),
  );
}
