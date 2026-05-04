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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(color: AppColors.bronzeGlow(0.035), blurRadius: 18),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 188,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(artifact.imageAsset, fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x26000000),
                        Color(0x5C000000),
                        Color(0xD9000000),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(child: _ArtifactHighlight()),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: AppTextStyles.premiumScreenTitle(context)
                                    .copyWith(
                                      fontSize: 20,
                                      color: AppColors.whiteTitle,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                artifact.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: AppTextStyles.premiumMutedBody(
                                  context,
                                ).copyWith(color: AppColors.bodyText),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                artifact.contextHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtifactHighlight extends StatelessWidget {
  const _ArtifactHighlight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.goldBorder(0.16)),
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.034),
              Colors.white.withValues(alpha: 0.010),
              Colors.transparent,
            ],
            stops: const [0.0, 0.18, 0.48],
          ),
        ),
      ),
    );
  }
}
