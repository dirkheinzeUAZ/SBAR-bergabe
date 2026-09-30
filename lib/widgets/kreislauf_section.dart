import 'package:flutter/material.dart';
import '../models/sbar_data.dart';
import '../theme/app_theme.dart';
import 'decimal_number_field.dart';

/// Kreislauf-Abschnitt: Katecholamine ja/nein, pro Substanz Dosierung
/// (µg/kg/min) <-> Perfusor-Laufrate (ml/h), Umrechnung in beide Richtungen
/// basierend auf Körpergewicht und Perfusor-Konzentration.
class KreislaufSection extends StatefulWidget {
  final bool katecholamineJa;
  final List<CatecholamineEntry> entries;
  final double? patientWeightKg;
  final VoidCallback onChanged;
  final ValueChanged<bool> onJaChanged;

  const KreislaufSection({
    super.key,
    required this.katecholamineJa,
    required this.entries,
    required this.patientWeightKg,
    required this.onChanged,
    required this.onJaChanged,
  });

  @override
  State<KreislaufSection> createState() => _KreislaufSectionState();
}

class _KreislaufSectionState extends State<KreislaufSection> {
  static const List<String> _substanzen = ['Arterenol', 'Dobutamin', 'Vasopressin', 'Sonstiges'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Katecholamine', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Row(
          children: ['nein', 'ja'].map((opt) {
            final selected = widget.katecholamineJa == (opt == 'ja');
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  widget.onJaChanged(opt == 'ja');
                  if (opt == 'ja' && widget.entries.isEmpty) {
                    setState(() => widget.entries.add(CatecholamineEntry()));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderLight),
                  ),
                  child: Text(opt,
                      style: TextStyle(
                          color: selected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5)),
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.katecholamineJa) ...[
          const SizedBox(height: 14),
          if (widget.patientWeightKg == null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.statusAmberBg, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.statusAmberText),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kein Körpergewicht in den Basisdaten hinterlegt – Umrechnung nicht möglich.',
                      style: TextStyle(fontSize: 12, color: AppColors.statusAmberText),
                    ),
                  ),
                ],
              ),
            ),
          for (int i = 0; i < widget.entries.length; i++)
            _buildEntryCard(widget.entries[i], i),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() => widget.entries.add(CatecholamineEntry()));
                widget.onChanged();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Weiteres Medikament'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEntryCard(CatecholamineEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _substanzen.map((s) {
                    final selected = entry.name == s;
                    return GestureDetector(
                      onTap: () {
                        setState(() => entry.name = s);
                        widget.onChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.secondaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? AppColors.secondaryBlue : AppColors.borderLight),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textDark)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (widget.entries.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  onPressed: () {
                    setState(() => widget.entries.removeAt(index));
                    widget.onChanged();
                  },
                ),
            ],
          ),
          if (entry.name == 'Sonstiges') ...[
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'Substanz eingeben...', isDense: true),
              controller: TextEditingController(text: entry.freitext)
                ..selection = TextSelection.collapsed(offset: entry.freitext.length),
              onChanged: (v) {
                entry.freitext = v;
                widget.onChanged();
              },
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DecimalNumberField(
                  label: 'Konzentration (mg/ml)',
                  value: entry.konzentrationMgMl,
                  onChanged: (v) {
                    entry.konzentrationMgMl = v;
                    _recalcFromDosis(entry);
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecimalNumberField(
                  label: 'Dosierung (µg/kg/min)',
                  value: entry.dosierungMcgKgMin,
                  onChanged: (v) {
                    entry.dosierungMcgKgMin = v;
                    _recalcLaufrate(entry);
                    widget.onChanged();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Icon(Icons.sync_alt, size: 18, color: AppColors.textMuted),
              ),
              Expanded(
                child: DecimalNumberField(
                  label: 'Laufrate (ml/h)',
                  value: entry.laufrateMlH,
                  onChanged: (v) {
                    entry.laufrateMlH = v;
                    _recalcDosis(entry);
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Beide Felder sind verknüpft – Eingabe in einem Feld berechnet automatisch das andere (bei hinterlegtem Gewicht & Konzentration).',
            style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // Laufrate (ml/h) = Dosierung(µg/kg/min) * Gewicht(kg) * 60 / (Konzentration(mg/ml) * 1000)
  void _recalcLaufrate(CatecholamineEntry e) {
    final w = widget.patientWeightKg;
    if (w == null || e.dosierungMcgKgMin == null || e.konzentrationMgMl == null || e.konzentrationMgMl == 0) return;
    setState(() {
      e.laufrateMlH = double.parse(((e.dosierungMcgKgMin! * w * 60) / (e.konzentrationMgMl! * 1000)).toStringAsFixed(2));
    });
  }

  // Dosierung(µg/kg/min) = Laufrate(ml/h) * Konzentration(mg/ml) * 1000 / (60 * Gewicht(kg))
  void _recalcDosis(CatecholamineEntry e) {
    final w = widget.patientWeightKg;
    if (w == null || w == 0 || e.laufrateMlH == null || e.konzentrationMgMl == null) return;
    setState(() {
      e.dosierungMcgKgMin = double.parse(((e.laufrateMlH! * e.konzentrationMgMl! * 1000) / (60 * w)).toStringAsFixed(3));
    });
  }

  void _recalcFromDosis(CatecholamineEntry e) {
    if (e.dosierungMcgKgMin != null) {
      _recalcLaufrate(e);
    } else if (e.laufrateMlH != null) {
      _recalcDosis(e);
    }
  }
}
