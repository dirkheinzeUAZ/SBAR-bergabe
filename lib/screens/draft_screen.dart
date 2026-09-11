import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bed_patient.dart';
import '../theme/app_theme.dart';

/// Zeigt einen automatisch generierten SBAR-Text-Entwurf für die nächste
/// Übergabe an, basierend auf den aktuell erfassten Daten.
class DraftScreen extends StatelessWidget {
  final BedPatient bed;

  const DraftScreen({super.key, required this.bed});

  @override
  Widget build(BuildContext context) {
    final draftText = bed.sbar.buildHandoverDraft(bedLabel: bed.bedLabel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entwurf für nächste Übergabe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'In Zwischenablage kopieren',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: draftText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entwurf wurde kopiert.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.chipBackground,
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.secondaryBlue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Automatisch aus den aktuellen Angaben erstellt. Bitte vor der Übergabe prüfen und ggf. anpassen.',
                      style: TextStyle(color: AppColors.secondaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
                  ),
                  child: SelectableText(
                    draftText,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, height: 1.5, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
