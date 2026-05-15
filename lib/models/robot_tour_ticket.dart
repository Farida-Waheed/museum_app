import 'package:cloud_firestore/cloud_firestore.dart';

import 'museum_ticket.dart';
import 'ticket_order.dart';

/// Robot guided tour ticket model
class RobotTourTicket {
  final String id;
  final String userId;
  final String packageId;
  final String packageName;
  final int durationMinutes;
  final String languageCode;
  final List<String> includedFeatures;
  final double price;
  final String currency;
  final TicketStatus status;
  final DateTime purchasedAt;
  final RobotTourType tourType;
  final StandardTourConfig? standardTourConfig;
  final PersonalizedTourConfig? personalizedTourConfig;
  final DateTime? visitDate;
  final String? timeSlot;
  final String? museumTicketId;
  final String? orderId;
  final String? bookingId;
  final String? bookingSource;
  final String? qrCodeValue;

  // Optional for future extension
  final List<String>? selectedInterests;
  final List<String>? selectedArtifactIds;

  const RobotTourTicket({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.durationMinutes,
    required this.languageCode,
    required this.includedFeatures,
    required this.price,
    required this.currency,
    required this.status,
    required this.purchasedAt,
    this.tourType = RobotTourType.standard,
    this.standardTourConfig,
    this.personalizedTourConfig,
    this.visitDate,
    this.timeSlot,
    this.museumTicketId,
    this.orderId,
    this.bookingId,
    this.bookingSource,
    this.qrCodeValue,
    this.selectedInterests,
    this.selectedArtifactIds,
  });

  /// Create a copy with optional field overrides
  RobotTourTicket copyWith({
    String? id,
    String? userId,
    String? packageId,
    String? packageName,
    int? durationMinutes,
    String? languageCode,
    List<String>? includedFeatures,
    double? price,
    String? currency,
    TicketStatus? status,
    DateTime? purchasedAt,
    RobotTourType? tourType,
    StandardTourConfig? standardTourConfig,
    PersonalizedTourConfig? personalizedTourConfig,
    DateTime? visitDate,
    String? timeSlot,
    String? museumTicketId,
    String? orderId,
    String? bookingId,
    String? bookingSource,
    String? qrCodeValue,
    List<String>? selectedInterests,
    List<String>? selectedArtifactIds,
  }) {
    return RobotTourTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      languageCode: languageCode ?? this.languageCode,
      includedFeatures: includedFeatures ?? this.includedFeatures,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      tourType: tourType ?? this.tourType,
      standardTourConfig: standardTourConfig ?? this.standardTourConfig,
      personalizedTourConfig:
          personalizedTourConfig ?? this.personalizedTourConfig,
      visitDate: visitDate ?? this.visitDate,
      timeSlot: timeSlot ?? this.timeSlot,
      museumTicketId: museumTicketId ?? this.museumTicketId,
      orderId: orderId ?? this.orderId,
      bookingId: bookingId ?? this.bookingId,
      bookingSource: bookingSource ?? this.bookingSource,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedArtifactIds: selectedArtifactIds ?? this.selectedArtifactIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'packageId': packageId,
      'packageName': packageName,
      'durationMinutes': durationMinutes,
      'languageCode': languageCode,
      'includedFeatures': includedFeatures,
      'price': price,
      'currency': currency,
      'status': status.name,
      'purchasedAt': purchasedAt.toIso8601String(),
      'tourType': tourType.name,
      'standardTourConfig': standardTourConfig?.toJson(),
      'personalizedTourConfig': personalizedTourConfig?.toJson(),
      'visitDate': visitDate?.toIso8601String(),
      'timeSlot': timeSlot,
      'museumTicketId': museumTicketId,
      'orderId': orderId,
      'bookingId': bookingId,
      'bookingSource': bookingSource,
      'qrCodeValue': qrCodeValue,
      'selectedInterests': selectedInterests,
      'selectedArtifactIds': selectedArtifactIds,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'museumTicketId': museumTicketId,
      'museum_ticket_id': museumTicketId,
      'packageId': packageId,
      'packageName': packageName,
      'tour_type': tourType.name,
      'tour_duration': durationMinutes,
      'durationMinutes': durationMinutes,
      'preferred_language': languageCode,
      'languageCode': languageCode,
      'includedFeatures': includedFeatures,
      'price': price,
      'currency': currency,
      'status': status.name,
      'visit_date': visitDate == null ? null : _dateOnly(visitDate!),
      'visit_time': timeSlot,
      'qr_value': qrCodeValue,
      'qrCodeValue': qrCodeValue,
      'booking_id': bookingId,
      'booking_source': bookingSource,
      'purchased_at': Timestamp.fromDate(purchasedAt),
    };
  }

  /// Create from JSON
  factory RobotTourTicket.fromJson(Map<String, dynamic> json) {
    return RobotTourTicket(
      id: json['id'] as String,
      userId: json['userId'] as String,
      packageId: json['packageId'] as String,
      packageName: json['packageName'] as String,
      durationMinutes: json['durationMinutes'] as int,
      languageCode: json['languageCode'] as String,
      includedFeatures: List<String>.from(json['includedFeatures'] as List),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.pending,
      ),
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      tourType: json['tourType'] == null
          ? RobotTourType.standard
          : RobotTourType.values.firstWhere(
              (value) => value.name == json['tourType'],
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
      visitDate: json['visitDate'] == null
          ? null
          : DateTime.parse(json['visitDate'] as String),
      timeSlot: json['timeSlot'] as String?,
      museumTicketId: json['museumTicketId'] as String?,
      orderId: json['orderId'] as String?,
      bookingId: json['bookingId'] as String? ?? json['booking_id'] as String?,
      bookingSource:
          json['bookingSource'] as String? ?? json['booking_source'] as String?,
      qrCodeValue: json['qrCodeValue'] as String?,
      selectedInterests: json['selectedInterests'] != null
          ? List<String>.from(json['selectedInterests'] as List)
          : null,
      selectedArtifactIds: json['selectedArtifactIds'] != null
          ? List<String>.from(json['selectedArtifactIds'] as List)
          : null,
    );
  }

  factory RobotTourTicket.fromFirestore(
    String docId,
    Map<String, dynamic> json,
  ) {
    final tourType = _tourTypeValue(json['tourType'] ?? json['tour_type']);
    final selectedExhibitIds = _stringList(
      json['selectedArtifactIds'] ??
          json['selected_exhibits'] ??
          json['selected_exhibit_ids'],
    );
    final interests = _stringList(
      json['selectedInterests'] ?? json['interests'],
    );
    final accessibility = _stringList(
      json['accessibilityNeeds'] ?? json['accessibility'],
    );
    final duration =
        _intValue(json['durationMinutes']) ??
        _intValue(json['tour_duration_min']) ??
        _intValue(json['tour_duration']) ??
        90;
    final language =
        _stringValue(json['languageCode']) ??
        _languageCode(_stringValue(json['preferred_language'])) ??
        'en';
    final standardConfig = _standardConfigFromFirestore(
      json,
      duration,
      language,
      selectedExhibitIds,
    );
    final personalizedConfig = _personalizedConfigFromFirestore(
      json,
      duration,
      language,
      selectedExhibitIds,
      interests,
      accessibility,
    );

    return RobotTourTicket(
      id: _stringValue(json['tourTicketId']) ?? _stringValue(json['id']) ?? docId,
      userId: _stringValue(json['userId']) ?? '',
      packageId: _stringValue(json['packageId']) ?? tourType.name,
      packageName:
          _stringValue(json['packageName']) ??
          (tourType == RobotTourType.personalized
              ? 'Personalized Horus-Bot Tour'
              : tourType == RobotTourType.none
              ? 'No Horus-Bot Tour'
              : 'Standard Horus-Bot Tour'),
      durationMinutes: duration,
      languageCode: language,
      includedFeatures: _stringList(json['includedFeatures']),
      price:
          _doubleValue(json['price']) ?? _doubleValue(json['total_price']) ?? 0,
      currency: _stringValue(json['currency']) ?? 'EGP',
      status: _statusValue(json['status']),
      purchasedAt:
          _dateValue(json['purchasedAt']) ??
          _dateValue(json['purchased_at']) ??
          _dateValue(json['created_at']) ??
          DateTime.now(),
      tourType: tourType,
      standardTourConfig: tourType == RobotTourType.standard
          ? standardConfig
          : null,
      personalizedTourConfig: tourType == RobotTourType.personalized
          ? personalizedConfig
          : null,
      visitDate:
          _dateValue(json['visitDate']) ?? _dateValue(json['visit_date']),
      timeSlot:
          _stringValue(json['timeSlot']) ?? _stringValue(json['visit_time']),
      museumTicketId:
          _stringValue(json['museumTicketId']) ??
          _stringValue(json['museum_ticket_id']),
      orderId: _stringValue(json['orderId']) ?? _stringValue(json['order_id']),
      bookingId:
          _stringValue(json['bookingId']) ?? _stringValue(json['booking_id']),
      bookingSource:
          _stringValue(json['bookingSource']) ??
          _stringValue(json['booking_source']),
      qrCodeValue:
          _stringValue(json['qrCodeValue']) ?? _stringValue(json['qr_value']),
      selectedInterests: interests,
      selectedArtifactIds: selectedExhibitIds,
    );
  }

  static StandardTourConfig _standardConfigFromFirestore(
    Map<String, dynamic> json,
    int duration,
    String language,
    List<String> selectedExhibitIds,
  ) {
    final rawConfig =
        json['standardTourConfig'] ?? json['standard_tour_config'];
    if (rawConfig is Map) {
      return StandardTourConfig.fromJson(Map<String, dynamic>.from(rawConfig));
    }

    return StandardTourConfig(
      durationMinutes: duration,
      languageCode: language,
      routeName:
          _stringValue(json['routeName']) ??
          _stringValue(json['route_name']) ??
          StandardTourConfig.defaultConfig.routeName,
      routeExhibitIds: selectedExhibitIds.isEmpty
          ? StandardTourConfig.defaultConfig.routeExhibitIds
          : selectedExhibitIds,
    );
  }

  static PersonalizedTourConfig _personalizedConfigFromFirestore(
    Map<String, dynamic> json,
    int duration,
    String language,
    List<String> selectedExhibitIds,
    List<String> interests,
    List<String> accessibility,
  ) {
    final rawConfig =
        json['personalizedTourConfig'] ?? json['personalized_tour_config'];
    if (rawConfig is Map) {
      return PersonalizedTourConfig.fromJson(
        Map<String, dynamic>.from(rawConfig),
      );
    }

    return PersonalizedTourConfig(
      selectedExhibitIds: selectedExhibitIds,
      selectedThemes: interests,
      durationMinutes: duration,
      languageCode: language,
      accessibilityNeeds: accessibility,
      visitorMode: _visitorModeValue(
        json['visitorMode'] ?? json['visitor_mode'],
      ),
      pace: _paceValue(json['pace']),
      photoSpotsEnabled:
          _boolValue(
            json['photoSpotsEnabled'] ??
                json['photo_spots_enabled'] ??
                json['photo_spots'],
          ) ??
          true,
      avoidCrowds:
          _boolValue(json['avoidCrowds'] ?? json['avoid_crowds']) ?? false,
    );
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _doubleValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  static String? _languageCode(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'english':
        return 'en';
      case 'arabic':
        return 'ar';
      default:
        return value;
    }
  }

  static TicketStatus _statusValue(Object? value) {
    final status = value?.toString();
    return TicketStatus.values.firstWhere(
      (entry) => entry.name == status,
      orElse: () => TicketStatus.active,
    );
  }

  static RobotTourType _tourTypeValue(Object? value) {
    final type = value?.toString();
    return RobotTourType.values.firstWhere(
      (entry) => entry.name == type,
      orElse: () => RobotTourType.standard,
    );
  }

  static VisitorMode _visitorModeValue(Object? value) {
    final mode = value?.toString();
    return VisitorMode.values.firstWhere(
      (entry) => entry.name == mode,
      orElse: () => VisitorMode.adult,
    );
  }

  static TourPace _paceValue(Object? value) {
    final pace = value?.toString();
    return TourPace.values.firstWhere(
      (entry) => entry.name == pace,
      orElse: () => TourPace.normal,
    );
  }
}
