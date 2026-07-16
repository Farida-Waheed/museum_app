import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// Emergency-assistance preparation (Phase 8). Phase 1 only carries the data so
/// the Emergency Assistance System can plug in without a schema change.
class EmergencySettings {
  /// Master switch for one-tap emergency assistance affordances.
  final bool sosEnabled;

  final SosTrigger trigger;

  /// Optional emergency contact name (personal, kept in the user's own doc).
  final String? contactName;

  /// Optional emergency contact phone.
  final String? contactPhone;

  /// Share live location with staff/robot during an emergency.
  final bool shareLocation;

  /// Free-text medical note staff may need (allergies, conditions).
  final String? medicalNote;

  const EmergencySettings({
    this.sosEnabled = false,
    this.trigger = SosTrigger.tapButton,
    this.contactName,
    this.contactPhone,
    this.shareLocation = false,
    this.medicalNote,
  });

  static const EmergencySettings standard = EmergencySettings();

  bool get isNeutral =>
      !sosEnabled &&
      trigger == SosTrigger.tapButton &&
      (contactName == null || contactName!.isEmpty) &&
      (contactPhone == null || contactPhone!.isEmpty) &&
      !shareLocation &&
      (medicalNote == null || medicalNote!.isEmpty);

  EmergencySettings copyWith({
    bool? sosEnabled,
    SosTrigger? trigger,
    String? contactName,
    String? contactPhone,
    bool? shareLocation,
    String? medicalNote,
  }) {
    return EmergencySettings(
      sosEnabled: sosEnabled ?? this.sosEnabled,
      trigger: trigger ?? this.trigger,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      shareLocation: shareLocation ?? this.shareLocation,
      medicalNote: medicalNote ?? this.medicalNote,
    );
  }

  Map<String, dynamic> toMap() => {
        'sos_enabled': sosEnabled,
        'trigger': trigger.storageKey,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'share_location': shareLocation,
        'medical_note': medicalNote,
      };

  factory EmergencySettings.fromMap(Map<String, dynamic> map) =>
      EmergencySettings(
        sosEnabled: AccessibilityParse.asBool(map['sos_enabled']),
        trigger: SosTrigger.fromStorage(map['trigger']),
        contactName: AccessibilityParse.asString(map['contact_name']).isEmpty
            ? null
            : AccessibilityParse.asString(map['contact_name']),
        contactPhone: AccessibilityParse.asString(map['contact_phone']).isEmpty
            ? null
            : AccessibilityParse.asString(map['contact_phone']),
        shareLocation: AccessibilityParse.asBool(map['share_location']),
        medicalNote: AccessibilityParse.asString(map['medical_note']).isEmpty
            ? null
            : AccessibilityParse.asString(map['medical_note']),
      );

  @override
  bool operator ==(Object other) =>
      other is EmergencySettings &&
      other.sosEnabled == sosEnabled &&
      other.trigger == trigger &&
      other.contactName == contactName &&
      other.contactPhone == contactPhone &&
      other.shareLocation == shareLocation &&
      other.medicalNote == medicalNote;

  @override
  int get hashCode => Object.hash(sosEnabled, trigger, contactName,
      contactPhone, shareLocation, medicalNote);
}
