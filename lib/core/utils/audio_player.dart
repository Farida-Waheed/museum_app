import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioGuideService {
  final AudioPlayer _player = AudioPlayer();

  Future<bool> playAudio(String assetPath) async {
    try {
      await rootBundle.load('assets/$assetPath');
      await _player.setSourceAsset(assetPath);
      await _player.resume();
      return true;
    } catch (exception, stackTrace) {
      if (exception is FlutterError &&
          exception.message.contains('Unable to load asset')) {
        debugPrint('AudioGuideService audio asset unavailable: $assetPath');
        return false;
      }
      debugPrint('AudioGuideService playAudio error: $exception');
      debugPrint('$stackTrace');
      return false;
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
