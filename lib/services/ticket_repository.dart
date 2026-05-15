import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/museum_ticket.dart';
import '../models/robot_tour_ticket.dart';
import '../models/ticket_order.dart';

class TicketRepository {
  TicketRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  static const String mobileBookingSource = 'mobile_app';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _museumTickets =>
      _firestore.collection('museumTickets');

  CollectionReference<Map<String, dynamic>> get _robotTourTickets =>
      _firestore.collection('robotTourTickets');

  Future<TicketCheckoutResult> checkoutDraft({
    required String userId,
    required TicketOrderDraft draft,
  }) async {
    final uid = _verifiedUid(userId);
    final now = DateTime.now();

    try {
      final bookingDoc = _bookings.doc();
      final museumDoc = _museumTickets.doc();
      final robotDoc = _robotTourTickets.doc();
      final bookingId = bookingDoc.id;
      final museumTicketId = museumDoc.id;
      final robotTicketId = robotDoc.id;

      final museumTicket = _museumTicketFromDraft(
        uid: uid,
        draft: draft,
        now: now,
        bookingId: bookingId,
        museumTicketId: museumTicketId,
        robotTicketId: robotTicketId,
      );
      final robotTicket = _robotTicketFromDraft(
        uid: uid,
        draft: draft,
        now: now,
        bookingId: bookingId,
        museumTicketId: museumTicketId,
        robotTicketId: robotTicketId,
      );

      final batch = _firestore.batch();
      batch.set(
        bookingDoc,
        _bookingData(
          uid: uid,
          bookingId: bookingId,
          museumTicketId: museumTicketId,
          robotTicketId: robotTicketId,
          draft: draft,
        ),
      );
      batch.set(museumDoc, _museumTicketData(museumTicket, draft));
      batch.set(robotDoc, _robotTicketData(robotTicket, draft));

      await batch.commit();

      return TicketCheckoutResult(
        bookingId: bookingId,
        museumTicket: museumTicket,
        robotTourTicket: robotTicket,
      );
    } on FirebaseException catch (e) {
      throw TicketRepositoryException(_friendlyFirestoreError(e));
    }
  }

  Future<TicketLoadResult> loadUserTickets(String userId) async {
    final uid = _verifiedUid(userId);

    try {
      final bookingSnapshot = await _bookings
          .where('userId', isEqualTo: uid)
          .get();
      final museumTickets = <MuseumTicket>[];
      final robotTickets = <RobotTourTicket>[];

      for (final bookingDoc in bookingSnapshot.docs) {
        final booking = bookingDoc.data();
        final bookingId = _stringValue(booking['booking_id']) ?? bookingDoc.id;
        final museumTicketId = _stringValue(booking['museum_ticket_id']);
        final robotTicketId = _stringValue(booking['robot_tour_ticket_id']);

        if (museumTicketId != null) {
          final doc = await _museumTickets.doc(museumTicketId).get();
          if (doc.exists && doc.data() != null) {
            museumTickets.add(
              MuseumTicket.fromFirestore(doc.id, {
                ...doc.data()!,
                'booking_id': bookingId,
              }),
            );
          }
        }

        if (robotTicketId != null) {
          final doc = await _robotTourTickets.doc(robotTicketId).get();
          if (doc.exists && doc.data() != null) {
            robotTickets.add(
              RobotTourTicket.fromFirestore(doc.id, {
                ...doc.data()!,
                'booking_id': bookingId,
              }),
            );
          }
        }
      }

      if (bookingSnapshot.docs.isEmpty) {
        return _loadLegacyTickets(uid);
      }

      return TicketLoadResult(
        museumTickets: museumTickets,
        robotTourTickets: robotTickets,
      );
    } on FirebaseException catch (e) {
      throw TicketRepositoryException(_friendlyFirestoreError(e));
    }
  }

  Future<void> cancelBooking({
    required String userId,
    required String bookingId,
    required String museumTicketId,
    required String robotTourTicketId,
  }) async {
    _verifiedUid(userId);

    try {
      final update = {
        'status': TicketStatus.cancelled.name,
        'updated_at': FieldValue.serverTimestamp(),
        'cancelled_at': FieldValue.serverTimestamp(),
      };
      final batch = _firestore.batch();
      batch.set(_bookings.doc(bookingId), update, SetOptions(merge: true));
      batch.set(
        _museumTickets.doc(museumTicketId),
        update,
        SetOptions(merge: true),
      );
      batch.set(
        _robotTourTickets.doc(robotTourTicketId),
        update,
        SetOptions(merge: true),
      );
      await batch.commit();
    } on FirebaseException catch (e) {
      throw TicketRepositoryException(_friendlyFirestoreError(e));
    }
  }

  Future<TicketLoadResult> _loadLegacyTickets(String uid) async {
    final museumSnapshot = await _museumTickets
        .where('userId', isEqualTo: uid)
        .get();
    final robotSnapshot = await _robotTourTickets
        .where('userId', isEqualTo: uid)
        .get();

    return TicketLoadResult(
      museumTickets: museumSnapshot.docs
          .map((doc) => MuseumTicket.fromFirestore(doc.id, doc.data()))
          .toList(),
      robotTourTickets: robotSnapshot.docs
          .map((doc) => RobotTourTicket.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }

  String _verifiedUid(String userId) {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) {
      throw const TicketRepositoryException('Please sign in to buy tickets.');
    }
    if (userId.trim().isNotEmpty && userId != uid) {
      throw const TicketRepositoryException('Ticket user does not match login.');
    }
    return uid;
  }

  MuseumTicket _museumTicketFromDraft({
    required String uid,
    required TicketOrderDraft draft,
    required DateTime now,
    required String bookingId,
    required String museumTicketId,
    required String robotTicketId,
  }) {
    return MuseumTicket(
      id: museumTicketId,
      userId: uid,
      museumName: 'The Egyptian Museum',
      visitDate: draft.visitDate,
      timeSlot: draft.timeSlot,
      visitorCount: draft.visitorCount,
      price: draft.museumSubtotal,
      currency: 'EGP',
      qrCodeValue: 'MUSEUM-$museumTicketId',
      status: TicketStatus.active,
      purchasedAt: now,
      lineItems: draft.museumLineItems,
      bookingId: bookingId,
      bookingSource: mobileBookingSource,
      robotTourTicketId: robotTicketId,
    );
  }

  RobotTourTicket _robotTicketFromDraft({
    required String uid,
    required TicketOrderDraft draft,
    required DateTime now,
    required String bookingId,
    required String museumTicketId,
    required String robotTicketId,
  }) {
    final tourType = draft.robotTourType;
    final standardConfig =
        draft.standardTourConfig ?? StandardTourConfig.defaultConfig;
    final personalizedConfig =
        draft.personalizedTourConfig ?? PersonalizedTourConfig.defaultConfig;
    final isPersonalized = tourType == RobotTourType.personalized;
    final duration = isPersonalized
        ? personalizedConfig.durationMinutes
        : standardConfig.durationMinutes;
    final languageCode = isPersonalized
        ? personalizedConfig.languageCode
        : standardConfig.languageCode;

    return RobotTourTicket(
      id: robotTicketId,
      userId: uid,
      packageId: tourType.name,
      packageName: isPersonalized
          ? 'Personalized Horus-Bot Tour'
          : 'Standard Horus-Bot Tour',
      durationMinutes: duration,
      languageCode: languageCode,
      includedFeatures: _robotFeaturesForDraft(tourType),
      price: draft.robotTourSubtotal,
      currency: 'EGP',
      status: TicketStatus.active,
      purchasedAt: now,
      tourType: tourType,
      standardTourConfig: tourType == RobotTourType.standard
          ? standardConfig
          : null,
      personalizedTourConfig: isPersonalized ? personalizedConfig : null,
      visitDate: draft.visitDate,
      timeSlot: draft.timeSlot,
      museumTicketId: museumTicketId,
      bookingId: bookingId,
      bookingSource: mobileBookingSource,
      selectedInterests: isPersonalized
          ? personalizedConfig.selectedThemes
          : const [],
      selectedArtifactIds: isPersonalized
          ? personalizedConfig.selectedExhibitIds
          : const [],
    );
  }

  Map<String, dynamic> _bookingData({
    required String uid,
    required String bookingId,
    required String museumTicketId,
    required String robotTicketId,
    required TicketOrderDraft draft,
  }) {
    return {
      'booking_id': bookingId,
      'booking_source': mobileBookingSource,
      'userId': uid,
      'museum_ticket_id': museumTicketId,
      'robot_tour_ticket_id': robotTicketId,
      'museum_name': 'The Egyptian Museum',
      'visit_date': _dateOnly(draft.visitDate),
      'visit_time': _slotStart(draft.timeSlot),
      'visitor_count': draft.visitorCount,
      'ticket_types': _ticketTypesFromLineItems(draft.museumLineItems),
      'museum_entry_total': draft.museumSubtotal,
      'robot_tour_price': draft.robotTourSubtotal,
      'total_price': draft.total,
      'currency': 'EGP',
      'payment_method': 'cash',
      'payment_status': 'pay_at_counter',
      'status': TicketStatus.active.name,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'cancelled_at': null,
    };
  }

  Map<String, dynamic> _museumTicketData(
    MuseumTicket ticket,
    TicketOrderDraft draft,
  ) {
    return {
      'ticketId': ticket.id,
      'userId': ticket.userId,
      'booking_id': ticket.bookingId,
      'booking_source': mobileBookingSource,
      'robot_tour_ticket_id': ticket.robotTourTicketId,
      'museum_name': ticket.museumName,
      'visit_date': _dateOnly(ticket.visitDate),
      'visit_time': _slotStart(ticket.timeSlot),
      'ticket_types': _ticketTypesFromLineItems(ticket.lineItems),
      'total_tickets': ticket.visitorCount,
      'total_price': draft.museumSubtotal,
      'currency': 'EGP',
      'payment_method': 'cash',
      'payment_status': 'pay_at_counter',
      'status': TicketStatus.active.name,
      'qr_value': ticket.qrCodeValue,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'cancelled_at': null,
    };
  }

  Map<String, dynamic> _robotTicketData(
    RobotTourTicket ticket,
    TicketOrderDraft draft,
  ) {
    final personalized =
        ticket.personalizedTourConfig ?? draft.personalizedTourConfig;
    return {
      'tourTicketId': ticket.id,
      'userId': ticket.userId,
      'booking_id': ticket.bookingId,
      'booking_source': mobileBookingSource,
      'museum_ticket_id': ticket.museumTicketId,
      'tour_type': ticket.tourType.name,
      'visit_date': ticket.visitDate == null
          ? null
          : _dateOnly(ticket.visitDate!),
      'visit_time': ticket.timeSlot == null ? null : _slotStart(ticket.timeSlot!),
      'tour_duration_min': ticket.durationMinutes,
      'preferred_language': _normalizedLanguage(ticket.languageCode),
      'pace': personalized?.pace.name ?? TourPace.normal.name,
      'interests':
          personalized?.selectedThemes ??
          ticket.selectedInterests ??
          const <String>[],
      'selected_exhibits':
          personalized?.selectedExhibitIds ??
          ticket.selectedArtifactIds ??
          const <String>[],
      'accessibility': personalized?.accessibilityNeeds ?? const <String>[],
      'kids_mode': personalized?.visitorMode == VisitorMode.kidsFamily,
      'photo_spots': personalized?.photoSpotsEnabled ?? false,
      'notes': null,
      'total_price': draft.robotTourSubtotal,
      'currency': 'EGP',
      'status': TicketStatus.active.name,
      'paired_robot_id': null,
      'session_id': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'cancelled_at': null,
    };
  }

  Map<String, int> _ticketTypesFromLineItems(
    List<MuseumTicketLineItem> lineItems,
  ) {
    final values = {
      for (final category in VisitorTicketCategory.defaults)
        category.id.replaceAll('-', '_'): 0,
    };

    for (final item in lineItems) {
      values[item.category.id.replaceAll('-', '_')] = item.quantity;
    }

    return values;
  }

  List<String> _robotFeaturesForDraft(RobotTourType tourType) {
    switch (tourType) {
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

  String _normalizedLanguage(String languageCode) {
    switch (languageCode.trim().toLowerCase().replaceAll('-', '_')) {
      case 'en':
      case 'english':
        return 'english';
      case 'ar':
      case 'arabic':
        return 'arabic';
      case 'egyptian_arabic':
        return 'egyptian_arabic';
      default:
        return languageCode.trim().toLowerCase().replaceAll('-', '_');
    }
  }

  String _slotStart(String slot) {
    final trimmed = slot.trim();
    if (trimmed.contains(' - ')) {
      return _toTwentyFourHourStart(trimmed.split(' - ').first);
    }
    return _toTwentyFourHourStart(trimmed);
  }

  String _toTwentyFourHourStart(String raw) {
    final value = raw.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(value);
    if (match == null) return value;
    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  String _friendlyFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access these tickets.';
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Ticket service is unavailable. Please try again.';
    }
  }
}

class TicketCheckoutResult {
  final String bookingId;
  final MuseumTicket museumTicket;
  final RobotTourTicket robotTourTicket;

  const TicketCheckoutResult({
    required this.bookingId,
    required this.museumTicket,
    required this.robotTourTicket,
  });
}

class TicketLoadResult {
  final List<MuseumTicket> museumTickets;
  final List<RobotTourTicket> robotTourTickets;

  const TicketLoadResult({
    required this.museumTickets,
    required this.robotTourTickets,
  });
}

class TicketRepositoryException implements Exception {
  final String message;

  const TicketRepositoryException(this.message);

  @override
  String toString() => message;
}
