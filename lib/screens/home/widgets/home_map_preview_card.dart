import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../state/home_snapshot.dart';

class HomeMapPreviewCard extends StatelessWidget {
  const HomeMapPreviewCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onFullView,
    required this.legendHorus,
    required this.legendYou,
    required this.fullViewLabel,
  });

  final HomeMapPreviewData data;
  final VoidCallback onTap;
  final VoidCallback onFullView;
  final String legendHorus;
  final String legendYou;
  final String fullViewLabel;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 154,
            decoration: BoxDecoration(
              color: AppColors.cardGlass(0.58),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.goldBorder(0.20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _GridPainter()),
                ),
                const Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: Center(
                      child: Icon(
                        Icons.museum_outlined,
                        size: 100,
                        color: AppColors.whiteTitle,
                      ),
                    ),
                  ),
                ),
                if (data.isLive)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF451717),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF8C2F2F)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFFFF5B5B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LIVE',
                            style: AppTextStyles.premiumMutedBody(context)
                                .copyWith(
                                  color: const Color(0xFFFFB5B5),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (data.isLive) ...[
                  _DotMarker(
                    alignment: Alignment(
                      data.horusPosition.dx * 2 - 1,
                      data.horusPosition.dy * 2 - 1,
                    ),
                    color: AppColors.primaryGold,
                    glow: true,
                    icon: Icons.smart_toy_outlined,
                  ),
                  _DotMarker(
                    alignment: Alignment(
                      data.userPosition.dx * 2 - 1,
                      data.userPosition.dy * 2 - 1,
                    ),
                    color: const Color(0xFF4D8DFF),
                    icon: Icons.person_pin_circle_outlined,
                  ),
                  PositionedDirectional(
                    start: 16,
                    top: 16,
                    child: _LiveStatusPill(text: data.hint),
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        data.hint,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.premiumMutedBody(
                          context,
                        ).copyWith(color: AppColors.bodyText),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Row(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    children: [
                      _LegendDot(
                        color: AppColors.primaryGold,
                        label: legendHorus,
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(
                        color: const Color(0xFF4D8DFF),
                        label: legendYou,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 14,
                  child: TextButton(
                    onPressed: onFullView,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      fullViewLabel,
                      style: AppTextStyles.premiumButtonLabel(
                        context,
                      ).copyWith(color: AppColors.primaryGold, fontSize: 15),
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

class _LiveStatusPill extends StatelessWidget {
  const _LiveStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardGlass(0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder(0.24)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.premiumMutedBody(
          context,
        ).copyWith(color: AppColors.whiteTitle, fontSize: 12),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.premiumMutedBody(context).copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _DotMarker extends StatelessWidget {
  const _DotMarker({
    required this.alignment,
    required this.color,
    this.glow = false,
    required this.icon,
  });

  final Alignment alignment;
  final Color color;
  final bool glow;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
          boxShadow: [
            if (glow)
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 18,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 32.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
