import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] for voice dictation.
/// [initialize] is safe to call multiple times — it only runs once.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  void Function()? _onListeningStop;
  String? _lastErrorMessage;

  bool get isListening => _stt.isListening;
  String? get lastErrorMessage => _lastErrorMessage;

  /// Returns true if speech recognition is available and permissions were granted.
  /// Safe to call multiple times; subsequent calls are no-ops if already initialised.
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
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
      _lastErrorMessage = _initialized
          ? null
          : 'Speech recognition not available on this device';
    } catch (error) {
      _initialized = false;
      _lastErrorMessage = _mapErrorMessage(error);
    }

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
    if (!_initialized) {
      onError?.call(
        _lastErrorMessage ?? 'Speech recognition not available on this device',
      );
      return;
    }

    _onListeningStop = onDone;
    // Update the error listener for this session (public field on singleton).
    if (onError != null) {
      _stt.errorListener = (error) {
        _lastErrorMessage = error.errorMsg;
        onError(error.errorMsg);
      };
    }

    // Note: SpeechToText.listen() returns bare Future (not Future<bool>).
    // Do not use its return value — rely on onStatus for state changes.
    try {
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
    } catch (error) {
      _lastErrorMessage = _mapErrorMessage(error);
      onError?.call(_lastErrorMessage!);
    }
  }

  Future<void> stopListening() async {
    _onListeningStop = null;

    if (!_initialized) {
      return;
    }

    try {
      await _stt.stop();
    } catch (error) {
      _lastErrorMessage = _mapErrorMessage(error);
      rethrow;
    }
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString();
    final normalizedMessage = message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;

    if (normalizedMessage.toLowerCase().contains('message port closed')) {
      return 'Microphone access was interrupted by the browser. Please allow microphone access and try again.';
    }

    if (normalizedMessage.toLowerCase() == 'network') {
      return 'Speech recognition could not start in the browser. Brave often does not support this reliably; please use Chrome or Edge and check microphone permissions.';
    }

    return normalizedMessage;
  }
}
