// ─── witness_model.dart ───────────────────────────────────────────────────────
// Mis à jour : age supprimé, birth_year (int) ajouté
// collect_info_temoin.birth_year = année extraite de dateNaissance
// ─────────────────────────────────────────────────────────────────────────────

class WitnessModel {
  final int?    id;
  final String  nom;
  final String  prenom;
  final String  dateNaissance;   // YYYY-MM-DD — stocké en SQLite
  final String  departementId;
  final String  regionId;
  final String? audioPath;
  final String? audioDuration;
  final bool    acceptRgpd;
  final String  createdAt;
  final String  syncStatus;
  final String? supabaseId;
  final String? audioSupabaseId;
  final String? audioPublicUrl;
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
    this.syncStatus     = 'pending',
    this.supabaseId,
    this.audioSupabaseId,
    this.audioPublicUrl,
    this.errorMessage,
  });

  // ── Extrait l'année depuis dateNaissance (YYYY-MM-DD → int) ─────────────────
  int get birthYear {
    try {
      return int.parse(dateNaissance.split('-')[0]);
    } catch (_) {
      return 0;
    }
  }

  // ── SQLite → WitnessModel ──────────────────────────────────────────────────

  factory WitnessModel.fromMap(Map<String, dynamic> m) => WitnessModel(
    id:              m['id'] as int?,
    nom:             m['nom'] as String,
    prenom:          m['prenom'] as String,
    dateNaissance:   m['date_naissance'] as String,
    departementId:   m['departement_id'] as String,
    regionId:        m['region_id'] as String,
    audioPath:       m['audio_path'] as String?,
    audioDuration:   m['audio_duration'] as String?,
    acceptRgpd:      (m['accept_rgpd'] as int) == 1,
    createdAt:       m['created_at'] as String,
    syncStatus:      m['sync_status'] as String? ?? 'pending',
    supabaseId:      m['supabase_id'] as String?,
    audioSupabaseId: m['audio_supabase_id'] as String?,
    audioPublicUrl:  m['audio_public_url'] as String?,
    errorMessage:    m['error_message'] as String?,
  );

  // ── WitnessModel → SQLite ──────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nom':               nom,
    'prenom':            prenom,
    'date_naissance':    dateNaissance,   // stocké tel quel en SQLite
    'departement_id':    departementId,
    'region_id':         regionId,
    'audio_path':        audioPath,
    'audio_duration':    audioDuration,
    'accept_rgpd':       acceptRgpd ? 1 : 0,
    'created_at':        createdAt,
    'sync_status':       syncStatus,
    'supabase_id':       supabaseId,
    'audio_supabase_id': audioSupabaseId,
    'audio_public_url':  audioPublicUrl,
    'error_message':     errorMessage,
  };

  // ── WitnessModel → Supabase insert ────────────────────────────────────────
  // ✅ birth_year extrait depuis dateNaissance
  // ✅ date_naissance supprimé (n'existe plus dans collect_info_temoin)

  Map<String, dynamic> toSupabaseInsert({required String audioId}) => {
    'nom':            nom,
    'first_name':     prenom,
    'birth_year':     birthYear,     // ✅ int extrait de dateNaissance
    'accept_rgpd':    acceptRgpd,
    'departement_id': departementId,
    'region_id':      regionId,
    'audio_id':       audioId,
    'created_at':     createdAt,
  };

  // ── copyWith ───────────────────────────────────────────────────────────────

  WitnessModel copyWith({
    String? syncStatus,
    String? supabaseId,
    String? audioSupabaseId,
    String? audioPublicUrl,
    String? errorMessage,
    String? audioPath,
    String? audioDuration,
  }) => WitnessModel(
    id: id, nom: nom, prenom: prenom,
    dateNaissance:   dateNaissance,
    departementId:   departementId,
    regionId:        regionId,
    audioPath:       audioPath       ?? this.audioPath,
    audioDuration:   audioDuration   ?? this.audioDuration,
    acceptRgpd:      acceptRgpd,
    createdAt:       createdAt,
    syncStatus:      syncStatus      ?? this.syncStatus,
    supabaseId:      supabaseId      ?? this.supabaseId,
    audioSupabaseId: audioSupabaseId ?? this.audioSupabaseId,
    audioPublicUrl:  audioPublicUrl  ?? this.audioPublicUrl,
    errorMessage:    errorMessage    ?? this.errorMessage,
  );
}
