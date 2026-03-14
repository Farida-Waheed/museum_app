import 'package:flutter/material.dart';
import '../core/constants/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool isUppercase;
  final EdgeInsetsGeometry? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.isUppercase = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isUppercase ? title.toUpperCase() : title,
              style: AppTextStyles.sectionTitle(context),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
