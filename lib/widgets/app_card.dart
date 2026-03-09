import 'package:flutter/material.dart';
import '../core/constants/sizes.dart';

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
    final theme = Theme.of(context);

    return Card(
      color: color ?? theme.cardTheme.color,
      elevation: elevation ?? theme.cardTheme.elevation,
      shape: shape ?? theme.cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSizes.md),
          child: child,
        ),
      ),
    );
  }
}
