import 'change_log_entry.dart';

/// Ein Katecholamin-Eintrag im Kreislauf-Bereich: Substanz + Dosierung
/// (µg/kg/min) und die daraus resultierende Perfusor-Laufrate (ml/h).
/// Die Umrechnung funktioniert in beide Richtungen (siehe KreislaufSection).
class CatecholamineEntry {
  String name; // 'Arterenol' | 'Dobutamin' | 'Vasopressin' | 'Sonstiges'
  String freitext; // nur relevant bei name == 'Sonstiges'
  double? konzentrationMgMl; // Perfusor-Konzentration
  double? dosierungMcgKgMin; // Dosierung pro kg Körpergewicht
  double? laufrateMlH; // daraus berechnete/eingegebene Perfusor-Laufrate

  CatecholamineEntry({
    this.name = 'Arterenol',
    this.freitext = '',
    this.konzentrationMgMl,
    this.dosierungMcgKgMin,
    this.laufrateMlH,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'freitext': freitext,
        'konzentrationMgMl': konzentrationMgMl,
        'dosierungMcgKgMin': dosierungMcgKgMin,
        'laufrateMlH': laufrateMlH,
      };

  factory CatecholamineEntry.fromMap(Map map) => CatecholamineEntry(
        name: map['name']?.toString() ?? 'Arterenol',
        freitext: map['freitext']?.toString() ?? '',
        konzentrationMgMl: (map['konzentrationMgMl'] as num?)?.toDouble(),
        dosierungMcgKgMin: (map['dosierungMcgKgMin'] as num?)?.toDouble(),
        laufrateMlH: (map['laufrateMlH'] as num?)?.toDouble(),
      );
}

/// Enthält den kompletten SBAR-Übergabetext für ein Bett.
/// Bewusst schlanke Struktur: alles reine medizinische Inhalte,
/// keine identifizierenden Angaben möglich.
class SbarData {
  // S – Situation
  String situation;

  // B – Background
  String background;

  // A – Assessment (Unterkategorien)

  // Atmung – strukturiert
  bool spontanatmungJa;
  String atmungsart; // 'Tubus/Trachealkanüle' | 'Maske' | 'HFNO'
  String beatmungsform; // 'kontrolliert' | 'assistiert' | 'unterstützt'
  String beatmungsmodusFreitext;
  String atmungBeatmung; // ergänzende Freitext-Angaben (BGA etc.)

  // Kreislauf – strukturiert
  bool katecholamineJa;
  List<CatecholamineEntry> katecholamine;
  String kreislauf; // ergänzende Freitext-Angaben (Ziel-/Grenzwerte etc.)

  // Neurologie
  int? rassScore; // -5 .. +4
  String camIcuStatus; // 'negativ' | 'positiv' | 'nicht erhoben'
  String schmerzSkalaTyp; // 'BPS' | 'NRS'
  int? schmerzWert;
  String schlaf;

  // Ausscheidung
  String urinMlProH;
  String stuhlgang;
  String ausscheidungSonstiges;

  // Wunden / Drainagen
  String wundenDrainagen;

  // Zugänge
  String zugaenge;

  // Medikation/Infusion – nur bei Besonderheiten
  bool medikationBesonderheit;
  String medikationText;

  // Infektionen / Schleuse
  String infektionenText;
  bool isolationSchleuse;
  String isolationArt;

  // Labor – nur bei Besonderheiten
  bool laborBesonderheit;
  String laborText;

  // R – Recommendation
  String offeneAufgaben;
  String geplanteInterventionen;

  // Änderungsverlauf (chronologisch, nur Zeitstempel + Kategorie)
  List<ChangeLogEntry> changeLog;

  DateTime updatedAt;

  SbarData({
    this.situation = '',
    this.background = '',
    this.spontanatmungJa = true,
    this.atmungsart = 'Tubus/Trachealkanüle',
    this.beatmungsform = 'kontrolliert',
    this.beatmungsmodusFreitext = '',
    this.atmungBeatmung = '',
    this.katecholamineJa = false,
    List<CatecholamineEntry>? katecholamine,
    this.kreislauf = '',
    this.rassScore,
    this.camIcuStatus = 'nicht erhoben',
    this.schmerzSkalaTyp = 'NRS',
    this.schmerzWert,
    this.schlaf = '',
    this.urinMlProH = '',
    this.stuhlgang = '',
    this.ausscheidungSonstiges = '',
    this.wundenDrainagen = '',
    this.zugaenge = '',
    this.medikationBesonderheit = false,
    this.medikationText = '',
    this.infektionenText = '',
    this.isolationSchleuse = false,
    this.isolationArt = '',
    this.laborBesonderheit = false,
    this.laborText = '',
    this.offeneAufgaben = '',
    this.geplanteInterventionen = '',
    List<ChangeLogEntry>? changeLog,
    DateTime? updatedAt,
  })  : katecholamine = katecholamine ?? [],
        changeLog = changeLog ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  void addChange(String categoryLabel, {String? note}) {
    changeLog.insert(
      0,
      ChangeLogEntry(timestamp: DateTime.now(), categoryLabel: categoryLabel, note: note),
    );
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toMap() => {
        'situation': situation,
        'background': background,
        'spontanatmungJa': spontanatmungJa,
        'atmungsart': atmungsart,
        'beatmungsform': beatmungsform,
        'beatmungsmodusFreitext': beatmungsmodusFreitext,
        'atmungBeatmung': atmungBeatmung,
        'katecholamineJa': katecholamineJa,
        'katecholamine': katecholamine.map((e) => e.toMap()).toList(),
        'kreislauf': kreislauf,
        'rassScore': rassScore,
        'camIcuStatus': camIcuStatus,
        'schmerzSkalaTyp': schmerzSkalaTyp,
        'schmerzWert': schmerzWert,
        'schlaf': schlaf,
        'urinMlProH': urinMlProH,
        'stuhlgang': stuhlgang,
        'ausscheidungSonstiges': ausscheidungSonstiges,
        'wundenDrainagen': wundenDrainagen,
        'zugaenge': zugaenge,
        'medikationBesonderheit': medikationBesonderheit,
        'medikationText': medikationText,
        'infektionenText': infektionenText,
        'isolationSchleuse': isolationSchleuse,
        'isolationArt': isolationArt,
        'laborBesonderheit': laborBesonderheit,
        'laborText': laborText,
        'offeneAufgaben': offeneAufgaben,
        'geplanteInterventionen': geplanteInterventionen,
        'changeLog': changeLog.map((e) => e.toMap()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SbarData.fromMap(Map map) {
    return SbarData(
      situation: map['situation']?.toString() ?? '',
      background: map['background']?.toString() ?? '',
      spontanatmungJa: map['spontanatmungJa'] == null ? true : map['spontanatmungJa'] == true,
      atmungsart: map['atmungsart']?.toString() ?? 'Tubus/Trachealkanüle',
      beatmungsform: map['beatmungsform']?.toString() ?? 'kontrolliert',
      beatmungsmodusFreitext: map['beatmungsmodusFreitext']?.toString() ?? '',
      atmungBeatmung: map['atmungBeatmung']?.toString() ?? '',
      katecholamineJa: map['katecholamineJa'] == true,
      katecholamine: (map['katecholamine'] as List? ?? [])
          .map((e) => CatecholamineEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      kreislauf: map['kreislauf']?.toString() ?? '',
      rassScore: map['rassScore'] is int ? map['rassScore'] as int : int.tryParse(map['rassScore']?.toString() ?? ''),
      camIcuStatus: map['camIcuStatus']?.toString() ?? 'nicht erhoben',
      schmerzSkalaTyp: map['schmerzSkalaTyp']?.toString() ?? 'NRS',
      schmerzWert: map['schmerzWert'] is int ? map['schmerzWert'] as int : int.tryParse(map['schmerzWert']?.toString() ?? ''),
      schlaf: map['schlaf']?.toString() ?? '',
      urinMlProH: map['urinMlProH']?.toString() ?? '',
      stuhlgang: map['stuhlgang']?.toString() ?? '',
      ausscheidungSonstiges: map['ausscheidungSonstiges']?.toString() ?? '',
      wundenDrainagen: map['wundenDrainagen']?.toString() ?? '',
      zugaenge: map['zugaenge']?.toString() ?? '',
      medikationBesonderheit: map['medikationBesonderheit'] == true,
      medikationText: map['medikationText']?.toString() ?? '',
      infektionenText: map['infektionenText']?.toString() ?? '',
      isolationSchleuse: map['isolationSchleuse'] == true,
      isolationArt: map['isolationArt']?.toString() ?? '',
      laborBesonderheit: map['laborBesonderheit'] == true,
      laborText: map['laborText']?.toString() ?? '',
      offeneAufgaben: map['offeneAufgaben']?.toString() ?? '',
      geplanteInterventionen: map['geplanteInterventionen']?.toString() ?? '',
      changeLog: (map['changeLog'] as List? ?? [])
          .map((e) => ChangeLogEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Prüft, ob überhaupt inhaltliche Angaben vorhanden sind (für Status-Anzeige).
  bool get hasAnyContent =>
      situation.trim().isNotEmpty ||
      background.trim().isNotEmpty ||
      atmungBeatmung.trim().isNotEmpty ||
      kreislauf.trim().isNotEmpty ||
      offeneAufgaben.trim().isNotEmpty;

  /// Erstellt einen strukturierten Text-Entwurf für die nächste Übergabe.
  String buildHandoverDraft({required String bedLabel}) {
    final buf = StringBuffer();
    buf.writeln('SBAR-ÜBERGABE ENTWURF – $bedLabel');
    buf.writeln('Stand: ${_formatDateTime(updatedAt)}');
    buf.writeln();
    buf.writeln('S – SITUATION');
    buf.writeln(situation.trim().isEmpty ? '– keine Angabe –' : situation.trim());
    buf.writeln();
    buf.writeln('B – BACKGROUND');
    buf.writeln(background.trim().isEmpty ? '– keine Angabe –' : background.trim());
    buf.writeln();
    buf.writeln('A – ASSESSMENT');
    buf.writeln('• Atmung: ${_atmungSummary()}${atmungBeatmung.trim().isNotEmpty ? ' – ${atmungBeatmung.trim()}' : ''}');
    buf.writeln('• Kreislauf: ${_kreislaufSummary()}${kreislauf.trim().isNotEmpty ? ' – ${kreislauf.trim()}' : ''}');
    buf.writeln('• Neurologie:');
    buf.writeln('   - Bewusstsein (RASS): ${rassScore != null ? rassScore.toString() : '– n.e. –'}');
    buf.writeln('   - Delir (CAM-ICU): $camIcuStatus');
    buf.writeln('   - Schmerz ($schmerzSkalaTyp): ${schmerzWert != null ? schmerzWert.toString() : '– n.e. –'}');
    buf.writeln('   - Schlaf: ${_orDash(schlaf)}');
    buf.writeln('• Ausscheidung: Urin ${_orDash(urinMlProH)} ml/h Ø, Stuhlgang: ${_orDash(stuhlgang)}${ausscheidungSonstiges.trim().isNotEmpty ? ', ${ausscheidungSonstiges.trim()}' : ''}');
    buf.writeln('• Wunden/Drainagen: ${_orDash(wundenDrainagen)}');
    buf.writeln('• Zugänge: ${_orDash(zugaenge)}');
    buf.writeln('• Medikation/Infusion: ${medikationBesonderheit ? _orDash(medikationText) : 'unauffällig'}');
    buf.writeln('• Infektionen/Schleuse: ${_orDash(infektionenText)}${isolationSchleuse ? ' (Isolation: ${_orDash(isolationArt)})' : ''}');
    buf.writeln('• Labor: ${laborBesonderheit ? _orDash(laborText) : 'unauffällig'}');
    buf.writeln();
    buf.writeln('R – RECOMMENDATION');
    buf.writeln('• Offene Aufgaben: ${_orDash(offeneAufgaben)}');
    buf.writeln('• Geplante Interventionen: ${_orDash(geplanteInterventionen)}');
    return buf.toString();
  }

  String _atmungSummary() {
    if (spontanatmungJa) return 'Spontanatmung';
    final art = atmungsart == 'Tubus/Trachealkanüle'
        ? 'Tubus/Trachealkanüle ($beatmungsform${beatmungsmodusFreitext.trim().isNotEmpty ? ', ${beatmungsmodusFreitext.trim()}' : ''})'
        : atmungsart;
    return art;
  }

  String _kreislaufSummary() {
    if (!katecholamineJa || katecholamine.isEmpty) return 'keine Katecholamine';
    return katecholamine.map((k) {
      final subst = k.name == 'Sonstiges' ? (k.freitext.trim().isEmpty ? 'Sonstiges' : k.freitext.trim()) : k.name;
      final dosis = k.dosierungMcgKgMin != null ? '${k.dosierungMcgKgMin} µg/kg/min' : null;
      final rate = k.laufrateMlH != null ? '${k.laufrateMlH} ml/h' : null;
      final details = [dosis, rate].where((e) => e != null).join(' / ');
      return details.isEmpty ? subst : '$subst ($details)';
    }).join(', ');
  }

  String _orDash(String s) => s.trim().isEmpty ? '–' : s.trim();

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
