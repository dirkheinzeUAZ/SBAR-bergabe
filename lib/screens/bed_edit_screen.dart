import 'package:flutter/material.dart';
import '../models/bed_patient.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/privacy_hint.dart';
import '../utils/decimal_input_formatter.dart';

/// Bearbeitungs-Screen für die medizinischen Basisdaten eines Bettes.
/// Enthält bewusst NUR die zulässigen, nicht identifizierenden Felder.
class BedEditScreen extends StatefulWidget {
  final StorageService storageService;
  final BedPatient bed;
  final bool isNew;

  const BedEditScreen({super.key, required this.storageService, required this.bed, this.isNew = false});

  @override
  State<BedEditScreen> createState() => _BedEditScreenState();
}

class _BedEditScreenState extends State<BedEditScreen> {
  late TextEditingController _labelCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _injuriesCtrl;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final b = widget.bed;
    _labelCtrl = TextEditingController(text: b.bedLabel);
    _ageCtrl = TextEditingController(text: b.ageYears?.toString() ?? '');
    _weightCtrl = TextEditingController(text: b.weightKg?.toString() ?? '');
    _heightCtrl = TextEditingController(text: b.heightCm?.toString() ?? '');
    _allergiesCtrl = TextEditingController(text: b.allergies);
    _injuriesCtrl = TextEditingController(text: b.injuriesNotes);
    _gender = b.gender;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _allergiesCtrl.dispose();
    _injuriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bed = widget.bed;
    bed.bedLabel = _labelCtrl.text.trim().isEmpty ? bed.bedLabel : _labelCtrl.text.trim();
    bed.gender = _gender;
    bed.ageYears = int.tryParse(_ageCtrl.text.trim());
    bed.weightKg = double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.'));
    bed.heightCm = double.tryParse(_heightCtrl.text.trim().replaceAll(',', '.'));
    bed.allergies = _allergiesCtrl.text.trim();
    bed.injuriesNotes = _injuriesCtrl.text.trim();

    await widget.storageService.saveBed(bed);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Bett anlegen' : 'Basisdaten bearbeiten'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: 'Identifikation',
              icon: Icons.bed,
              children: [
                _label('Bettbezeichnung'),
                TextField(controller: _labelCtrl, decoration: const InputDecoration(hintText: 'z.B. Bett 4')),
              ],
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Medizinische Basisdaten',
              icon: Icons.medical_information_outlined,
              children: [
                _label('Geschlecht'),
                Row(
                  children: ['männlich', 'weiblich', 'divers'].map((g) {
                    final selected = _gender == g;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(g, style: const TextStyle(fontSize: 12.5)),
                        selected: selected,
                        onSelected: (_) => setState(() => _gender = g),
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600),
                        side: BorderSide(color: selected ? AppColors.primaryBlue : AppColors.borderLight),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Alter (Jahre)'),
                          TextField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'z.B. 67'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Gewicht (kg)'),
                          TextField(
                            controller: _weightCtrl,
                            keyboardType: decimalKeyboardType(),
                            inputFormatters: decimalInputFormatters(decimalDigits: 2),
                            decoration: const InputDecoration(hintText: 'z.B. 78'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Größe (cm)'),
                TextField(
                  controller: _heightCtrl,
                  keyboardType: decimalKeyboardType(),
                  inputFormatters: decimalInputFormatters(decimalDigits: 2),
                  decoration: const InputDecoration(hintText: 'z.B. 175'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Allergien & Verletzungen',
              icon: Icons.warning_amber_outlined,
              children: [
                const PrivacyHint(),
                _label('Allergien'),
                TextField(
                  controller: _allergiesCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'z.B. Penicillin, Latex'),
                ),
                const SizedBox(height: 14),
                _label('Relevante Verletzungen / Diagnosen-Stichworte'),
                TextField(
                  controller: _injuriesCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'z.B. Polytrauma, Z.n. Reanimation'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13.5)),
      );

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.secondaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 14.5)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
