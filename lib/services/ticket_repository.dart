import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/museum_ticket.dart';
import '../models/robot_tour_ticket.dart';
import '../models/ticket_order.dart';

class TicketRepository {
  TicketRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _museumTickets =>
      _firestore.collection('museumTickets');

  CollectionReference<Map<String, dynamic>> get _robotTourTickets =>
      _firestore.collection('robotTourTickets');

  Future<TicketCheckoutResult> checkoutDraft({
    required String userId,
    required TicketOrderDraft draft,
    required MuseumTicket museumTicket,
    RobotTourTicket? robotTicket,
  }) async {
    if (userId.trim().isEmpty) {
      throw const TicketRepositoryException('Please sign in to buy tickets.');
    }

    try {
      final museumDoc = _museumTickets.doc(museumTicket.id);
      final robotDoc = robotTicket == null
          ? null
          : _robotTourTickets.doc(robotTicket.id);

      final savedMuseumTicket = robotTicket == null
          ? museumTicket
          : museumTicket.copyWith(robotTourTicketId: robotTicket.id);
      final savedRobotTicket = robotTicket?.copyWith(
        museumTicketId: museumTicket.id,
      );

      final batch = _firestore.batch();
      batch.set(
        museumDoc,
        _museumTicketData(savedMuseumTicket, draft, savedRobotTicket),
      );

      if (robotDoc != null && savedRobotTicket != null) {
        batch.set(robotDoc, _robotTicketData(savedRobotTicket, draft));
      }

      await batch.commit();

      return TicketCheckoutResult(
        museumTicket: savedMuseumTicket,
        robotTourTicket: savedRobotTicket,
      );
    } on FirebaseException catch (e) {
      throw TicketRepositoryException(_friendlyFirestoreError(e));
    }
  }

  Future<TicketLoadResult> loadUserTickets(String userId) async {
    if (userId.trim().isEmpty) {
      throw const TicketRepositoryException('Please sign in to view tickets.');
    }

    try {
      final museumSnapshot = await _museumTickets
          .where('userId', isEqualTo: userId)
          .get();
      final robotSnapshot = await _robotTourTickets
          .where('userId', isEqualTo: userId)
          .get();

      final museumTickets = museumSnapshot.docs
          .map((doc) => MuseumTicket.fromFirestore(doc.id, doc.data()))
          .toList();
      final robotTickets = robotSnapshot.docs
          .map((doc) => RobotTourTicket.fromFirestore(doc.id, doc.data()))
          .toList();

      return TicketLoadResult(
        museumTickets: museumTickets,
        robotTourTickets: robotTickets,
      );
    } on FirebaseException catch (e) {
      throw TicketRepositoryException(_friendlyFirestoreError(e));
    }
  }

  Map<String, dynamic> _museumTicketData(
    MuseumTicket ticket,
    TicketOrderDraft draft,
    RobotTourTicket? robotTicket,
  ) {
    return {
      ...ticket.toFirestore(),
      'ticket_types': _ticketTypesFromLineItems(ticket.lineItems),
      'total_tickets': ticket.visitorCount,
      'total_price': ticket.price,
      'qr_value': ticket.qrCodeValue,
      'robot_tour_ticket_id': robotTicket?.id,
      'tour_type': robotTicket?.tourType.name,
      'standard_tour_config': draft.standardTourConfig?.toJson(),
      'personalized_tour_config': draft.personalizedTourConfig?.toJson(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _robotTicketData(
    RobotTourTicket ticket,
    TicketOrderDraft draft,
  ) {
    final personalized =
        ticket.personalizedTourConfig ?? draft.personalizedTourConfig;
    final standard = ticket.standardTourConfig ?? draft.standardTourConfig;

    return {
      ...ticket.toFirestore(),
      'selected_exhibit_ids':
          personalized?.selectedExhibitIds ??
          standard?.routeExhibitIds ??
          ticket.selectedArtifactIds ??
          const <String>[],
      'interests':
          personalized?.selectedThemes ??
          ticket.selectedInterests ??
          const <String>[],
      'accessibility': personalized?.accessibilityNeeds ?? const <String>[],
      'visitor_mode': personalized?.visitorMode.name ?? VisitorMode.adult.name,
      'pace': personalized?.pace.name ?? TourPace.normal.name,
      'photo_spots_enabled': personalized?.photoSpotsEnabled ?? true,
      'avoid_crowds': personalized?.avoidCrowds ?? false,
      'standard_tour_config': ticket.standardTourConfig?.toJson(),
      'personalized_tour_config': ticket.personalizedTourConfig?.toJson(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
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
  final MuseumTicket museumTicket;
  final RobotTourTicket? robotTourTicket;

  const TicketCheckoutResult({
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
