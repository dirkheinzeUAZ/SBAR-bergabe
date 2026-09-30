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

/// Ein Drainagen-Eintrag: Typ (Ventrikel/Redon/Robinson/Thorax/Easyflow)
/// mit gemeinsamen Feldern (Lokalisation, Menge, Beschaffenheit/Sekret)
/// und typ-spezifischen Zusatzfeldern (Thorax: Sog + Sog-Wert;
/// Ventrikel: Höhe in cm über Kopf).
class DrainageEntry {
  String type; // 'Ventrikel' | 'Redon' | 'Robinson' | 'Thorax' | 'Easyflow'
  String lokalisation;
  String menge;
  String beschaffenheit; // Sekret-Beschaffenheit
  bool sog; // nur relevant bei type == 'Thorax'
  String sogWert; // nur relevant bei type == 'Thorax', z.B. "-20 cmH2O"
  double? hoeheCmUeberKopf; // nur relevant bei type == 'Ventrikel'

  DrainageEntry({
    this.type = 'Thorax',
    this.lokalisation = '',
    this.menge = '',
    this.beschaffenheit = '',
    this.sog = false,
    this.sogWert = '',
    this.hoeheCmUeberKopf,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'lokalisation': lokalisation,
        'menge': menge,
        'beschaffenheit': beschaffenheit,
        'sog': sog,
        'sogWert': sogWert,
        'hoeheCmUeberKopf': hoeheCmUeberKopf,
      };

  factory DrainageEntry.fromMap(Map map) => DrainageEntry(
        type: map['type']?.toString() ?? 'Thorax',
        lokalisation: map['lokalisation']?.toString() ?? '',
        menge: map['menge']?.toString() ?? '',
        beschaffenheit: map['beschaffenheit']?.toString() ?? '',
        sog: map['sog'] == true,
        sogWert: map['sogWert']?.toString() ?? '',
        hoeheCmUeberKopf: (map['hoeheCmUeberKopf'] as num?)?.toDouble(),
      );

  /// Kurzbeschreibung für den Übergabe-Entwurfstext.
  String summary() {
    final parts = <String>[];
    if (lokalisation.trim().isNotEmpty) parts.add(lokalisation.trim());
    if (menge.trim().isNotEmpty) parts.add('Menge: ${menge.trim()}');
    if (beschaffenheit.trim().isNotEmpty) parts.add('Beschaffenheit: ${beschaffenheit.trim()}');
    if (type == 'Thorax' && sog) {
      parts.add(sogWert.trim().isNotEmpty ? 'Sog: ${sogWert.trim()}' : 'Sog: ja');
    }
    if (type == 'Ventrikel' && hoeheCmUeberKopf != null) {
      parts.add('Höhe: ${hoeheCmUeberKopf!.toStringAsFixed(0)} cm über Kopf');
    }
    final details = parts.join(', ');
    return details.isEmpty ? type : '$type ($details)';
  }
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
  String atmungBeatmung; // ergänzende Freitext-Angaben

  // BGA – feste Werte (immer erfasst, für automatische Auswertung)
  double? fiO2Prozent; // FiO2 in % (für P/F-Ratio)
  double? bgaPaO2; // mmHg
  double? bgaPaCO2; // mmHg
  double? bgaHco3; // mmol/l
  double? bgaBe; // mmol/l (Base Excess)
  double? bgaLaktat; // mmol/l
  double? bgaPh;
  double? bgaHb; // g/dl
  double? bgaK; // K+ mmol/l
  double? bgaBz; // Blutzucker mg/dl

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
  String wunden; // Freitext Wundstatus
  List<DrainageEntry> drainagen; // strukturierte Drainagen-Liste

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
    this.fiO2Prozent,
    this.bgaPaO2,
    this.bgaPaCO2,
    this.bgaHco3,
    this.bgaBe,
    this.bgaLaktat,
    this.bgaPh,
    this.bgaHb,
    this.bgaK,
    this.bgaBz,
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
    this.wunden = '',
    List<DrainageEntry>? drainagen,
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
        drainagen = drainagen ?? [],
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
        'fiO2Prozent': fiO2Prozent,
        'bgaPaO2': bgaPaO2,
        'bgaPaCO2': bgaPaCO2,
        'bgaHco3': bgaHco3,
        'bgaBe': bgaBe,
        'bgaLaktat': bgaLaktat,
        'bgaPh': bgaPh,
        'bgaHb': bgaHb,
        'bgaK': bgaK,
        'bgaBz': bgaBz,
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
        'wunden': wunden,
        'drainagen': drainagen.map((e) => e.toMap()).toList(),
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
      fiO2Prozent: (map['fiO2Prozent'] as num?)?.toDouble(),
      bgaPaO2: (map['bgaPaO2'] as num?)?.toDouble(),
      bgaPaCO2: (map['bgaPaCO2'] as num?)?.toDouble(),
      bgaHco3: (map['bgaHco3'] as num?)?.toDouble(),
      bgaBe: (map['bgaBe'] as num?)?.toDouble(),
      bgaLaktat: (map['bgaLaktat'] as num?)?.toDouble(),
      bgaPh: (map['bgaPh'] as num?)?.toDouble(),
      bgaHb: (map['bgaHb'] as num?)?.toDouble(),
      bgaK: (map['bgaK'] as num?)?.toDouble(),
      bgaBz: (map['bgaBz'] as num?)?.toDouble(),
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
      wunden: map['wunden']?.toString() ?? map['wundenDrainagen']?.toString() ?? '',
      drainagen: (map['drainagen'] as List? ?? [])
          .map((e) => DrainageEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
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

  // ---------------------------------------------------------------------
  // BGA-Auswertung: P/F-Ratio (Horowitz-Quotient) & Säure-Basen-Status
  // ---------------------------------------------------------------------

  /// P/F-Ratio (Horowitz-Quotient) = PaO2 (mmHg) / FiO2 (Anteil 0.21–1.0).
  /// Liefert null, wenn PaO2 oder FiO2 nicht vorliegen.
  double? get pfRatio {
    if (bgaPaO2 == null || fiO2Prozent == null || fiO2Prozent == 0) return null;
    final fiO2Anteil = fiO2Prozent! / 100.0;
    return bgaPaO2! / fiO2Anteil;
  }

  /// Klinische Einordnung der P/F-Ratio (Berlin-Definition ARDS).
  String? get pfRatioBewertung {
    final pf = pfRatio;
    if (pf == null) return null;
    if (pf > 300) return 'unauffällig / kein ARDS';
    if (pf > 200) return 'mildes ARDS';
    if (pf > 100) return 'moderates ARDS';
    return 'schweres ARDS';
  }

  /// Automatische Säure-Basen-Analyse anhand pH, PaCO2 (mmHg) und HCO3 (mmol/l).
  /// Liefert eine kurze, klinisch verständliche Aussage
  /// (respiratorisch/metabolisch, Azidose/Alkalose, Kompensationsgrad)
  /// oder null, wenn nicht genug Werte vorliegen.
  String? get saeureBasenStatus {
    if (bgaPh == null || bgaPaCO2 == null || bgaHco3 == null) return null;
    final ph = bgaPh!;
    final paco2 = bgaPaCO2!;
    final hco3 = bgaHco3!;

    // Normbereiche
    const phLow = 7.35, phHigh = 7.45;
    const paco2Low = 35.0, paco2High = 45.0;
    const hco3Low = 22.0, hco3High = 26.0;

    final phNormal = ph >= phLow && ph <= phHigh;
    final phAcidotic = ph < phLow;
    final paco2High_ = paco2 > paco2High;
    final paco2Low_ = paco2 < paco2Low;
    final hco3Low_ = hco3 < hco3Low;
    final hco3High_ = hco3 > hco3High;

    if (phNormal && paco2 >= paco2Low && paco2 <= paco2High && hco3 >= hco3Low && hco3 <= hco3High) {
      return 'Kein Hinweis auf eine Säure-Basen-Störung (pH, PaCO2 und HCO3 im Normbereich).';
    }

    String primaerstoerung;
    String richtung = phAcidotic ? 'Azidose' : 'Alkalose';

    // Primäre respiratorische Störung: PaCO2 und pH gegensätzlich verändert
    final respiratorisch = (phAcidotic && paco2High_) || (!phAcidotic && paco2Low_);
    // Primäre metabolische Störung: HCO3 und pH gleichgerichtet verändert
    final metabolisch = (phAcidotic && hco3Low_) || (!phAcidotic && hco3High_);

    if (respiratorisch && !metabolisch) {
      primaerstoerung = 'respiratorische $richtung';
    } else if (metabolisch && !respiratorisch) {
      primaerstoerung = 'metabolische $richtung';
    } else if (respiratorisch && metabolisch) {
      primaerstoerung = 'gemischte respiratorisch-metabolische $richtung';
    } else if (!phNormal) {
      primaerstoerung = richtung;
    } else {
      // pH normal, aber PaCO2/HCO3 auffällig -> vollständig kompensierte Störung
      if (paco2High_ || hco3Low_) {
        primaerstoerung = paco2High_ ? 'respiratorische Azidose' : 'metabolische Azidose';
      } else {
        primaerstoerung = paco2Low_ ? 'respiratorische Alkalose' : 'metabolische Alkalose';
      }
      return '$primaerstoerung, vollständig kompensiert (pH im Normbereich, Gegenregulation durch ${paco2High_ || paco2Low_ ? 'metabolisches System (HCO3)' : 'respiratorisches System (PaCO2)'} aktiv).';
    }

    // Kompensationsgrad bei nicht-normalem pH bestimmen:
    // - Gegenregulierendes System (bei resp. Störung: HCO3; bei metab. Störung: PaCO2)
    //   noch im Normbereich -> nicht kompensiert
    //   außerhalb Norm, aber pH noch nicht normalisiert -> teilweise kompensiert
    String kompensation;
    if (respiratorisch && !metabolisch) {
      final hco3Ausgelenkt = hco3Low_ || hco3High_;
      kompensation = hco3Ausgelenkt ? 'teilweise kompensiert (metabolische Gegenregulation über HCO3 erkennbar)' : 'nicht kompensiert';
    } else if (metabolisch && !respiratorisch) {
      final paco2Ausgelenkt = paco2Low_ || paco2High_;
      kompensation = paco2Ausgelenkt ? 'teilweise kompensiert (respiratorische Gegenregulation über PaCO2 erkennbar)' : 'nicht kompensiert';
    } else {
      kompensation = 'gemischte Störung – Kompensationsgrad nicht sicher zuordenbar';
    }

    return '$primaerstoerung, $kompensation.';
  }

  /// Kompakter Textblock der BGA-Werte inkl. automatischer Auswertung
  /// für den Übergabe-Entwurf.
  String buildBgaSummary() {
    final buf = StringBuffer();
    final werte = <String>[];
    if (bgaPh != null) werte.add('pH ${bgaPh!.toStringAsFixed(2)}');
    if (bgaPaO2 != null) werte.add('PaO2 ${bgaPaO2!.toStringAsFixed(0)} mmHg');
    if (bgaPaCO2 != null) werte.add('PaCO2 ${bgaPaCO2!.toStringAsFixed(0)} mmHg');
    if (bgaHco3 != null) werte.add('HCO3 ${bgaHco3!.toStringAsFixed(1)} mmol/l');
    if (bgaBe != null) werte.add('BE ${bgaBe!.toStringAsFixed(1)} mmol/l');
    if (bgaLaktat != null) werte.add('Laktat ${bgaLaktat!.toStringAsFixed(1)} mmol/l');
    if (bgaHb != null) werte.add('Hb ${bgaHb!.toStringAsFixed(1)} g/dl');
    if (bgaK != null) werte.add('K+ ${bgaK!.toStringAsFixed(1)} mmol/l');
    if (bgaBz != null) werte.add('BZ ${bgaBz!.toStringAsFixed(0)} mg/dl');
    if (fiO2Prozent != null) werte.add('FiO2 ${fiO2Prozent!.toStringAsFixed(0)}%');

    if (werte.isEmpty) {
      buf.write('– keine BGA-Werte erfasst –');
      return buf.toString();
    }
    buf.write(werte.join(', '));
    final pf = pfRatio;
    if (pf != null) {
      buf.write(' | P/F-Ratio: ${pf.toStringAsFixed(0)} (${pfRatioBewertung ?? ''})');
    }
    final sb = saeureBasenStatus;
    if (sb != null) {
      buf.write(' | Säure-Basen-Status: $sb');
    }
    return buf.toString();
  }

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
    buf.writeln('   - BGA: ${buildBgaSummary()}');
    buf.writeln('• Kreislauf: ${_kreislaufSummary()}${kreislauf.trim().isNotEmpty ? ' – ${kreislauf.trim()}' : ''}');
    buf.writeln('• Neurologie:');
    buf.writeln('   - Bewusstsein (RASS): ${rassScore != null ? rassScore.toString() : '– n.e. –'}');
    buf.writeln('   - Delir (CAM-ICU): $camIcuStatus');
    buf.writeln('   - Schmerz ($schmerzSkalaTyp): ${schmerzWert != null ? schmerzWert.toString() : '– n.e. –'}');
    buf.writeln('   - Schlaf: ${_orDash(schlaf)}');
    buf.writeln('• Ausscheidung: Urin ${_orDash(urinMlProH)} ml/h Ø, Stuhlgang: ${_orDash(stuhlgang)}${ausscheidungSonstiges.trim().isNotEmpty ? ', ${ausscheidungSonstiges.trim()}' : ''}');
    buf.writeln('• Wunden: ${_orDash(wunden)}');
    buf.writeln('• Drainagen: ${_drainagenSummary()}');
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

  String _drainagenSummary() {
    if (drainagen.isEmpty) return '–';
    return drainagen.map((d) => d.summary()).join('; ');
  }

  String _orDash(String s) => s.trim().isEmpty ? '–' : s.trim();

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
