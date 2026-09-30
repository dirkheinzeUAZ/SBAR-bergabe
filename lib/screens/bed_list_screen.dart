import 'package:flutter/material.dart';
import '../models/bed_patient.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'bed_edit_screen.dart';
import 'sbar_handover_screen.dart';

class BedListScreen extends StatefulWidget {
  final StorageService storageService;

  const BedListScreen({super.key, required this.storageService});

  @override
  State<BedListScreen> createState() => _BedListScreenState();
}

class _BedListScreenState extends State<BedListScreen> {
  List<BedPatient> _beds = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadBeds();
  }

  void _loadBeds() {
    setState(() {
      _beds = widget.storageService.getAllBeds();
    });
  }

  List<BedPatient> get _filteredBeds {
    if (_search.trim().isEmpty) return _beds;
    final q = _search.toLowerCase();
    return _beds.where((b) => b.bedLabel.toLowerCase().contains(q)).toList();
  }

  Future<void> _createNewBed() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Bett anlegen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'z.B. Bett 4 oder Zimmer 12B'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Anlegen'),
          ),
        ],
      ),
    );

    if (label != null && label.isNotEmpty) {
      final bed = widget.storageService.createBed(label);
      _loadBeds();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BedEditScreen(storageService: widget.storageService, bed: bed, isNew: true),
          ),
        ).then((_) => _loadBeds());
      }
    }
  }

  Future<void> _deleteBed(BedPatient bed) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bett löschen?'),
        content: Text('${bed.bedLabel} und alle zugehörigen Übergabedaten werden entfernt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen', style: TextStyle(color: AppColors.statusRedText)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.storageService.deleteBed(bed.id);
      _loadBeds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SBAR Übergabe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            tooltip: 'Datenschutz-Hinweis',
            onPressed: () => _showPrivacyInfo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.secondaryBlue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anonymisiert: Nur Bettnummer, keine Namen oder Geburtsdaten',
                            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _infoChip('Strukturiert nach SBAR'),
                        _infoChip('Lokal auf Gerät gespeichert'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Bett suchen...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredBeds.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: _filteredBeds.length,
                      itemBuilder: (ctx, i) => _buildBedCard(_filteredBeds[i]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewBed,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        icon: const Icon(Icons.add, color: Colors.white, size: 26),
        label: const Text(
          'Bett anlegen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.secondaryBlue, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed_outlined, size: 56, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              _beds.isEmpty ? 'Noch keine Betten angelegt' : 'Kein Bett gefunden',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tippen Sie auf "Bett anlegen", um zu starten.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedCard(BedPatient bed) {
    final hasContent = bed.sbar.hasAnyContent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SbarHandoverScreen(storageService: widget.storageService, bed: bed),
            ),
          ).then((_) => _loadBeds());
        },
        onLongPress: () => _deleteBed(bed),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bed, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bed.bedLabel, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(
                      bed.shortInfo.isEmpty ? 'Keine Basisdaten erfasst' : bed.shortInfo,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: hasContent ? AppColors.statusGreenBg : AppColors.statusNeutralBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasContent ? 'erfasst' : 'offen',
                  style: TextStyle(
                    color: hasContent ? AppColors.statusGreenText : AppColors.statusNeutralText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datenschutz'),
        content: const Text(
          'Diese App speichert ausschließlich anonymisierte, medizinische Basisdaten '
          '(Geschlecht, Alter in Jahren, Gewicht, Größe, Allergien, Verletzungen) sowie '
          'die SBAR-Übergabeinhalte. Patienten werden nur über Bettnummern identifiziert.\n\n'
          'Es werden KEINE Namen, Geburtsdaten oder sonstige identifizierende Angaben '
          'abgefragt, gespeichert oder verarbeitet. Alle Daten bleiben ausschließlich lokal '
          'auf diesem Gerät – es findet keine Übertragung an einen Server statt.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Verstanden'))],
      ),
    );
  }
}
