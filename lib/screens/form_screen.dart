import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/local_database.dart';
import '../models/witness_model.dart';
import '../services/audio_service.dart';
import '../services/cache_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nomCtrl    = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _dateCtrl   = TextEditingController();

  String?  _deptId;
  String?  _regionId;
  String?  _audioPath;
  String?  _audioDuration;
  bool     _acceptRgpd  = false;
  bool     _isRecording = false;
  bool     _hasAudio    = false;
  bool     _isSaving    = false;

  List<Map<String, dynamic>> _depts   = [];
  List<Map<String, dynamic>> _regions = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final d = await CacheService.getDepartements();
    final r = await CacheService.getRegionsCorse();
    if (mounted) setState(() { _depts = d; _regions = r; });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context, initialDate: DateTime(1950),
      firstDate: DateTime(1900), lastDate: DateTime.now(),
    );
    if (date != null) {
      _dateCtrl.text =
          '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.stopRecording();
      if (path != null) {
        final dur = await AudioService.getAudioDuration(path);
        setState(() {
          _audioPath = path; _audioDuration = dur;
          _isRecording = false; _hasAudio = true;
        });
      }
    } else {
      final ok = await AudioService.requestMicPermission();
      if (!ok) { _snack('Permission microphone refusée'); return; }
      await AudioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickAudio() async {
    final path = await AudioService.pickAudioFile();
    if (path != null) {
      final dur = await AudioService.getAudioDuration(path);
      setState(() { _audioPath = path; _audioDuration = dur; _hasAudio = true; });
    }
  }

  void _removeAudio() =>
      setState(() { _audioPath = null; _audioDuration = null; _hasAudio = false; });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deptId   == null) { _snack('Sélectionnez un département'); return; }
    if (_regionId == null) { _snack('Sélectionnez une région');     return; }
    if (!_hasAudio)        { _snack('Ajoutez un enregistrement audio'); return; }
    if (!_acceptRgpd)      { _snack('Acceptez le partage RGPD');    return; }

    setState(() => _isSaving = true);
    try {
      await LocalDatabase.insertWitness(WitnessModel(
        nom:           _nomCtrl.text.trim(),
        prenom:        _prenomCtrl.text.trim(),
        dateNaissance: _dateCtrl.text.trim(),
        departementId: _deptId!,
        regionId:      _regionId!,
        audioPath:     _audioPath,
        audioDuration: _audioDuration,
        acceptRgpd:    _acceptRgpd,
        createdAt:     DateTime.now().toIso8601String(),
      ));
      _snack('Sauvegardé localement ✓', success: true);
      _reset();
    } catch (e) {
      _snack('Erreur : $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _reset() {
    _nomCtrl.clear(); _prenomCtrl.clear(); _dateCtrl.clear();
    setState(() {
      _deptId = null; _regionId = null;
      _audioPath = null; _audioDuration = null;
      _acceptRgpd = false; _hasAudio = false;
    });
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Nouveau témoin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/transfert'),
            icon:  const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3ECF8E)),
            label: const Text('Cloud', style: TextStyle(color: Color(0xFF3ECF8E))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Nom & Prénom — CustomTextField ────────────────────────────
              Row(children: [
                Expanded(child: CustomTextField(
                  controller: _nomCtrl, label: 'Nom *', hint: 'ex. Ferracci')),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  controller: _prenomCtrl, label: 'Prénom *', hint: 'ex. Maria')),
              ]),
              const SizedBox(height: 16),

              // ── Date — CustomTextField readonly ───────────────────────────
              CustomTextField(
                controller: _dateCtrl,
                label: 'Date de naissance *', hint: 'Sélectionner',
                readOnly: true, onTap: _pickDate,
                suffix: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF3ECF8E), size: 18),
              ),
              const SizedBox(height: 16),

              // ── Département — CustomDropdown ──────────────────────────────
              CustomDropdown(
                label: 'Département *', value: _deptId,
                items: _depts, displayKey: 'name_departement',
                onChanged: (v) => setState(() => _deptId = v),
              ),
              const SizedBox(height: 16),

              // ── Région — CustomDropdown ───────────────────────────────────
              CustomDropdown(
                label: 'Région *', value: _regionId,
                items: _regions, displayKey: 'name_region',
                onChanged: (v) => setState(() => _regionId = v),
              ),
              const SizedBox(height: 24),

              // ── Audio ─────────────────────────────────────────────────────
              const Text('Enregistrement audio *',
                  style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 12,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5)),
              const SizedBox(height: 10),

              if (!_hasAudio) ...[
                Row(children: [
                  Expanded(child: _audioBtn(
                    icon:  _isRecording ? Icons.stop : Icons.mic,
                    label: _isRecording ? 'Arrêter' : 'Enregistrer',
                    color: _isRecording ? Colors.red : const Color(0xFF3ECF8E),
                    onPressed: _toggleRecording,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _audioBtn(
                    icon:  Icons.upload_file_outlined,
                    label: 'Importer MP3',
                    color: const Color(0xFF3ECF8E),
                    onPressed: _pickAudio,
                  )),
                ]),
                if (_isRecording)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(children: [
                      Icon(Icons.fiber_manual_record, color: Colors.red, size: 10),
                      SizedBox(width: 6),
                      Text('Enregistrement en cours...',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ]),
                  ),
              ] else
                _audioFileCard(),

              const SizedBox(height: 24),

              // ── RGPD ──────────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _acceptRgpd
                        ? const Color(0xFF3ECF8E).withValues(alpha: 0.6)
                        : const Color(0xFF2D3142)),
                ),
                child: CheckboxListTile(
                  value: _acceptRgpd,
                  onChanged: (v) => setState(() => _acceptRgpd = v ?? false),
                  activeColor: const Color(0xFF3ECF8E),
                  checkColor:  Colors.black,
                  title: const Text(
                    'Le témoin accepte le partage de ses informations',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: const Text(
                    'Conformément au Règlement Général sur la Protection des Données (RGPD)',
                    style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 11)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 28),

              // ── Bouton sauvegarder ────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3ECF8E),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        const Color(0xFF3ECF8E).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Sauvegarde...' : 'Sauvegarder localement',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),

              // ── Bouton remplir un autre ───────────────────────────────────
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3ECF8E),
                    side: const BorderSide(color: Color(0xFF3ECF8E)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon:  const Icon(Icons.add),
                  label: const Text('Remplir un autre formulaire',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _audioBtn({required IconData icon, required String label,
      required Color color, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _audioFileCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3ECF8E).withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.audio_file, color: Color(0xFF3ECF8E)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_audioPath!.split('/').last,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis),
            Text(_audioDuration ?? '--:--:--',
                style: const TextStyle(color: Color(0xFF8A8F9E), fontSize: 11)),
          ],
        )),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8A8F9E), size: 18),
          onPressed: _removeAudio,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _dateCtrl.dispose();
    AudioService.dispose();
    super.dispose();
  }
}
