import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/notifications/notification_models.dart';
import '../core/notifications/notification_service.dart';
import '../core/notifications/notification_types.dart';
import '../app/router.dart';
import '../models/support_message.dart';
import '../models/support_request.dart';

/// In-memory support request manager for creator/admin assistance.
///
/// This is intentionally built with a clean interface so a backend can be
/// plugged in later without altering the chat or UI layer.
class SupportRequestService {
  static final SupportRequestService _instance = SupportRequestService._internal();

  factory SupportRequestService() => _instance;

  SupportRequestService._internal();

  final List<SupportRequest> _requests = [];
  int _idCounter = 1;

  List<SupportRequest> get requests => List.unmodifiable(_requests);

  SupportRequest createRequest({
    required String requesterId,
    required String requesterName,
    required String screen,
    required String contextSummary,
    required List<SupportMessage> initialMessages,
  }) {
    final request = SupportRequest(
      id: 'support_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      requesterId: requesterId,
      requesterName: requesterName,
      screen: screen,
      contextSummary: contextSummary,
      createdAt: DateTime.now(),
      messages: initialMessages,
    );

    _requests.insert(0, request);
    _notifyCreator(request);
    return request;
  }

  SupportRequest? getRequest(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addHumanReply({
    required String requestId,
    required String replyText,
  }) {
    final request = getRequest(requestId);
    if (request == null) return;
    request.messages.add(SupportMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: SupportSender.human,
      timestamp: DateTime.now(),
      text: replyText,
    ));
    request.status = SupportRequestStatus.inProgress;
  }

  void markResolved(String requestId) {
    final request = getRequest(requestId);
    if (request == null) return;
    request.status = SupportRequestStatus.resolved;
  }

  void _notifyCreator(SupportRequest request) {
    final payload = NotificationPayload(
      type: NotificationType.askGuideReminder,
      targetRoute: AppRoutes.supportConversation,
      routeParams: {'requestId': request.id},
    );

    final notification = ImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      type: NotificationType.askGuideReminder,
      title: 'Human support requested',
      body: 'A visitor has requested live support.',
      priority: NotificationPriority.high,
      category: NotificationCategory.guideReminders,
      payload: payload,
    );

    NotificationService().showNotification(notification);
  }
}
