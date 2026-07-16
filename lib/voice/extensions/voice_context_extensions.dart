import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/voice_status_snapshot.dart';
import '../state/voice_controller.dart';

/// Ergonomic access to the voice engine from any widget, mirroring
/// `AccessibilityContextX` so screens never re-implement provider plumbing.
///
/// * [voice] — the controller for actions (does NOT subscribe to rebuilds).
/// * [watchVoice] — the controller with rebuild subscription.
/// * [voiceStatus] — the current status snapshot (subscribes to rebuilds), for
///   the status indicator / controls.
extension VoiceContextX on BuildContext {
  VoiceController get voice => read<VoiceController>();

  VoiceController get watchVoice => watch<VoiceController>();

  VoiceStatusSnapshot get voiceStatus =>
      watch<VoiceController>().status;
}
