import 'package:flutter/material.dart';
import '../models/bed_patient.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_text_field.dart';
import '../widgets/category_card.dart';
import '../widgets/score_selectors.dart';
import 'bed_edit_screen.dart';
import 'guided_mode_screen.dart';
import 'draft_screen.dart';
import 'change_log_screen.dart';

class SbarHandoverScreen extends StatefulWidget {
  final StorageService storageService;
  final BedPatient bed;

  const SbarHandoverScreen({super.key, required this.storageService, required this.bed});

  @override
  State<SbarHandoverScreen> createState() => _SbarHandoverScreenState();
}

class _SbarHandoverScreenState extends State<SbarHandoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers für alle Textfelder
  late TextEditingController _situationCtrl;
  late TextEditingController _backgroundCtrl;
  late TextEditingController _atmungCtrl;
  late TextEditingController _kreislaufCtrl;
  late TextEditingController _schlafCtrl;
  late TextEditingController _urinCtrl;
  late TextEditingController _stuhlgangCtrl;
  late TextEditingController _ausscheidungSonstCtrl;
  late TextEditingController _wundenCtrl;
  late TextEditingController _zugaengeCtrl;
  late TextEditingController _medikationCtrl;
  late TextEditingController _infektionenCtrl;
  late TextEditingController _isolationArtCtrl;
  late TextEditingController _laborCtrl;
  late TextEditingController _offeneAufgabenCtrl;
  late TextEditingController _interventionenCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final s = widget.bed.sbar;
    _situationCtrl = TextEditingController(text: s.situation);
    _backgroundCtrl = TextEditingController(text: s.background);
    _atmungCtrl = TextEditingController(text: s.atmungBeatmung);
    _kreislaufCtrl = TextEditingController(text: s.kreislauf);
    _schlafCtrl = TextEditingController(text: s.schlaf);
    _urinCtrl = TextEditingController(text: s.urinMlProH);
    _stuhlgangCtrl = TextEditingController(text: s.stuhlgang);
    _ausscheidungSonstCtrl = TextEditingController(text: s.ausscheidungSonstiges);
    _wundenCtrl = TextEditingController(text: s.wundenDrainagen);
    _zugaengeCtrl = TextEditingController(text: s.zugaenge);
    _medikationCtrl = TextEditingController(text: s.medikationText);
    _infektionenCtrl = TextEditingController(text: s.infektionenText);
    _isolationArtCtrl = TextEditingController(text: s.isolationArt);
    _laborCtrl = TextEditingController(text: s.laborText);
    _offeneAufgabenCtrl = TextEditingController(text: s.offeneAufgaben);
    _interventionenCtrl = TextEditingController(text: s.geplanteInterventionen);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _situationCtrl,
      _backgroundCtrl,
      _atmungCtrl,
      _kreislaufCtrl,
      _schlafCtrl,
      _urinCtrl,
      _stuhlgangCtrl,
      _ausscheidungSonstCtrl,
      _wundenCtrl,
      _zugaengeCtrl,
      _medikationCtrl,
      _infektionenCtrl,
      _isolationArtCtrl,
      _laborCtrl,
      _offeneAufgabenCtrl,
      _interventionenCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _persist() async {
    await widget.storageService.saveBed(widget.bed);
  }

  void _syncControllersToModel() {
    final s = widget.bed.sbar;
    s.situation = _situationCtrl.text;
    s.background = _backgroundCtrl.text;
    s.atmungBeatmung = _atmungCtrl.text;
    s.kreislauf = _kreislaufCtrl.text;
    s.schlaf = _schlafCtrl.text;
    s.urinMlProH = _urinCtrl.text;
    s.stuhlgang = _stuhlgangCtrl.text;
    s.ausscheidungSonstiges = _ausscheidungSonstCtrl.text;
    s.wundenDrainagen = _wundenCtrl.text;
    s.zugaenge = _zugaengeCtrl.text;
    s.medikationText = _medikationCtrl.text;
    s.infektionenText = _infektionenCtrl.text;
    s.isolationArt = _isolationArtCtrl.text;
    s.laborText = _laborCtrl.text;
    s.offeneAufgaben = _offeneAufgabenCtrl.text;
    s.geplanteInterventionen = _interventionenCtrl.text;
  }

  Future<void> _logChangeAndSave(String category) async {
    widget.bed.sbar.addChange(category);
    _syncControllersToModel();
    await _persist();
  }

  Future<void> _openGuidedMode() async {
    _syncControllersToModel();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuidedModeScreen(bed: widget.bed, storageService: widget.storageService)),
    );
    // Nach Rückkehr Controller neu befüllen (könnten sich geändert haben)
    setState(() {
      final s = widget.bed.sbar;
      _situationCtrl.text = s.situation;
      _backgroundCtrl.text = s.background;
      _atmungCtrl.text = s.atmungBeatmung;
      _kreislaufCtrl.text = s.kreislauf;
      _schlafCtrl.text = s.schlaf;
      _urinCtrl.text = s.urinMlProH;
      _stuhlgangCtrl.text = s.stuhlgang;
      _ausscheidungSonstCtrl.text = s.ausscheidungSonstiges;
      _wundenCtrl.text = s.wundenDrainagen;
      _zugaengeCtrl.text = s.zugaenge;
      _medikationCtrl.text = s.medikationText;
      _infektionenCtrl.text = s.infektionenText;
      _isolationArtCtrl.text = s.isolationArt;
      _laborCtrl.text = s.laborText;
      _offeneAufgabenCtrl.text = s.offeneAufgaben;
      _interventionenCtrl.text = s.geplanteInterventionen;
    });
  }

  void _openDraft() {
    _syncControllersToModel();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DraftScreen(bed: widget.bed)),
    );
  }

  void _openChangeLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChangeLogScreen(bed: widget.bed)),
    );
  }

  Future<void> _editBaseData() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BedEditScreen(storageService: widget.storageService, bed: widget.bed)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bed = widget.bed;
    return Scaffold(
      appBar: AppBar(
        title: Text(bed.bedLabel),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(text: 'S'),
            Tab(text: 'B'),
            Tab(text: 'A'),
            Tab(text: 'R'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), tooltip: 'Änderungsverlauf', onPressed: _openChangeLog),
          IconButton(icon: const Icon(Icons.medical_information_outlined), tooltip: 'Basisdaten', onPressed: _editBaseData),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBaseInfoBar(bed),
            _buildActionRow(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSituationTab(),
                  _buildBackgroundTab(),
                  _buildAssessmentTab(),
                  _buildRecommendationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseInfoBar(BedPatient bed) {
    final parts = <String>[];
    if (bed.gender != 'divers') parts.add(bed.gender);
    if (bed.ageYears != null) parts.add('${bed.ageYears} Jahre');
    if (bed.weightKg != null) parts.add('${bed.weightKg!.toStringAsFixed(0)} kg');
    if (bed.heightCm != null) parts.add('${bed.heightCm!.toStringAsFixed(0)} cm');
    final info = parts.join(' · ');
    return Container(
      width: double.infinity,
      color: AppColors.chipBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.secondaryBlue),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              info.isEmpty ? 'Keine Basisdaten erfasst' : info,
              style: const TextStyle(color: AppColors.secondaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (bed.allergies.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.statusRedBg, borderRadius: BorderRadius.circular(20)),
              child: const Text('Allergie!', style: TextStyle(color: AppColors.statusRedText, fontSize: 10.5, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openGuidedMode,
              icon: const Icon(Icons.checklist_rtl, size: 18),
              label: const Text('Geführter Modus', style: TextStyle(fontSize: 12.5)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _openDraft,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Entwurf erstellen', style: TextStyle(fontSize: 12.5)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSituationTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        VoiceTextField(
          label: 'S – Situation',
          hint: 'Warum ist der Patient auf die ITS gekommen und/oder warum ist er noch da?',
          controller: _situationCtrl,
          minLines: 4,
          maxLines: 10,
          onChanged: (_) => _logChangeAndSave('Situation'),
        ),
      ],
    );
  }

  Widget _buildBackgroundTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        VoiceTextField(
          label: 'B – Background',
          hint: 'Diagnose-Stichworte, OP, relevanter Verlauf...',
          controller: _backgroundCtrl,
          minLines: 4,
          maxLines: 10,
          onChanged: (_) => _logChangeAndSave('Background'),
        ),
      ],
    );
  }

  Widget _buildAssessmentTab() {
    final s = widget.bed.sbar;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        CategoryCard(
          icon: Icons.air,
          title: 'Atmung / Beatmung / BGA',
          subtitle: _atmungCtrl.text.trim().isEmpty ? 'Keine Angabe' : 'Erfasst',
          initiallyExpanded: true,
          child: VoiceTextField(
            label: '',
            hint: 'Beatmungsmodus, Parameter, BGA-Werte...',
            controller: _atmungCtrl,
            showPrivacyHint: false,
            onChanged: (_) => _logChangeAndSave('Atmung/Beatmung/BGA'),
          ),
        ),
        CategoryCard(
          icon: Icons.favorite_border,
          title: 'Kreislauf',
          subtitle: _kreislaufCtrl.text.trim().isEmpty ? 'Keine Angabe' : 'Erfasst',
          child: VoiceTextField(
            label: '',
            hint: 'Katecholamine (Substanz/Dosis), Ziel-/Grenzwerte...',
            controller: _kreislaufCtrl,
            showPrivacyHint: false,
            onChanged: (_) => _logChangeAndSave('Kreislauf'),
          ),
        ),
        CategoryCard(
          icon: Icons.psychology_outlined,
          title: 'Neurologie',
          subtitle: 'Bewusstsein, Schmerz, Schlaf',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RassSelector(
                value: s.rassScore,
                onChanged: (v) {
                  setState(() => s.rassScore = v);
                  _logChangeAndSave('Neurologie – RASS');
                },
              ),
              const SizedBox(height: 16),
              CamIcuSelector(
                value: s.camIcuStatus,
                onChanged: (v) {
                  setState(() => s.camIcuStatus = v);
                  _logChangeAndSave('Neurologie – CAM-ICU');
                },
              ),
              const SizedBox(height: 16),
              SchmerzSelector(
                skalaTyp: s.schmerzSkalaTyp,
                wert: s.schmerzWert,
                onSkalaChanged: (v) {
                  setState(() => s.schmerzSkalaTyp = v);
                  _logChangeAndSave('Neurologie – Schmerzskala');
                },
                onWertChanged: (v) {
                  setState(() => s.schmerzWert = v);
                  _logChangeAndSave('Neurologie – Schmerz');
                },
              ),
              const SizedBox(height: 16),
              VoiceTextField(
                label: 'Schlaf',
                hint: 'Kurze Einschätzung...',
                controller: _schlafCtrl,
                showPrivacyHint: false,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => _logChangeAndSave('Neurologie – Schlaf'),
              ),
            ],
          ),
        ),
        CategoryCard(
          icon: Icons.water_drop_outlined,
          title: 'Ausscheidung',
          subtitle: 'Urin, Stuhlgang, Sonstiges',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VoiceTextField(
                label: 'Urin (ml/h, im Mittel)',
                hint: 'z.B. ca. 60 ml/h',
                controller: _urinCtrl,
                showPrivacyHint: false,
                minLines: 1,
                maxLines: 2,
                onChanged: (_) => _logChangeAndSave('Ausscheidung – Urin'),
              ),
              const SizedBox(height: 14),
              VoiceTextField(
                label: 'Stuhlgang',
                hint: 'zuletzt wann, Beschaffenheit...',
                controller: _stuhlgangCtrl,
                showPrivacyHint: false,
                minLines: 1,
                maxLines: 2,
                onChanged: (_) => _logChangeAndSave('Ausscheidung – Stuhlgang'),
              ),
              const SizedBox(height: 14),
              VoiceTextField(
                label: 'Sonstiges',
                controller: _ausscheidungSonstCtrl,
                showPrivacyHint: false,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => _logChangeAndSave('Ausscheidung – Sonstiges'),
              ),
            ],
          ),
        ),
        CategoryCard(
          icon: Icons.healing_outlined,
          title: 'Wunden / Drainagen',
          subtitle: _wundenCtrl.text.trim().isEmpty ? 'Keine Angabe' : 'Erfasst',
          child: VoiceTextField(
            label: '',
            hint: 'Wundstatus, Drainagen (Art, Menge, Beschaffenheit)...',
            controller: _wundenCtrl,
            showPrivacyHint: false,
            onChanged: (_) => _logChangeAndSave('Wunden/Drainagen'),
          ),
        ),
        CategoryCard(
          icon: Icons.link,
          title: 'Zugänge',
          subtitle: _zugaengeCtrl.text.trim().isEmpty ? 'Keine Angabe' : 'Erfasst',
          child: VoiceTextField(
            label: '',
            hint: 'z.B. ZVK re. Jugularis seit 2 Tagen, Arterie li. Radialis...',
            controller: _zugaengeCtrl,
            showPrivacyHint: false,
            onChanged: (_) => _logChangeAndSave('Zugänge'),
          ),
        ),
        CategoryCard(
          icon: Icons.medication_outlined,
          title: 'Medikation / Infusion',
          subtitle: s.medikationBesonderheit ? 'Besonderheit vorhanden' : 'Unauffällig',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Besonderheit vorhanden', style: TextStyle(fontSize: 13.5)),
                value: s.medikationBesonderheit,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (v) {
                  setState(() => s.medikationBesonderheit = v);
                  _logChangeAndSave('Medikation/Infusion');
                },
              ),
              if (s.medikationBesonderheit)
                VoiceTextField(
                  label: '',
                  hint: 'Besonderheit beschreiben...',
                  controller: _medikationCtrl,
                  showPrivacyHint: false,
                  onChanged: (_) => _logChangeAndSave('Medikation/Infusion'),
                ),
            ],
          ),
        ),
        CategoryCard(
          icon: Icons.coronavirus_outlined,
          title: 'Infektionen',
          subtitle: s.isolationSchleuse ? 'Isolation/Schleuse aktiv' : 'Keine Isolation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VoiceTextField(
                label: 'Erreger / Screening-Status',
                controller: _infektionenCtrl,
                showPrivacyHint: false,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => _logChangeAndSave('Infektionen'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Isolation / Schleuse', style: TextStyle(fontSize: 13.5)),
                value: s.isolationSchleuse,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (v) {
                  setState(() => s.isolationSchleuse = v);
                  _logChangeAndSave('Infektionen – Isolation');
                },
              ),
              if (s.isolationSchleuse)
                VoiceTextField(
                  label: 'Art der Isolation',
                  hint: 'z.B. Kontaktisolation, MRE-Schleuse...',
                  controller: _isolationArtCtrl,
                  showPrivacyHint: false,
                  minLines: 1,
                  maxLines: 2,
                  onChanged: (_) => _logChangeAndSave('Infektionen – Isolationsart'),
                ),
            ],
          ),
        ),
        CategoryCard(
          icon: Icons.biotech_outlined,
          title: 'Labor',
          subtitle: s.laborBesonderheit ? 'Besonderheit vorhanden' : 'Unauffällig',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Besonderheit vorhanden', style: TextStyle(fontSize: 13.5)),
                value: s.laborBesonderheit,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (v) {
                  setState(() => s.laborBesonderheit = v);
                  _logChangeAndSave('Labor');
                },
              ),
              if (s.laborBesonderheit)
                VoiceTextField(
                  label: '',
                  hint: 'Besonderheit beschreiben...',
                  controller: _laborCtrl,
                  showPrivacyHint: false,
                  onChanged: (_) => _logChangeAndSave('Labor'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        VoiceTextField(
          label: 'Offene Aufgaben',
          hint: 'Was muss die nächste Schicht erledigen?',
          controller: _offeneAufgabenCtrl,
          minLines: 3,
          maxLines: 8,
          onChanged: (_) => _logChangeAndSave('Recommendation – Offene Aufgaben'),
        ),
        const SizedBox(height: 18),
        VoiceTextField(
          label: 'Geplante Interventionen',
          hint: 'Welche Maßnahmen sind in der kommenden Zeit geplant?',
          controller: _interventionenCtrl,
          minLines: 3,
          maxLines: 8,
          onChanged: (_) => _logChangeAndSave('Recommendation – Geplante Interventionen'),
        ),
      ],
    );
  }
}
