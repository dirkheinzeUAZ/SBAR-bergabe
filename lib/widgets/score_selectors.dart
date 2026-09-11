import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// RASS – Richmond Agitation-Sedation Scale (-5 bis +4)
class RassSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const RassSelector({super.key, required this.value, required this.onChanged});

  static const Map<int, String> _labels = {
    4: 'Streitlustig',
    3: 'Sehr agitiert',
    2: 'Agitiert',
    1: 'Unruhig',
    0: 'Aufmerksam, ruhig',
    -1: 'Schläfrig',
    -2: 'Leichte Sedierung',
    -3: 'Mäßige Sedierung',
    -4: 'Tiefe Sedierung',
    -5: 'Nicht erweckbar',
  };

  Color _colorFor(int v) {
    if (v > 0) return AppColors.statusOrangeText;
    if (v == 0) return AppColors.statusGreenText;
    return AppColors.secondaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RASS – Bewusstsein/Sedierung', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(10, (i) => 4 - i).map((v) {
            final selected = value == v;
            final color = _colorFor(v);
            return GestureDetector(
              onTap: () => onChanged(selected ? null : v),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? color : AppColors.borderLight),
                ),
                child: Text(
                  '${v > 0 ? '+' : ''}$v',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${value! > 0 ? '+' : ''}$value  ·  ${_labels[value]}',
              style: TextStyle(color: _colorFor(value!), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

/// CAM-ICU – Delir-Screening
class CamIcuSelector extends StatelessWidget {
  final String value; // 'negativ' | 'positiv' | 'nicht erhoben'
  final ValueChanged<String> onChanged;

  const CamIcuSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = ['nicht erhoben', 'negativ', 'positiv'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CAM-ICU – Delir-Screening', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final selected = value == opt;
            Color color = AppColors.statusNeutralText;
            Color bg = AppColors.statusNeutralBg;
            if (opt == 'negativ') {
              color = AppColors.statusGreenText;
              bg = AppColors.statusGreenBg;
            } else if (opt == 'positiv') {
              color = AppColors.statusRedText;
              bg = AppColors.statusRedBg;
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? bg : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? color : AppColors.borderLight),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: selected ? color : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Schmerz-Skala: NRS (0-10, ansprechbare Pat.) oder BPS (3-12, sedierte Pat.)
class SchmerzSelector extends StatelessWidget {
  final String skalaTyp; // 'NRS' | 'BPS'
  final int? wert;
  final ValueChanged<String> onSkalaChanged;
  final ValueChanged<int?> onWertChanged;

  const SchmerzSelector({
    super.key,
    required this.skalaTyp,
    required this.wert,
    required this.onSkalaChanged,
    required this.onWertChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isNrs = skalaTyp == 'NRS';
    final min = isNrs ? 0 : 3;
    final max = isNrs ? 10 : 12;
    final count = max - min + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schmerz', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
        const SizedBox(height: 8),
        Row(
          children: ['NRS', 'BPS'].map((t) {
            final selected = skalaTyp == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t == 'NRS' ? 'NRS (ansprechbar)' : 'BPS (sediert)', style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) => onSkalaChanged(t),
                selectedColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600),
                side: BorderSide(color: selected ? AppColors.primaryBlue : AppColors.borderLight),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(count, (i) => min + i).map((v) {
            final selected = wert == v;
            Color color = AppColors.statusGreenText;
            if (isNrs) {
              if (v >= 7) {
                color = AppColors.statusRedText;
              } else if (v >= 4) {
                color = AppColors.statusAmberText;
              }
            } else {
              if (v >= 9) {
                color = AppColors.statusRedText;
              } else if (v >= 6) {
                color = AppColors.statusAmberText;
              }
            }
            return GestureDetector(
              onTap: () => onWertChanged(selected ? null : v),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: selected ? color : AppColors.borderLight),
                ),
                child: Text('$v', style: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
