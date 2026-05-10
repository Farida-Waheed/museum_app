import 'package:cloud_firestore/cloud_firestore.dart';

import 'ticket_order.dart';

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
  final List<MuseumTicketLineItem> lineItems;
  final String? orderId;
  final String? robotTourTicketId;

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
    this.lineItems = const [],
    this.orderId,
    this.robotTourTicketId,
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
    List<MuseumTicketLineItem>? lineItems,
    String? orderId,
    String? robotTourTicketId,
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
      lineItems: lineItems ?? this.lineItems,
      orderId: orderId ?? this.orderId,
      robotTourTicketId: robotTourTicketId ?? this.robotTourTicketId,
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
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'orderId': orderId,
      'robotTourTicketId': robotTourTicketId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'museum_name': museumName,
      'visit_date': _dateOnly(visitDate),
      'visit_time': timeSlot,
      'visitor_count': visitorCount,
      'total_tickets': visitorCount,
      'price': price,
      'total_price': price,
      'currency': currency,
      'qr_value': qrCodeValue,
      'qrCodeValue': qrCodeValue,
      'status': status.name,
      'purchased_at': Timestamp.fromDate(purchasedAt),
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'orderId': orderId,
      'robot_tour_ticket_id': robotTourTicketId,
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
      lineItems: json['lineItems'] == null
          ? const []
          : (json['lineItems'] as List)
                .map(
                  (item) => MuseumTicketLineItem.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      orderId: json['orderId'] as String?,
      robotTourTicketId: json['robotTourTicketId'] as String?,
    );
  }

  factory MuseumTicket.fromFirestore(String docId, Map<String, dynamic> json) {
    final lineItems = _lineItemsFromFirestore(json);
    final visitorCount =
        _intValue(json['visitorCount']) ??
        _intValue(json['visitor_count']) ??
        _intValue(json['total_tickets']) ??
        lineItems.fold<int>(0, (total, item) => total + item.quantity);
    final price =
        _doubleValue(json['price']) ??
        _doubleValue(json['total_price']) ??
        lineItems.fold<double>(0.0, (total, item) => total + item.subtotal);

    return MuseumTicket(
      id: _stringValue(json['id']) ?? docId,
      userId: _stringValue(json['userId']) ?? '',
      museumName:
          _stringValue(json['museumName']) ??
          _stringValue(json['museum_name']) ??
          'Egyptian Museum',
      visitDate:
          _dateValue(json['visitDate']) ??
          _dateValue(json['visit_date']) ??
          DateTime.now(),
      timeSlot:
          _stringValue(json['timeSlot']) ??
          _stringValue(json['visit_time']) ??
          'Time not selected',
      visitorCount: visitorCount,
      price: price,
      currency: _stringValue(json['currency']) ?? 'EGP',
      qrCodeValue:
          _stringValue(json['qrCodeValue']) ??
          _stringValue(json['qr_value']) ??
          docId,
      status: _statusValue(json['status']),
      purchasedAt:
          _dateValue(json['purchasedAt']) ??
          _dateValue(json['purchased_at']) ??
          _dateValue(json['created_at']) ??
          DateTime.now(),
      lineItems: lineItems,
      orderId: _stringValue(json['orderId']) ?? _stringValue(json['order_id']),
      robotTourTicketId:
          _stringValue(json['robotTourTicketId']) ??
          _stringValue(json['robot_tour_ticket_id']),
    );
  }

  static List<MuseumTicketLineItem> _lineItemsFromFirestore(
    Map<String, dynamic> json,
  ) {
    final lineItems = json['lineItems'] ?? json['line_items'];
    if (lineItems is List) {
      return lineItems
          .whereType<Map>()
          .map(
            (item) =>
                MuseumTicketLineItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final ticketTypes = json['ticket_types'];
    if (ticketTypes is Map) {
      return ticketTypes.entries
          .map((entry) {
            final category = VisitorTicketCategory.fromId(
              entry.key.toString().replaceAll('_', '-'),
            );
            final quantity = _intValue(entry.value) ?? 0;
            if (category == null || quantity <= 0) return null;
            return MuseumTicketLineItem(
              category: category,
              quantity: quantity,
              unitPrice: category.price,
            );
          })
          .whereType<MuseumTicketLineItem>()
          .toList();
    }

    return const [];
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

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static TicketStatus _statusValue(Object? value) {
    final status = value?.toString();
    return TicketStatus.values.firstWhere(
      (entry) => entry.name == status,
      orElse: () => TicketStatus.active,
    );
  }
}
