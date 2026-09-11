import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import 'privacy_hint.dart';

/// Ein Text-Eingabefeld mit integriertem Mikrofon-Button für Spracheingabe.
/// Zeigt außerdem einen Datenschutz-Hinweis und eine sanfte Warnung, falls
/// der eingegebene Text nach einem Datum (mögliches Geburtsdatum) aussieht.
class VoiceTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool showPrivacyHint;

  const VoiceTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.minLines = 2,
    this.maxLines = 6,
    this.onChanged,
    this.showPrivacyHint = true,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _dateWarning = false;
  String _baseTextBeforeListening = '';

  @override
  void dispose() {
    _speechService.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speechService.init();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_speechService.lastError ?? 'Spracherkennung ist auf diesem Gerät nicht verfügbar.'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return;
    }

    _baseTextBeforeListening = widget.controller.text;
    setState(() => _isListening = true);

    await _speechService.startListening(
      onResult: (text, isFinal) {
        final separator = _baseTextBeforeListening.isEmpty || _baseTextBeforeListening.endsWith(' ')
            ? ''
            : ' ';
        final combined = '$_baseTextBeforeListening$separator$text';
        widget.controller.text = combined;
        widget.controller.selection = TextSelection.collapsed(offset: combined.length);
        widget.onChanged?.call(combined);
        _checkDateWarning(combined);
        if (isFinal) {
          setState(() => _isListening = false);
        }
      },
    );
  }

  void _checkDateWarning(String text) {
    final hasDate = looksLikeDatePattern(text);
    if (hasDate != _dateWarning) {
      setState(() => _dateWarning = hasDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 6),
        if (widget.showPrivacyHint) const PrivacyHint(),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            TextField(
              controller: widget.controller,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              decoration: InputDecoration(
                hintText: widget.hint,
                suffixIcon: null,
              ),
              onChanged: (v) {
                widget.onChanged?.call(v);
                _checkDateWarning(v);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: _isListening ? AppColors.statusRedText : AppColors.chipBackground,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleListening,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 18,
                      color: _isListening ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_dateWarning)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.statusOrangeText),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Das sieht nach einem Datum aus – bitte keine Geburtsdaten eintragen.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.statusOrangeText),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
