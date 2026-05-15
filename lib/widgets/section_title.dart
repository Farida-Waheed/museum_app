import 'package:flutter/material.dart';
import '../core/constants/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.displaySectionTitle(context),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
