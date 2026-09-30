import 'package:flutter/material.dart';
import '../utils/decimal_input_formatter.dart' show decimalInputFormatters, decimalKeyboardType;

/// Zahlenfeld mit einem eigenen, dauerhaften [TextEditingController].
///
/// WICHTIG: Der Controller wird NUR in [initState] erzeugt und danach
/// (außer bei externen Wertänderungen, s.u.) nicht mehr neu aufgebaut.
/// Andernfalls würde bei jedem Tastendruck (Elternwidget ruft `setState`
/// auf, weil sich der gespeicherte Wert ändert) ein komplett neuer
/// Controller mit dem bereits als `double` neu formatierten Text erzeugt
/// – wodurch ein gerade eingegebenes Komma sofort wieder verschwindet
/// (z.B. "7," -> wird zu 7.0 -> Anzeige springt sofort zurück auf "7").
///
/// Externe Wertänderungen (z.B. die automatische Umrechnung
/// Dosierung <-> Laufrate bei den Katecholaminen) werden trotzdem
/// übernommen – aber nur, wenn das Feld gerade NICHT den Fokus hat,
/// damit die eigene, laufende Eingabe nie überschrieben wird.
class DecimalNumberField extends StatefulWidget {
  final String label;
  final String? hint;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool allowNegative;
  final int decimalDigits;

  const DecimalNumberField({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.onChanged,
    this.allowNegative = false,
    this.decimalDigits = 2,
  });

  @override
  State<DecimalNumberField> createState() => _DecimalNumberFieldState();
}

class _DecimalNumberFieldState extends State<DecimalNumberField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant DecimalNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      final formatted = _format(widget.value);
      if (formatted != _controller.text) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _format(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: decimalKeyboardType(allowNegative: widget.allowNegative),
      inputFormatters: decimalInputFormatters(decimalDigits: widget.decimalDigits, allowNegative: widget.allowNegative),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: (v) => widget.onChanged(double.tryParse(v.replaceAll(',', '.'))),
    );
  }
}
