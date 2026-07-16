/// Public entry point for the Voice Communication Engine (Phase 3).
///
/// Import this single file to access the whole module:
///   `import 'package:museum_app/voice/voice.dart';`
///
/// The module is self-contained, mirroring `lib/accessibility/`: enums, models,
/// engines (behind abstract interfaces), services, coordinator, state,
/// integration adapters, extensions, and constants all live under `lib/voice/`.
/// No voice code is scattered elsewhere; the only touch points in the rest of
/// the app are the provider registration in `main.dart` and optional UI widgets.
///
/// Layering (top depends on bottom, never the reverse):
///   widgets / state (VoiceController)         ← Flutter-facing
///   integration (AI / navigation adapters)
///   services (VoiceService → VoiceCoordinator → queue / director / robot floor)
///   engines (TtsEngine / SpeechRecognizer — abstract; plugin + fake impls)
///   models / enums / constants                ← pure Dart
library;

// Constants & enums
export 'constants/voice_constants.dart';
export 'enums/voice_enums.dart';

// Models
export 'models/speech_config.dart';
export 'models/voice_content.dart';
export 'models/voice_message.dart';
export 'models/voice_command.dart';
export 'models/voice_status_snapshot.dart';

// Engine interfaces + swappable implementations (plugin adapters + fakes)
export 'engine/tts_engine.dart';
export 'engine/speech_recognizer.dart';
export 'engine/audio_session_manager.dart';
export 'engine/fake_tts_engine.dart';
export 'engine/fake_speech_recognizer.dart';
export 'engine/flutter_tts_engine.dart';
export 'engine/speech_to_text_recognizer.dart';

// Core services + coordinator + facade
export 'services/voice_queue_manager.dart';
export 'services/voice_settings_repository.dart';
export 'services/voice_command_parser.dart';
export 'services/voice_director.dart';
export 'services/robot_speech_coordinator.dart';
export 'services/voice_coordinator.dart';
export 'services/voice_service.dart';

// Integration adapters + seams
export 'integration/ai_voice_adapter.dart';
export 'integration/voice_navigation_announcer.dart';
export 'integration/voice_feature_registration.dart';

// Reactive state + extensions
export 'state/voice_controller.dart';
export 'extensions/voice_context_extensions.dart';
