import 'package:flutter/material.dart';
import 'museum_ticket.dart';
import 'robot_tour_ticket.dart';
import 'tour_package.dart';
import 'payment_record.dart';

/// Provider for managing user tickets and payments
class TicketProvider with ChangeNotifier {
  // Mock data storage (in real app, this would be API calls)
  final List<MuseumTicket> _museumTickets = [];
  final List<RobotTourTicket> _robotTourTickets = [];
  final List<PaymentRecord> _payments = [];

  // Getters
  List<MuseumTicket> get museumTickets => List.unmodifiable(_museumTickets);
  List<RobotTourTicket> get robotTourTickets =>
      List.unmodifiable(_robotTourTickets);
  List<PaymentRecord> get payments => List.unmodifiable(_payments);

  // Computed getters
  bool get hasMuseumTicket =>
      _museumTickets.any((t) => t.status == TicketStatus.active);
  bool get hasRobotTourTicket =>
      _robotTourTickets.any((t) => t.status == TicketStatus.active);
  bool get hasTickets => hasMuseumTicket || hasRobotTourTicket;

  MuseumTicket? get latestMuseumTicket {
    if (_museumTickets.isEmpty) return null;
    return _museumTickets.reduce(
      (a, b) => a.purchasedAt.isAfter(b.purchasedAt) ? a : b,
    );
  }

  RobotTourTicket? get latestRobotTourTicket {
    if (_robotTourTickets.isEmpty) return null;
    return _robotTourTickets.reduce(
      (a, b) => a.purchasedAt.isAfter(b.purchasedAt) ? a : b,
    );
  }

  /// Buy a package for a user
  /// Creates appropriate tickets and payment record
  void buyPackage({
    required String userId,
    required TourPackage package,
    required DateTime visitDate,
    required String timeSlot,
    required int visitorCount,
  }) {
    final now = DateTime.now();
    final ticketIds = <String>[];

    // Create museum ticket if package includes it
    if (package.includesMuseumEntry) {
      final museumTicket = MuseumTicket(
        id: 'MT-${now.millisecondsSinceEpoch}',
        userId: userId,
        museumName: 'Egyptian Museum',
        visitDate: visitDate,
        timeSlot: timeSlot,
        visitorCount: visitorCount,
        price: package
            .price, // For bundle, full price; for entry-only, entry price
        currency: package.currency,
        qrCodeValue: 'TKT-MUSEUM-MT-${now.millisecondsSinceEpoch}',
        status: TicketStatus.active,
        purchasedAt: now,
      );
      _museumTickets.add(museumTicket);
      ticketIds.add(museumTicket.id);
    }

    // Create robot tour ticket if package includes it
    if (package.includesRobotTour) {
      final robotTicket = RobotTourTicket(
        id: 'RT-${now.millisecondsSinceEpoch}',
        userId: userId,
        packageId: package.id,
        packageName: package.name,
        durationMinutes: package.durationMinutes,
        languageCode: 'en', // Default to English
        includedFeatures: package.includedFeatures,
        price: package.includesMuseumEntry
            ? 0
            : package.price, // If bundle, robot is free
        currency: package.currency,
        status: TicketStatus.active,
        purchasedAt: now,
      );
      _robotTourTickets.add(robotTicket);
      ticketIds.add(robotTicket.id);
    }

    // Create payment record
    final payment = PaymentRecord(
      id: 'PAY-${now.millisecondsSinceEpoch}',
      userId: userId,
      amount: package.price,
      currency: package.currency,
      label: package.name,
      date: now,
      status: 'completed',
      relatedTicketIds: ticketIds,
    );
    _payments.add(payment);

    notifyListeners();
  }

  /// Clear all tickets for a user (e.g., on logout)
  void clearUserTickets(String userId) {
    _museumTickets.removeWhere((t) => t.userId == userId);
    _robotTourTickets.removeWhere((t) => t.userId == userId);
    _payments.removeWhere((p) => p.userId == userId);
    notifyListeners();
  }

  /// Load mock tickets for a user (for development)
  void loadMockUserTickets(String userId) {
    // Clear existing
    clearUserTickets(userId);

    // Add some mock tickets
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Mock museum ticket
    final museumTicket = MuseumTicket(
      id: 'MT-MOCK-001',
      userId: userId,
      museumName: 'Egyptian Museum',
      visitDate: tomorrow,
      timeSlot: '10:00 AM - 12:00 PM',
      visitorCount: 2,
      price: 40.0,
      currency: 'USD',
      qrCodeValue: 'TKT-MUSEUM-MT-MOCK-001',
      status: TicketStatus.active,
      purchasedAt: now.subtract(const Duration(hours: 2)),
    );
    _museumTickets.add(museumTicket);

    // Mock robot tour ticket
    final robotTicket = RobotTourTicket(
      id: 'RT-MOCK-001',
      userId: userId,
      packageId: 'robot-tour-only',
      packageName: 'Horus-Bot Guided Tour',
      durationMinutes: 90,
      languageCode: 'en',
      includedFeatures: [
        'Personal robot guide',
        'Interactive storytelling',
        'Photo opportunities',
      ],
      price: 35.0,
      currency: 'USD',
      status: TicketStatus.active,
      purchasedAt: now.subtract(const Duration(hours: 1)),
    );
    _robotTourTickets.add(robotTicket);

    // Mock payment
    final payment = PaymentRecord(
      id: 'PAY-MOCK-001',
      userId: userId,
      amount: 75.0,
      currency: 'USD',
      label: 'Complete Experience Bundle',
      date: now.subtract(const Duration(hours: 2)),
      status: 'completed',
      relatedTicketIds: [museumTicket.id, robotTicket.id],
    );
    _payments.add(payment);

    notifyListeners();
  }
}
