import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/bed_patient.dart';

/// Zentraler lokaler Speicherdienst (Hive, komplett offline / on-device).
/// Es findet KEINE Übertragung an einen Server statt.
class StorageService {
  static const String _boxName = 'beds_box';
  static const _uuid = Uuid();

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  List<BedPatient> getAllBeds() {
    final beds = <BedPatient>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        try {
          beds.add(BedPatient.fromMap(raw));
        } catch (_) {
          // korrupten Eintrag ignorieren
        }
      }
    }
    // Sortierung nach Bettbezeichnung (natürliche Sortierung best effort)
    beds.sort((a, b) => a.bedLabel.compareTo(b.bedLabel));
    return beds;
  }

  BedPatient createBed(String bedLabel) {
    final bed = BedPatient(id: _uuid.v4(), bedLabel: bedLabel);
    _box.put(bed.id, bed.toMap());
    return bed;
  }

  Future<void> saveBed(BedPatient bed) async {
    await _box.put(bed.id, bed.toMap());
  }

  Future<void> deleteBed(String id) async {
    await _box.delete(id);
  }

  BedPatient? getBed(String id) {
    final raw = _box.get(id);
    if (raw is Map) {
      return BedPatient.fromMap(raw);
    }
    return null;
  }
}
