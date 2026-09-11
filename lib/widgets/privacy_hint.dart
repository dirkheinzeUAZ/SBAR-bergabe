import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kleiner, unaufdringlicher Datenschutz-Hinweis über Freitext-/Spracheingabefeldern.
class PrivacyHint extends StatelessWidget {
  const PrivacyHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Bitte keine Namen, Geburtsdaten oder sonstige identifizierende Angaben eintragen.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sehr einfache Heuristik, um typische Datumsmuster (mögliche Geburtsdaten)
/// zu erkennen. Ersetzt keine vollständige Kontrolle, ist aber ein nützlicher
/// zusätzlicher Hinweis für die Pflegeperson.
bool looksLikeDatePattern(String text) {
  final datePattern = RegExp(r'\b\d{1,2}[.\/]\d{1,2}[.\/]\d{2,4}\b');
  return datePattern.hasMatch(text);
}
