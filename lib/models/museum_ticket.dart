/// Status of a museum ticket
enum TicketStatus { pending, active, used, expired, cancelled }

/// Museum entry ticket model
class MuseumTicket {
  final String id;
  final String userId;
  final String museumName;
  final DateTime visitDate;
  final String timeSlot;
  final int visitorCount;
  final double price;
  final String currency;
  final String qrCodeValue;
  final TicketStatus status;
  final DateTime purchasedAt;

  const MuseumTicket({
    required this.id,
    required this.userId,
    required this.museumName,
    required this.visitDate,
    required this.timeSlot,
    required this.visitorCount,
    required this.price,
    required this.currency,
    required this.qrCodeValue,
    required this.status,
    required this.purchasedAt,
  });

  /// Create a copy with optional field overrides
  MuseumTicket copyWith({
    String? id,
    String? userId,
    String? museumName,
    DateTime? visitDate,
    String? timeSlot,
    int? visitorCount,
    double? price,
    String? currency,
    String? qrCodeValue,
    TicketStatus? status,
    DateTime? purchasedAt,
  }) {
    return MuseumTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      museumName: museumName ?? this.museumName,
      visitDate: visitDate ?? this.visitDate,
      timeSlot: timeSlot ?? this.timeSlot,
      visitorCount: visitorCount ?? this.visitorCount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'museumName': museumName,
      'visitDate': visitDate.toIso8601String(),
      'timeSlot': timeSlot,
      'visitorCount': visitorCount,
      'price': price,
      'currency': currency,
      'qrCodeValue': qrCodeValue,
      'status': status.name,
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MuseumTicket.fromJson(Map<String, dynamic> json) {
    return MuseumTicket(
      id: json['id'] as String,
      userId: json['userId'] as String,
      museumName: json['museumName'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      timeSlot: json['timeSlot'] as String,
      visitorCount: json['visitorCount'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      qrCodeValue: json['qrCodeValue'] as String,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.pending,
      ),
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
    );
  }
}
