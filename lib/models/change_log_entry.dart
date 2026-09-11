/// Ein einzelner Änderungs-Eintrag: NUR Zeitstempel + Kategorie.
/// Es wird bewusst KEIN Autor/Name gespeichert (Anonymitätsprinzip).
class ChangeLogEntry {
  final DateTime timestamp;
  final String categoryLabel;
  final String? note; // optionaler kurzer Hinweis, was ergänzt wurde

  ChangeLogEntry({
    required this.timestamp,
    required this.categoryLabel,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'categoryLabel': categoryLabel,
        'note': note,
      };

  factory ChangeLogEntry.fromMap(Map map) => ChangeLogEntry(
        timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
        categoryLabel: map['categoryLabel']?.toString() ?? '',
        note: map['note']?.toString(),
      );
}
