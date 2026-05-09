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
      'selectedInterests': selectedInterests,
      'selectedArtifactIds': selectedArtifactIds,
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
      selectedInterests: json['selectedInterests'] != null
          ? List<String>.from(json['selectedInterests'] as List)
          : null,
      selectedArtifactIds: json['selectedArtifactIds'] != null
          ? List<String>.from(json['selectedArtifactIds'] as List)
          : null,
    );
  }
}
