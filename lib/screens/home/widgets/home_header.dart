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
    required this.showScanRobotQr,
  });

  final VoidCallback onMenu;
  final VoidCallback onScanRobotQr;
  final ScrollController scrollController;
  final bool showScanRobotQr;

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
          height: topPadding + 86,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding + 86,
                child: IgnorePointer(
                  child: _HeaderProtectionLayer(scrollStrength: scrollStrength),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 3, 16, 0),
                  child: SizedBox(
                    height: 50,
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
                            if (showScanRobotQr)
                              _HeaderButton(
                                icon: Icons.qr_code_scanner_rounded,
                                onTap: onScanRobotQr,
                                scrollStrength: scrollStrength,
                              )
                            else
                              const SizedBox(width: 44, height: 44),
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

class _HeaderProtectionLayer extends StatelessWidget {
  const _HeaderProtectionLayer({required this.scrollStrength});

  final double scrollStrength;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.56, 1.0],
            ).createShader(bounds);
          },
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7 * scrollStrength,
                sigmaY: 7 * scrollStrength,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12 * scrollStrength),
                      Colors.black.withValues(alpha: 0.18 * scrollStrength),
                      Colors.black.withValues(alpha: 0.08 * scrollStrength),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.36, 0.68, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
            fontSize: 17.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 10,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.09 + (0.15 * scrollStrength),
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldBorder(0.18), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.10 + (0.10 * scrollStrength),
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
