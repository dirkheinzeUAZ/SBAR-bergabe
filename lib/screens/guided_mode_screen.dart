import 'package:flutter/material.dart';
import '../models/bed_patient.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_text_field.dart';

class _GuidedStep {
  final String category;
  final String question;
  final TextEditingController controller;
  final void Function(String) onSave;

  _GuidedStep({required this.category, required this.question, required this.controller, required this.onSave});
}

/// Geführter Modus: führt Schritt für Schritt durch die SBAR-Fragen.
class GuidedModeScreen extends StatefulWidget {
  final BedPatient bed;
  final StorageService storageService;

  const GuidedModeScreen({super.key, required this.bed, required this.storageService});

  @override
  State<GuidedModeScreen> createState() => _GuidedModeScreenState();
}

class _GuidedModeScreenState extends State<GuidedModeScreen> {
  late List<_GuidedStep> _steps;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final s = widget.bed.sbar;
    _steps = [
      _GuidedStep(
        category: 'Situation',
        question: 'Warum ist der Patient auf die ITS gekommen und/oder warum ist er noch da?',
        controller: TextEditingController(text: s.situation),
        onSave: (v) => s.situation = v,
      ),
      _GuidedStep(
        category: 'Background',
        question: 'Was ist die relevante Vorgeschichte? (Diagnosen, OP, Verlauf)',
        controller: TextEditingController(text: s.background),
        onSave: (v) => s.background = v,
      ),
      _GuidedStep(
        category: 'Atmung/Beatmung/BGA',
        question: 'Wie ist der aktuelle Beatmungsmodus/die Atmung? Aktuelle BGA-Werte?',
        controller: TextEditingController(text: s.atmungBeatmung),
        onSave: (v) => s.atmungBeatmung = v,
      ),
      _GuidedStep(
        category: 'Kreislauf',
        question: 'Werden Katecholamine gegeben (Substanz/Dosis)? Welche Grenzwerte gelten?',
        controller: TextEditingController(text: s.kreislauf),
        onSave: (v) => s.kreislauf = v,
      ),
      _GuidedStep(
        category: 'Wunden',
        question: 'Gibt es relevante Wunden zu berichten? (Drainagen werden separat in der Übersicht erfasst)',
        controller: TextEditingController(text: s.wunden),
        onSave: (v) => s.wunden = v,
      ),
      _GuidedStep(
        category: 'Zugänge',
        question: 'Welche Zugänge liegen aktuell (Art, Lage, seit wann)?',
        controller: TextEditingController(text: s.zugaenge),
        onSave: (v) => s.zugaenge = v,
      ),
      _GuidedStep(
        category: 'Infektionen',
        question: 'Gibt es relevante Infektionen oder ein Screening-Ergebnis mitzuteilen?',
        controller: TextEditingController(text: s.infektionenText),
        onSave: (v) => s.infektionenText = v,
      ),
      _GuidedStep(
        category: 'Recommendation – Offene Aufgaben',
        question: 'Was muss die nächste Schicht konkret erledigen?',
        controller: TextEditingController(text: s.offeneAufgaben),
        onSave: (v) => s.offeneAufgaben = v,
      ),
      _GuidedStep(
        category: 'Recommendation – Geplante Interventionen',
        question: 'Welche Interventionen/Maßnahmen sind in der kommenden Zeit geplant?',
        controller: TextEditingController(text: s.geplanteInterventionen),
        onSave: (v) => s.geplanteInterventionen = v,
      ),
    ];
  }

  @override
  void dispose() {
    for (final s in _steps) {
      s.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCurrentAndProceed({bool forward = true}) async {
    final step = _steps[_index];
    step.onSave(step.controller.text);
    widget.bed.sbar.addChange(step.category);
    await widget.storageService.saveBed(widget.bed);

    if (forward && _index < _steps.length - 1) {
      setState(() => _index++);
    } else if (!forward && _index > 0) {
      setState(() => _index--);
    } else if (forward && _index == _steps.length - 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geführte Übergabe abgeschlossen.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Geführter Modus')),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: progress, color: AppColors.primaryBlue, backgroundColor: AppColors.chipBackground),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Frage ${_index + 1} von ${_steps.length}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(20)),
                    child: Text(step.category, style: const TextStyle(color: AppColors.secondaryBlue, fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(step.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  const SizedBox(height: 16),
                  VoiceTextField(
                    label: 'Antwort',
                    controller: step.controller,
                    minLines: 4,
                    maxLines: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _saveCurrentAndProceed(forward: false),
                        child: const Text('Zurück'),
                      ),
                    ),
                  if (_index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveCurrentAndProceed(forward: true),
                      child: Text(_index == _steps.length - 1 ? 'Abschließen' : 'Weiter'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
