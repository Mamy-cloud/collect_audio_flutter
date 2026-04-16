import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/local_database.dart';
import '../services/audio_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';

// ── Départements ──────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _kDepartements = [
  {'id': 'dept_2A', 'nom': 'Corse-du-Sud'},
  {'id': 'dept_2B', 'nom': 'Haute-Corse'},
];

// ── Régions et micro-régions par département ──────────────────────────────────

const List<Map<String, dynamic>> _kRegions = [

  // ── Corse-du-Sud (2A) ─────────────────────────────────────────────────────
  {'id': 'reg_2A_01', 'departement_id': 'dept_2A', 'nom': 'Ajaccio'},
  {'id': 'reg_2A_02', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Gravona'},
  {'id': 'reg_2A_03', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Prunelli'},
  {'id': 'reg_2A_04', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Alata'},
  {'id': 'reg_2A_05', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Appietto'},
  {'id': 'reg_2A_06', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Afa'},
  {'id': 'reg_2A_07', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Aullène'},
  {'id': 'reg_2A_08', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Levie'},
  {'id': 'reg_2A_09', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Serra-di-Scopamène'},
  {'id': 'reg_2A_10', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Sartène'},
  {'id': 'reg_2A_11', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Propriano'},
  {'id': 'reg_2A_12', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Olmeto'},
  {'id': 'reg_2A_13', 'departement_id': 'dept_2A', 'nom': 'Taravo — Petreto-Bicchisano'},
  {'id': 'reg_2A_14', 'departement_id': 'dept_2A', 'nom': 'Taravo — Santa-Maria-Sicché'},
  {'id': 'reg_2A_15', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Cauro'},
  {'id': 'reg_2A_16', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Bastelicaccia'},
  {'id': 'reg_2A_17', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Eccica-Suarella'},
  {'id': 'reg_2A_18', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Calcatoggio'},
  {'id': 'reg_2A_19', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Cannelle'},
  {'id': 'reg_2A_20', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Ambiegna'},
  {'id': 'reg_2A_21', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Azzana'},
  {'id': 'reg_2A_22', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Murzo'},
  {'id': 'reg_2A_23', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Poggiolo'},
  {'id': 'reg_2A_24', 'departement_id': 'dept_2A', 'nom': 'Porto — Ota'},
  {'id': 'reg_2A_25', 'departement_id': 'dept_2A', 'nom': 'Porto — Serriera'},
  {'id': 'reg_2A_26', 'departement_id': 'dept_2A', 'nom': 'Porto — Osani'},
  {'id': 'reg_2A_27', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Calacuccia'},
  {'id': 'reg_2A_28', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Casamaccioli'},
  {'id': 'reg_2A_29', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Corscia'},
  {'id': 'reg_2A_30', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Mela'},
  {'id': 'reg_2A_31', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Zilia'},
  {'id': 'reg_2A_32', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Montegrosso'},

  // ── Haute-Corse (2B) ──────────────────────────────────────────────────────
  {'id': 'reg_2B_01', 'departement_id': 'dept_2B', 'nom': 'Bastia'},
  {'id': 'reg_2B_02', 'departement_id': 'dept_2B', 'nom': 'Bastia — Cardo'},
  {'id': 'reg_2B_03', 'departement_id': 'dept_2B', 'nom': 'Bastia — Lupino'},
  {'id': 'reg_2B_04', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Ersa'},
  {'id': 'reg_2B_05', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Rogliano'},
  {'id': 'reg_2B_06', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Pino'},
  {'id': 'reg_2B_07', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Nonza'},
  {'id': 'reg_2B_08', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Saint-Florent'},
  {'id': 'reg_2B_09', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Oletta'},
  {'id': 'reg_2B_10', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Murato'},
  {'id': 'reg_2B_11', 'departement_id': 'dept_2B', 'nom': 'Conca d\'Oro — San-Martino-di-Lota'},
  {'id': 'reg_2B_12', 'departement_id': 'dept_2B', 'nom': 'Conca d\'Oro — Ville-di-Pietrabugno'},
  {'id': 'reg_2B_13', 'departement_id': 'dept_2B', 'nom': 'Casinca — Vescovato'},
  {'id': 'reg_2B_14', 'departement_id': 'dept_2B', 'nom': 'Casinca — Penta-di-Casinca'},
  {'id': 'reg_2B_15', 'departement_id': 'dept_2B', 'nom': 'Casinca — Venzolasca'},
  {'id': 'reg_2B_16', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Piedicroce'},
  {'id': 'reg_2B_17', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Cervione'},
  {'id': 'reg_2B_18', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Orezza'},
  {'id': 'reg_2B_19', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Ghisonaccia'},
  {'id': 'reg_2B_20', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Aléria'},
  {'id': 'reg_2B_21', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Serra-di-Fiumorbo'},
  {'id': 'reg_2B_22', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Linguizzetta'},
  {'id': 'reg_2B_23', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Tallone'},
  {'id': 'reg_2B_24', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Prunete'},
  {'id': 'reg_2B_25', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Corte'},
  {'id': 'reg_2B_26', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Venaco'},
  {'id': 'reg_2B_27', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Soveria'},
  {'id': 'reg_2B_28', 'departement_id': 'dept_2B', 'nom': 'Bozio — Sermano'},
  {'id': 'reg_2B_29', 'departement_id': 'dept_2B', 'nom': 'Bozio — Bustanico'},
  {'id': 'reg_2B_30', 'departement_id': 'dept_2B', 'nom': 'Bozio — Mazzola'},
  {'id': 'reg_2B_31', 'departement_id': 'dept_2B', 'nom': 'Balagne — Calvi'},
  {'id': 'reg_2B_32', 'departement_id': 'dept_2B', 'nom': 'Balagne — L\'Île-Rousse'},
  {'id': 'reg_2B_33', 'departement_id': 'dept_2B', 'nom': 'Balagne — Belgodère'},
  {'id': 'reg_2B_34', 'departement_id': 'dept_2B', 'nom': 'Balagne — Pigna'},
  {'id': 'reg_2B_35', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Pietralba'},
  {'id': 'reg_2B_36', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Novella'},
  {'id': 'reg_2B_37', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Palasca'},
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

  static const String _apiBaseUrl = 'https://votre-api.exemple.com';

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs   = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('first_launch') ?? true;
    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showConnectionSnackbar());
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
          label: 'OK', textColor: const Color(0xFF3ECF8E), onPressed: () {}),
      ),
    );
  }

  void _onDeptChanged(String? deptId) {
    setState(() {
      _deptId          = deptId;
      _regionId        = null;
      _filteredRegions = deptId == null
          ? []
          : _kRegions.where((r) => r['departement_id'] == deptId).toList();
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context:     context,
      initialDate: DateTime(1950),
      firstDate:   DateTime(1900),
      lastDate:    DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3ECF8E), surface: Color(0xFF1A1D27)),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      _dateCtrl.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  void _removeAudio() => setState(() {
    _audioPath = null; _audioDuration = null; _hasAudio = false;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deptId   == null) { _snack('Sélectionnez un département');     return; }
    if (_regionId == null) { _snack('Sélectionnez une région');         return; }
    if (!_hasAudio)        { _snack('Ajoutez un enregistrement audio'); return; }
    if (!_acceptRgpd)      { _snack('Acceptez le partage RGPD');        return; }

    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> data = {
        'nom':            _nomCtrl.text.trim(),
        'prenom':         _prenomCtrl.text.trim(),
        'date_naissance': _dateCtrl.text.trim(),
        'departement':    _deptId,
        'region':         _regionId,
        'chemin_audio':   _audioPath,
        'duree_audio':    _audioDuration,
        'accept_rgpd':    _acceptRgpd ? 1 : 0,
        'date_creation':  DateTime.now().toIso8601String(),
      };
      await LocalDatabase.insertTemoin(data);
      // await _postToApi(data); // décommenter quand FastAPI prêt
      _snack('Sauvegardé localement ✓', success: true);
      _reset();
    } catch (e) {
      _snack('Erreur : $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

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
      _deptId = null; _regionId = null; _filteredRegions = [];
      _audioPath = null; _audioDuration = null;
      _acceptRgpd = false; _hasAudio = false;
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

              Row(children: [
                Expanded(child: CustomTextField(
                  controller: _nomCtrl, label: 'Nom *', hint: 'ex. Ferracci')),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  controller: _prenomCtrl, label: 'Prénom *', hint: 'ex. Maria')),
              ]),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _dateCtrl,
                label: 'Date de naissance *', hint: 'Sélectionner',
                readOnly: true, onTap: _pickDate,
                suffix: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF3ECF8E), size: 18),
              ),
              const SizedBox(height: 16),

              // ── Département (uniquement Corse) ────────────────────────────
              CustomDropdown(
                label:      'Département *',
                value:      _deptId,
                items:      _kDepartements,
                displayKey: 'nom',
                valueKey:   'id',
                onChanged:  _onDeptChanged,
              ),
              const SizedBox(height: 16),

              // ── Région / Micro-région filtrée ─────────────────────────────
              if (_deptId == null)
                _regionPlaceholder()
              else if (_filteredRegions.isEmpty)
                _regionEmpty()
              else
                CustomDropdown(
                  label:      'Région / Micro-région *',
                  value:      _regionId,
                  items:      _filteredRegions,
                  displayKey: 'nom',
                  valueKey:   'id',
                  onChanged:  (v) => setState(() => _regionId = v),
                ),
              const SizedBox(height: 24),

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
                    icon: Icons.upload_file_outlined, label: 'Importer MP3',
                    color: const Color(0xFF3ECF8E), onPressed: _pickAudio,
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
                  checkColor: Colors.black,
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
                  icon: const Icon(Icons.add),
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
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _audioFileCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D27),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
          color: const Color(0xFF3ECF8E).withValues(alpha: 0.4)),
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
