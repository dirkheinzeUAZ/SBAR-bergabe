import 'package:flutter/material.dart';
import '../models/sbar_data.dart';
import '../theme/app_theme.dart';
import '../utils/decimal_input_formatter.dart';

/// Drainagen-Abschnitt: strukturierte Liste mit mehreren Einträgen.
/// Typen: Ventrikel, Redon, Robinson, Thorax, Easyflow.
/// Gemeinsame Felder: Lokalisation, Menge, Beschaffenheit (Sekret).
/// Zusatzfelder: Thorax -> Sog + Sog-Wert; Ventrikel -> Höhe cm über Kopf.
class DrainageSection extends StatefulWidget {
  final List<DrainageEntry> entries;
  final VoidCallback onChanged;

  const DrainageSection({super.key, required this.entries, required this.onChanged});

  @override
  State<DrainageSection> createState() => _DrainageSectionState();
}

class _DrainageSectionState extends State<DrainageSection> {
  static const List<String> _typen = ['Ventrikel', 'Redon', 'Robinson', 'Thorax', 'Easyflow'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Drainagen',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        if (widget.entries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Keine Drainagen erfasst.', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          ),
        for (int i = 0; i < widget.entries.length; i++) _buildEntryCard(widget.entries[i], i),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => widget.entries.add(DrainageEntry()));
              widget.onChanged();
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Weitere Drainage'),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(DrainageEntry entry, int index) {
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
                  children: _typen.map((t) {
                    final selected = entry.type == t;
                    return GestureDetector(
                      onTap: () {
                        setState(() => entry.type = t);
                        widget.onChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.secondaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? AppColors.secondaryBlue : AppColors.borderLight),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textDark)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  setState(() => widget.entries.removeAt(index));
                  widget.onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _textField(
            label: 'Lokalisation',
            value: entry.lokalisation,
            onChanged: (v) {
              entry.lokalisation = v;
              widget.onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Menge',
                  hint: 'z.B. 120 ml/24h',
                  value: entry.menge,
                  onChanged: (v) {
                    entry.menge = v;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                  label: 'Beschaffenheit (Sekret)',
                  hint: 'z.B. serös, blutig...',
                  value: entry.beschaffenheit,
                  onChanged: (v) {
                    entry.beschaffenheit = v;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          if (entry.type == 'Thorax') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: entry.sog,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (v) {
                    setState(() => entry.sog = v);
                    widget.onChanged();
                  },
                ),
                const Text('Sog', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 12),
                if (entry.sog)
                  Expanded(
                    child: _textField(
                      label: 'Sog-Wert',
                      hint: 'z.B. -20 cmH2O',
                      value: entry.sogWert,
                      onChanged: (v) {
                        entry.sogWert = v;
                        widget.onChanged();
                      },
                    ),
                  ),
              ],
            ),
          ],
          if (entry.type == 'Ventrikel') ...[
            const SizedBox(height: 10),
            _numberField(
              label: 'Höhe (cm über Kopf)',
              value: entry.hoeheCmUeberKopf,
              onChanged: (v) {
                setState(() => entry.hoeheCmUeberKopf = v);
                widget.onChanged();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    String? hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final ctrl = TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length);
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }

  Widget _numberField({required String label, required double? value, required ValueChanged<double?> onChanged}) {
    final ctrl = TextEditingController(text: value == null ? '' : _fmt(value));
    return TextField(
      controller: ctrl..selection = TextSelection.collapsed(offset: ctrl.text.length),
      keyboardType: decimalKeyboardType(),
      inputFormatters: decimalInputFormatters(decimalDigits: 2),
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
