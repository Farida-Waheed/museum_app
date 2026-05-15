import 'package:flutter/material.dart';
import 'museum_ticket.dart';
import 'robot_tour_ticket.dart';
import 'tour_package.dart';
import 'payment_record.dart';
import 'ticket_order.dart';
import '../services/ticket_repository.dart';

/// Provider for managing user tickets, draft orders, and ticket entitlements.
class TicketProvider with ChangeNotifier {
  final TicketRepository _ticketRepository;

  final List<MuseumTicket> _museumTickets = [];
  final List<RobotTourTicket> _robotTourTickets = [];
  final List<PaymentRecord> _payments = [];
  final List<PurchasedTicketSet> _purchasedTicketSets = [];

  TicketOrderDraft _currentOrderDraft = TicketOrderDraft.initial();
  bool _isLoadingTickets = false;
  bool _isCheckingOut = false;
  String? _ticketError;

  TicketProvider({TicketRepository? ticketRepository})
    : _ticketRepository = ticketRepository ?? TicketRepository();

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
  bool get isLoadingTickets => _isLoadingTickets;
  bool get isCheckingOut => _isCheckingOut;
  String? get ticketError => _ticketError;

  // Computed getters
  bool get hasMuseumTicket =>
      _museumTickets.any((t) => t.status == TicketStatus.active);
  bool get hasRobotTourTicket =>
      _robotTourTickets.any((t) => t.status == TicketStatus.active);
  bool get hasTickets => hasMuseumTicket || hasRobotTourTicket;

  /// Canonical entitlement checks used across Home/Map/Live Tour and ticket flow.
  bool get hasValidMuseumEntryEntitlement => hasMuseumTicket;
  bool get hasValidRobotTourEntitlement => hasRobotTourTicket;
  bool get hasValidMuseumEntry => hasValidMuseumEntryEntitlement;
  bool get hasValidRobotTour => hasValidRobotTourEntitlement;
  bool get hasValidRobotTourEligibility =>
      hasValidMuseumEntryEntitlement && hasValidRobotTourEntitlement;

  double get museumSubtotal => _currentOrderDraft.museumSubtotal;
  double get robotTourSubtotal => _currentOrderDraft.robotTourSubtotal;
  double get orderTotal => _currentOrderDraft.total;
  int get draftVisitorCount => _currentOrderDraft.visitorCount;
  bool get isPersonalizedDraftComplete {
    if (_currentOrderDraft.robotTourType != RobotTourType.personalized) {
      return true;
    }

    final config = _currentOrderDraft.personalizedTourConfig;
    return config != null &&
        config.selectedExhibitIds.isNotEmpty &&
        config.durationMinutes > 0 &&
        config.languageCode.trim().isNotEmpty;
  }

  bool get canCheckoutDraft =>
      _currentOrderDraft.hasMuseumEntry &&
      _currentOrderDraft.hasRobotTour &&
      isPersonalizedDraftComplete;

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
          ? StandardTourConfig.defaultConfig.copyWith(
              languageCode:
                  _currentOrderDraft.standardTourConfig?.languageCode ??
                  StandardTourConfig.defaultConfig.languageCode,
            )
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
      standardTourConfig: config.copyWith(
        durationMinutes: StandardTourConfig.defaultConfig.durationMinutes,
      ),
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
    final draft = _currentOrderDraft;
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
      amount: draft.total,
      currency: 'EGP',
      label: _paymentLabelForDraft(),
      date: now,
      status: 'pay_at_counter',
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
      totalAmount: draft.total,
    );
    _purchasedTicketSets.add(purchasedSet);
    resetOrderDraft();
    return purchasedSet;
  }

  Future<PurchasedTicketSet?> checkoutFromDraft({
    required String userId,
  }) async {
    if (!canCheckoutDraft) return null;
    if (userId.trim().isEmpty) {
      _ticketError = 'Please sign in to buy tickets.';
      notifyListeners();
      return null;
    }

    _isCheckingOut = true;
    _ticketError = null;
    notifyListeners();

    try {
      final draft = _currentOrderDraft;

      final result = await _ticketRepository.checkoutDraft(
        userId: userId,
        draft: draft,
      );

      final savedMuseumTicket = result.museumTicket;
      final savedRobotTicket = result.robotTourTicket;
      final ticketIds = [
        savedMuseumTicket.id,
        savedRobotTicket.id,
      ];
      final payment = PaymentRecord(
        id: 'PAY-${result.bookingId}',
        userId: userId,
        amount: draft.total,
        currency: 'EGP',
        label: _paymentLabelForDraft(),
        date: savedMuseumTicket.purchasedAt,
        status: 'pay_at_counter',
        relatedTicketIds: ticketIds,
      );

      _upsertMuseumTicket(savedMuseumTicket);
      _upsertRobotTicket(savedRobotTicket);
      _payments.add(payment);

      final purchasedSet = PurchasedTicketSet(
        id: result.bookingId,
        userId: userId,
        museumTicket: savedMuseumTicket,
        robotTourTicket: savedRobotTicket,
        paymentRecord: payment,
        purchasedAt: savedMuseumTicket.purchasedAt,
        totalAmount: draft.total,
      );
      _upsertPurchasedTicketSet(purchasedSet);
      resetOrderDraft();
      return purchasedSet;
    } on TicketRepositoryException catch (e) {
      _ticketError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _ticketError = 'Unable to save your tickets. Please try again.';
      notifyListeners();
      return null;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTickets(String userId) async {
    if (userId.trim().isEmpty) {
      _ticketError = 'Please sign in to view tickets.';
      notifyListeners();
      return;
    }

    _isLoadingTickets = true;
    _ticketError = null;
    notifyListeners();

    try {
      final result = await _ticketRepository.loadUserTickets(userId);
      _museumTickets
        ..removeWhere((ticket) => ticket.userId == userId)
        ..addAll(result.museumTickets);
      _robotTourTickets
        ..removeWhere((ticket) => ticket.userId == userId)
        ..addAll(result.robotTourTickets);
      _rebuildPurchasedSetsForUser(userId);
    } on TicketRepositoryException catch (e) {
      _ticketError = e.message;
    } catch (_) {
      _ticketError = 'Unable to load tickets. Showing saved tickets if any.';
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(PurchasedTicketSet set) async {
    final bookingId =
        set.museumTicket?.bookingId ??
        set.robotTourTicket?.bookingId ??
        set.id;
    final museumTicketId = set.museumTicket?.id;
    final robotTourTicketId = set.robotTourTicket?.id;
    if (museumTicketId == null || robotTourTicketId == null) {
      _ticketError = 'Unable to cancel this booking.';
      notifyListeners();
      return false;
    }

    try {
      await _ticketRepository.cancelBooking(
        userId: set.userId,
        bookingId: bookingId,
        museumTicketId: museumTicketId,
        robotTourTicketId: robotTourTicketId,
      );

      _upsertMuseumTicket(
        set.museumTicket!.copyWith(status: TicketStatus.cancelled),
      );
      _upsertRobotTicket(
        set.robotTourTicket!.copyWith(status: TicketStatus.cancelled),
      );
      _rebuildPurchasedSetsForUser(set.userId);
      notifyListeners();
      return true;
    } on TicketRepositoryException catch (e) {
      debugPrint('Ticket cancellation failed: ${e.message}');
      _ticketError = e.message;
    } catch (e) {
      debugPrint('Ticket cancellation failed unexpectedly: $e');
      _ticketError = 'Unable to cancel this booking. Please try again. $e';
    }
    notifyListeners();
    return false;
  }

  MuseumTicket _createMuseumTicketFromDraft({
    required String userId,
    required String orderId,
    required DateTime now,
  }) {
    return MuseumTicket(
      id: 'MT-${now.millisecondsSinceEpoch}',
      userId: userId,
      museumName: 'The Egyptian Museum',
      visitDate: _currentOrderDraft.visitDate,
      timeSlot: _currentOrderDraft.timeSlot,
      visitorCount: _currentOrderDraft.visitorCount,
      price: _currentOrderDraft.museumSubtotal,
      currency: 'EGP',
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
      currency: 'EGP',
      status: TicketStatus.active,
      purchasedAt: now,
      tourType: tourType,
      standardTourConfig: isPersonalized ? null : standardConfig,
      personalizedTourConfig: isPersonalized ? personalizedConfig : null,
      visitDate: _currentOrderDraft.visitDate,
      timeSlot: _currentOrderDraft.timeSlot,
      museumTicketId: museumTicketId,
      orderId: orderId,
      qrCodeValue: 'TKT-ROBOT-$orderId',
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

  void _upsertMuseumTicket(MuseumTicket ticket) {
    final index = _museumTickets.indexWhere((item) => item.id == ticket.id);
    if (index == -1) {
      _museumTickets.add(ticket);
    } else {
      _museumTickets[index] = ticket;
    }
  }

  void _upsertRobotTicket(RobotTourTicket ticket) {
    final index = _robotTourTickets.indexWhere((item) => item.id == ticket.id);
    if (index == -1) {
      _robotTourTickets.add(ticket);
    } else {
      _robotTourTickets[index] = ticket;
    }
  }

  void _upsertPurchasedTicketSet(PurchasedTicketSet set) {
    final index = _purchasedTicketSets.indexWhere((item) => item.id == set.id);
    if (index == -1) {
      _purchasedTicketSets.add(set);
    } else {
      _purchasedTicketSets[index] = set;
    }
  }

  void _rebuildPurchasedSetsForUser(String userId) {
    _purchasedTicketSets.removeWhere((set) => set.userId == userId);
    _payments.removeWhere((payment) => payment.userId == userId);

    final userMuseumTickets = _museumTickets
        .where((ticket) => ticket.userId == userId)
        .toList();
    final userRobotTickets = _robotTourTickets
        .where((ticket) => ticket.userId == userId)
        .toList();

    for (final museumTicket in userMuseumTickets) {
      final robotTicket = _matchingRobotTicket(museumTicket, userRobotTickets);
      final payment = _paymentForTickets(userId, museumTicket, robotTicket);
      _payments.add(payment);
      _purchasedTicketSets.add(
        PurchasedTicketSet(
          id: museumTicket.bookingId ?? museumTicket.orderId ?? museumTicket.id,
          userId: userId,
          museumTicket: museumTicket,
          robotTourTicket: robotTicket,
          paymentRecord: payment,
          purchasedAt: museumTicket.purchasedAt,
          totalAmount: payment.amount,
        ),
      );
    }

    final pairedRobotIds = _purchasedTicketSets
        .map((set) => set.robotTourTicket?.id)
        .whereType<String>()
        .toSet();
    for (final robotTicket in userRobotTickets) {
      if (pairedRobotIds.contains(robotTicket.id)) continue;
      final payment = _paymentForTickets(userId, null, robotTicket);
      _payments.add(payment);
      _purchasedTicketSets.add(
        PurchasedTicketSet(
          id: robotTicket.bookingId ?? robotTicket.orderId ?? robotTicket.id,
          userId: userId,
          museumTicket: null,
          robotTourTicket: robotTicket,
          paymentRecord: payment,
          purchasedAt: robotTicket.purchasedAt,
          totalAmount: payment.amount,
        ),
      );
    }
  }

  RobotTourTicket? _matchingRobotTicket(
    MuseumTicket museumTicket,
    List<RobotTourTicket> robotTickets,
  ) {
    for (final robotTicket in robotTickets) {
      if (museumTicket.robotTourTicketId != null &&
          robotTicket.id == museumTicket.robotTourTicketId) {
        return robotTicket;
      }
      if (robotTicket.museumTicketId == museumTicket.id) {
        return robotTicket;
      }
      if (museumTicket.bookingId != null &&
          robotTicket.bookingId == museumTicket.bookingId) {
        return robotTicket;
      }
      if (museumTicket.orderId != null &&
          robotTicket.orderId == museumTicket.orderId) {
        return robotTicket;
      }
    }
    return null;
  }

  PaymentRecord _paymentForTickets(
    String userId,
    MuseumTicket? museumTicket,
    RobotTourTicket? robotTicket,
  ) {
    final amount = (museumTicket?.price ?? 0) + (robotTicket?.price ?? 0);
    final purchasedAt =
        museumTicket?.purchasedAt ?? robotTicket?.purchasedAt ?? DateTime.now();
    final ids = [
      if (museumTicket != null) museumTicket.id,
      if (robotTicket != null) robotTicket.id,
    ];

    return PaymentRecord(
      id: 'PAY-${ids.join('-')}',
      userId: userId,
      amount: amount,
      currency: museumTicket?.currency ?? robotTicket?.currency ?? 'EGP',
      label: robotTicket == null
          ? 'Museum Entry Tickets'
          : 'Museum Entry + ${robotTicket.packageName}',
      date: purchasedAt,
      status: 'pay_at_counter',
      relatedTicketIds: ids,
    );
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
        museumName: 'The Egyptian Museum',
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
        languageCode: 'english',
        includedFeatures: package.includedFeatures,
        price: package.includesMuseumEntry ? 0 : package.price,
        currency: package.currency,
        status: TicketStatus.active,
        purchasedAt: now,
        tourType: RobotTourType.standard,
        standardTourConfig: StandardTourConfig(
          durationMinutes: package.durationMinutes,
          languageCode: 'english',
          routeName: package.name,
          routeExhibitIds: StandardTourConfig.defaultConfig.routeExhibitIds,
        ),
        visitDate: visitDate,
        timeSlot: timeSlot,
        museumTicketId: museumTicket?.id,
        orderId: orderId,
        qrCodeValue: 'TKT-ROBOT-$orderId',
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
      status: 'pay_at_counter',
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
        totalAmount: payment.amount,
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
      museumName: 'The Egyptian Museum',
      visitDate: tomorrow,
      timeSlot: '11:00',
      visitorCount: 2,
      price: 1000.0,
      currency: 'EGP',
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
            price: 500,
            currency: 'EGP',
          ),
          quantity: 2,
          unitPrice: 500,
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
      languageCode: 'english',
      includedFeatures: const [
        'Personal robot guide',
        'Interactive storytelling',
        'Photo opportunities',
      ],
      price: 150.0,
      currency: 'EGP',
      status: TicketStatus.active,
      purchasedAt: now.subtract(const Duration(hours: 1)),
      tourType: RobotTourType.standard,
      standardTourConfig: StandardTourConfig.defaultConfig,
      visitDate: tomorrow,
      timeSlot: '11:00',
      museumTicketId: museumTicket.id,
      orderId: orderId,
      qrCodeValue: 'TKT-ROBOT-$orderId',
    );
    _robotTourTickets.add(robotTicket);

    final payment = PaymentRecord(
      id: 'PAY-MOCK-001',
      userId: userId,
      amount: 1150.0,
      currency: 'EGP',
      label: 'Complete Experience Bundle',
      date: now.subtract(const Duration(hours: 2)),
      status: 'pay_at_counter',
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
        totalAmount: payment.amount,
      ),
    );

    notifyListeners();
  }
}
