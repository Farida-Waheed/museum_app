import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final Widget? icon;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.useLightSurfaces
                  ? AppColors.cardGlass(0.90)
                  : AppColors.darkInk.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(
                  AppColors.useLightSurfaces ? 0.22 : 0.4,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceShadow(
                    AppColors.useLightSurfaces ? 0.18 : 0.5,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 16, 16),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 12)],
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.titleLarge(context).copyWith(
                            color: AppColors.resolvedTitleText,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.resolvedMutedText,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      0,
                      24,
                      24,
                    ),
                    child: content,
                  ),
                ),

                // Actions
                if (actions != null && actions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!.map((a) {
                        final isLast = a == actions!.last;
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: isLast ? 0 : 12,
                          ),
                          child: a,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
