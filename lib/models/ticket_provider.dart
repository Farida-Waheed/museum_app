import 'package:flutter/material.dart';
import 'museum_ticket.dart';
import 'recommended_route.dart';
import 'robot_tour_ticket.dart';
import 'tour_package.dart';
import 'payment_record.dart';
import 'ticket_order.dart';
import '../services/ticket_repository.dart';
import '../core/constants/pricing.dart';

/// Provider for managing user tickets, draft orders, and ticket entitlements.
class TicketProvider with ChangeNotifier {
  final TicketRepository _ticketRepository;

  final List<MuseumTicket> _museumTickets = [];
  final List<RobotTourTicket> _robotTourTickets = [];
  final List<PaymentRecord> _payments = [];
  final List<PurchasedTicketSet> _purchasedTicketSets = [];

  TicketOrderDraft _currentOrderDraft = TicketOrderDraft.initial();
  bool _tourLanguageTouched = false;
  bool _isLoadingTickets = false;
  bool _isCheckingOut = false;
  String? _ticketError;
  int _skippedTicketSetCount = 0;

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
  int get skippedTicketSetCount => _skippedTicketSetCount;

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
    _tourLanguageTouched = false;
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
      clearRecommendedRoute: true,
    );
    notifyListeners();
  }

  void selectRecommendedRoute(RecommendedRoute route) {
    final artifactIds = route.artifactIds
        .where((id) => RegExp(r'^artifact_\d{3}$').hasMatch(id))
        .toList(growable: false);
    if (artifactIds.isEmpty) return;

    final currentLanguage =
        _currentOrderDraft.robotTourType == RobotTourType.personalized
        ? _currentOrderDraft.personalizedTourConfig?.languageCode
        : _currentOrderDraft.standardTourConfig?.languageCode;
    final languageCode = _tourLanguageTouched
        ? (currentLanguage ?? StandardTourConfig.defaultConfig.languageCode)
        : route.recommendedLanguage;

    if (route.id == 'horus_highlights') {
      _currentOrderDraft = _currentOrderDraft.copyWith(
        robotTourType: RobotTourType.standard,
        standardTourConfig: StandardTourConfig(
          durationMinutes: route.durationMin,
          languageCode: languageCode,
          routeName: route.titleEn,
          routeExhibitIds: artifactIds,
        ),
        recommendedRouteId: route.id,
        recommendedRouteTitleEn: route.titleEn,
        recommendedRouteTitleAr: route.titleAr,
      );
    } else {
      final existing =
          _currentOrderDraft.personalizedTourConfig ??
          PersonalizedTourConfig.defaultConfig;
      _currentOrderDraft = _currentOrderDraft.copyWith(
        robotTourType: RobotTourType.personalized,
        personalizedTourConfig: existing.copyWith(
          selectedExhibitIds: artifactIds,
          selectedThemes: route.theme.trim().isEmpty
              ? route.recommendedFor
              : [route.theme],
          durationMinutes: route.durationMin,
          languageCode: languageCode,
          visitorMode: route.kidsFriendly
              ? VisitorMode.kidsFamily
              : existing.visitorMode,
          pace: _paceFromRecommendedRoute(route.pace),
          photoSpotsEnabled: route.photoSpots,
        ),
        recommendedRouteId: route.id,
        recommendedRouteTitleEn: route.titleEn,
        recommendedRouteTitleAr: route.titleAr,
      );
    }
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

  void updateTourLanguage(String languageCode) {
    final normalized = languageCode.trim().toLowerCase().replaceAll('-', '_');
    _tourLanguageTouched = true;
    final standardConfig =
        _currentOrderDraft.standardTourConfig ??
        StandardTourConfig.defaultConfig;
    final personalizedConfig =
        _currentOrderDraft.personalizedTourConfig ??
        PersonalizedTourConfig.defaultConfig;

    _currentOrderDraft = _currentOrderDraft.copyWith(
      standardTourConfig: standardConfig.copyWith(languageCode: normalized),
      personalizedTourConfig: personalizedConfig.copyWith(
        languageCode: normalized,
      ),
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
    if (_isCheckingOut) return null;
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
      final ticketIds = [savedMuseumTicket.id, savedRobotTicket.id];
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
      _ticketError = _bookingErrorMessage(e.message);
      notifyListeners();
      return null;
    } catch (_) {
      _ticketError = 'We could not complete your booking. Please try again.';
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
    _skippedTicketSetCount = 0;
    notifyListeners();

    try {
      final result = await _ticketRepository.loadUserTickets(userId);
      _museumTickets
        ..removeWhere((ticket) => ticket.userId == userId)
        ..addAll(result.museumTickets);
      _robotTourTickets
        ..removeWhere((ticket) => ticket.userId == userId)
        ..addAll(result.robotTourTickets);
      _rebuildPurchasedSetsForUser(
        userId,
        skippedBookingCount: result.skippedBookingCount,
      );
    } on TicketRepositoryException catch (e) {
      _skippedTicketSetCount = 0;
      _ticketError = _ticketsErrorMessage(e.message);
    } catch (_) {
      _skippedTicketSetCount = 0;
      _ticketError = 'We could not load your tickets. Showing available saved content.';
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(PurchasedTicketSet set) async {
    _ticketError = null;
    final bookingId =
        set.museumTicket?.bookingId ?? set.robotTourTicket?.bookingId ?? set.id;
    final museumTicketId = set.museumTicket?.id;
    final robotTourTicketId = set.robotTourTicket?.id;
    final bookingSource =
        set.museumTicket?.bookingSource ??
        set.robotTourTicket?.bookingSource ??
        'unknown';
    if (!_isSharedBookingId(bookingId) ||
        museumTicketId == null ||
        robotTourTicketId == null) {
      _ticketError = 'Unable to cancel this booking.';
      notifyListeners();
      return false;
    }
    if (!isBookingCancellable(set)) {
      _ticketError = isWithinCancellationDeadline(set)
          ? 'Cancellation is available up to 24 hours before your visit.'
          : 'Unable to cancel this booking.';
      notifyListeners();
      return false;
    }

    try {
      debugPrint(
        'Cancelling booking from My Tickets: '
        'booking_id=$bookingId; booking_source=$bookingSource; '
        'museum_ticket_id=$museumTicketId; '
        'robot_tour_ticket_id=$robotTourTicketId',
      );
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
      _ticketError = null;
      notifyListeners();
      return true;
    } on TicketRepositoryException catch (e) {
      debugPrint('Ticket cancellation failed: ${e.message}');
      _ticketError = _ticketsErrorMessage(e.message);
    } catch (e) {
      debugPrint('Ticket cancellation failed unexpectedly: $e');
      _ticketError = 'Something went wrong. Please try again.';
    }
    notifyListeners();
    return false;
  }

  String _bookingErrorMessage(String message) {
    if (_isNetworkMessage(message)) {
      return 'Connection issue. Please check your internet connection and try again.';
    }
    if (message == 'Please sign in to buy tickets.') return message;
    return 'We could not complete your booking. Please try again.';
  }

  String _ticketsErrorMessage(String message) {
    if (_isNetworkMessage(message)) {
      return 'Connection issue. Please check your internet connection and try again.';
    }
    if (message == 'Cancellation is available up to 24 hours before your visit.') {
      return message;
    }
    if (message == 'Please sign in to view tickets.') return message;
    return 'We could not load your tickets.';
  }

  bool _isNetworkMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('connection issue') || lower.contains('network');
  }

  bool isBookingCancellable(PurchasedTicketSet set) {
    final museumTicket = set.museumTicket;
    final robotTicket = set.robotTourTicket;
    if (museumTicket == null || robotTicket == null) return false;
    if (museumTicket.status == TicketStatus.used ||
        museumTicket.status == TicketStatus.cancelled ||
        museumTicket.status == TicketStatus.expired) {
      return false;
    }
    if (robotTicket.status == TicketStatus.paired ||
        robotTicket.status == TicketStatus.in_progress ||
        robotTicket.status == TicketStatus.completed ||
        robotTicket.status == TicketStatus.cancelled ||
        robotTicket.status == TicketStatus.expired) {
      return false;
    }
    return !isWithinCancellationDeadline(set);
  }

  bool isWithinCancellationDeadline(PurchasedTicketSet set) {
    final startsAt = _visitStartsAt(set);
    if (startsAt == null) return true;
    return startsAt.difference(DateTime.now()) <= const Duration(hours: 24);
  }

  DateTime? _visitStartsAt(PurchasedTicketSet set) {
    final date = set.museumTicket?.visitDate ?? set.robotTourTicket?.visitDate;
    if (date == null) return null;
    final rawTime =
        set.museumTicket?.timeSlot ?? set.robotTourTicket?.timeSlot ?? '';
    final time = _timeFromSlot(rawTime);
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.$1, time.$2);
  }

  (int, int)? _timeFromSlot(String value) {
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
      routeId: _currentOrderDraft.recommendedRouteId,
      routeTitleEn: _currentOrderDraft.recommendedRouteTitleEn,
      routeTitleAr: _currentOrderDraft.recommendedRouteTitleAr,
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

  TourPace _paceFromRecommendedRoute(String pace) {
    return TourPace.values.firstWhere(
      (value) => value.name == pace.trim().toLowerCase(),
      orElse: () => TourPace.normal,
    );
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

  void _rebuildPurchasedSetsForUser(
    String userId, {
    int skippedBookingCount = 0,
  }) {
    _purchasedTicketSets.removeWhere((set) => set.userId == userId);
    _payments.removeWhere((payment) => payment.userId == userId);
    var skippedCount = skippedBookingCount;

    final userMuseumTickets = _museumTickets
        .where((ticket) => ticket.userId == userId)
        .where(_isSharedMuseumTicket)
        .toList();
    final userRobotTickets = _robotTourTickets
        .where((ticket) => ticket.userId == userId)
        .where(_isSharedRobotTicket)
        .toList();

    for (final museumTicket in userMuseumTickets) {
      final robotTicket = _matchingRobotTicket(museumTicket, userRobotTickets);
      if (robotTicket == null) {
        skippedCount++;
        continue;
      }
      final payment = _paymentForTickets(userId, museumTicket, robotTicket);
      _payments.add(payment);
      _purchasedTicketSets.add(
        PurchasedTicketSet(
          id: museumTicket.bookingId!,
          userId: userId,
          museumTicket: museumTicket,
          robotTourTicket: robotTicket,
          paymentRecord: payment,
          purchasedAt: museumTicket.purchasedAt,
          totalAmount: payment.amount,
        ),
      );
    }
    _skippedTicketSetCount = skippedCount;

    // Final QA uses complete shared bookings only. Legacy/order-only or
    // orphaned ticket docs are intentionally hidden from My Tickets.
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
    }
    return null;
  }

  bool _isSharedMuseumTicket(MuseumTicket ticket) {
    return _isSharedBookingId(ticket.bookingId) &&
        ticket.robotTourTicketId != null &&
        ticket.robotTourTicketId!.trim().isNotEmpty;
  }

  bool _isSharedRobotTicket(RobotTourTicket ticket) {
    return _isSharedBookingId(ticket.bookingId) &&
        ticket.museumTicketId != null &&
        ticket.museumTicketId!.trim().isNotEmpty;
  }

  bool _isSharedBookingId(String? value) {
    final id = value?.trim();
    if (id == null || id.isEmpty) return false;
    return !id.toUpperCase().startsWith('ORD-');
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
    _skippedTicketSetCount = 0;
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
      price: BookingPricing.foreignerAdult * 2,
      currency: BookingPricing.currency,
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
            price: BookingPricing.foreignerAdult,
            currency: BookingPricing.currency,
          ),
          quantity: 2,
          unitPrice: BookingPricing.foreignerAdult,
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
      price: BookingPricing.standardRobotTour,
      currency: BookingPricing.currency,
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
      amount:
          BookingPricing.foreignerAdult * 2 + BookingPricing.standardRobotTour,
      currency: BookingPricing.currency,
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
