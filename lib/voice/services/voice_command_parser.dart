import '../enums/voice_enums.dart';
import '../models/voice_command.dart';

/// Maps a recognized utterance to a [VoiceCommandIntent] using a bilingual
/// (English + Arabic) keyword/phrase grammar. Pure, synchronous, and fully
/// unit-testable — no plugin or recognizer dependency.
///
/// This is deliberately a rule/keyword matcher rather than an ML model: it is
/// deterministic, offline, instant, and trivially extensible (add a phrase to a
/// list to teach a new phrasing; add an enum value + list for a new command).
/// Because it is isolated behind [parse], the whole grammar can be replaced with
/// an on-device intent classifier later without changing any caller.
class VoiceCommandParser {
  const VoiceCommandParser();

  /// Ordered so that more specific intents are tested before generic ones (e.g.
  /// "next" before a bare "tour"). First match wins.
  static const List<_Rule> _rules = [
    _Rule(VoiceCommandIntent.stopSpeaking, [
      'stop', 'be quiet', 'quiet', 'silence', 'shut up', 'stop talking',
      'stop speaking', 'enough',
      'توقف', 'اسكت', 'صمت', 'اصمت', 'كفى', 'خلاص', 'اسكتي',
    ]),
    _Rule(VoiceCommandIntent.callAssistance, [
      'help', 'assistance', 'assist me', 'call for help', 'i need help',
      'emergency', 'call staff', 'call assistance', 'sos',
      'مساعدة', 'ساعدني', 'النجدة', 'نجدة', 'طوارئ', 'اتصل بالمساعدة', 'ساعدوني',
    ]),
    _Rule(VoiceCommandIntent.repeatExplanation, [
      'repeat', 'again', 'say again', 'say that again', 'repeat that',
      'one more time', 'come again',
      'أعد', 'اعد', 'كرر', 'مرة أخرى', 'مرة اخرى', 'اعد الشرح', 'كررها',
    ]),
    _Rule(VoiceCommandIntent.nextExhibit, [
      'next', 'next exhibit', 'next stop', 'move on', 'go next', 'forward',
      'continue', 'skip',
      'التالي', 'التالى', 'المعروض التالي', 'المحطة التالية', 'استمر', 'تابع', 'تخطى',
    ]),
    _Rule(VoiceCommandIntent.previousExhibit, [
      'previous', 'back', 'go back', 'previous exhibit', 'last exhibit',
      'before', 'prior',
      'السابق', 'السابقة', 'المعروض السابق', 'ارجع', 'رجوع', 'العودة', 'قبل',
    ]),
    _Rule(VoiceCommandIntent.pauseTour, [
      'pause', 'pause tour', 'hold on', 'wait', 'pause the tour', 'freeze',
      'إيقاف مؤقت', 'ايقاف مؤقت', 'أوقف الجولة', 'انتظر', 'توقف مؤقتا', 'مهلا',
    ]),
    _Rule(VoiceCommandIntent.resumeTour, [
      'resume', 'continue tour', 'resume tour', 'carry on', 'unpause', 'go on',
      'استأنف', 'استئناف', 'اكمل الجولة', 'أكمل', 'واصل', 'استكمال',
    ]),
    _Rule(VoiceCommandIntent.startTour, [
      'start', 'start tour', 'begin', 'begin tour', 'lets go', "let's go",
      'start the tour', 'begin the tour',
      'ابدأ', 'ابدا', 'ابدأ الجولة', 'بدء', 'لنبدأ', 'ابدأ الجوله', 'هيا',
    ]),
    _Rule(VoiceCommandIntent.increaseVolume, [
      'louder', 'volume up', 'increase volume', 'turn it up', 'speak up',
      'raise volume', 'higher volume',
      'ارفع الصوت', 'صوت أعلى', 'اعلى', 'بصوت أعلى', 'زد الصوت', 'علي الصوت',
    ]),
    _Rule(VoiceCommandIntent.decreaseVolume, [
      'quieter', 'volume down', 'decrease volume', 'turn it down',
      'lower volume', 'softer', 'less volume',
      'اخفض الصوت', 'صوت أقل', 'أقل', 'بصوت أخفض', 'قلل الصوت', 'نزل الصوت',
    ]),
    _Rule(VoiceCommandIntent.fasterSpeech, [
      'faster', 'speak faster', 'speed up', 'talk faster', 'quicker',
      'more speed',
      'أسرع', 'اسرع', 'تكلم بسرعة', 'بسرعة', 'زد السرعة', 'اسرع بالكلام',
    ]),
    _Rule(VoiceCommandIntent.slowerSpeech, [
      'slower', 'speak slower', 'slow down', 'talk slower', 'take it slow',
      'less speed',
      'أبطأ', 'ابطأ', 'تكلم ببطء', 'ببطء', 'أبطئ', 'قلل السرعة', 'على مهلك',
    ]),
  ];

  /// Parse a transcript into a [VoiceCommand]. [confidence] is the recognizer's
  /// confidence in the transcript itself; the returned command combines it with
  /// match quality. Returns [VoiceCommand.unknown] when nothing matches.
  VoiceCommand parse(
    String transcript, {
    double confidence = 1.0,
    VoiceLanguage language = VoiceLanguage.english,
  }) {
    final normalized = _normalize(transcript);
    if (normalized.isEmpty) return VoiceCommand.unknown;

    for (final rule in _rules) {
      for (final phrase in rule.phrases) {
        final p = _normalize(phrase);
        if (p.isEmpty) continue;
        if (_matches(normalized, p)) {
          return VoiceCommand(
            intent: rule.intent,
            transcript: transcript.trim(),
            confidence: confidence,
            language: language,
          );
        }
      }
    }

    return VoiceCommand(
      intent: VoiceCommandIntent.unknown,
      transcript: transcript.trim(),
      confidence: confidence,
      language: language,
    );
  }

  /// Word-boundary-aware containment: an exact word/phrase match, so "start"
  /// does not fire on "restart" and "back" does not fire inside "background".
  bool _matches(String haystack, String needle) {
    if (needle.contains(' ')) {
      return haystack == needle ||
          haystack.startsWith('$needle ') ||
          haystack.endsWith(' $needle') ||
          haystack.contains(' $needle ');
    }
    // Single token: compare against whitespace-split words.
    return haystack.split(' ').contains(needle);
  }

  /// Lowercase, strip punctuation/diacritics, collapse whitespace. Arabic
  /// tashkeel and tatweel are removed so "توقّف" and "توقف" match.
  String _normalize(String input) {
    var s = input.toLowerCase().trim();
    // Remove Arabic diacritics (tashkeel) and tatweel.
    s = s.replaceAll(RegExp('[ؐ-ًؚ-ٰٟـ]'), '');
    // Normalize alef variants and taa marbuta for robust Arabic matching.
    s = s
        .replaceAll(RegExp('[آأإ]'), 'ا') // آأإ → ا
        .replaceAll('ة', 'ه'); // ة → ه
    // Replace non-letter (keep Arabic + latin letters + spaces) with space.
    s = s.replaceAll(RegExp(r'[^؀-ۿ\w\s]', unicode: true), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

class _Rule {
  final VoiceCommandIntent intent;
  final List<String> phrases;
  const _Rule(this.intent, this.phrases);
}
