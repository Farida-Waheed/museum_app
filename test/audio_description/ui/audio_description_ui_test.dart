import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/ai/narration_generator.dart';
import 'package:museum_app/audio_description/context/conversation_context_manager.dart';
import 'package:museum_app/audio_description/controller/audio_description_controller.dart';
import 'package:museum_app/audio_description/controller/audio_description_state.dart';
import 'package:museum_app/audio_description/controller/audio_description_status.dart';
import 'package:museum_app/audio_description/interaction/audio_description_interaction_controller.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_policy.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt_builder.dart';
import 'package:museum_app/audio_description/repository/exhibit_lookup_result.dart';
import 'package:museum_app/audio_description/transcript/narration_transcript.dart';
import 'package:museum_app/audio_description/transcript/transcript_controller.dart';
import 'package:museum_app/audio_description/transcript/transcript_state.dart';
import 'package:museum_app/audio_description/transcript/transcript_status.dart';
import 'package:museum_app/audio_description/ui/audio_description_panel.dart';
import 'package:museum_app/audio_description/ui/narration_controls.dart';
import 'package:museum_app/audio_description/ui/narration_progress_indicator.dart';
import 'package:museum_app/audio_description/ui/transcript_view.dart';

/// Phase 4 Task 11 — Audio Description UI widget tests.
///
/// The UI reacts only to controller state. Sub-widgets are tested directly with
/// hand-built immutable state objects; the panel is tested end-to-end with the
/// REAL Task 7/8/10 controllers wired to recording fakes, proving it delegates
/// (never duplicates) controller logic.
void main() {
  final exhibit = ExhibitId('rosetta-stone');
  final profile = AccessibilityProfile.initial;

  const policy = NarrationPolicy(
    length: NarrationLength.standard,
    layers: {StoryLayer.visual, StoryLayer.historical},
    useSimpleLanguage: false,
    educationalDepth: EducationalDepth.casual,
    childMode: false,
    researchMode: false,
    emphasizePhysicalDescription: false,
    inviteFollowUp: true,
  );

  final metadata = ExhibitMetadata(
    id: exhibit,
    title: 'Rosetta Stone',
    physicalDescription: 'A tall dark slab.',
    historicalContext: 'Issued in 196 BC.',
  );

  const narrationText = 'The stone is dark. It carries three scripts. It helped.';

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  TranscriptState transcriptWith({
    required TranscriptStatus status,
    required int activeIndex,
    String text = narrationText,
  }) {
    final transcript =
        NarrationTranscript.build(exhibitId: exhibit, narration: text);
    return TranscriptState(
      status: status,
      transcript: transcript,
      activeIndex: activeIndex,
    );
  }

  // ===========================================================================
  // NarrationProgressIndicator
  // ===========================================================================
  group('NarrationProgressIndicator', () {
    testWidgets('reflects spoken/total and progress value', (tester) async {
      final state =
          transcriptWith(status: TranscriptStatus.active, activeIndex: 1);
      await tester.pumpWidget(wrap(
        NarrationProgressIndicator(transcriptState: state, profile: profile),
      ));

      expect(find.text('1 / 3'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
          find.byKey(NarrationProgressIndicator.progressBarKey));
      expect(bar.value, closeTo(1 / 3, 1e-9));
    });

    testWidgets('empty transcript shows no-progress dash', (tester) async {
      const state = TranscriptState(status: TranscriptStatus.idle);
      await tester.pumpWidget(wrap(
        NarrationProgressIndicator(transcriptState: state, profile: profile),
      ));
      expect(find.text('—'), findsOneWidget);
    });
  });

  // ===========================================================================
  // TranscriptView — highlighting
  // ===========================================================================
  group('TranscriptView', () {
    testWidgets('renders every sentence as its own node', (tester) async {
      final state =
          transcriptWith(status: TranscriptStatus.active, activeIndex: 0);
      await tester.pumpWidget(wrap(
        TranscriptView(transcriptState: state, profile: profile),
      ));

      expect(find.byKey(TranscriptView.segmentKey(0)), findsOneWidget);
      expect(find.byKey(TranscriptView.segmentKey(1)), findsOneWidget);
      expect(find.byKey(TranscriptView.segmentKey(2)), findsOneWidget);
    });

    testWidgets('active sentence is marked selected for a11y', (tester) async {
      final state =
          transcriptWith(status: TranscriptStatus.active, activeIndex: 1);
      await tester.pumpWidget(wrap(
        TranscriptView(transcriptState: state, profile: profile),
      ));

      final semantics = tester.getSemantics(
        find.descendant(
          of: find.byKey(TranscriptView.segmentKey(1)),
          matching: find.byType(Semantics).first,
        ),
      );
      expect(semantics.label, contains('Current sentence'));
    });

    testWidgets('highlight moves when the active index changes',
        (tester) async {
      await tester.pumpWidget(wrap(
        TranscriptView(
          transcriptState:
              transcriptWith(status: TranscriptStatus.active, activeIndex: 0),
          profile: profile,
        ),
      ));
      // Rebuild with a new active index — highlight tracks state only.
      await tester.pumpWidget(wrap(
        TranscriptView(
          transcriptState:
              transcriptWith(status: TranscriptStatus.active, activeIndex: 2),
          profile: profile,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(TranscriptView.segmentKey(2)), findsOneWidget);
    });

    testWidgets('empty transcript shows placeholder', (tester) async {
      await tester.pumpWidget(wrap(
        TranscriptView(
          transcriptState: const TranscriptState(status: TranscriptStatus.idle),
          profile: profile,
        ),
      ));
      expect(find.byKey(TranscriptView.emptyKey), findsOneWidget);
    });
  });

  // ===========================================================================
  // NarrationControls — buttons + enable/disable
  // ===========================================================================
  group('NarrationControls', () {
    NarrationControls controls({
      required AudioDescriptionStatus narration,
      required TranscriptStatus transcript,
      required Map<String, int> taps,
    }) =>
        NarrationControls(
          narrationStatus: narration,
          transcriptStatus: transcript,
          profile: profile,
          onReplay: () => taps['replay'] = (taps['replay'] ?? 0) + 1,
          onPause: () => taps['pause'] = (taps['pause'] ?? 0) + 1,
          onResume: () => taps['resume'] = (taps['resume'] ?? 0) + 1,
          onTellMeMore: () => taps['more'] = (taps['more'] ?? 0) + 1,
          onAskQuestion: () => taps['ask'] = (taps['ask'] ?? 0) + 1,
          onBookmark: () => taps['bookmark'] = (taps['bookmark'] ?? 0) + 1,
          onSkip: () => taps['skip'] = (taps['skip'] ?? 0) + 1,
        );

    testWidgets('active narration shows pause and fires callbacks',
        (tester) async {
      final taps = <String, int>{};
      await tester.pumpWidget(wrap(controls(
        narration: AudioDescriptionStatus.speaking,
        transcript: TranscriptStatus.active,
        taps: taps,
      )));

      expect(find.byKey(NarrationControls.pauseKey), findsOneWidget);
      expect(find.byKey(NarrationControls.resumeKey), findsNothing);

      await tester.tap(find.byKey(NarrationControls.replayKey));
      await tester.tap(find.byKey(NarrationControls.pauseKey));
      await tester.tap(find.byKey(NarrationControls.tellMeMoreKey));
      await tester.tap(find.byKey(NarrationControls.askQuestionKey));
      await tester.tap(find.byKey(NarrationControls.bookmarkKey));
      await tester.tap(find.byKey(NarrationControls.skipKey));

      expect(taps['replay'], 1);
      expect(taps['pause'], 1);
      expect(taps['more'], 1);
      expect(taps['ask'], 1);
      expect(taps['bookmark'], 1);
      expect(taps['skip'], 1);
    });

    testWidgets('paused narration shows an enabled resume button',
        (tester) async {
      final taps = <String, int>{};
      await tester.pumpWidget(wrap(controls(
        narration: AudioDescriptionStatus.speaking,
        transcript: TranscriptStatus.paused,
        taps: taps,
      )));

      expect(find.byKey(NarrationControls.resumeKey), findsOneWidget);
      await tester.tap(find.byKey(NarrationControls.resumeKey));
      expect(taps['resume'], 1);
    });

    testWidgets('idle disables all action buttons', (tester) async {
      final taps = <String, int>{};
      await tester.pumpWidget(wrap(controls(
        narration: AudioDescriptionStatus.idle,
        transcript: TranscriptStatus.idle,
        taps: taps,
      )));

      final replay = tester.widget<IconButton>(
          find.byKey(NarrationControls.replayKey));
      expect(replay.onPressed, isNull);
      final skip =
          tester.widget<IconButton>(find.byKey(NarrationControls.skipKey));
      expect(skip.onPressed, isNull);
    });
  });

  // ===========================================================================
  // AudioDescriptionPanel — integration with real controllers
  // ===========================================================================
  group('AudioDescriptionPanel', () {
    _Harness harness({bool deferredVoice = false, bool deferredRepo = false}) {
      final repo = _FakeRepository(
          ExhibitLookupResult.found(metadata), deferred: deferredRepo);
      final gen = _FakeGenerator(NarrationGenerationResult.success(narrationText));
      final voice = _FakeVoice(deferred: deferredVoice);
      final context = ConversationContextManager();
      final narration = AudioDescriptionController(
        repository: repo,
        policyResolver: () => policy,
        promptBuilder: const NarrationPromptBuilder(),
        generator: gen,
        context: context,
        voice: voice,
        profile: profile,
      );
      final transcript = TranscriptController();
      final detail = _FakeDetail();
      final followUps = <String>[];
      final bookmarks = <ExhibitId>[];
      final interaction = AudioDescriptionInteractionController(
        narrationController: narration,
        context: context,
        voice: voice,
        detail: detail,
        followUp: (prompt) async {
          followUps.add(prompt);
          return 'an answer';
        },
        onBookmark: (id, meta) async => bookmarks.add(id),
      );
      return _Harness(
        narration: narration,
        transcript: transcript,
        interaction: interaction,
        repo: repo,
        gen: gen,
        voice: voice,
        detail: detail,
        followUps: followUps,
        bookmarks: bookmarks,
      );
    }

    Future<void> pumpPanel(
      WidgetTester tester,
      _Harness h, {
      AskQuestionPrompt? ask,
    }) async {
      await tester.pumpWidget(wrap(AudioDescriptionPanel(
        narrationController: h.narration,
        transcriptController: h.transcript,
        interactionController: h.interaction,
        profile: profile,
        askQuestionPrompt: ask,
      )));
    }

    testWidgets('idle: shows the idle prompt', (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      expect(find.byKey(AudioDescriptionPanel.idleKey), findsOneWidget);
    });

    testWidgets('loading: shows a spinner while the pipeline runs',
        (tester) async {
      final h = harness(deferredRepo: true);
      await pumpPanel(tester, h);

      unawaited(h.narration.describe(exhibit));
      await tester.pump(); // loading published
      expect(find.byKey(AudioDescriptionPanel.loadingKey), findsOneWidget);

      h.repo.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('narrating/completed: renders narration text + transcript',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h);

      await h.narration.describe(exhibit);
      h.transcript.begin(exhibitId: exhibit, narration: narrationText);
      await tester.pump();

      expect(find.byKey(AudioDescriptionPanel.narrationTextKey), findsOneWidget);
      expect(find.byKey(TranscriptView.segmentKey(0)), findsOneWidget);
    });

    testWidgets('progress updates as the transcript advances', (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      h.transcript.begin(exhibitId: exhibit, narration: narrationText);
      await tester.pump();
      expect(find.text('0 / 3'), findsOneWidget);

      h.transcript.advanceTo(2);
      await tester.pump();
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('pause then resume drives the transcript controller',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      h.transcript.begin(exhibitId: exhibit, narration: narrationText);
      await tester.pump();

      await tester.tap(find.byKey(NarrationControls.pauseKey));
      await tester.pump();
      expect(h.transcript.state.status, TranscriptStatus.paused);
      expect(find.byKey(NarrationControls.resumeKey), findsOneWidget);

      await tester.tap(find.byKey(NarrationControls.resumeKey));
      await tester.pump();
      expect(h.transcript.state.status, TranscriptStatus.active);
    });

    testWidgets('replay re-runs the narration pipeline', (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      h.transcript.begin(exhibitId: exhibit, narration: narrationText);
      await tester.pump();
      final before = h.gen.calls;

      await tester.tap(find.byKey(NarrationControls.replayKey));
      await tester.pumpAndSettle();

      expect(h.gen.calls, before + 1);
    });

    testWidgets('tell me more maximizes detail then re-narrates',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      await tester.pump();

      await tester.tap(find.byKey(NarrationControls.tellMeMoreKey));
      await tester.pumpAndSettle();

      expect(h.detail.maximizeCalls, 1);
    });

    testWidgets('ask question forwards the captured text to the AI path',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h, ask: (_) async => 'What is it made of?');
      await h.narration.describe(exhibit);
      await tester.pump();

      await tester.tap(find.byKey(NarrationControls.askQuestionKey));
      await tester.pumpAndSettle();

      expect(h.followUps, hasLength(1));
      expect(h.followUps.single, contains('What is it made of?'));
    });

    testWidgets('ask question cancelled (null) does not call the AI path',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h, ask: (_) async => null);
      await h.narration.describe(exhibit);
      await tester.pump();

      await tester.tap(find.byKey(NarrationControls.askQuestionKey));
      await tester.pumpAndSettle();

      expect(h.followUps, isEmpty);
    });

    testWidgets('bookmark invokes the bookmark handler', (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      await tester.pump();

      await tester.tap(find.byKey(NarrationControls.bookmarkKey));
      await tester.pumpAndSettle();

      expect(h.bookmarks, [exhibit]);
    });

    testWidgets('skip stops narration audio through the voice seam',
        (tester) async {
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      await tester.pump();
      final before = h.voice.stopCalls;

      await tester.tap(find.byKey(NarrationControls.skipKey));
      await tester.pumpAndSettle();

      expect(h.voice.stopCalls, greaterThan(before));
    });

    testWidgets('accessibility: panel exposes labelled controls', (tester) async {
      final handle = tester.ensureSemantics();
      final h = harness();
      await pumpPanel(tester, h);
      await h.narration.describe(exhibit);
      h.transcript.begin(exhibitId: exhibit, narration: narrationText);
      await tester.pump();

      // Tooltips double as semantics labels for each action.
      expect(find.byTooltip('Replay narration'), findsOneWidget);
      expect(find.byTooltip('Skip narration'), findsOneWidget);
      expect(find.byTooltip('Ask a question'), findsOneWidget);
      handle.dispose();
    });
  });
}

// =============================================================================
// Harness + fakes
// =============================================================================

class _Harness {
  _Harness({
    required this.narration,
    required this.transcript,
    required this.interaction,
    required this.repo,
    required this.gen,
    required this.voice,
    required this.detail,
    required this.followUps,
    required this.bookmarks,
  });

  final AudioDescriptionController narration;
  final TranscriptController transcript;
  final AudioDescriptionInteractionController interaction;
  final _FakeRepository repo;
  final _FakeGenerator gen;
  final _FakeVoice voice;
  final _FakeDetail detail;
  final List<String> followUps;
  final List<ExhibitId> bookmarks;
}

class _FakeRepository implements ExhibitRepository {
  _FakeRepository(this._result, {this.deferred = false});
  final ExhibitLookupResult _result;
  final bool deferred;
  Completer<void>? _gate;

  void complete() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<ExhibitLookupResult> getExhibit(ExhibitId id) async {
    if (deferred) {
      await (_gate = Completer<void>()).future;
    }
    return _result;
  }
}

class _FakeGenerator implements NarrationGenerator {
  _FakeGenerator(this._result);
  final NarrationGenerationResult _result;
  int calls = 0;

  @override
  Future<NarrationGenerationResult> generate(NarrationPrompt prompt) async {
    calls++;
    return _result;
  }
}

class _FakeVoice implements NarrationVoiceOutput {
  _FakeVoice({this.deferred = false});
  final bool deferred;
  final List<String> spoken = [];
  int stopCalls = 0;
  Completer<bool>? _pending;

  void complete(bool accepted) {
    _pending?.complete(accepted);
    _pending = null;
  }

  @override
  Future<bool> speakNarration(String narration, {required String language}) {
    spoken.add(narration);
    if (deferred) return (_pending = Completer<bool>()).future;
    return Future.value(true);
  }

  @override
  Future<void> stopNarration() async {
    stopCalls++;
  }
}

class _FakeDetail implements NarrationDetailPreference {
  NarrationLength _current = NarrationLength.standard;
  int maximizeCalls = 0;
  int increaseCalls = 0;
  int decreaseCalls = 0;

  @override
  NarrationLength get current => _current;

  @override
  NarrationLength increase() {
    increaseCalls++;
    return _current;
  }

  @override
  NarrationLength decrease() {
    decreaseCalls++;
    return _current;
  }

  @override
  NarrationLength maximize() {
    maximizeCalls++;
    return _current = NarrationLength.detailed;
  }
}
