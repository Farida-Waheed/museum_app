import 'package:flutter/material.dart';

import '../enums/accessibility_enums.dart';
import 'accessibility_l10n.dart';

/// UI presentation for each accessibility category — icon + localized label and
/// description used by the wizard's need cards, the profile page chips, and the
/// home banner. Keeps presentation out of the pure enum (which stays UI-free).
class AccessibilityCategoryPresentation {
  final AccessibilityCategory category;
  final IconData icon;
  final String label;
  final String description;

  const AccessibilityCategoryPresentation({
    required this.category,
    required this.icon,
    required this.label,
    required this.description,
  });

  static IconData iconFor(AccessibilityCategory c) => switch (c) {
        AccessibilityCategory.standard => Icons.person_outline_rounded,
        AccessibilityCategory.visualImpairment => Icons.visibility_outlined,
        AccessibilityCategory.hearingImpairment => Icons.hearing_outlined,
        AccessibilityCategory.wheelchairUser => Icons.accessible_forward,
        AccessibilityCategory.cognitiveAssistance => Icons.psychology_outlined,
      };

  static AccessibilityCategoryPresentation resolve(
    AccessibilityCategory c,
    AccessibilityL10n t,
  ) {
    switch (c) {
      case AccessibilityCategory.standard:
        return AccessibilityCategoryPresentation(
          category: c,
          icon: iconFor(c),
          label: t.isAr ? 'التجربة القياسية' : 'Standard experience',
          description: t.isAr
              ? 'لا أحتاج إلى تسهيلات إضافية في الوقت الحالي.'
              : 'I don’t need extra assistance right now.',
        );
      case AccessibilityCategory.visualImpairment:
        return AccessibilityCategoryPresentation(
          category: c,
          icon: iconFor(c),
          label: t.isAr ? 'إعانة بصرية' : 'Visual assistance',
          description: t.isAr
              ? 'نص أكبر وتباين أعلى ووصف صوتي وإرشاد منطوق.'
              : 'Larger text, high contrast, audio description and spoken guidance.',
        );
      case AccessibilityCategory.hearingImpairment:
        return AccessibilityCategoryPresentation(
          category: c,
          icon: iconFor(c),
          label: t.isAr ? 'إعانة سمعية' : 'Hearing assistance',
          description: t.isAr
              ? 'ترجمة نصية حيّة وإشارات مرئية بدلاً من الصوت وحده.'
              : 'Live captions and visual cues instead of audio alone.',
        );
      case AccessibilityCategory.wheelchairUser:
        return AccessibilityCategoryPresentation(
          category: c,
          icon: iconFor(c),
          label: t.isAr ? 'مستخدم كرسي متحرك' : 'Wheelchair user',
          description: t.isAr
              ? 'مسارات خالية من الدرَج ونقاط استراحة وإيقاع مريح.'
              : 'Step-free routes, rest points and a relaxed pace.',
        );
      case AccessibilityCategory.cognitiveAssistance:
        return AccessibilityCategoryPresentation(
          category: c,
          icon: iconFor(c),
          label: t.isAr ? 'إعانة إدراكية' : 'Cognitive assistance',
          description: t.isAr
              ? 'لغة أبسط وشرح أقصر وحركة أقل ووتيرة هادئة.'
              : 'Simpler language, shorter explanations, less motion and a calm pace.',
        );
    }
  }

  /// The categories the wizard offers, in display order (Standard last as the
  /// "none of these" option).
  static const List<AccessibilityCategory> selectable = [
    AccessibilityCategory.visualImpairment,
    AccessibilityCategory.hearingImpairment,
    AccessibilityCategory.wheelchairUser,
    AccessibilityCategory.cognitiveAssistance,
    AccessibilityCategory.standard,
  ];
}
