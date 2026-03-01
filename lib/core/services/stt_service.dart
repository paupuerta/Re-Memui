import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] for voice dictation.
/// [initialize] is safe to call multiple times — it only runs once.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  void Function()? _onListeningStop;

  bool get isListening => _stt.isListening;

  /// Returns true if speech recognition is available and permissions were granted.
  /// Safe to call multiple times; subsequent calls are no-ops if already initialised.
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      // onStatus is the only reliable way to detect when the engine
      // stops on web (finalResult is not always fired by the browser).
      onStatus: (status) {
        if (status == SpeechToText.notListeningStatus ||
            status == SpeechToText.doneStatus) {
          _onListeningStop?.call();
        }
      },
    );
    return _initialized;
  }

  /// Starts listening and streams recognised words via [onResult].
  /// [onDone] is called when recognition ends (via status change or final result).
  /// [onError] is called with a human-readable message when recognition fails
  /// (e.g. "not-allowed" when microphone permission is denied).
  Future<void> startListening({
    required void Function(String text) onResult,
    void Function()? onDone,
    void Function(String errorMsg)? onError,
    String localeId = 'en-US',
  }) async {
    if (!_initialized) return;
    _onListeningStop = onDone;
    // Update the error listener for this session (public field on singleton).
    if (onError != null) {
      _stt.errorListener = (error) => onError(error.errorMsg);
    }
    // Note: SpeechToText.listen() returns bare Future (not Future<bool>).
    // Do not use its return value — rely on onStatus for state changes.
    await _stt.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult && !kIsWeb) onDone?.call();
      },
      localeId: localeId,
      listenOptions: kIsWeb
          ? null
          : SpeechListenOptions(listenMode: ListenMode.dictation),
    );
  }

  Future<void> stopListening() async {
    _onListeningStop = null;
    await _stt.stop();
  }
}
