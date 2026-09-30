import 'package:flutter/material.dart';
import '../models/sbar_data.dart';
import '../theme/app_theme.dart';
import '../utils/decimal_input_formatter.dart';

/// BGA-Abschnitt: feste, immer sichtbare Eingabefelder für die
/// Blutgasanalyse (PaO2, PaCO2, HCO3, BE, Laktat, pH, Hb, K+, BZ) sowie
/// FiO2 (für die P/F-Ratio). Berechnet automatisch die P/F-Ratio und
/// den Säure-Basen-Status (respiratorisch/metabolisch, Kompensationsgrad).
class BgaSection extends StatefulWidget {
  final SbarData sbar;
  final VoidCallback onChanged;

  const BgaSection({super.key, required this.sbar, required this.onChanged});

  @override
  State<BgaSection> createState() => _BgaSectionState();
}

class _BgaSectionState extends State<BgaSection> {
  @override
  Widget build(BuildContext context) {
    final s = widget.sbar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BGA (Blutgasanalyse)',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                label: 'FiO2 (%)',
                value: s.fiO2Prozent,
                onChanged: (v) => setState(() {
                  s.fiO2Prozent = v;
                  widget.onChanged();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                label: 'PaO2 (mmHg)',
                value: s.bgaPaO2,
                onChanged: (v) => setState(() {
                  s.bgaPaO2 = v;
                  widget.onChanged();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                label: 'PaCO2 (mmHg)',
                value: s.bgaPaCO2,
                onChanged: (v) => setState(() {
                  s.bgaPaCO2 = v;
                  widget.onChanged();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                label: 'pH-Wert',
                value: s.bgaPh,
                decimals: 2,
                onChanged: (v) => setState(() {
                  s.bgaPh = v;
                  widget.onChanged();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                label: 'HCO3 (mmol/l)',
                value: s.bgaHco3,
                onChanged: (v) => setState(() {
                  s.bgaHco3 = v;
                  widget.onChanged();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                label: 'BE (mmol/l)',
                value: s.bgaBe,
                allowNegative: true,
                onChanged: (v) => setState(() {
                  s.bgaBe = v;
                  widget.onChanged();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                label: 'Laktat (mmol/l)',
                value: s.bgaLaktat,
                onChanged: (v) => setState(() {
                  s.bgaLaktat = v;
                  widget.onChanged();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                label: 'Hb (g/dl)',
                value: s.bgaHb,
                onChanged: (v) => setState(() {
                  s.bgaHb = v;
                  widget.onChanged();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                label: 'K+ (mmol/l)',
                value: s.bgaK,
                onChanged: (v) => setState(() {
                  s.bgaK = v;
                  widget.onChanged();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                label: 'BZ (mg/dl)',
                value: s.bgaBz,
                onChanged: (v) => setState(() {
                  s.bgaBz = v;
                  widget.onChanged();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAuswertung(s),
      ],
    );
  }

  Widget _buildAuswertung(SbarData s) {
    final pf = s.pfRatio;
    final pfBewertung = s.pfRatioBewertung;
    final sb = s.saeureBasenStatus;

    if (pf == null && sb == null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.statusNeutralBg, borderRadius: BorderRadius.circular(10)),
        child: const Text(
          'Für die automatische Auswertung PaO2 + FiO2 (P/F-Ratio) bzw. pH + PaCO2 + HCO3 (Säure-Basen-Status) eingeben.',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pf != null) ...[
            Row(
              children: [
                const Icon(Icons.calculate_outlined, size: 16, color: AppColors.secondaryBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'P/F-Ratio: ${pf.toStringAsFixed(0)}${pfBewertung != null ? ' – $pfBewertung' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
          if (pf != null && sb != null) const SizedBox(height: 8),
          if (sb != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science_outlined, size: 16, color: AppColors.secondaryBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Säure-Basen-Status: $sb',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
    int decimals = 0,
    bool allowNegative = false,
  }) {
    final text = value == null ? '' : (decimals > 0 ? value.toStringAsFixed(decimals) : _fmt(value));
    final ctrl = TextEditingController(text: text);
    return TextField(
      controller: ctrl..selection = TextSelection.collapsed(offset: ctrl.text.length),
      keyboardType: decimalKeyboardType(allowNegative: allowNegative),
      inputFormatters: decimalInputFormatters(decimalDigits: 2, allowNegative: allowNegative),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.'))),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}
