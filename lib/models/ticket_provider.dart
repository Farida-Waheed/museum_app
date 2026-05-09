import 'package:flutter/material.dart';
import 'museum_ticket.dart';
import 'robot_tour_ticket.dart';
import 'tour_package.dart';
import 'payment_record.dart';
import 'ticket_order.dart';

/// Provider for managing user tickets, draft orders, and mock payments.
class TicketProvider with ChangeNotifier {
  // Mock data storage (in real app, this would be API calls)
  final List<MuseumTicket> _museumTickets = [];
  final List<RobotTourTicket> _robotTourTickets = [];
  final List<PaymentRecord> _payments = [];
  final List<PurchasedTicketSet> _purchasedTicketSets = [];

  TicketOrderDraft _currentOrderDraft = TicketOrderDraft.initial();

  // Getters
  List<MuseumTicket> get museumTickets => List.unmodifiable(_museumTickets);
  List<RobotTourTicket> get robotTourTickets =>
      List.unmodifiable(_robotTourTickets);
  List<PaymentRecord> get payments => List.unmodifiable(_payments);
  List<PurchasedTicketSet> get purchasedTicketSets =>
      List.unmodifiable(_purchasedTicketSets);
  TicketOrderDraft get currentOrderDraft => _currentOrderDraft;
  List<VisitorTicketCategory> get visitorCategories =>
      VisitorTicketCategory.defaults;

  // Computed getters
  bool get hasMuseumTicket =>
      _museumTickets.any((t) => t.status == TicketStatus.active);
  bool get hasRobotTourTicket =>
      _robotTourTickets.any((t) => t.status == TicketStatus.active);
  bool get hasTickets => hasMuseumTicket || hasRobotTourTicket;

  /// Canonical entitlement checks used across Home/Map/Live Tour and ticket flow.
  bool get hasValidMuseumEntryEntitlement => hasMuseumTicket;
  bool get hasValidRobotTourEntitlement => hasRobotTourTicket;
  bool get hasValidRobotTourEligibility =>
      hasValidMuseumEntryEntitlement && hasValidRobotTourEntitlement;

  double get museumSubtotal => _currentOrderDraft.museumSubtotal;
  double get robotTourSubtotal => _currentOrderDraft.robotTourSubtotal;
  double get orderTotal => _currentOrderDraft.total;
  int get draftVisitorCount => _currentOrderDraft.visitorCount;
  bool get canCheckoutDraft => _currentOrderDraft.hasMuseumEntry;

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

  VisitorTicketCategory? categoryById(String categoryId) {
    for (final category in VisitorTicketCategory.defaults) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  MuseumTicketLineItem? lineItemForCategory(String categoryId) {
    for (final item in _currentOrderDraft.museumLineItems) {
      if (item.category.id == categoryId) return item;
    }
    return null;
  }

  int quantityForCategory(String categoryId) =>
      lineItemForCategory(categoryId)?.quantity ?? 0;

  void resetOrderDraft() {
    _currentOrderDraft = TicketOrderDraft.initial();
    notifyListeners();
  }

  void updateVisitDate(DateTime visitDate) {
    _currentOrderDraft = _currentOrderDraft.copyWith(visitDate: visitDate);
    notifyListeners();
  }

  void updateTimeSlot(String timeSlot) {
    _currentOrderDraft = _currentOrderDraft.copyWith(timeSlot: timeSlot);
    notifyListeners();
  }

  void incrementVisitorCategory(String categoryId) {
    setVisitorCategoryQuantity(categoryId, quantityForCategory(categoryId) + 1);
  }

  void decrementVisitorCategory(String categoryId) {
    final nextQuantity = quantityForCategory(categoryId) - 1;
    setVisitorCategoryQuantity(categoryId, nextQuantity < 0 ? 0 : nextQuantity);
  }

  void setVisitorCategoryQuantity(String categoryId, int quantity) {
    final category = categoryById(categoryId);
    if (category == null) return;

    final safeQuantity = quantity < 0 ? 0 : quantity;
    final updatedItems = <MuseumTicketLineItem>[];
    var didUpdateExisting = false;

    for (final item in _currentOrderDraft.museumLineItems) {
      if (item.category.id == categoryId) {
        didUpdateExisting = true;
        if (safeQuantity > 0) {
          updatedItems.add(item.copyWith(quantity: safeQuantity));
        }
      } else {
        updatedItems.add(item);
      }
    }

    if (!didUpdateExisting && safeQuantity > 0) {
      updatedItems.add(
        MuseumTicketLineItem(
          category: category,
          quantity: safeQuantity,
          unitPrice: category.price,
        ),
      );
    }

    _currentOrderDraft = _currentOrderDraft.copyWith(
      museumLineItems: updatedItems,
    );
    notifyListeners();
  }

  void selectRobotTourType(RobotTourType tourType) {
    _currentOrderDraft = _currentOrderDraft.copyWith(
      robotTourType: tourType,
      standardTourConfig: tourType == RobotTourType.standard
          ? _currentOrderDraft.standardTourConfig ??
                StandardTourConfig.defaultConfig
          : _currentOrderDraft.standardTourConfig,
      personalizedTourConfig: tourType == RobotTourType.personalized
          ? _currentOrderDraft.personalizedTourConfig ??
                PersonalizedTourConfig.defaultConfig
          : _currentOrderDraft.personalizedTourConfig,
    );
    notifyListeners();
  }

  void updateStandardTourConfig(StandardTourConfig config) {
    _currentOrderDraft = _currentOrderDraft.copyWith(
      standardTourConfig: config,
      robotTourType: RobotTourType.standard,
    );
    notifyListeners();
  }

  void updatePersonalizedTourConfig(PersonalizedTourConfig config) {
    _currentOrderDraft = _currentOrderDraft.copyWith(
      personalizedTourConfig: config,
      robotTourType: RobotTourType.personalized,
    );
    notifyListeners();
  }

  PurchasedTicketSet? mockCheckoutFromDraft({required String userId}) {
    if (!canCheckoutDraft) return null;

    final now = DateTime.now();
    final orderId = 'ORD-${now.millisecondsSinceEpoch}';
    final ticketIds = <String>[];
    final museumTicket = _createMuseumTicketFromDraft(
      userId: userId,
      orderId: orderId,
      now: now,
    );
    _museumTickets.add(museumTicket);
    ticketIds.add(museumTicket.id);

    RobotTourTicket? robotTicket;
    if (_currentOrderDraft.hasRobotTour) {
      robotTicket = _createRobotTourTicketFromDraft(
        userId: userId,
        orderId: orderId,
        museumTicketId: museumTicket.id,
        now: now,
      );
      _robotTourTickets.add(robotTicket);
      ticketIds.add(robotTicket.id);
    }

    final payment = PaymentRecord(
      id: 'PAY-${now.millisecondsSinceEpoch}',
      userId: userId,
      amount: _currentOrderDraft.total,
      currency: 'USD',
      label: _paymentLabelForDraft(),
      date: now,
      status: 'completed',
      relatedTicketIds: ticketIds,
    );
    _payments.add(payment);

    final purchasedSet = PurchasedTicketSet(
      id: orderId,
      userId: userId,
      museumTicket: museumTicket,
      robotTourTicket: robotTicket,
      paymentRecord: payment,
      purchasedAt: now,
    );
    _purchasedTicketSets.add(purchasedSet);
    resetOrderDraft();
    return purchasedSet;
  }

  MuseumTicket _createMuseumTicketFromDraft({
    required String userId,
    required String orderId,
    required DateTime now,
  }) {
    return MuseumTicket(
      id: 'MT-${now.millisecondsSinceEpoch}',
      userId: userId,
      museumName: 'Egyptian Museum',
      visitDate: _currentOrderDraft.visitDate,
      timeSlot: _currentOrderDraft.timeSlot,
      visitorCount: _currentOrderDraft.visitorCount,
      price: _currentOrderDraft.museumSubtotal,
      currency: 'USD',
      qrCodeValue: 'TKT-MUSEUM-$orderId',
      status: TicketStatus.active,
      purchasedAt: now,
      lineItems: _currentOrderDraft.museumLineItems,
      orderId: orderId,
    );
  }

  RobotTourTicket _createRobotTourTicketFromDraft({
    required String userId,
    required String orderId,
    required String museumTicketId,
    required DateTime now,
  }) {
    final tourType = _currentOrderDraft.robotTourType;
    final standardConfig =
        _currentOrderDraft.standardTourConfig ??
        StandardTourConfig.defaultConfig;
    final personalizedConfig =
        _currentOrderDraft.personalizedTourConfig ??
        PersonalizedTourConfig.defaultConfig;
    final isPersonalized = tourType == RobotTourType.personalized;
    final duration = isPersonalized
        ? personalizedConfig.durationMinutes
        : standardConfig.durationMinutes;
    final languageCode = isPersonalized
        ? personalizedConfig.languageCode
        : standardConfig.languageCode;

    return RobotTourTicket(
      id: 'RT-${now.millisecondsSinceEpoch}',
      userId: userId,
      packageId: tourType.name,
      packageName: isPersonalized
          ? 'Personalized Horus-Bot Tour'
          : 'Standard Horus-Bot Tour',
      durationMinutes: duration,
      languageCode: languageCode,
      includedFeatures: _robotFeaturesForDraft(),
      price: _currentOrderDraft.robotTourSubtotal,
      currency: 'USD',
      status: TicketStatus.active,
      purchasedAt: now,
      tourType: tourType,
      standardTourConfig: isPersonalized ? null : standardConfig,
      personalizedTourConfig: isPersonalized ? personalizedConfig : null,
      visitDate: _currentOrderDraft.visitDate,
      timeSlot: _currentOrderDraft.timeSlot,
      museumTicketId: museumTicketId,
      orderId: orderId,
      selectedInterests: isPersonalized
          ? personalizedConfig.selectedThemes
          : null,
      selectedArtifactIds: isPersonalized
          ? personalizedConfig.selectedExhibitIds
          : standardConfig.routeExhibitIds,
    );
  }

  String _paymentLabelForDraft() {
    switch (_currentOrderDraft.robotTourType) {
      case RobotTourType.none:
        return 'Museum Entry Tickets';
      case RobotTourType.standard:
        return 'Museum Entry + Standard Horus-Bot Tour';
      case RobotTourType.personalized:
        return 'Museum Entry + Personalized Horus-Bot Tour';
    }
  }

  List<String> _robotFeaturesForDraft() {
    switch (_currentOrderDraft.robotTourType) {
      case RobotTourType.none:
        return const [];
      case RobotTourType.standard:
        return const [
          'Recommended route',
          'Personal robot guide',
          'Interactive storytelling',
          'Photo opportunities',
        ];
      case RobotTourType.personalized:
        return const [
          'Custom exhibit route',
          'Personal robot guide',
          'Interest-based storytelling',
          'Photo opportunities',
          'Accessibility-aware pacing',
        ];
    }
  }

  /// Buy a package for a user.
  ///
  /// Compatibility API for the existing TicketScreen. The rebuilt Tickets flow
  /// should use the draft methods and mockCheckoutFromDraft instead.
  void buyPackage({
    required String userId,
    required TourPackage package,
    required DateTime visitDate,
    required String timeSlot,
    required int visitorCount,
  }) {
    final now = DateTime.now();
    final orderId = 'ORD-${now.millisecondsSinceEpoch}';
    final ticketIds = <String>[];

    MuseumTicket? museumTicket;
    if (package.includesMuseumEntry) {
      museumTicket = MuseumTicket(
        id: 'MT-${now.millisecondsSinceEpoch}',
        userId: userId,
        museumName: 'Egyptian Museum',
        visitDate: visitDate,
        timeSlot: timeSlot,
        visitorCount: visitorCount,
        price: package.price,
        currency: package.currency,
        qrCodeValue: 'TKT-MUSEUM-MT-${now.millisecondsSinceEpoch}',
        status: TicketStatus.active,
        purchasedAt: now,
        orderId: orderId,
      );
      _museumTickets.add(museumTicket);
      ticketIds.add(museumTicket.id);
    }

    RobotTourTicket? robotTicket;
    if (package.includesRobotTour) {
      robotTicket = RobotTourTicket(
        id: 'RT-${now.millisecondsSinceEpoch}',
        userId: userId,
        packageId: package.id,
        packageName: package.name,
        durationMinutes: package.durationMinutes,
        languageCode: 'en',
        includedFeatures: package.includedFeatures,
        price: package.includesMuseumEntry ? 0 : package.price,
        currency: package.currency,
        status: TicketStatus.active,
        purchasedAt: now,
        tourType: RobotTourType.standard,
        standardTourConfig: StandardTourConfig(
          durationMinutes: package.durationMinutes,
          languageCode: 'en',
          routeName: package.name,
          routeExhibitIds: StandardTourConfig.defaultConfig.routeExhibitIds,
        ),
        visitDate: visitDate,
        timeSlot: timeSlot,
        museumTicketId: museumTicket?.id,
        orderId: orderId,
      );
      _robotTourTickets.add(robotTicket);
      ticketIds.add(robotTicket.id);
    }

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
    _purchasedTicketSets.add(
      PurchasedTicketSet(
        id: orderId,
        userId: userId,
        museumTicket: museumTicket,
        robotTourTicket: robotTicket,
        paymentRecord: payment,
        purchasedAt: now,
      ),
    );

    notifyListeners();
  }

  /// Clear all tickets for a user (e.g., on logout)
  void clearUserTickets(String userId) {
    _museumTickets.removeWhere((t) => t.userId == userId);
    _robotTourTickets.removeWhere((t) => t.userId == userId);
    _payments.removeWhere((p) => p.userId == userId);
    _purchasedTicketSets.removeWhere((set) => set.userId == userId);
    notifyListeners();
  }

  /// Load mock tickets for a user (for development)
  void loadMockUserTickets(String userId) {
    clearUserTickets(userId);

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    const orderId = 'ORD-MOCK-001';

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
      lineItems: const [
        MuseumTicketLineItem(
          category: VisitorTicketCategory(
            id: 'foreigner-adult',
            audience: VisitorAudience.foreigner,
            ageGroup: VisitorAgeGroup.adult,
            labelEn: 'Foreigner Adult',
            labelAr: 'أجنبي بالغ',
            price: 20,
            currency: 'USD',
          ),
          quantity: 2,
          unitPrice: 20,
        ),
      ],
      orderId: orderId,
    );
    _museumTickets.add(museumTicket);

    final robotTicket = RobotTourTicket(
      id: 'RT-MOCK-001',
      userId: userId,
      packageId: 'standard',
      packageName: 'Standard Horus-Bot Tour',
      durationMinutes: 90,
      languageCode: 'en',
      includedFeatures: const [
        'Personal robot guide',
        'Interactive storytelling',
        'Photo opportunities',
      ],
      price: 35.0,
      currency: 'USD',
      status: TicketStatus.active,
      purchasedAt: now.subtract(const Duration(hours: 1)),
      tourType: RobotTourType.standard,
      standardTourConfig: StandardTourConfig.defaultConfig,
      visitDate: tomorrow,
      timeSlot: '10:00 AM - 12:00 PM',
      museumTicketId: museumTicket.id,
      orderId: orderId,
    );
    _robotTourTickets.add(robotTicket);

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
    _purchasedTicketSets.add(
      PurchasedTicketSet(
        id: orderId,
        userId: userId,
        museumTicket: museumTicket,
        robotTourTicket: robotTicket,
        paymentRecord: payment,
        purchasedAt: payment.date,
      ),
    );

    notifyListeners();
  }
}
