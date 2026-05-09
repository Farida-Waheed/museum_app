import 'museum_ticket.dart';
import 'payment_record.dart';
import 'robot_tour_ticket.dart';

enum VisitorAudience { egyptian, foreigner }

enum VisitorAgeGroup { adult, student, child }

enum RobotTourType { none, standard, personalized }

enum VisitorMode { adult, student, kidsFamily, disabledVisitor }

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

  static const List<VisitorTicketCategory> defaults = [
    VisitorTicketCategory(
      id: 'egyptian-adult',
      audience: VisitorAudience.egyptian,
      ageGroup: VisitorAgeGroup.adult,
      labelEn: 'Egyptian Adult',
      labelAr: '\u0645\u0635\u0631\u064a \u0628\u0627\u0644\u063a',
      price: 5,
      currency: 'USD',
    ),
    VisitorTicketCategory(
      id: 'egyptian-student',
      audience: VisitorAudience.egyptian,
      ageGroup: VisitorAgeGroup.student,
      labelEn: 'Egyptian Student',
      labelAr: '\u0637\u0627\u0644\u0628 \u0645\u0635\u0631\u064a',
      price: 3,
      currency: 'USD',
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
      price: 2,
      currency: 'USD',
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
      price: 20,
      currency: 'USD',
    ),
    VisitorTicketCategory(
      id: 'foreigner-student',
      audience: VisitorAudience.foreigner,
      ageGroup: VisitorAgeGroup.student,
      labelEn: 'Foreigner Student',
      labelAr: '\u0637\u0627\u0644\u0628 \u0623\u062c\u0646\u0628\u064a',
      price: 12,
      currency: 'USD',
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
      price: 8,
      currency: 'USD',
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
  final int durationMinutes;
  final String languageCode;
  final String routeName;
  final List<String> routeExhibitIds;

  const StandardTourConfig({
    required this.durationMinutes,
    required this.languageCode,
    required this.routeName,
    required this.routeExhibitIds,
  });

  StandardTourConfig copyWith({
    int? durationMinutes,
    String? languageCode,
    String? routeName,
    List<String>? routeExhibitIds,
  }) {
    return StandardTourConfig(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      languageCode: languageCode ?? this.languageCode,
      routeName: routeName ?? this.routeName,
      routeExhibitIds: routeExhibitIds ?? this.routeExhibitIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'languageCode': languageCode,
      'routeName': routeName,
      'routeExhibitIds': routeExhibitIds,
    };
  }

  factory StandardTourConfig.fromJson(Map<String, dynamic> json) {
    return StandardTourConfig(
      durationMinutes: json['durationMinutes'] as int,
      languageCode: json['languageCode'] as String,
      routeName: json['routeName'] as String,
      routeExhibitIds: List<String>.from(json['routeExhibitIds'] as List),
    );
  }

  static const StandardTourConfig defaultConfig = StandardTourConfig(
    durationMinutes: 90,
    languageCode: 'en',
    routeName: 'Horus-Bot Highlights Route',
    routeExhibitIds: [
      'tutankhamun_mask',
      'royal_mummies',
      'ancient_tools',
      'grand_statue',
    ],
  );
}

class PersonalizedTourConfig {
  final List<String> selectedExhibitIds;
  final List<String> selectedThemes;
  final int durationMinutes;
  final String languageCode;
  final List<String> accessibilityNeeds;
  final VisitorMode visitorMode;
  final TourPace pace;
  final bool photoSpotsEnabled;
  final bool avoidCrowds;

  const PersonalizedTourConfig({
    required this.selectedExhibitIds,
    required this.selectedThemes,
    required this.durationMinutes,
    required this.languageCode,
    required this.accessibilityNeeds,
    required this.visitorMode,
    required this.pace,
    required this.photoSpotsEnabled,
    required this.avoidCrowds,
  });

  PersonalizedTourConfig copyWith({
    List<String>? selectedExhibitIds,
    List<String>? selectedThemes,
    int? durationMinutes,
    String? languageCode,
    List<String>? accessibilityNeeds,
    VisitorMode? visitorMode,
    TourPace? pace,
    bool? photoSpotsEnabled,
    bool? avoidCrowds,
  }) {
    return PersonalizedTourConfig(
      selectedExhibitIds: selectedExhibitIds ?? this.selectedExhibitIds,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      languageCode: languageCode ?? this.languageCode,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      visitorMode: visitorMode ?? this.visitorMode,
      pace: pace ?? this.pace,
      photoSpotsEnabled: photoSpotsEnabled ?? this.photoSpotsEnabled,
      avoidCrowds: avoidCrowds ?? this.avoidCrowds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedExhibitIds': selectedExhibitIds,
      'selectedThemes': selectedThemes,
      'durationMinutes': durationMinutes,
      'languageCode': languageCode,
      'accessibilityNeeds': accessibilityNeeds,
      'visitorMode': visitorMode.name,
      'pace': pace.name,
      'photoSpotsEnabled': photoSpotsEnabled,
      'avoidCrowds': avoidCrowds,
    };
  }

  factory PersonalizedTourConfig.fromJson(Map<String, dynamic> json) {
    return PersonalizedTourConfig(
      selectedExhibitIds: List<String>.from(json['selectedExhibitIds'] as List),
      selectedThemes: List<String>.from(json['selectedThemes'] as List),
      durationMinutes: json['durationMinutes'] as int,
      languageCode: json['languageCode'] as String,
      accessibilityNeeds: List<String>.from(json['accessibilityNeeds'] as List),
      visitorMode: VisitorMode.values.firstWhere(
        (value) => value.name == json['visitorMode'],
        orElse: () => VisitorMode.adult,
      ),
      pace: TourPace.values.firstWhere(
        (value) => value.name == json['pace'],
        orElse: () => TourPace.normal,
      ),
      photoSpotsEnabled: json['photoSpotsEnabled'] as bool,
      avoidCrowds: json['avoidCrowds'] as bool,
    );
  }

  static const PersonalizedTourConfig defaultConfig = PersonalizedTourConfig(
    selectedExhibitIds: [],
    selectedThemes: [],
    durationMinutes: 90,
    languageCode: 'en',
    accessibilityNeeds: [],
    visitorMode: VisitorMode.adult,
    pace: TourPace.normal,
    photoSpotsEnabled: true,
    avoidCrowds: false,
  );
}

class TicketOrderDraft {
  final DateTime visitDate;
  final String timeSlot;
  final List<MuseumTicketLineItem> museumLineItems;
  final RobotTourType robotTourType;
  final StandardTourConfig? standardTourConfig;
  final PersonalizedTourConfig? personalizedTourConfig;

  const TicketOrderDraft({
    required this.visitDate,
    required this.timeSlot,
    required this.museumLineItems,
    required this.robotTourType,
    this.standardTourConfig,
    this.personalizedTourConfig,
  });

  double get museumSubtotal =>
      museumLineItems.fold(0, (total, item) => total + item.subtotal);

  int get visitorCount =>
      museumLineItems.fold(0, (total, item) => total + item.quantity);

  bool get hasMuseumEntry => visitorCount > 0;

  bool get hasRobotTour => robotTourType != RobotTourType.none;

  double get robotTourSubtotal {
    switch (robotTourType) {
      case RobotTourType.none:
        return 0;
      case RobotTourType.standard:
        return 35;
      case RobotTourType.personalized:
        return 50;
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
  }) {
    return TicketOrderDraft(
      visitDate: visitDate ?? this.visitDate,
      timeSlot: timeSlot ?? this.timeSlot,
      museumLineItems: museumLineItems ?? this.museumLineItems,
      robotTourType: robotTourType ?? this.robotTourType,
      standardTourConfig: standardTourConfig ?? this.standardTourConfig,
      personalizedTourConfig:
          personalizedTourConfig ?? this.personalizedTourConfig,
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
        orElse: () => RobotTourType.none,
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
    );
  }

  static TicketOrderDraft initial() {
    return TicketOrderDraft(
      visitDate: DateTime.now(),
      timeSlot: '10:00 AM - 12:00 PM',
      museumLineItems: const [],
      robotTourType: RobotTourType.none,
      standardTourConfig: StandardTourConfig.defaultConfig,
      personalizedTourConfig: PersonalizedTourConfig.defaultConfig,
    );
  }
}

class PurchasedTicketSet {
  final String id;
  final String userId;
  final MuseumTicket? museumTicket;
  final RobotTourTicket? robotTourTicket;
  final PaymentRecord paymentRecord;
  final DateTime purchasedAt;

  const PurchasedTicketSet({
    required this.id,
    required this.userId,
    required this.museumTicket,
    required this.robotTourTicket,
    required this.paymentRecord,
    required this.purchasedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'museumTicket': museumTicket?.toJson(),
      'robotTourTicket': robotTourTicket?.toJson(),
      'paymentRecord': paymentRecord.toJson(),
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }
}
