import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_types.dart';

/// Routes meaningful local notifications through the Voice Communication Engine
/// so a visitor relying on speech hears the important ones read aloud — without
/// the notification pipeline knowing anything about TTS.
///
/// This is the single seam the notification layer uses: `NotificationService`
/// invokes [announce] via a plain callback (set in `main.dart`), and this bridge
/// decides *what is worth speaking* and hands the localized text to an injected
/// speak function. It never imports the engine or Flutter, so the
/// "meaningful notification" policy and the spoken-text formatting are pure and
/// unit-testable in isolation.
///
/// Design notes:
/// * **Additive & non-intrusive.** The engine still gates actual playback (voice
///   enabled / muted / current activity), so this bridge only decides candidacy;
///   it never forces audio on anyone.
/// * **Only meaningful events.** Passive engagement nudges (did-you-know, quiz
///   available, saved-exhibit reminders, permission prompts…) and any
///   low-priority (batched) notification are deliberately NOT spoken, honoring
///   the "avoid overwhelming the visitor" requirement.
class NotificationVoiceBridge {
  NotificationVoiceBridge({required void Function(String text) speak})
      : _speak = speak;

  final void Function(String text) _speak;

  /// Notification types that are engagement nudges rather than events the
  /// visitor needs spoken. Excluded from speech even at medium priority.
  static const Set<NotificationType> passiveTypes = {
    NotificationType.didYouKnow,
    NotificationType.quizAvailable,
    NotificationType.savedExhibitReminder,
    NotificationType.askGuideReminder,
    NotificationType.mapHelpReminder,
    NotificationType.notificationPermissionReminder,
  };

  /// Whether [notification] is meaningful enough to read aloud. Pure and
  /// side-effect-free so the policy is exhaustively testable.
  ///
  /// Rules: never speak low-priority (passive / batched) notifications, and
  /// never speak the passive engagement types above. Everything else — tour
  /// flow, proximity, practical, and system alerts at medium/high priority — is
  /// spoken.
  static bool shouldAnnounce(ImmediateNotification notification) {
    if (notification.priority == NotificationPriority.low) return false;
    if (passiveTypes.contains(notification.type)) return false;
    return spokenText(notification).isNotEmpty;
  }

  /// Build the spoken form from the notification's already-localized title and
  /// body (so speech matches exactly what is shown, in whatever language the
  /// producer created it). Pure.
  static String spokenText(ImmediateNotification notification) {
    final title = notification.title.trim();
    final body = notification.body.trim();
    if (title.isEmpty) return body;
    if (body.isEmpty) return title;
    return '$title. $body';
  }

  /// Offer a shown notification to the engine. No-op when it is not meaningful,
  /// so callers can wire this unconditionally to the notification seam.
  void announce(ImmediateNotification notification) {
    if (!shouldAnnounce(notification)) return;
    _speak(spokenText(notification));
  }
}
