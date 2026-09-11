import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Kapselt die Spracherkennung (Deutsch).
/// - Auf Android: läuft komplett on-device über die Plattform-Engine.
/// - Im Web: nutzt die Browser-eigene Web Speech API (nur Chrome/Edge-basierte
///   Browser unterstützen das zuverlässig; Firefox/Safari nicht oder nur eingeschränkt).
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;
  String? _lastError;

  String? get lastError => _lastError;
  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;

  Future<bool> init() async {
    if (_initialized && _available) return _available;
    _lastError = null;
    try {
      _available = await _speech.initialize(
        onError: (err) {
          _lastError = err.errorMsg;
          if (kDebugMode) {
            debugPrint('SpeechService onError: ${err.errorMsg} (permanent: ${err.permanent})');
          }
        },
        onStatus: (status) {
          if (kDebugMode) {
            debugPrint('SpeechService onStatus: $status');
          }
        },
        debugLogging: kDebugMode,
      );
    } catch (e) {
      _available = false;
      _lastError = e.toString();
    }
    _initialized = true;

    if (!_available && _lastError == null) {
      if (kIsWeb) {
        _lastError =
            'Spracherkennung wird von diesem Browser nicht unterstützt. Bitte einen aktuellen Chrome- oder Edge-Browser verwenden und die Seite direkt (nicht eingebettet) öffnen.';
      } else {
        _lastError = 'Mikrofon-Berechtigung wurde nicht erteilt oder ist auf diesem Gerät nicht verfügbar.';
      }
    }
    return _available;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'de_DE',
  }) async {
    if (!_available) {
      final ok = await init();
      if (!ok) return;
    }
    _lastError = null;
    try {
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
    } catch (e) {
      _lastError = e.toString();
    }
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
