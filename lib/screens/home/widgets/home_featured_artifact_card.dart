import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../state/home_snapshot.dart';

class HomeFeaturedArtifactCard extends StatelessWidget {
  const HomeFeaturedArtifactCard({
    super.key,
    required this.artifact,
    required this.onTap,
  });

  final HomeFeaturedArtifact artifact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 176,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(artifact.imageAsset, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.useLightSurfaces
                        ? [
                            AppColors.websiteLightBackground.withValues(
                              alpha: 0.00,
                            ),
                            AppColors.darkInk.withValues(alpha: 0.20),
                            AppColors.websiteLightBackground.withValues(
                              alpha: 0.94,
                            ),
                          ]
                        : const [
                            Color(0x26000000),
                            Color(0x5C000000),
                            Color(0xD9000000),
                          ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.useLightSurfaces
                            ? AppColors.websiteLightBackground.withValues(
                                alpha: 0.58,
                              )
                            : AppColors.darkInk.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.goldBorder(0.14)),
                      ),
                      child: Row(
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artifact.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: AppTextStyles.premiumScreenTitle(
                                    context,
                                  ).copyWith(
                                    fontSize: 20,
                                    color: AppColors.resolvedTitleText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artifact.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: AppTextStyles.premiumMutedBody(
                                    context,
                                  ).copyWith(color: AppColors.resolvedBodyText),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  artifact.contextHint,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: AppTextStyles.premiumMutedBody(context)
                                      .copyWith(
                                        fontSize: 13,
                                        color: AppColors.primaryGold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
