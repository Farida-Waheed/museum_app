import '../prompt/narration_prompt.dart';
import 'narration_generation_result.dart';

/// The contract Task 7 depends on to turn a [NarrationPrompt] into narration
/// text. Exposed as an interface (DIP) so the orchestrator never binds to a
/// concrete AI client, and tests inject a fake generator with scripted results.
///
/// A generator NEVER throws to its caller: every outcome — success or any
/// failure mode — is a [NarrationGenerationResult].
abstract class NarrationGenerator {
  Future<NarrationGenerationResult> generate(NarrationPrompt prompt);
}

/// The completion seam over the app's EXISTING AI infrastructure. This is the
/// single function Task 7 binds to whatever `ChatProvider` already uses to get
/// an answer — deliberately a bare `Future<String>` so this module adds NO
/// second AI client and stays free of any backend/network import.
///
/// Contract used by [AiNarrationGenerator]:
/// * resolve to the narration text on success,
/// * throw [TimeoutException] if it times out (the generator also enforces its
///   own timeout as a safety net),
/// * throw [FormatException] when the response is malformed/unparseable,
/// * throw any other error for a general backend failure.
typedef NarrationCompletion = Future<String> Function(NarrationPrompt prompt);
