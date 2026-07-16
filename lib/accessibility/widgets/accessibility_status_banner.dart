import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../enums/accessibility_enums.dart';
import '../l10n/accessibility_l10n.dart';
import '../models/accessibility_profile.dart';
import '../state/accessibility_controller.dart';

/// Compact, tappable banner for the Home screen that shows the visitor their
/// accessibility profile is active and understood. Purely additive — drop it
/// into the existing Home column. Renders nothing when the profile is neutral,
/// so standard visitors see no clutter.
class AccessibilityStatusBanner extends StatelessWidget {
  /// Optional greeting name (e.g. the signed-in user's first name).
  final String? userName;

  /// Route to open on tap (the profile management page).
  final String profileRoute;

  const AccessibilityStatusBanner({
    super.key,
    required this.profileRoute,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AccessibilityController>();
    final profile = controller.profile;
    final t = AccessibilityL10n.of(context);

    // Standard visitors: show nothing (no clutter).
    if (profile.isNeutral) return const SizedBox.shrink();

    final chips = _readyChips(profile, t);

    return Semantics(
      button: true,
      label: '${t.profileActive}. ${chips.join(', ')}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, profileRoute),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.secondaryGlassCard(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.accessibility_new_rounded,
                        color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName == null
                              ? t.profileActive
                              : t.greeting(userName!),
                          style: AppTextStyles.bodyPrimary(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t.profileActive,
                          style: AppTextStyles.metadata(context)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.primaryGold.withValues(alpha: 0.7)),
                ],
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in chips) _ReadyChip(label: c),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _readyChips(AccessibilityProfile p, AccessibilityL10n t) {
    final chips = <String>[];
    if (p.voice.voiceGuidanceEnabled) chips.add(t.readyVoiceNavigation);
    if (p.interaction.captionsEnabled) chips.add(t.readyLiveCaptions);
    if (p.navigation.routePreference.requiresStepFree) {
      chips.add(t.readyAccessibleRoute);
    }
    if (p.voice.audioDescriptionEnabled) chips.add(t.readyAudioDescription);
    if (p.tour.explanationLevel == ExplanationLevel.simple) {
      chips.add(t.readySimpleMode);
    }
    return chips;
  }
}

class _ReadyChip extends StatelessWidget {
  final String label;
  const _ReadyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 13, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.metadata(context)
                .copyWith(fontSize: 11.5, color: AppColors.resolvedTitleText),
          ),
        ],
      ),
    );
  }
}
