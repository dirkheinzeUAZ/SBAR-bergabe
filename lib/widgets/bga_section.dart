import 'package:flutter/material.dart';
import '../models/sbar_data.dart';
import '../theme/app_theme.dart';
import 'decimal_number_field.dart';

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
              child: DecimalNumberField(
                label: 'FiO2 (%)',
                value: s.fiO2Prozent,
                onChanged: (v) {
                  s.fiO2Prozent = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecimalNumberField(
                label: 'PaO2 (mmHg)',
                value: s.bgaPaO2,
                onChanged: (v) {
                  s.bgaPaO2 = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DecimalNumberField(
                label: 'PaCO2 (mmHg)',
                value: s.bgaPaCO2,
                onChanged: (v) {
                  s.bgaPaCO2 = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecimalNumberField(
                label: 'pH-Wert',
                value: s.bgaPh,
                onChanged: (v) {
                  s.bgaPh = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DecimalNumberField(
                label: 'HCO3 (mmol/l)',
                value: s.bgaHco3,
                onChanged: (v) {
                  s.bgaHco3 = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecimalNumberField(
                label: 'BE (mmol/l)',
                value: s.bgaBe,
                allowNegative: true,
                onChanged: (v) {
                  s.bgaBe = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DecimalNumberField(
                label: 'Laktat (mmol/l)',
                value: s.bgaLaktat,
                onChanged: (v) {
                  s.bgaLaktat = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecimalNumberField(
                label: 'Hb (g/dl)',
                value: s.bgaHb,
                onChanged: (v) {
                  s.bgaHb = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DecimalNumberField(
                label: 'K+ (mmol/l)',
                value: s.bgaK,
                onChanged: (v) {
                  s.bgaK = v;
                  setState(() {});
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecimalNumberField(
                label: 'BZ (mg/dl)',
                value: s.bgaBz,
                onChanged: (v) {
                  s.bgaBz = v;
                  setState(() {});
                  widget.onChanged();
                },
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

}
