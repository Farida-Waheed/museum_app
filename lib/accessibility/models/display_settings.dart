import '../constants/accessibility_constants.dart';
import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// Visual presentation preferences. This is the group that feeds the existing
/// MaterialApp theming pipeline (text scale + high contrast) and the future
/// color-blind / reduced-motion theming.
class DisplaySettings {
  final double textScale;
  final bool highContrast;
  final bool boldText;
  final bool reduceMotion;
  final bool largeTapTargets;
  final ColorVisionMode colorVision;

const DisplaySettings({
  double textScale = AccessibilityConstants.defaultTextScale,
  this.highContrast = false,
  this.boldText = false,
  this.reduceMotion = false,
  this.largeTapTargets = false,
  this.colorVision = ColorVisionMode.none,
}) : textScale =
        textScale < AccessibilityConstants.minTextScale
            ? AccessibilityConstants.minTextScale
            : textScale > AccessibilityConstants.maxTextScale
                ? AccessibilityConstants.maxTextScale
                : textScale;

  static const DisplaySettings standard = DisplaySettings();

  bool get isNeutral =>
      (textScale - AccessibilityConstants.defaultTextScale).abs() < 0.001 &&
      !highContrast &&
      !boldText &&
      !reduceMotion &&
      !largeTapTargets &&
      !colorVision.isActive;

  DisplaySettings copyWith({
    double? textScale,
    bool? highContrast,
    bool? boldText,
    bool? reduceMotion,
    bool? largeTapTargets,
    ColorVisionMode? colorVision,
  }) {
    return DisplaySettings(
      textScale: _clampScale(textScale ?? this.textScale),
      highContrast: highContrast ?? this.highContrast,
      boldText: boldText ?? this.boldText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largeTapTargets: largeTapTargets ?? this.largeTapTargets,
      colorVision: colorVision ?? this.colorVision,
    );
  }

  static double _clampScale(double v) => v
      .clamp(
        AccessibilityConstants.minTextScale,
        AccessibilityConstants.maxTextScale,
      )
      .toDouble();

  Map<String, dynamic> toMap() => {
        'text_scale': textScale,
        'high_contrast': highContrast,
        'bold_text': boldText,
        'reduce_motion': reduceMotion,
        'large_tap_targets': largeTapTargets,
        'color_vision': colorVision.storageKey,
      };

  factory DisplaySettings.fromMap(Map<String, dynamic> map) => DisplaySettings(
        textScale: AccessibilityParse.asClampedDouble(
          map['text_scale'],
          min: AccessibilityConstants.minTextScale,
          max: AccessibilityConstants.maxTextScale,
          fallback: AccessibilityConstants.defaultTextScale,
        ),
        highContrast: AccessibilityParse.asBool(map['high_contrast']),
        boldText: AccessibilityParse.asBool(map['bold_text']),
        reduceMotion: AccessibilityParse.asBool(map['reduce_motion']),
        largeTapTargets: AccessibilityParse.asBool(map['large_tap_targets']),
        colorVision: ColorVisionMode.fromStorage(map['color_vision']),
      );

  @override
  bool operator ==(Object other) =>
      other is DisplaySettings &&
      (other.textScale - textScale).abs() < 0.001 &&
      other.highContrast == highContrast &&
      other.boldText == boldText &&
      other.reduceMotion == reduceMotion &&
      other.largeTapTargets == largeTapTargets &&
      other.colorVision == colorVision;

  @override
  int get hashCode => Object.hash(textScale, highContrast, boldText,
      reduceMotion, largeTapTargets, colorVision);
}
