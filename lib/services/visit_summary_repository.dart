import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/robot_tour_ticket.dart';
import '../models/tour_photo.dart';
import '../models/tour_question.dart';
import '../models/tour_session.dart';
import 'photo_repository.dart';
import 'question_repository.dart';

class VisitSummaryData {
  final TourSession? session;
  final RobotTourTicket? robotTicket;
  final List<TourPhoto> photos;
  final List<TourQuestion> questions;

  const VisitSummaryData({
    required this.session,
    required this.robotTicket,
    required this.photos,
    required this.questions,
  });
}

class VisitSummaryRepository {
  VisitSummaryRepository({
    FirebaseFirestore? firestore,
    PhotoRepository? photoRepository,
    QuestionRepository? questionRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _photoRepository = photoRepository ?? PhotoRepository(),
       _questionRepository = questionRepository ?? QuestionRepository();

  final FirebaseFirestore _firestore;
  final PhotoRepository _photoRepository;
  final QuestionRepository _questionRepository;

  Future<VisitSummaryData> load(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      return const VisitSummaryData(
        session: null,
        robotTicket: null,
        photos: [],
        questions: [],
      );
    }

    final sessionDoc = await _firestore
        .collection('tourSessions')
        .doc(sessionId)
        .get();
    final sessionData = sessionDoc.data();
    final session = sessionDoc.exists && sessionData != null
        ? TourSession.fromFirestore(sessionDoc.id, sessionData)
        : null;

    RobotTourTicket? ticket;
    final robotTicketId = session?.robotTourTicketId;
    if (robotTicketId != null && robotTicketId.isNotEmpty) {
      final ticketDoc = await _firestore
          .collection('robotTourTickets')
          .doc(robotTicketId)
          .get();
      final ticketData = ticketDoc.data();
      if (ticketDoc.exists && ticketData != null) {
        ticket = RobotTourTicket.fromFirestore(ticketDoc.id, ticketData);
      }
    }

    final photos = await _photoRepository.loadSessionPhotos(sessionId);
    final questions = await _questionRepository.loadSessionQuestions(sessionId);

    return VisitSummaryData(
      session: session,
      robotTicket: ticket,
      photos: photos,
      questions: questions,
    );
  }
}
