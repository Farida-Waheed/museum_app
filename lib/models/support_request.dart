import 'support_message.dart';

enum SupportRequestStatus { pending, inProgress, resolved }

class SupportRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String screen;
  final String contextSummary;
  final DateTime createdAt;
  SupportRequestStatus status;
  final List<SupportMessage> messages;

  SupportRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.screen,
    required this.contextSummary,
    required this.createdAt,
    this.status = SupportRequestStatus.pending,
    List<SupportMessage>? messages,
  }) : messages = messages ?? [];

  String get statusLabel {
    switch (status) {
      case SupportRequestStatus.pending:
        return 'Pending';
      case SupportRequestStatus.inProgress:
        return 'In Progress';
      case SupportRequestStatus.resolved:
        return 'Resolved';
    }
  }

  String get latestMessage {
    if (messages.isEmpty) return contextSummary;
    return messages.last.text;
  }
}
