import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/voice/voice.dart';

/// Batch 2 of the Voice Communication Engine (Phase 3) test suite.
///
/// Deterministic unit tests built on the existing fake engines (no plugin, no
/// Flutter binding, no real timers beyond short settles), in the same plain-Dart
/// style as Batch 1 and the accessibility module:
///   * [VoiceCoordinator]        — the single speak/listen arbiter (with fakes)
///   * [VoiceSettingsRepository] — profile → speech-config mapping + persistence
///   * [AiVoiceAdapter]          — AI answers become speakable content
///
/// NOTE on VoiceController: it is intentionally NOT covered here. Its constructor
/// hard-requires a concrete [AccessibilityController], which transitively builds
/// an AuthService (FirebaseAuth.instance) and a Firebase-only repository, so it
/// cannot be constructed in a headless unit test without Firebase channel mocks
/// or a production change (both out of scope for Task 6). Its own logic is a thin
/// 1:1 delegation to [VoiceService]/[VoiceCoordinator], which ARE exercised here.
void main() {
  // A tiny settle so the coordinator's fire-and-forget drain microtasks run.
  Future<void> settle([int ms = 20]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  // ---------------------------------------------------------------------------
  // VoiceCoordinator
  // ---------------------------------------------------------------------------
  group('VoiceCoordinator with fake engines', () {
    late FakeTtsEngine tts;
    late FakeSpeechRecognizer recognizer;
    late VoiceCoordinator coordinator;

    const enabled = SpeechConfig(enabled: true, language: VoiceLanguage.english);

    Future<void> boot({
      bool ttsAvailable = true,
      bool micAvailable = true,
      Duration speakDuration = const Duration(milliseconds: 1),
    }) async {
      tts = FakeTtsEngine(available: ttsAvailable, speakDuration: speakDuration);
      recognizer = FakeSpeechRecognizer(available: micAvailable);
      coordinator = VoiceCoordinator(tts: tts, recognizer: recognizer);
      await coordinator.initialize();
      coordinator.updateConfig(enabled);
    }

    test('initialize reports ready + ttsAvailable when the backend is up',
        () async {
      await boot();
      expect(coordinator.status.status, VoiceStatus.ready);
      expect(coordinator.status.ttsAvailable, isTrue);
    });

    test('initialize reports unavailable when TTS is down', () async {
      await boot(ttsAvailable: false);
      expect(coordinator.status.ttsAvailable, isFalse);
      expect(coordinator.status.status, VoiceStatus.unavailable);
    });

    test('speak drains through TTS and returns to ready', () async {
      await boot();
      coordinator.announce('hello', event: VoiceEventType.genericNotice);
      await settle();
      expect(tts.spoken, contains('hello'));
      expect(coordinator.status.status, VoiceStatus.ready);
    });

    test('disabled config drops non-critical speech', () async {
      await boot();
      coordinator.updateConfig(SpeechConfig.disabled);
      final result =
          coordinator.announce('quiet please', event: VoiceEventType.genericNotice);
      await settle();
      expect(result, VoiceEnqueueResult.dropped);
      expect(tts.spoken, isEmpty);
    });

    test('mute suppresses non-critical but still speaks critical safety events',
        () async {
      await boot();
      await coordinator.setMuted(true);

      final dropped = coordinator.announce('ambient chatter',
          event: VoiceEventType.genericNotice);
      final emergency = coordinator.speak(VoiceMessage(
        content: VoiceContent.plain('evacuate now'),
        event: VoiceEventType.emergency,
        priority: VoicePriority.critical,
      ));
      await settle();

      expect(dropped, VoiceEnqueueResult.dropped);
      expect(emergency, isNot(VoiceEnqueueResult.dropped));
      expect(tts.spoken, contains('evacuate now'));
      expect(tts.spoken, isNot(contains('ambient chatter')));
    });

    test('a critical message interrupts the current utterance', () async {
      await boot(speakDuration: const Duration(milliseconds: 120));
      coordinator.speak(VoiceMessage(
        content: VoiceContent.plain('a long exhibit description'),
        event: VoiceEventType.exhibitIntroduction,
        priority: VoicePriority.content,
      ));
      await settle(10); // let it start speaking
      coordinator.speak(VoiceMessage(
        content: VoiceContent.plain('sos'),
        event: VoiceEventType.emergency,
        priority: VoicePriority.critical,
      ));
      await settle(250);

      expect(tts.stopCount, greaterThanOrEqualTo(1));
      expect(tts.spoken, contains('sos'));
    });

    test('pause and resume drive the TTS backend and status', () async {
      await boot();
      await coordinator.pause();
      expect(coordinator.status.status, VoiceStatus.paused);
      expect(tts.pauseCount, 1);

      await coordinator.resume();
      expect(tts.resumeCount, 1);
      expect(coordinator.isPaused, isFalse);
    });

    test('setMuted(true) stops playback and clears the queue', () async {
      await boot();
      await coordinator.setMuted(true);
      expect(coordinator.isMuted, isTrue);
      expect(coordinator.status.status, VoiceStatus.muted);
      expect(tts.stopCount, greaterThanOrEqualTo(1));
    });

    test('replayLast is dropped until a replayable message has been spoken',
        () async {
      await boot();
      expect(coordinator.replayLast(), VoiceEnqueueResult.dropped);

      coordinator.speak(VoiceMessage(
        content: VoiceContent.plain('the Rosetta Stone'),
        event: VoiceEventType.exhibitIntroduction,
        priority: VoicePriority.content,
      ));
      await settle();

      final replay = coordinator.replayLast();
      await settle();
      expect(replay, isNot(VoiceEnqueueResult.dropped));
      // Spoken at least twice: original + replay.
      expect(
          tts.spoken.where((s) => s.contains('Rosetta Stone')).length,
          greaterThanOrEqualTo(2));
    });

    test('listenForCommand returns unknown when the mic is unavailable',
        () async {
      await boot(micAvailable: false);
      final command = await coordinator.listenForCommand();
      expect(command.intent, VoiceCommandIntent.unknown);
      expect(coordinator.status.micAvailable, isFalse);
    });

    test('listenForCommand parses a scripted transcript into an intent',
        () async {
      await boot();
      recognizer.enqueueTranscript('next exhibit');
      final command = await coordinator.listenForCommand();
      expect(command.intent, VoiceCommandIntent.nextExhibit);
    });

    test('handleEngineCommand consumes engine-scoped commands only', () async {
      await boot();
      final stop = await coordinator
          .handleEngineCommand(const VoiceCommand(intent: VoiceCommandIntent.stopSpeaking));
      final appScoped = await coordinator
          .handleEngineCommand(const VoiceCommand(intent: VoiceCommandIntent.startTour));
      expect(stop, isTrue); // stop is engine-scoped → handled
      expect(appScoped, isFalse); // start tour is app-scoped → left to the app
    });
  });

  // ---------------------------------------------------------------------------
  // VoiceSettingsRepository
  // ---------------------------------------------------------------------------
  group('VoiceSettingsRepository profile → config mapping', () {
    test('a neutral profile yields a disabled config', () {
      final config = VoiceSettingsRepository.deriveFromProfile(
        AccessibilityProfile.initial,
        language: VoiceLanguage.english,
      );
      expect(config.enabled, isFalse);
    });

    test('voice guidance enables speech and auto-speak', () {
      final profile = AccessibilityProfile(
        voice: const VoiceSettings(voiceGuidanceEnabled: true),
      );
      final config = VoiceSettingsRepository.deriveFromProfile(
        profile,
        language: VoiceLanguage.english,
      );
      expect(config.enabled, isTrue);
      expect(config.autoSpeak, isTrue);
    });

    test('screen-reader-first yields detailed verbosity + auto-speak', () {
      final profile = AccessibilityProfile(
        voice: const VoiceSettings(screenReaderFirst: true),
      );
      final config = VoiceSettingsRepository.deriveFromProfile(
        profile,
        language: VoiceLanguage.arabic,
      );
      expect(config.enabled, isTrue);
      expect(config.autoSpeak, isTrue);
      expect(config.navigationVerbosity, VoiceVerbosity.detailed);
      expect(config.explanationVerbosity, VoiceVerbosity.detailed);
      expect(config.language, VoiceLanguage.arabic);
    });

    test('audio description alone enables rich speech without auto-speak', () {
      final profile = AccessibilityProfile(
        voice: const VoiceSettings(audioDescriptionEnabled: true),
      );
      final config = VoiceSettingsRepository.deriveFromProfile(
        profile,
        language: VoiceLanguage.english,
      );
      expect(config.enabled, isTrue);
      expect(config.autoSpeak, isFalse); // only screenReader/guidance auto-speak
      expect(config.explanationVerbosity, VoiceVerbosity.detailed);
    });

    test('cognitive assistance forces concise verbosity', () {
      final profile =
          AccessibilityProfile.forCategory(AccessibilityCategory.cognitiveAssistance);
      final config = VoiceSettingsRepository.deriveFromProfile(
        profile,
        language: VoiceLanguage.english,
      );
      expect(config.navigationVerbosity, VoiceVerbosity.concise);
      expect(config.explanationVerbosity, VoiceVerbosity.concise);
    });

    test('resolve layers session overrides on top of the profile baseline', () {
      final profile = AccessibilityProfile(
        voice: const VoiceSettings(voiceGuidanceEnabled: true),
      );
      final base = VoiceSettingsRepository.deriveFromProfile(
        profile,
        language: VoiceLanguage.english,
      );
      const prefs = VoicePreferences(
        volume: 0.5,
        rateBias: 0.2,
        gender: VoiceGender.female,
      );
      final resolved = VoiceSettingsRepository.resolve(
        profile,
        prefs,
        language: VoiceLanguage.english,
      );
      expect(resolved.volume, closeTo(0.5, 0.0001));
      expect(resolved.rate, closeTo(base.rate + 0.2, 0.0001));
      expect(resolved.gender, VoiceGender.female);
    });

    test('preferences round-trip through storage and back', () async {
      final store = InMemoryVoicePreferencesStore();
      final repo = VoiceSettingsRepository(store: store);
      const prefs = VoicePreferences(
        muted: true,
        volume: 0.4,
        rateBias: -0.1,
        gender: VoiceGender.male,
      );
      await repo.update(prefs);

      final reloaded = VoiceSettingsRepository(store: store);
      final loaded = await reloaded.load();
      expect(loaded.muted, isTrue);
      expect(loaded.volume, closeTo(0.4, 0.0001));
      expect(loaded.rateBias, closeTo(-0.1, 0.0001));
      expect(loaded.gender, VoiceGender.male);
    });

    test('a corrupt store degrades to safe defaults instead of throwing',
        () async {
      final repo = VoiceSettingsRepository(store: _ThrowingStore());
      final loaded = await repo.load();
      expect(loaded, VoicePreferences.defaults);
    });
  });

  // ---------------------------------------------------------------------------
  // AiVoiceAdapter
  // ---------------------------------------------------------------------------
  group('AiVoiceAdapter voice-enables AI answers', () {
    late FakeTtsEngine tts;
    late VoiceService service;
    late AiVoiceAdapter adapter;

    Future<void> boot() async {
      tts = FakeTtsEngine(speakDuration: const Duration(milliseconds: 1));
      service = VoiceService(
        coordinator: VoiceCoordinator(
          tts: tts,
          recognizer: FakeSpeechRecognizer(),
        ),
      );
      // A voice-guidance profile so the resolved config is enabled and speaks.
      await service.initialize(
        profile: AccessibilityProfile(
          voice: const VoiceSettings(voiceGuidanceEnabled: true),
        ),
      );
      adapter = AiVoiceAdapter(service);
    }

    test('fromAnswer preserves the display text and plain speakable text', () {
      final response = AiVoiceAdapter.fromAnswer('Hello, visitor.');
      expect(response.displayText, 'Hello, visitor.');
      expect(response.toVoiceContent().plainText, 'Hello, visitor.');
      expect(response.voiceLanguage, VoiceLanguage.english);
    });

    test('emphasis and pronunciations do not corrupt the spoken text', () {
      final response = AiVoiceAdapter.fromAnswer(
        'The Rosetta Stone is famous.',
        emphasize: ['Rosetta Stone'],
        pronunciations: {'Rosetta': 'Ro-zetta'},
      );
      expect(response.toVoiceContent().plainText, 'The Rosetta Stone is famous.');
    });

    test('speakAnswer routes the answer through the engine to TTS', () async {
      await boot();
      adapter.speakAnswer('Welcome to the museum.');
      await settle();
      expect(tts.spoken, contains('Welcome to the museum.'));
    });

    test('speak routes a prebuilt response through the engine to TTS', () async {
      await boot();
      final response = AiVoiceAdapter.fromAnswer('An interactive answer.');
      adapter.speak(response);
      await settle();
      expect(tts.spoken, contains('An interactive answer.'));
    });

    test('the language of the answer is carried through', () async {
      await boot();
      adapter.speakAnswer('مرحبا بك', language: VoiceLanguage.arabic);
      await settle();
      expect(tts.spoken, contains('مرحبا بك'));
    });
  });
}

/// A store whose load always throws, to exercise the repository's safe-defaults
/// degradation path.
class _ThrowingStore implements VoicePreferencesStore {
  @override
  Future<Map<String, dynamic>?> load() async => throw Exception('corrupt');

  @override
  Future<void> save(Map<String, dynamic> data) async {}
}
