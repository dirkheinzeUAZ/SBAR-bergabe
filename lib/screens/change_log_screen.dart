import 'package:flutter/material.dart';
import '../models/bed_patient.dart';
import '../theme/app_theme.dart';

/// Zeigt den chronologischen Änderungsverlauf (nur Zeitstempel + Kategorie,
/// bewusst KEIN Autor/Name) für ein Bett an.
class ChangeLogScreen extends StatelessWidget {
  final BedPatient bed;

  const ChangeLogScreen({super.key, required this.bed});

  String _formatTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}. ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final log = bed.sbar.changeLog;
    return Scaffold(
      appBar: AppBar(title: Text('Änderungsverlauf – ${bed.bedLabel}')),
      body: SafeArea(
        child: log.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('Noch keine Änderungen erfasst', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: log.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final entry = log[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.secondaryBlue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Text(_formatTime(entry.timestamp),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 13)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(entry.categoryLabel, style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
