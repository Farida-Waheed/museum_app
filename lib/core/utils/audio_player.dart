import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioGuideService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudio(String assetPath) async {
    try {
      await _player.setSourceAsset(assetPath);
      await _player.resume();
    } catch (exception, stackTrace) {
      debugPrint('AudioGuideService playAudio error: $exception');
      debugPrint('$stackTrace');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (exception, stackTrace) {
      debugPrint('AudioGuideService stop error: $exception');
      debugPrint('$stackTrace');
    }
  }
}
