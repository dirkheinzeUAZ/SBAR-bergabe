import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Atmung-Abschnitt: Spontanatmung ja/nein, bei nein Auswahl des
/// Atemwegszugangs (Tubus/Trachealkanüle, Maske, HFNO); bei
/// Tubus/Trachealkanüle zusätzlich Beatmungsform + Freitext für den
/// verwendeten Modus.
class AtmungSection extends StatelessWidget {
  final bool spontanatmungJa;
  final String atmungsart;
  final String beatmungsform;
  final String beatmungsmodusFreitext;
  final ValueChanged<bool> onSpontanChanged;
  final ValueChanged<String> onAtmungsartChanged;
  final ValueChanged<String> onBeatmungsformChanged;
  final ValueChanged<String> onFreitextChanged;

  const AtmungSection({
    super.key,
    required this.spontanatmungJa,
    required this.atmungsart,
    required this.beatmungsform,
    required this.beatmungsmodusFreitext,
    required this.onSpontanChanged,
    required this.onAtmungsartChanged,
    required this.onBeatmungsformChanged,
    required this.onFreitextChanged,
  });

  static const List<String> _atmungsarten = ['Tubus/Trachealkanüle', 'Maske', 'HFNO'];
  static const List<String> _beatmungsformen = ['kontrolliert', 'assistiert', 'unterstützt'];

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderLight),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spontanatmung', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            _chip(label: 'ja', selected: spontanatmungJa, onTap: () => onSpontanChanged(true)),
            _chip(label: 'nein', selected: !spontanatmungJa, onTap: () => onSpontanChanged(false)),
          ],
        ),
        if (!spontanatmungJa) ...[
          const SizedBox(height: 12),
          const Text('Atemwegszugang', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
          const SizedBox(height: 8),
          Wrap(
            children: _atmungsarten
                .map((a) => _chip(label: a, selected: atmungsart == a, onTap: () => onAtmungsartChanged(a)))
                .toList(),
          ),
          if (atmungsart == 'Tubus/Trachealkanüle') ...[
            const SizedBox(height: 10),
            const Text('Beatmungsform', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
            const SizedBox(height: 8),
            Wrap(
              children: _beatmungsformen
                  .map((b) => _chip(label: b, selected: beatmungsform == b, onTap: () => onBeatmungsformChanged(b)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: beatmungsmodusFreitext)
                ..selection = TextSelection.collapsed(offset: beatmungsmodusFreitext.length),
              decoration: const InputDecoration(labelText: 'Verwendeter Modus', hintText: 'z.B. PCV, PSV, ASV...', isDense: true),
              onChanged: onFreitextChanged,
            ),
          ],
        ],
      ],
    );
  }
}
