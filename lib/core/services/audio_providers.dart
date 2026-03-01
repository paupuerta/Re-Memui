import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/core/services/stt_service.dart';
import 'package:re_mem_ui/core/services/tts_service.dart';

/// Provides a singleton [TtsService], initialised on first access.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  service.initialize();
  return service;
});

/// Provides a singleton [SttService].
final sttServiceProvider = Provider<SttService>((ref) {
  return SttService();
});
