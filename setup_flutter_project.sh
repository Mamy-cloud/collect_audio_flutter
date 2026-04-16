#!/bin/bash
# Structure du projet Flutter — Conta Mobile
# Crée tous les fichiers et dossiers nécessaires

PROJECT="conta_mobile"

# ─── Dossiers ─────────────────────────────────────────────────────────────────
mkdir -p $PROJECT/lib/screens
mkdir -p $PROJECT/lib/services
mkdir -p $PROJECT/lib/models
mkdir -p $PROJECT/lib/widgets
mkdir -p $PROJECT/lib/database
mkdir -p $PROJECT/assets

echo "✅ Dossiers créés"

# ─── pubspec.yaml ─────────────────────────────────────────────────────────────
cat > $PROJECT/pubspec.yaml << 'EOF'
name: conta_mobile
description: Application de collecte de témoignages audio — Offline First
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Navigation
  go_router: ^14.0.0

  # Supabase
  supabase_flutter: ^2.5.0

  # Stockage local SQLite
  sqflite: ^2.3.0
  path: ^1.9.0
  path_provider: ^2.1.0

  # Audio — enregistrement + lecture + upload
  record: ^5.1.0
  just_audio: ^0.9.0
  file_picker: ^8.0.0
  permission_handler: ^11.0.0

  # Réseau
  connectivity_plus: ^6.0.0

  # Variables d'environnement
  flutter_dotenv: ^5.1.0

  # Utilitaires
  intl: ^0.19.0
  uuid: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
EOF

# ─── .env ─────────────────────────────────────────────────────────────────────
cat > $PROJECT/.env << 'EOF'
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJxxx...
EOF

# ─── .gitignore ───────────────────────────────────────────────────────────────
cat > $PROJECT/.gitignore << 'EOF'
.env
*.iml
.gradle
/local.properties
/.idea/
.DS_Store
/build
/captures
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
EOF

# ─── main.dart ────────────────────────────────────────────────────────────────
cat > $PROJECT/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router.dart';
import 'database/local_database.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  await dotenv.load(fileName: '.env');

  // Initialiser SQLite
  await LocalDatabase.init();

  // Initialiser Supabase
  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Activer la sync automatique au retour en ligne
  SyncService.enableAutoSync();

  runApp(const ContaApp());
}

class ContaApp extends StatelessWidget {
  const ContaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Conta Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
EOF

# ─── router.dart ──────────────────────────────────────────────────────────────
cat > $PROJECT/lib/router.dart << 'EOF'
import 'package:go_router/go_router.dart';
import 'screens/form_screen.dart';
import 'screens/sync_screen.dart';

final router = GoRouter(
  initialLocation: '/formulaire',
  routes: [
    GoRoute(
      path: '/formulaire',
      name: 'formulaire',
      builder: (context, state) => const FormScreen(),
    ),
    GoRoute(
      path: '/transfert',
      name: 'transfert',
      builder: (context, state) => const SyncScreen(),
    ),
  ],
);
EOF

# ─── models/witness_model.dart ────────────────────────────────────────────────
cat > $PROJECT/lib/models/witness_model.dart << 'EOF'
class WitnessModel {
  final int?   id;
  final String nom;
  final String prenom;
  final String dateNaissance;   // format YYYY-MM-DD
  final String departementId;  // uuid FK → departements
  final String regionId;       // uuid FK → regions_corse
  final String? audioPath;     // chemin local du fichier audio
  final String? audioDuration; // format HH:MM:SS
  final bool   acceptRgpd;
  final String createdAt;
  final String syncStatus;     // pending | syncing | synced | error
  final String? supabaseId;
  final String? errorMessage;

  const WitnessModel({
    this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.departementId,
    required this.regionId,
    this.audioPath,
    this.audioDuration,
    required this.acceptRgpd,
    required this.createdAt,
    this.syncStatus = 'pending',
    this.supabaseId,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nom':            nom,
    'prenom':         prenom,
    'date_naissance': dateNaissance,
    'departement_id': departementId,
    'region_id':      regionId,
    'audio_path':     audioPath,
    'audio_duration': audioDuration,
    'accept_rgpd':    acceptRgpd ? 1 : 0,
    'created_at':     createdAt,
    'sync_status':    syncStatus,
    'supabase_id':    supabaseId,
    'error_message':  errorMessage,
  };

  factory WitnessModel.fromMap(Map<String, dynamic> map) => WitnessModel(
    id:             map['id'],
    nom:            map['nom'],
    prenom:         map['prenom'],
    dateNaissance:  map['date_naissance'],
    departementId:  map['departement_id'],
    regionId:       map['region_id'],
    audioPath:      map['audio_path'],
    audioDuration:  map['audio_duration'],
    acceptRgpd:     map['accept_rgpd'] == 1,
    createdAt:      map['created_at'],
    syncStatus:     map['sync_status'] ?? 'pending',
    supabaseId:     map['supabase_id'],
    errorMessage:   map['error_message'],
  );

  WitnessModel copyWith({
    String? syncStatus,
    String? supabaseId,
    String? errorMessage,
    String? audioPath,
    String? audioDuration,
  }) => WitnessModel(
    id:             id,
    nom:            nom,
    prenom:         prenom,
    dateNaissance:  dateNaissance,
    departementId:  departementId,
    regionId:       regionId,
    audioPath:      audioPath      ?? this.audioPath,
    audioDuration:  audioDuration  ?? this.audioDuration,
    acceptRgpd:     acceptRgpd,
    createdAt:      createdAt,
    syncStatus:     syncStatus     ?? this.syncStatus,
    supabaseId:     supabaseId     ?? this.supabaseId,
    errorMessage:   errorMessage   ?? this.errorMessage,
  );
}
EOF

# ─── database/local_database.dart ─────────────────────────────────────────────
cat > $PROJECT/lib/database/local_database.dart << 'EOF'
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/witness_model.dart';

class LocalDatabase {
  static Database? _db;

  // ── Initialisation ──────────────────────────────────────────────────────────
  static Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'conta.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS witnesses (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            nom            TEXT NOT NULL,
            prenom         TEXT NOT NULL,
            date_naissance TEXT NOT NULL,
            departement_id TEXT NOT NULL,
            region_id      TEXT NOT NULL,
            audio_path     TEXT,
            audio_duration TEXT,
            accept_rgpd    INTEGER DEFAULT 0,
            created_at     TEXT NOT NULL,
            sync_status    TEXT DEFAULT 'pending',
            supabase_id    TEXT,
            error_message  TEXT
          )
        ''');
      },
    );
  }

  static Database get db {
    if (_db == null) throw Exception('LocalDatabase non initialisée');
    return _db!;
  }

  // ── INSERT ──────────────────────────────────────────────────────────────────
  static Future<int> insertWitness(WitnessModel witness) async {
    return await db.insert('witnesses', witness.toMap());
  }

  // ── SELECT tous ─────────────────────────────────────────────────────────────
  static Future<List<WitnessModel>> getAllWitnesses() async {
    final maps = await db.query('witnesses', orderBy: 'created_at DESC');
    return maps.map(WitnessModel.fromMap).toList();
  }

  // ── SELECT pending ──────────────────────────────────────────────────────────
  static Future<List<WitnessModel>> getPendingWitnesses() async {
    final maps = await db.query(
      'witnesses',
      where: "sync_status = 'pending' OR sync_status = 'error'",
    );
    return maps.map(WitnessModel.fromMap).toList();
  }

  // ── Compte les pending ──────────────────────────────────────────────────────
  static Future<int> countPending() async {
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM witnesses WHERE sync_status = 'pending' OR sync_status = 'error'"
    );
    return result.first['count'] as int;
  }

  // ── UPDATE statut ───────────────────────────────────────────────────────────
  static Future<void> updateSyncStatus(
    int id,
    String status, {
    String? supabaseId,
    String? errorMessage,
  }) async {
    await db.update(
      'witnesses',
      {
        'sync_status':   status,
        'supabase_id':   supabaseId,
        'error_message': errorMessage,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE après sync réussie ───────────────────────────────────────────────
  static Future<void> deleteWitness(int id) async {
    await db.delete('witnesses', where: 'id = ?', whereArgs: [id]);
  }

  // ── DELETE tout ─────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await db.delete('witnesses');
  }
}
EOF

# ─── services/audio_service.dart ──────────────────────────────────────────────
cat > $PROJECT/lib/services/audio_service.dart << 'EOF'
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final _recorder = AudioRecorder();
  static final _player   = AudioPlayer();
  static String? _recordingPath;

  // ── Demander les permissions ────────────────────────────────────────────────
  static Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // ── Démarrer l'enregistrement ───────────────────────────────────────────────
  static Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw Exception('Permission micro refusée');

    final dir = await getApplicationDocumentsDirectory();
    _recordingPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: _recordingPath!,
    );
  }

  // ── Arrêter et retourner le chemin ──────────────────────────────────────────
  static Future<String?> stopRecording() async {
    await _recorder.stop();
    return _recordingPath;
  }

  // ── Pause / Resume ──────────────────────────────────────────────────────────
  static Future<void> pauseRecording()  async => await _recorder.pause();
  static Future<void> resumeRecording() async => await _recorder.resume();
  static Future<bool> isRecording()     async => await _recorder.isRecording();

  // ── Sélectionner un fichier audio existant ──────────────────────────────────
  static Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type:            FileType.audio,
      allowMultiple:   false,
      withData:        false,
      withReadStream:  false,
    );
    return result?.files.single.path;
  }

  // ── Obtenir la durée d'un fichier audio ─────────────────────────────────────
  static Future<String> getAudioDuration(String path) async {
    await _player.setFilePath(path);
    final duration = _player.duration ?? Duration.zero;
    final h  = duration.inHours.toString().padLeft(2, '0');
    final m  = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s  = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Lire un fichier audio ───────────────────────────────────────────────────
  static Future<void> playAudio(String path) async {
    await _player.setFilePath(path);
    await _player.play();
  }

  static Future<void> stopAudio() async => await _player.stop();

  static void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
EOF

# ─── services/sync_service.dart ───────────────────────────────────────────────
cat > $PROJECT/lib/services/sync_service.dart << 'EOF'
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/local_database.dart';
import '../models/witness_model.dart';

class SyncResult {
  final int uploaded;
  final int failed;
  final List<String> errors;

  const SyncResult({
    required this.uploaded,
    required this.failed,
    required this.errors,
  });
}

class SyncService {
  static final _supabase = Supabase.instance.client;

  // ── Auto-sync au retour en ligne ────────────────────────────────────────────
  static void enableAutoSync({
    void Function(SyncResult result)? onComplete,
  }) {
    Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        syncAll(onComplete: onComplete);
      }
    });
  }

  // ── Vérifier la connexion ───────────────────────────────────────────────────
  static Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  // ── Sync manuelle ou automatique ────────────────────────────────────────────
  static Future<SyncResult> syncAll({
    void Function(int synced, int total)? onProgress,
    void Function(SyncResult result)? onComplete,
  }) async {
    int uploaded = 0;
    int failed   = 0;
    final errors = <String>[];

    final pending = await LocalDatabase.getPendingWitnesses();
    if (pending.isEmpty) {
      final result = SyncResult(uploaded: 0, failed: 0, errors: []);
      onComplete?.call(result);
      return result;
    }

    for (final witness in pending) {
      try {
        await _syncOne(witness);
        uploaded++;
        onProgress?.call(uploaded, pending.length);
      } catch (e) {
        failed++;
        errors.add(e.toString());
        await LocalDatabase.updateSyncStatus(
          witness.id!,
          'error',
          errorMessage: e.toString(),
        );
      }
    }

    final result = SyncResult(uploaded: uploaded, failed: failed, errors: errors);
    onComplete?.call(result);
    return result;
  }

  // ── Sync d'un seul témoin ───────────────────────────────────────────────────
  static Future<void> _syncOne(WitnessModel witness) async {
    await LocalDatabase.updateSyncStatus(witness.id!, 'syncing');

    String? audioSupabaseId;

    // ── 1. Upload audio si présent ────────────────────────────────────────────
    if (witness.audioPath != null) {
      final file     = File(witness.audioPath!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await _supabase.storage
          .from('collect_audio')
          .upload('audios/$fileName', file);

      final publicUrl = _supabase.storage
          .from('collect_audio')
          .getPublicUrl('audios/$fileName');

      // ── 2. Insert collect_audio ───────────────────────────────────────────
      final audioData = await _supabase
          .from('collect_audio')
          .insert({
            'url':        publicUrl,
            'duration':   witness.audioDuration ?? '00:00:00',
            'created_at': witness.createdAt,
          })
          .select('id')
          .single();

      audioSupabaseId = audioData['id'];
    }

    if (audioSupabaseId == null) throw Exception('audio_id manquant');

    // ── 3. Insert collect_info_temoin ─────────────────────────────────────────
    final result = await _supabase
        .from('collect_info_temoin')
        .insert({
          'nom':            witness.nom,
          'first_name':     witness.prenom,
          'date_naissance': witness.dateNaissance,
          'accept_rgpd':    witness.acceptRgpd,
          'departement_id': witness.departementId,
          'region_id':      witness.regionId,
          'audio_id':       audioSupabaseId,
          'created_at':     witness.createdAt,
        })
        .select('id')
        .single();

    // ── 4. Marque comme synced et supprime ────────────────────────────────────
    await LocalDatabase.updateSyncStatus(
      witness.id!,
      'synced',
      supabaseId: result['id'],
    );
    await LocalDatabase.deleteWitness(witness.id!);

    // Supprime le fichier audio local après upload réussi
    if (witness.audioPath != null) {
      final file = File(witness.audioPath!);
      if (await file.exists()) await file.delete();
    }
  }
}
EOF

# ─── screens/form_screen.dart ─────────────────────────────────────────────────
cat > $PROJECT/lib/screens/form_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/witness_model.dart';
import '../database/local_database.dart';
import '../services/audio_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nomCtrl       = TextEditingController();
  final _prenomCtrl    = TextEditingController();
  final _dateCtrl      = TextEditingController();

  String?  _selectedDept;
  String?  _selectedRegion;
  String?  _audioPath;
  String?  _audioDuration;
  bool     _acceptRgpd   = false;
  bool     _isRecording  = false;
  bool     _isSaving     = false;
  bool     _hasAudio     = false;

  List<Map<String, dynamic>> _departements = [];
  List<Map<String, dynamic>> _regions      = [];

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  // ── Chargement des options depuis Supabase ──────────────────────────────────
  Future<void> _loadOptions() async {
    try {
      final depts   = await _supabase.from('departements').select('id, name_departement');
      final regions = await _supabase.from('regions_corse').select('id, name_region').order('name_region');
      if (mounted) setState(() { _departements = List<Map<String, dynamic>>.from(depts); _regions = List<Map<String, dynamic>>.from(regions); });
    } catch (_) {}
  }

  // ── Sélection de la date ────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dateCtrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  // ── Enregistrement micro ────────────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await AudioService.stopRecording();
      if (path != null) {
        final duration = await AudioService.getAudioDuration(path);
        setState(() { _audioPath = path; _audioDuration = duration; _isRecording = false; _hasAudio = true; });
      }
    } else {
      final granted = await AudioService.requestPermissions();
      if (!granted) { _showSnack('Permission micro refusée'); return; }
      await AudioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  // ── Upload fichier audio ────────────────────────────────────────────────────
  Future<void> _pickAudio() async {
    final path = await AudioService.pickAudioFile();
    if (path != null) {
      final duration = await AudioService.getAudioDuration(path);
      setState(() { _audioPath = path; _audioDuration = duration; _hasAudio = true; });
    }
  }

  // ── Suppression audio ───────────────────────────────────────────────────────
  void _removeAudio() => setState(() { _audioPath = null; _audioDuration = null; _hasAudio = false; });

  // ── Soumission du formulaire ────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptRgpd)    { _showSnack('Veuillez accepter le RGPD'); return; }
    if (!_hasAudio)      { _showSnack('Veuillez ajouter un enregistrement audio'); return; }
    if (_selectedDept   == null) { _showSnack('Sélectionnez un département'); return; }
    if (_selectedRegion == null) { _showSnack('Sélectionnez une région'); return; }

    setState(() => _isSaving = true);

    try {
      final witness = WitnessModel(
        nom:            _nomCtrl.text.trim(),
        prenom:         _prenomCtrl.text.trim(),
        dateNaissance:  _dateCtrl.text.trim(),
        departementId:  _selectedDept!,
        regionId:       _selectedRegion!,
        audioPath:      _audioPath,
        audioDuration:  _audioDuration,
        acceptRgpd:     _acceptRgpd,
        createdAt:      DateTime.now().toIso8601String(),
      );

      await LocalDatabase.insertWitness(witness);
      _showSnack('Sauvegardé localement ✓', success: true);
      _resetForm();
    } catch (e) {
      _showSnack('Erreur : $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetForm() {
    _nomCtrl.clear();
    _prenomCtrl.clear();
    _dateCtrl.clear();
    setState(() {
      _selectedDept = null; _selectedRegion = null;
      _audioPath = null; _audioDuration = null;
      _acceptRgpd = false; _hasAudio = false;
    });
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau témoin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Transfert cloud',
            onPressed: () => context.go('/transfert'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Nom & Prénom ─────────────────────────────────────────────
              Row(children: [
                Expanded(child: CustomTextField(controller: _nomCtrl,    label: 'Nom',    hint: 'ex. Ferracci', required: true)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: _prenomCtrl, label: 'Prénom', hint: 'ex. Maria',    required: true)),
              ]),
              const SizedBox(height: 12),

              // ── Date de naissance ────────────────────────────────────────
              CustomTextField(
                controller: _dateCtrl,
                label: 'Date de naissance',
                hint: 'Sélectionner',
                required: true,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 12),

              // ── Département ──────────────────────────────────────────────
              CustomDropdown(
                label: 'Département',
                value: _selectedDept,
                items: _departements.map((d) => DropdownMenuItem(value: d['id'] as String, child: Text(d['name_departement']))).toList(),
                onChanged: (v) => setState(() => _selectedDept = v),
              ),
              const SizedBox(height: 12),

              // ── Région ───────────────────────────────────────────────────
              CustomDropdown(
                label: 'Région',
                value: _selectedRegion,
                items: _regions.map((r) => DropdownMenuItem(value: r['id'] as String, child: Text(r['name_region']))).toList(),
                onChanged: (v) => setState(() => _selectedRegion = v),
              ),
              const SizedBox(height: 20),

              // ── Audio ────────────────────────────────────────────────────
              _AudioSection(
                hasAudio:     _hasAudio,
                isRecording:  _isRecording,
                audioPath:    _audioPath,
                audioDuration: _audioDuration,
                onRecord:     _toggleRecording,
                onPick:       _pickAudio,
                onRemove:     _removeAudio,
              ),
              const SizedBox(height: 20),

              // ── RGPD ─────────────────────────────────────────────────────
              Card(
                child: CheckboxListTile(
                  value: _acceptRgpd,
                  onChanged: (v) => setState(() => _acceptRgpd = v ?? false),
                  title: const Text('Le témoin accepte le traitement de ses données', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Conformément au RGPD', style: TextStyle(fontSize: 12)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 20),

              // ── Bouton sauvegarder ───────────────────────────────────────
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder localement'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _dateCtrl.dispose();
    AudioService.dispose();
    super.dispose();
  }
}

// ── Widget section audio ─────────────────────────────────────────────────────
class _AudioSection extends StatelessWidget {
  final bool     hasAudio;
  final bool     isRecording;
  final String?  audioPath;
  final String?  audioDuration;
  final VoidCallback onRecord;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _AudioSection({
    required this.hasAudio,
    required this.isRecording,
    required this.audioPath,
    required this.audioDuration,
    required this.onRecord,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enregistrement audio *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (!hasAudio) ...[
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRecord,
                    icon: Icon(isRecording ? Icons.stop : Icons.mic),
                    label: Text(isRecording ? 'Arrêter' : 'Enregistrer'),
                    style: isRecording ? OutlinedButton.styleFrom(foregroundColor: Colors.red) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importer'),
                  ),
                ),
              ]),
              if (isRecording)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Icon(Icons.circle, color: Colors.red, size: 10),
                    SizedBox(width: 6),
                    Text('Enregistrement en cours...', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ]),
                ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.audio_file, color: Colors.teal),
                title: Text(audioPath!.split('/').last, overflow: TextOverflow.ellipsis),
                subtitle: Text(audioDuration ?? '--:--:--'),
                trailing: IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
EOF

# ─── screens/sync_screen.dart ─────────────────────────────────────────────────
cat > $PROJECT/lib/screens/sync_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/local_database.dart';
import '../services/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  int    _pendingCount = 0;
  bool   _isSyncing   = false;
  bool   _isOnline    = false;
  int    _syncedCount = 0;
  int    _totalCount  = 0;
  String _statusMsg   = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final pending = await LocalDatabase.countPending();
    final online  = await SyncService.isOnline();
    setState(() { _pendingCount = pending; _isOnline = online; });
  }

  Future<void> _startSync() async {
    if (!_isOnline) {
      _showSnack('Aucune connexion internet', error: true);
      return;
    }

    setState(() { _isSyncing = true; _syncedCount = 0; _totalCount = _pendingCount; _statusMsg = 'Transfert en cours...'; });

    final result = await SyncService.syncAll(
      onProgress: (synced, total) {
        if (mounted) setState(() { _syncedCount = synced; _totalCount = total; _statusMsg = 'Transfert $synced/$total...'; });
      },
    );

    if (mounted) {
      setState(() { _isSyncing = false; _statusMsg = ''; });
      await _checkStatus();

      if (result.failed == 0) {
        _showSnack('${result.uploaded} enregistrement(s) transféré(s) ✓', success: true);
      } else {
        _showSnack('${result.uploaded} transféré(s), ${result.failed} échec(s)', error: true);
      }
    }
  }

  void _showSnack(String msg, {bool success = false, bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : error ? Colors.red : null,
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert cloud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/formulaire'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Carte statut local ───────────────────────────────────────
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage_outlined, color: Colors.teal, size: 32),
                title: const Text('Données sauvegardées localement', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$_pendingCount enregistrement(s) en attente'),
                trailing: _pendingCount > 0
                    ? Chip(label: Text('$_pendingCount'), backgroundColor: Colors.orange.shade100)
                    : const Chip(label: Text('Synchronisé'), backgroundColor: Color(0xFFDCFCE7)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Statut réseau ────────────────────────────────────────────
            Card(
              color: _isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              child: ListTile(
                leading: Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  color: _isOnline ? Colors.green : Colors.red,
                ),
                title: Text(
                  _isOnline ? 'Connexion disponible' : 'Hors connexion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _checkStatus,
                  child: const Text('Actualiser'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Progression ──────────────────────────────────────────────
            if (_isSyncing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text(_statusMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _totalCount > 0 ? _syncedCount / _totalCount : null,
                    ),
                    const SizedBox(height: 8),
                    Text('$_syncedCount / $_totalCount', style: const TextStyle(color: Colors.grey)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),

            // ── Avertissements ───────────────────────────────────────────
            if (_pendingCount > 0 && !_isOnline) ...[
              Card(
                color: Colors.orange.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('Connectez-vous à internet pour transférer les données vers le cloud.', style: TextStyle(fontSize: 13))),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Bouton transfert ─────────────────────────────────────────
            FilledButton.icon(
              onPressed: (_isSyncing || !_isOnline || _pendingCount == 0) ? null : _startSync,
              icon: _isSyncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_isSyncing ? 'Transfert en cours...' : 'Envoyer vers le cloud'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ─── widgets/custom_text_field.dart ───────────────────────────────────────────
cat > $PROJECT/lib/widgets/custom_text_field.dart << 'EOF'
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String  label;
  final String  hint;
  final bool    required;
  final bool    readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.required   = false,
    this.readOnly   = false,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:  controller,
      readOnly:    readOnly,
      onTap:       onTap,
      decoration: InputDecoration(
        labelText:   required ? '$label *' : label,
        hintText:    hint,
        border:      const OutlineInputBorder(),
        suffixIcon:  suffixIcon,
        filled:      true,
        fillColor:   Colors.grey.shade50,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null
          : null,
    );
  }
}
EOF

# ─── widgets/custom_dropdown.dart ─────────────────────────────────────────────
cat > $PROJECT/lib/widgets/custom_dropdown.dart << 'EOF'
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String   label;
  final String?  value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value:       value,
      items:       items,
      onChanged:   onChanged,
      decoration: InputDecoration(
        labelText: '$label *',
        border:    const OutlineInputBorder(),
        filled:    true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (v) => v == null ? 'Sélection obligatoire' : null,
    );
  }
}
EOF

echo ""
echo "✅ Projet Flutter structuré avec succès !"
echo ""
echo "📁 Structure créée :"
echo "   lib/main.dart"
echo "   lib/router.dart"
echo "   lib/models/witness_model.dart"
echo "   lib/database/local_database.dart"
echo "   lib/services/audio_service.dart"
echo "   lib/services/sync_service.dart"
echo "   lib/screens/form_screen.dart"
echo "   lib/screens/sync_screen.dart"
echo "   lib/widgets/custom_text_field.dart"
echo "   lib/widgets/custom_dropdown.dart"
echo ""
echo "🚀 Prochaines étapes :"
echo "   1. flutter create conta_mobile --template empty"
echo "   2. Copier les fichiers générés dans le projet"
echo "   3. flutter pub get"
echo "   4. Remplir .env avec tes clés Supabase"
echo "   5. flutter run"
