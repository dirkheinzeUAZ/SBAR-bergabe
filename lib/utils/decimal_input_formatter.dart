import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Begrenzt die Eingabe in Zahlenfeldern auf maximal [decimalDigits]
/// Nachkommastellen (Komma oder Punkt als Trennzeichen werden akzeptiert).
/// Optional wird ein führendes Minuszeichen erlaubt (z.B. für Base Excess).
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalDigits;
  final bool allowNegative;

  DecimalTextInputFormatter({this.decimalDigits = 2, this.allowNegative = false});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final pattern = allowNegative
        ? r'^-?\d*[.,]?\d{0,' + decimalDigits.toString() + r'}$'
        : r'^\d*[.,]?\d{0,' + decimalDigits.toString() + r'}$';
    final regExp = RegExp(pattern);

    if (regExp.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Fertige Formatter-Liste für [TextField.inputFormatters], mit maximal
/// zwei Nachkommastellen (Standard für alle numerischen Eingaben der App).
List<TextInputFormatter> decimalInputFormatters({int decimalDigits = 2, bool allowNegative = false}) => [
      DecimalTextInputFormatter(decimalDigits: decimalDigits, allowNegative: allowNegative),
    ];

/// Liefert den passenden Tastatur-Typ für Dezimal-Zahlenfelder.
///
/// Im Web-Preview zeigen viele Browser/Geräte bei
/// `TextInputType.numberWithOptions(decimal: true)` eine native
/// Zahlentastatur an, die je nach Geräte-Locale NUR den Punkt statt des
/// Kommas erlaubt (oder das Komma direkt blockiert). Deshalb wird auf Web
/// bewusst die normale Text-Tastatur verwendet (das Komma ist dort immer
/// eingebbar) – die Begrenzung auf Zahlen/Komma/Punkt übernimmt weiterhin
/// der [DecimalTextInputFormatter]. Auf der nativen Android-App bleibt die
/// komfortable Dezimaltastatur erhalten, da dort das Komma zuverlässig
/// verfügbar ist.
TextInputType decimalKeyboardType({bool allowNegative = false}) {
  if (kIsWeb) return TextInputType.text;
  return TextInputType.numberWithOptions(decimal: true, signed: allowNegative);
}
