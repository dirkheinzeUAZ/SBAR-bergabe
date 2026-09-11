import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Kapselt die on-device Spracherkennung (Deutsch).
/// Läuft lokal über die Plattform-APIs, es werden keine Audiodaten
/// dauerhaft gespeichert.
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;

  Future<bool> init() async {
    if (_initialized) return _available;
    try {
      _available = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    } catch (_) {
      _available = false;
    }
    _initialized = true;
    return _available;
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'de_DE',
  }) async {
    if (!_available) {
      final ok = await init();
      if (!ok) return;
    }
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
        localeId: localeId,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
