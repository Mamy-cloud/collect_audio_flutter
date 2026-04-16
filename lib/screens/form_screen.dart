import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/local_database.dart';
import '../services/audio_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';

// ── Données en dur ────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _kDepartements = [
  {'id': 'dept_01', 'nom': 'Ain'},
  {'id': 'dept_02', 'nom': 'Aisne'},
  {'id': 'dept_03', 'nom': 'Allier'},
  {'id': 'dept_06', 'nom': 'Alpes-Maritimes'},
  {'id': 'dept_13', 'nom': 'Bouches-du-Rhône'},
  {'id': 'dept_14', 'nom': 'Calvados'},
  {'id': 'dept_2A', 'nom': 'Corse-du-Sud'},
  {'id': 'dept_2B', 'nom': 'Haute-Corse'},
  {'id': 'dept_21', 'nom': 'Côte-d\'Or'},
  {'id': 'dept_31', 'nom': 'Haute-Garonne'},
  {'id': 'dept_33', 'nom': 'Gironde'},
  {'id': 'dept_34', 'nom': 'Hérault'},
  {'id': 'dept_35', 'nom': 'Ille-et-Vilaine'},
  {'id': 'dept_38', 'nom': 'Isère'},
  {'id': 'dept_44', 'nom': 'Loire-Atlantique'},
  {'id': 'dept_45', 'nom': 'Loiret'},
  {'id': 'dept_54', 'nom': 'Meurthe-et-Moselle'},
  {'id': 'dept_57', 'nom': 'Moselle'},
  {'id': 'dept_59', 'nom': 'Nord'},
  {'id': 'dept_62', 'nom': 'Pas-de-Calais'},
  {'id': 'dept_67', 'nom': 'Bas-Rhin'},
  {'id': 'dept_68', 'nom': 'Haut-Rhin'},
  {'id': 'dept_69', 'nom': 'Rhône'},
  {'id': 'dept_75', 'nom': 'Paris'},
  {'id': 'dept_76', 'nom': 'Seine-Maritime'},
  {'id': 'dept_77', 'nom': 'Seine-et-Marne'},
  {'id': 'dept_78', 'nom': 'Yvelines'},
  {'id': 'dept_80', 'nom': 'Somme'},
  {'id': 'dept_83', 'nom': 'Var'},
  {'id': 'dept_84', 'nom': 'Vaucluse'},
  {'id': 'dept_91', 'nom': 'Essonne'},
  {'id': 'dept_92', 'nom': 'Hauts-de-Seine'},
  {'id': 'dept_93', 'nom': 'Seine-Saint-Denis'},
  {'id': 'dept_94', 'nom': 'Val-de-Marne'},
  {'id': 'dept_95', 'nom': 'Val-d\'Oise'},
];

const List<Map<String, dynamic>> _kRegions = [
  {'id': 'reg_01', 'departement_id': 'dept_75', 'nom': 'Île-de-France'},
  {'id': 'reg_02', 'departement_id': 'dept_77', 'nom': 'Seine-et-Marne Est'},
  {'id': 'reg_03', 'departement_id': 'dept_78', 'nom': 'Yvelines Ouest'},
  {'id': 'reg_04', 'departement_id': 'dept_91', 'nom': 'Essonne Nord'},
  {'id': 'reg_05', 'departement_id': 'dept_92', 'nom': 'Hauts-de-Seine Centre'},
  {'id': 'reg_06', 'departement_id': 'dept_93', 'nom': 'Seine-Saint-Denis Sud'},
  {'id': 'reg_07', 'departement_id': 'dept_94', 'nom': 'Val-de-Marne Est'},
  {'id': 'reg_08', 'departement_id': 'dept_95', 'nom': 'Val-d\'Oise Nord'},
  {'id': 'reg_09', 'departement_id': 'dept_69', 'nom': 'Lyon Métropole'},
  {'id': 'reg_10', 'departement_id': 'dept_69', 'nom': 'Villeurbanne'},
  {'id': 'reg_11', 'departement_id': 'dept_13', 'nom': 'Marseille Centre'},
  {'id': 'reg_12', 'departement_id': 'dept_13', 'nom': 'Aix-en-Provence'},
  {'id': 'reg_13', 'departement_id': 'dept_31', 'nom': 'Toulouse Métropole'},
  {'id': 'reg_14', 'departement_id': 'dept_33', 'nom': 'Bordeaux Métropole'},
  {'id': 'reg_15', 'departement_id': 'dept_59', 'nom': 'Lille Métropole'},
  {'id': 'reg_16', 'departement_id': 'dept_67', 'nom': 'Strasbourg Eurométropole'},
  {'id': 'reg_17', 'departement_id': 'dept_44', 'nom': 'Nantes Métropole'},
  {'id': 'reg_18', 'departement_id': 'dept_35', 'nom': 'Rennes Métropole'},
  {'id': 'reg_19', 'departement_id': 'dept_34', 'nom': 'Montpellier Méditerranée'},
  {'id': 'reg_20', 'departement_id': 'dept_38', 'nom': 'Grenoble-Alpes'},
  {'id': 'reg_21', 'departement_id': 'dept_2A', 'nom': 'Ajaccio'},
  {'id': 'reg_22', 'departement_id': 'dept_2B', 'nom': 'Bastia'},
  {'id': 'reg_23', 'departement_id': 'dept_76', 'nom': 'Rouen Normandie'},
  {'id': 'reg_24', 'departement_id': 'dept_14', 'nom': 'Caen la Mer'},
  {'id': 'reg_25', 'departement_id': 'dept_57', 'nom': 'Metz Métropole'},
  {'id': 'reg_26', 'departement_id': 'dept_54', 'nom': 'Grand Nancy'},
  {'id': 'reg_27', 'departement_id': 'dept_06', 'nom': 'Nice Côte d\'Azur'},
  {'id': 'reg_28', 'departement_id': 'dept_83', 'nom': 'Toulon Provence'},
  {'id': 'reg_29', 'departement_id': 'dept_84', 'nom': 'Avignon'},
  {'id': 'reg_30', 'departement_id': 'dept_80', 'nom': 'Amiens Métropole'},
];

// ─────────────────────────────────────────────────────────────────────────────

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

  List<Map<String, dynamic>> _filteredRegions = [];

  // URL de l'API FastAPI — remplacez par votre URL réelle
  static const String _apiBaseUrl = 'https://votre-api.exemple.com';

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  // ── 1er lancement ──────────────────────────────────────────────────────────

  Future<void> _checkFirstLaunch() async {
    final prefs   = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('first_launch') ?? true;
    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConnectionSnackbar();
      });
      await prefs.setBool('first_launch', false);
    }
  }

  void _showConnectionSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: const [
          Icon(Icons.info_outline, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bienvenue ! Remplissez le formulaire pour enregistrer un témoin.',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ]),
        backgroundColor: const Color(0xFF1A1D27),
        behavior:        SnackBarBehavior.floating,
        duration:        const Duration(seconds: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF3ECF8E), width: 1),
        ),
        action: SnackBarAction(
          label:     'OK',
          textColor: const Color(0xFF3ECF8E),
          onPressed: () {},
        ),
      ),
    );
  }

  // ── Département → filtre régions ───────────────────────────────────────────

  void _onDeptChanged(String? deptId) {
    setState(() {
      _deptId  = deptId;
      _regionId = null;
      _filteredRegions = deptId == null
          ? []
          : _kRegions.where((r) => r['departement_id'] == deptId).toList();
    });
  }

  // ── Date ───────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context:     context,
      initialDate: DateTime(1950),
      firstDate:   DateTime(1900),
      lastDate:    DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3ECF8E),
            surface: Color(0xFF1A1D27),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      _dateCtrl.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  // ── Audio ──────────────────────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.stopRecording();
      if (path != null) {
        final dur = await AudioService.getAudioDuration(path);
        setState(() {
          _audioPath     = path;
          _audioDuration = dur;
          _isRecording   = false;
          _hasAudio      = true;
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
      setState(() {
        _audioPath     = path;
        _audioDuration = dur;
        _hasAudio      = true;
      });
    }
  }

  void _removeAudio() => setState(() {
    _audioPath = null; _audioDuration = null; _hasAudio = false;
  });

  // ── Sauvegarde SQLite ──────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deptId   == null) { _snack('Sélectionnez un département'); return; }
    if (_regionId == null) { _snack('Sélectionnez une région');     return; }
    if (!_hasAudio)        { _snack('Ajoutez un enregistrement audio'); return; }
    if (!_acceptRgpd)      { _snack('Acceptez le partage RGPD');    return; }

    setState(() => _isSaving = true);
    try {
      // Données à sauvegarder — clé/valeur directe
      final Map<String, dynamic> data = {
        'nom':           _nomCtrl.text.trim(),
        'prenom':        _prenomCtrl.text.trim(),
        'date_naissance': _dateCtrl.text.trim(),
        'departement':   _deptId,
        'region':        _regionId,
        'chemin_audio':  _audioPath,
        'duree_audio':   _audioDuration,
        'accept_rgpd':   _acceptRgpd ? 1 : 0,
        'date_creation': DateTime.now().toIso8601String(),
      };

      // 1. Sauvegarde locale SQLite
      await LocalDatabase.insertTemoin(data);

      // 2. Exemple d'appel API POST vers FastAPI (optionnel ici)
      // await _postToApi(data);

      _snack('Sauvegardé localement ✓', success: true);
      _reset();
    } catch (e) {
      _snack('Erreur : $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Exemple d'appel API POST vers FastAPI
  /// À appeler quand vous êtes prêt à connecter le backend
  Future<void> _postToApi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/temoins'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }

  void _reset() {
    _nomCtrl.clear(); _prenomCtrl.clear(); _dateCtrl.clear();
    setState(() {
      _deptId          = null;
      _regionId        = null;
      _filteredRegions = [];
      _audioPath       = null;
      _audioDuration   = null;
      _acceptRgpd      = false;
      _hasAudio        = false;
    });
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      behavior:        SnackBarBehavior.floating,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Nouveau témoin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Nom & Prénom ──────────────────────────────────────────────
              Row(children: [
                Expanded(child: CustomTextField(
                  controller: _nomCtrl, label: 'Nom *', hint: 'ex. Ferracci')),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  controller: _prenomCtrl, label: 'Prénom *', hint: 'ex. Maria')),
              ]),
              const SizedBox(height: 16),

              // ── Date de naissance ─────────────────────────────────────────
              CustomTextField(
                controller: _dateCtrl,
                label:    'Date de naissance *',
                hint:     'Sélectionner',
                readOnly: true,
                onTap:    _pickDate,
                suffix:   const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF3ECF8E), size: 18),
              ),
              const SizedBox(height: 16),

              // ── Département ───────────────────────────────────────────────
              CustomDropdown(
                label:      'Département *',
                value:      _deptId,
                items:      _kDepartements,
                displayKey: 'nom',
                valueKey:   'id',
                onChanged:  _onDeptChanged,
              ),
              const SizedBox(height: 16),

              // ── Région ────────────────────────────────────────────────────
              if (_deptId == null)
                _regionPlaceholder()
              else if (_filteredRegions.isEmpty)
                _regionEmpty()
              else
                CustomDropdown(
                  label:      'Région *',
                  value:      _regionId,
                  items:      _filteredRegions,
                  displayKey: 'nom',
                  valueKey:   'id',
                  onChanged:  (v) => setState(() => _regionId = v),
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
                  value:       _acceptRgpd,
                  onChanged:   (v) => setState(() => _acceptRgpd = v ?? false),
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
                    _isSaving ? 'Sauvegarde...' : 'Enregistrer le formulaire',
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

  // ── Widgets locaux ─────────────────────────────────────────────────────────

  Widget _regionPlaceholder() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D27),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF2D3142)),
    ),
    child: const Row(children: [
      Icon(Icons.info_outline, color: Color(0xFF3D4155), size: 16),
      SizedBox(width: 8),
      Text('Sélectionnez d\'abord un département',
          style: TextStyle(color: Color(0xFF3D4155), fontSize: 13)),
    ]),
  );

  Widget _regionEmpty() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D27),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
    ),
    child: const Row(children: [
      Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 16),
      SizedBox(width: 8),
      Text('Aucune région pour ce département',
          style: TextStyle(color: Colors.orange, fontSize: 13)),
    ]),
  );

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
      icon:  Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _audioFileCard() => Container(
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

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _dateCtrl.dispose();
    AudioService.dispose();
    super.dispose();
  }
}
