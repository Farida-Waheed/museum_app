import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onMenu,
    required this.onScanRobotQr,
    required this.scrollController,
  });

  final VoidCallback onMenu;
  final VoidCallback onScanRobotQr;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final scrollStrength = (offset / 90).clamp(0.0, 1.0);
        final topPadding = MediaQuery.paddingOf(context).top;

        return SizedBox(
          height: topPadding + 102,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4 + (8 * scrollStrength),
                      sigmaY: 4 + (8 * scrollStrength),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.52),
                            Colors.black.withValues(
                              alpha: 0.24 + (0.08 * scrollStrength),
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.52, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SizedBox(
                    height: 54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            _HeaderButton(
                              icon: Icons.menu_rounded,
                              onTap: onMenu,
                              scrollStrength: scrollStrength,
                            ),
                            const Spacer(),
                            _HeaderButton(
                              icon: Icons.qr_code_scanner_rounded,
                              onTap: onScanRobotQr,
                              scrollStrength: scrollStrength,
                            ),
                          ],
                        ),
                        const IgnorePointer(child: _HeaderBrand()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/ankh.png', width: 18, height: 18),
        const SizedBox(width: 8),
        Text(
          'HORUS-BOT',
          style: AppTextStyles.premiumBrandTitle(context).copyWith(
            fontSize: 18,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.scrollStrength,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double scrollStrength;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8 + (8 * scrollStrength),
              sigmaY: 8 + (8 * scrollStrength),
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.25 + (0.20 * scrollStrength),
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldBorder(0.30), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.22 + (0.14 * scrollStrength),
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.whiteTitle, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
