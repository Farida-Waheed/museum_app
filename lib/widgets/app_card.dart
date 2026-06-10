import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/constants/sizes.dart';
import '../core/constants/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.secondaryGlass(0.52),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.goldBorder(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.useLightSurfaces ? 0.07 : 0.18,
                ),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSizes.md),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
