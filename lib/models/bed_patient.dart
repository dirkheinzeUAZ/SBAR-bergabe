import 'sbar_data.dart';

/// Repräsentiert ein "Bett" auf der Intensivstation.
///
/// WICHTIG (Datenschutz-Prinzip): Es werden AUSSCHLIESSLICH nicht
/// identifizierende, medizinische Basisdaten erfasst. Es existiert
/// bewusst KEIN Feld für Name, Geburtsdatum, Adresse o.ä. – solche
/// Angaben können technisch gar nicht eingegeben werden.
class BedPatient {
  final String id; // internes technisches ID (kein Patientenbezug)
  String bedLabel; // z.B. "Bett 4" oder "Zimmer 12B"
  String gender; // 'männlich' | 'weiblich' | 'divers'
  int? ageYears;
  double? weightKg;
  double? heightCm;
  String allergies;
  String injuriesNotes; // relevante Verletzungen/Diagnosen-Stichworte

  SbarData sbar;

  DateTime createdAt;

  BedPatient({
    required this.id,
    required this.bedLabel,
    this.gender = 'divers',
    this.ageYears,
    this.weightKg,
    this.heightCm,
    this.allergies = '',
    this.injuriesNotes = '',
    SbarData? sbar,
    DateTime? createdAt,
  })  : sbar = sbar ?? SbarData(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'bedLabel': bedLabel,
        'gender': gender,
        'ageYears': ageYears,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'allergies': allergies,
        'injuriesNotes': injuriesNotes,
        'sbar': sbar.toMap(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory BedPatient.fromMap(Map map) => BedPatient(
        id: map['id']?.toString() ?? '',
        bedLabel: map['bedLabel']?.toString() ?? '',
        gender: map['gender']?.toString() ?? 'divers',
        ageYears: map['ageYears'] is int ? map['ageYears'] as int : int.tryParse(map['ageYears']?.toString() ?? ''),
        weightKg: (map['weightKg'] is num) ? (map['weightKg'] as num).toDouble() : double.tryParse(map['weightKg']?.toString() ?? ''),
        heightCm: (map['heightCm'] is num) ? (map['heightCm'] as num).toDouble() : double.tryParse(map['heightCm']?.toString() ?? ''),
        allergies: map['allergies']?.toString() ?? '',
        injuriesNotes: map['injuriesNotes']?.toString() ?? '',
        sbar: map['sbar'] != null ? SbarData.fromMap(Map<String, dynamic>.from(map['sbar'] as Map)) : SbarData(),
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  String get shortInfo {
    final parts = <String>[];
    if (gender.isNotEmpty && gender != 'divers') {
      parts.add(gender == 'männlich' ? 'm' : 'w');
    }
    if (ageYears != null) parts.add('${ageYears}J');
    return parts.join(', ');
  }
}
