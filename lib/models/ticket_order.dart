import 'museum_ticket.dart';
import 'payment_record.dart';
import 'robot_tour_ticket.dart';
import '../core/constants/pricing.dart';

enum VisitorAudience { egyptian, foreigner }

enum VisitorAgeGroup { adult, student, child }

enum RobotTourType { none, standard, personalized }

class TourNarrationLanguage {
  static const List<String> values = [
    'english',
    'arabic',
    'french',
    'german',
    'spanish',
    'italian',
    'korean',
    'chinese',
    'japanese',
    'other',
  ];

  static String? normalize(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll('-', '_');
    if (normalized == null || normalized.isEmpty) return null;
    switch (normalized) {
      case 'en':
        return 'english';
      case 'ar':
        return 'arabic';
      default:
        return values.contains(normalized) ? normalized : null;
    }
  }

  static bool isSupported(String? value) => normalize(value) != null;

  static String label(String? value, bool isArabic, {String? otherText}) {
    if (normalize(value) == 'other' && otherText?.trim().isNotEmpty == true) {
      return isArabic
          ? '\u0644\u063a\u0629 \u0623\u062e\u0631\u0649: ${otherText!.trim()}'
          : 'Other: ${otherText!.trim()}';
    }
    switch (normalize(value)) {
      case 'english':
        return isArabic
            ? '\u0627\u0644\u0625\u0646\u062c\u0644\u064a\u0632\u064a\u0629'
            : 'English';
      case 'arabic':
        return isArabic
            ? '\u0627\u0644\u0639\u0631\u0628\u064a\u0629'
            : 'Arabic';
      case 'french':
        return isArabic
            ? '\u0627\u0644\u0641\u0631\u0646\u0633\u064a\u0629'
            : 'French';
      case 'german':
        return isArabic
            ? '\u0627\u0644\u0623\u0644\u0645\u0627\u0646\u064a\u0629'
            : 'German';
      case 'spanish':
        return isArabic
            ? '\u0627\u0644\u0625\u0633\u0628\u0627\u0646\u064a\u0629'
            : 'Spanish';
      case 'italian':
        return isArabic
            ? '\u0627\u0644\u0625\u064a\u0637\u0627\u0644\u064a\u0629'
            : 'Italian';
      case 'korean':
        return isArabic
            ? '\u0627\u0644\u0643\u0648\u0631\u064a\u0629'
            : 'Korean';
      case 'chinese':
        return isArabic
            ? '\u0627\u0644\u0635\u064a\u0646\u064a\u0629'
            : 'Chinese';
      case 'japanese':
        return isArabic
            ? '\u0627\u0644\u064a\u0627\u0628\u0627\u0646\u064a\u0629'
            : 'Japanese';
      case 'other':
        return isArabic
            ? '\u0644\u063a\u0629 \u0623\u062e\u0631\u0649'
            : 'Other';
      default:
        return isArabic
            ? '\u0627\u0644\u0644\u063a\u0629 \u0627\u0644\u0645\u062e\u062a\u0627\u0631\u0629'
            : 'Selected language';
    }
  }
}

int maxExhibitsForDuration(int? durationMinutes) {
  final duration = durationMinutes ?? 45;
  if (duration <= 30) return 6;
  if (duration <= 45) return 9;
  if (duration <= 60) return 12;
  return 18;
}

enum VisitorMode { adult, student, disabledVisitor }

enum TourPace { relaxed, normal, fast }

class VisitorTicketCategory {
  final String id;
  final VisitorAudience audience;
  final VisitorAgeGroup ageGroup;
  final String labelEn;
  final String labelAr;
  final double price;
  final String currency;
  final String? eligibilityNoteEn;
  final String? eligibilityNoteAr;

  const VisitorTicketCategory({
    required this.id,
    required this.audience,
    required this.ageGroup,
    required this.labelEn,
    required this.labelAr,
    required this.price,
    required this.currency,
    this.eligibilityNoteEn,
    this.eligibilityNoteAr,
  });

  String label(String languageCode) => languageCode == 'ar' ? labelAr : labelEn;

  String? eligibilityNote(String languageCode) =>
      languageCode == 'ar' ? eligibilityNoteAr : eligibilityNoteEn;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audience': audience.name,
      'ageGroup': ageGroup.name,
      'labelEn': labelEn,
      'labelAr': labelAr,
      'price': price,
      'currency': currency,
      'eligibilityNoteEn': eligibilityNoteEn,
      'eligibilityNoteAr': eligibilityNoteAr,
    };
  }

  factory VisitorTicketCategory.fromJson(Map<String, dynamic> json) {
    return VisitorTicketCategory(
      id: json['id'] as String,
      audience: VisitorAudience.values.firstWhere(
        (value) => value.name == json['audience'],
        orElse: () => VisitorAudience.foreigner,
      ),
      ageGroup: VisitorAgeGroup.values.firstWhere(
        (value) => value.name == json['ageGroup'],
        orElse: () => VisitorAgeGroup.adult,
      ),
      labelEn: json['labelEn'] as String,
      labelAr: json['labelAr'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      eligibilityNoteEn: json['eligibilityNoteEn'] as String?,
      eligibilityNoteAr: json['eligibilityNoteAr'] as String?,
    );
  }

  static VisitorTicketCategory? fromId(String id) {
    final normalized = id.replaceAll('_', '-');
    for (final category in defaults) {
      if (category.id == normalized) return category;
    }
    return null;
  }

  static const List<VisitorTicketCategory> defaults = [
    VisitorTicketCategory(
      id: 'egyptian-adult',
      audience: VisitorAudience.egyptian,
      ageGroup: VisitorAgeGroup.adult,
      labelEn: 'Egyptian Adult',
      labelAr: '\u0645\u0635\u0631\u064a \u0628\u0627\u0644\u063a',
      price: BookingPricing.egyptianAdult,
      currency: BookingPricing.currency,
    ),
    VisitorTicketCategory(
      id: 'egyptian-student',
      audience: VisitorAudience.egyptian,
      ageGroup: VisitorAgeGroup.student,
      labelEn: 'Egyptian Student',
      labelAr: '\u0637\u0627\u0644\u0628 \u0645\u0635\u0631\u064a',
      price: BookingPricing.egyptianStudent,
      currency: BookingPricing.currency,
      eligibilityNoteEn: 'Student ID required.',
      eligibilityNoteAr:
          '\u064a\u0644\u0632\u0645 \u0625\u0628\u0631\u0627\u0632 \u0628\u0637\u0627\u0642\u0629 \u0637\u0627\u0644\u0628.',
    ),
    VisitorTicketCategory(
      id: 'egyptian-child',
      audience: VisitorAudience.egyptian,
      ageGroup: VisitorAgeGroup.child,
      labelEn: 'Egyptian Child',
      labelAr: '\u0637\u0641\u0644 \u0645\u0635\u0631\u064a',
      price: BookingPricing.egyptianChild,
      currency: BookingPricing.currency,
      eligibilityNoteEn: 'Child age verification may be required.',
      eligibilityNoteAr:
          '\u0642\u062f \u064a\u0644\u0632\u0645 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0639\u0645\u0631 \u0627\u0644\u0637\u0641\u0644.',
    ),
    VisitorTicketCategory(
      id: 'foreigner-adult',
      audience: VisitorAudience.foreigner,
      ageGroup: VisitorAgeGroup.adult,
      labelEn: 'Foreigner Adult',
      labelAr: '\u0623\u062c\u0646\u0628\u064a \u0628\u0627\u0644\u063a',
      price: BookingPricing.foreignerAdult,
      currency: BookingPricing.currency,
    ),
    VisitorTicketCategory(
      id: 'foreigner-student',
      audience: VisitorAudience.foreigner,
      ageGroup: VisitorAgeGroup.student,
      labelEn: 'Foreigner Student',
      labelAr: '\u0637\u0627\u0644\u0628 \u0623\u062c\u0646\u0628\u064a',
      price: BookingPricing.foreignerStudent,
      currency: BookingPricing.currency,
      eligibilityNoteEn: 'Student ID required.',
      eligibilityNoteAr:
          '\u064a\u0644\u0632\u0645 \u0625\u0628\u0631\u0627\u0632 \u0628\u0637\u0627\u0642\u0629 \u0637\u0627\u0644\u0628.',
    ),
    VisitorTicketCategory(
      id: 'foreigner-child',
      audience: VisitorAudience.foreigner,
      ageGroup: VisitorAgeGroup.child,
      labelEn: 'Foreigner Child',
      labelAr: '\u0637\u0641\u0644 \u0623\u062c\u0646\u0628\u064a',
      price: BookingPricing.foreignerChild,
      currency: BookingPricing.currency,
      eligibilityNoteEn: 'Child age verification may be required.',
      eligibilityNoteAr:
          '\u0642\u062f \u064a\u0644\u0632\u0645 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0639\u0645\u0631 \u0627\u0644\u0637\u0641\u0644.',
    ),
  ];
}

class MuseumTicketLineItem {
  final VisitorTicketCategory category;
  final int quantity;
  final double unitPrice;

  const MuseumTicketLineItem({
    required this.category,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  String? get eligibilityNoteEn => category.eligibilityNoteEn;
  String? get eligibilityNoteAr => category.eligibilityNoteAr;

  MuseumTicketLineItem copyWith({
    VisitorTicketCategory? category,
    int? quantity,
    double? unitPrice,
  }) {
    return MuseumTicketLineItem(
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory MuseumTicketLineItem.fromJson(Map<String, dynamic> json) {
    return MuseumTicketLineItem(
      category: VisitorTicketCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}

class StandardTourConfig {
  static const List<String> officialRouteExhibitIds = [
    'artifact_001',
    'artifact_005',
    'artifact_002',
    'artifact_006',
    'artifact_018',
    'artifact_030',
  ];

  final int durationMinutes;
  final String languageCode;
  final String? languageOther;
  final String routeName;
  final List<String> routeExhibitIds;

  const StandardTourConfig({
    required this.durationMinutes,
    required this.languageCode,
    this.languageOther,
    required this.routeName,
    required this.routeExhibitIds,
  });

  StandardTourConfig copyWith({
    int? durationMinutes,
    String? languageCode,
    String? languageOther,
    String? routeName,
    List<String>? routeExhibitIds,
  }) {
    return StandardTourConfig(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      languageCode: languageCode ?? this.languageCode,
      languageOther: languageOther ?? this.languageOther,
      routeName: routeName ?? this.routeName,
      routeExhibitIds: routeExhibitIds ?? this.routeExhibitIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'languageCode': languageCode,
      'languageOther': languageOther,
      'routeName': routeName,
      'routeExhibitIds': routeExhibitIds,
    };
  }

  factory StandardTourConfig.fromJson(Map<String, dynamic> json) {
    return StandardTourConfig(
      durationMinutes: _intValue(json['durationMinutes']) ?? 45,
      languageCode: _normalizeLanguage(json['languageCode']) ?? 'english',
      languageOther: _stringValue(
        json['languageOther'] ?? json['preferred_language_other'],
      ),
      routeName: json['routeName'] as String? ?? defaultConfig.routeName,
      routeExhibitIds: _stringList(json['routeExhibitIds']),
    );
  }

  static const StandardTourConfig defaultConfig = StandardTourConfig(
    durationMinutes: 45,
    languageCode: 'english',
    languageOther: null,
    routeName: 'Horus-Bot Highlights Route',
    routeExhibitIds: officialRouteExhibitIds,
  );
}

class PersonalizedTourConfig {
  final List<String> selectedExhibitIds;
  final List<String> selectedThemes;
  final int durationMinutes;
  final String languageCode;
  final String? languageOther;
  final List<String> accessibilityNeeds;
  final VisitorMode visitorMode;
  final TourPace pace;
  final bool photoSpotsEnabled;

  const PersonalizedTourConfig({
    required this.selectedExhibitIds,
    required this.selectedThemes,
    required this.durationMinutes,
    required this.languageCode,
    this.languageOther,
    required this.accessibilityNeeds,
    required this.visitorMode,
    required this.pace,
    required this.photoSpotsEnabled,
  });

  PersonalizedTourConfig copyWith({
    List<String>? selectedExhibitIds,
    List<String>? selectedThemes,
    int? durationMinutes,
    String? languageCode,
    String? languageOther,
    List<String>? accessibilityNeeds,
    VisitorMode? visitorMode,
    TourPace? pace,
    bool? photoSpotsEnabled,
  }) {
    return PersonalizedTourConfig(
      selectedExhibitIds: selectedExhibitIds ?? this.selectedExhibitIds,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      languageCode: languageCode ?? this.languageCode,
      languageOther: languageOther ?? this.languageOther,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      visitorMode: visitorMode ?? this.visitorMode,
      pace: pace ?? this.pace,
      photoSpotsEnabled: photoSpotsEnabled ?? this.photoSpotsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedExhibitIds': selectedExhibitIds,
      'selectedThemes': selectedThemes,
      'durationMinutes': durationMinutes,
      'languageCode': languageCode,
      'languageOther': languageOther,
      'accessibilityNeeds': accessibilityNeeds,
      'visitorMode': visitorMode.name,
      'pace': pace.name,
      'photoSpotsEnabled': photoSpotsEnabled,
    };
  }

  factory PersonalizedTourConfig.fromJson(Map<String, dynamic> json) {
    return PersonalizedTourConfig(
      selectedExhibitIds: _stringList(json['selectedExhibitIds']),
      selectedThemes: _stringList(json['selectedThemes']),
      durationMinutes: _intValue(json['durationMinutes']) ?? 45,
      languageCode: _normalizeLanguage(json['languageCode']) ?? 'english',
      languageOther: _stringValue(
        json['languageOther'] ?? json['preferred_language_other'],
      ),
      accessibilityNeeds: _stringList(json['accessibilityNeeds']),
      visitorMode: VisitorMode.values.firstWhere(
        (value) => value.name == json['visitorMode'],
        orElse: () => VisitorMode.adult,
      ),
      pace: TourPace.values.firstWhere(
        (value) => value.name == json['pace'],
        orElse: () => TourPace.normal,
      ),
      photoSpotsEnabled: json['photoSpotsEnabled'] as bool? ?? false,
    );
  }

  static const PersonalizedTourConfig defaultConfig = PersonalizedTourConfig(
    selectedExhibitIds: [],
    selectedThemes: [],
    durationMinutes: 45,
    languageCode: 'english',
    languageOther: null,
    accessibilityNeeds: [],
    visitorMode: VisitorMode.adult,
    pace: TourPace.normal,
    photoSpotsEnabled: false,
  );
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String> _stringList(Object? value) {
  if (value is List) return value.whereType<String>().toList();
  return const [];
}

String? _normalizeLanguage(Object? value) {
  return TourNarrationLanguage.normalize(value?.toString());
}

String? _stringValue(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

class TicketOrderDraft {
  final DateTime visitDate;
  final String timeSlot;
  final List<MuseumTicketLineItem> museumLineItems;
  final RobotTourType robotTourType;
  final StandardTourConfig? standardTourConfig;
  final PersonalizedTourConfig? personalizedTourConfig;
  final String? recommendedRouteId;
  final String? recommendedRouteTitleEn;
  final String? recommendedRouteTitleAr;

  const TicketOrderDraft({
    required this.visitDate,
    required this.timeSlot,
    required this.museumLineItems,
    required this.robotTourType,
    this.standardTourConfig,
    this.personalizedTourConfig,
    this.recommendedRouteId,
    this.recommendedRouteTitleEn,
    this.recommendedRouteTitleAr,
  });

  double get museumSubtotal =>
      museumLineItems.fold(0, (total, item) => total + item.subtotal);

  int get visitorCount =>
      museumLineItems.fold(0, (total, item) => total + item.quantity);

  bool get hasMuseumEntry => visitorCount > 0;

  bool get isWithinVisitorLimit =>
      visitorCount <= BookingPricing.maxVisitorsPerBooking;

  DateTime? get visitStartsAt => visitDateTimeFromParts(visitDate, timeSlot);

  bool isVisitTimeFuture([DateTime? now]) {
    final startsAt = visitStartsAt;
    return startsAt != null && startsAt.isAfter(now ?? DateTime.now());
  }

  bool get hasRobotTour => robotTourType != RobotTourType.none;

  double get robotTourSubtotal {
    switch (robotTourType) {
      case RobotTourType.none:
        return 0;
      case RobotTourType.standard:
        return BookingPricing.standardRobotTour;
      case RobotTourType.personalized:
        return BookingPricing.personalizedRobotTour;
    }
  }

  double get total => museumSubtotal + robotTourSubtotal;

  TicketOrderDraft copyWith({
    DateTime? visitDate,
    String? timeSlot,
    List<MuseumTicketLineItem>? museumLineItems,
    RobotTourType? robotTourType,
    StandardTourConfig? standardTourConfig,
    PersonalizedTourConfig? personalizedTourConfig,
    String? recommendedRouteId,
    String? recommendedRouteTitleEn,
    String? recommendedRouteTitleAr,
    bool clearRecommendedRoute = false,
  }) {
    return TicketOrderDraft(
      visitDate: visitDate ?? this.visitDate,
      timeSlot: timeSlot ?? this.timeSlot,
      museumLineItems: museumLineItems ?? this.museumLineItems,
      robotTourType: robotTourType ?? this.robotTourType,
      standardTourConfig: standardTourConfig ?? this.standardTourConfig,
      personalizedTourConfig:
          personalizedTourConfig ?? this.personalizedTourConfig,
      recommendedRouteId: clearRecommendedRoute
          ? null
          : recommendedRouteId ?? this.recommendedRouteId,
      recommendedRouteTitleEn: clearRecommendedRoute
          ? null
          : recommendedRouteTitleEn ?? this.recommendedRouteTitleEn,
      recommendedRouteTitleAr: clearRecommendedRoute
          ? null
          : recommendedRouteTitleAr ?? this.recommendedRouteTitleAr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitDate': visitDate.toIso8601String(),
      'timeSlot': timeSlot,
      'museumLineItems': museumLineItems.map((item) => item.toJson()).toList(),
      'robotTourType': robotTourType.name,
      'standardTourConfig': standardTourConfig?.toJson(),
      'personalizedTourConfig': personalizedTourConfig?.toJson(),
      'recommendedRouteId': recommendedRouteId,
      'recommendedRouteTitleEn': recommendedRouteTitleEn,
      'recommendedRouteTitleAr': recommendedRouteTitleAr,
      'museumSubtotal': museumSubtotal,
      'robotTourSubtotal': robotTourSubtotal,
      'total': total,
    };
  }

  factory TicketOrderDraft.fromJson(Map<String, dynamic> json) {
    return TicketOrderDraft(
      visitDate: DateTime.parse(json['visitDate'] as String),
      timeSlot: json['timeSlot'] as String,
      museumLineItems: (json['museumLineItems'] as List)
          .map(
            (item) =>
                MuseumTicketLineItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      robotTourType: RobotTourType.values.firstWhere(
        (value) => value.name == json['robotTourType'],
        orElse: () => RobotTourType.standard,
      ),
      standardTourConfig: json['standardTourConfig'] == null
          ? null
          : StandardTourConfig.fromJson(
              json['standardTourConfig'] as Map<String, dynamic>,
            ),
      personalizedTourConfig: json['personalizedTourConfig'] == null
          ? null
          : PersonalizedTourConfig.fromJson(
              json['personalizedTourConfig'] as Map<String, dynamic>,
            ),
      recommendedRouteId: json['recommendedRouteId'] as String?,
      recommendedRouteTitleEn: json['recommendedRouteTitleEn'] as String?,
      recommendedRouteTitleAr: json['recommendedRouteTitleAr'] as String?,
    );
  }

  static TicketOrderDraft initial() {
    return TicketOrderDraft(
      visitDate: DateTime.now(),
      timeSlot: '11:00',
      museumLineItems: const [],
      robotTourType: RobotTourType.standard,
      standardTourConfig: StandardTourConfig.defaultConfig,
      personalizedTourConfig: PersonalizedTourConfig.defaultConfig,
    );
  }
}

DateTime? visitDateTimeFromParts(DateTime date, String timeSlot) {
  final time = timeFromSlot(timeSlot);
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.$1, time.$2);
}

(int, int)? timeFromSlot(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return null;
  final start = raw.contains(' - ') ? raw.split(' - ').first.trim() : raw;
  final normalized = start.toUpperCase();
  final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(normalized);
  if (amPm != null) {
    var hour = int.parse(amPm.group(1)!);
    final minute = int.parse(amPm.group(2)!);
    final period = amPm.group(3)!;
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return (hour, minute);
  }
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(start);
  if (match == null) return null;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

class PurchasedTicketSet {
  final String id;
  final String userId;
  final MuseumTicket? museumTicket;
  final RobotTourTicket? robotTourTicket;
  final PaymentRecord paymentRecord;
  final DateTime purchasedAt;
  final double totalAmount;

  const PurchasedTicketSet({
    required this.id,
    required this.userId,
    required this.museumTicket,
    required this.robotTourTicket,
    required this.paymentRecord,
    required this.purchasedAt,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'museumTicket': museumTicket?.toJson(),
      'robotTourTicket': robotTourTicket?.toJson(),
      'paymentRecord': paymentRecord.toJson(),
      'purchasedAt': purchasedAt.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }
}

enum TicketSetDisplayStatus {
  active,
  paired,
  inProgress,
  completed,
  used,
  cancelled,
  expired,
  pending,
  partial,
}

TicketSetDisplayStatus deriveTicketSetDisplayStatus(PurchasedTicketSet set) {
  final museumStatus = set.museumTicket?.status;
  final robotStatus = set.robotTourTicket?.status;

  if (_isClosedTicketStatus(museumStatus) ||
      _isClosedTicketStatus(robotStatus)) {
    return TicketSetDisplayStatus.cancelled;
  }
  if (museumStatus == TicketStatus.expired ||
      robotStatus == TicketStatus.expired) {
    return TicketSetDisplayStatus.expired;
  }
  if (robotStatus == TicketStatus.in_progress) {
    return TicketSetDisplayStatus.inProgress;
  }
  if (robotStatus == TicketStatus.paired) {
    return TicketSetDisplayStatus.paired;
  }
  if (robotStatus == TicketStatus.completed) {
    return TicketSetDisplayStatus.completed;
  }
  if (museumStatus == TicketStatus.used) {
    return TicketSetDisplayStatus.used;
  }
  if (_isTicketSetVisitExpired(set)) {
    return TicketSetDisplayStatus.expired;
  }
  if (museumStatus == TicketStatus.active &&
      robotStatus == TicketStatus.active) {
    return TicketSetDisplayStatus.active;
  }
  if (museumStatus == TicketStatus.pending ||
      robotStatus == TicketStatus.pending) {
    return TicketSetDisplayStatus.pending;
  }

  return TicketSetDisplayStatus.partial;
}

bool _isTicketSetVisitExpired(PurchasedTicketSet set) {
  final museumTicket = set.museumTicket;
  final robotTicket = set.robotTourTicket;
  if (museumTicket?.status != TicketStatus.active &&
      robotTicket?.status != TicketStatus.active) {
    return false;
  }
  final date = museumTicket?.visitDate ?? robotTicket?.visitDate;
  if (date == null) return false;
  final slot = museumTicket?.timeSlot ?? robotTicket?.timeSlot ?? '';
  final startsAt =
      visitDateTimeFromParts(date, slot) ??
      DateTime(date.year, date.month, date.day);
  return DateTime.now().isAfter(startsAt);
}

bool _isClosedTicketStatus(TicketStatus? status) {
  return status == TicketStatus.cancelled ||
      status == TicketStatus.declined ||
      status == TicketStatus.archived ||
      status == TicketStatus.inactive;
}

int ticketSetStatusPriority(TicketSetDisplayStatus status) {
  switch (status) {
    case TicketSetDisplayStatus.active:
      return 1;
    case TicketSetDisplayStatus.paired:
      return 2;
    case TicketSetDisplayStatus.inProgress:
      return 3;
    case TicketSetDisplayStatus.completed:
    case TicketSetDisplayStatus.used:
      return 4;
    case TicketSetDisplayStatus.cancelled:
    case TicketSetDisplayStatus.expired:
      return 5;
    case TicketSetDisplayStatus.pending:
    case TicketSetDisplayStatus.partial:
      return 6;
  }
}

int comparePurchasedTicketSets(PurchasedTicketSet a, PurchasedTicketSet b) {
  final priorityDiff =
      ticketSetStatusPriority(deriveTicketSetDisplayStatus(a)) -
      ticketSetStatusPriority(deriveTicketSetDisplayStatus(b));
  if (priorityDiff != 0) return priorityDiff;
  return b.purchasedAt.compareTo(a.purchasedAt);
}
