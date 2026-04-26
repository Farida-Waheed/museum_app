/// Payment record for a transaction
class PaymentRecord {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String label; // e.g., "Museum Entry Ticket", "Robot Tour Package"
  final DateTime date;
  final String status; // e.g., "completed", "pending", "failed"
  final String? notes;
  final List<String> relatedTicketIds; // IDs of tickets created by this payment

  PaymentRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.label,
    required this.date,
    required this.status,
    this.notes,
    this.relatedTicketIds = const [],
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'label': label,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
      'relatedTicketIds': relatedTicketIds,
    };
  }

  /// Create from JSON
  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      label: json['label'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      relatedTicketIds: json['relatedTicketIds'] != null
          ? List<String>.from(json['relatedTicketIds'] as List)
          : [],
    );
  }
}
