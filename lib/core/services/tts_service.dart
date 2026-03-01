import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:re_mem_ui/core/services/language_detection.dart';

/// Wraps [FlutterTts] for Text-to-Speech playback.
/// Call [initialize] once before speaking.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    // iOS: play audio even when the device is on silent.
    if (!kIsWeb) {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
        IosTextToSpeechAudioMode.defaultMode,
      );
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    }
  }

  /// Speaks [text], inferring the language from its characters.
  /// Pass an explicit [languageCode] (e.g. 'es-ES') to override detection.
  Future<void> speak(String text, {String? languageCode}) async {
    final lang = languageCode ?? detectLanguageFromText(text);
    await _tts.setLanguage(lang);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
