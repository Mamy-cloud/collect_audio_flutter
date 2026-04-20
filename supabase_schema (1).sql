-- ── Supabase PostgreSQL Schema ─────────────────────────────────────────────
-- Avec vraies relations FK entre toutes les tables

-- ── 1. login_user ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS login_user (
    id          TEXT PRIMARY KEY,
    identifiant TEXT NOT NULL UNIQUE,
    password    TEXT NOT NULL,
    created_at  TEXT NOT NULL
);

-- ── 2. info_perso_temoin ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS info_perso_temoin (
    id             TEXT PRIMARY KEY,
    nom            TEXT NOT NULL,
    prenom         TEXT NOT NULL,
    date_naissance TEXT,
    departement    TEXT,
    region         TEXT,
    img_temoin     TEXT,
    date_creation  TEXT NOT NULL
);

-- ── 3. collect_info_from_temoin ────────────────────────────────────────────
-- temoin_id → vraie FK vers info_perso_temoin

CREATE TABLE IF NOT EXISTS collect_info_from_temoin (
    id            TEXT PRIMARY KEY,
    user_id       TEXT NOT NULL REFERENCES login_user(id)        ON DELETE CASCADE,
    temoin_id     TEXT NOT NULL REFERENCES info_perso_temoin(id) ON DELETE CASCADE,
    questionnaire JSONB NOT NULL DEFAULT '[]',
    url_audio     TEXT,
    synced        INTEGER NOT NULL DEFAULT 0,
    created_at    TEXT NOT NULL
);

-- ── 4. info_perso_temoin_collect ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS info_perso_temoin_collect (
    id          TEXT PRIMARY KEY,
    collect_id  TEXT NOT NULL REFERENCES collect_info_from_temoin(id) ON DELETE CASCADE,
    created_at  TEXT NOT NULL
);

-- ── Index ──────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_collect_user_id
    ON collect_info_from_temoin(user_id);

CREATE INDEX IF NOT EXISTS idx_collect_temoin_id
    ON collect_info_from_temoin(temoin_id);

CREATE INDEX IF NOT EXISTS idx_collect_created_at
    ON collect_info_from_temoin(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_temoin_collect_collect_id
    ON info_perso_temoin_collect(collect_id);

-- ── Row Level Security ─────────────────────────────────────────────────────

ALTER TABLE login_user                ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_perso_temoin         ENABLE ROW LEVEL SECURITY;
ALTER TABLE collect_info_from_temoin  ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_perso_temoin_collect ENABLE ROW LEVEL SECURITY;

-- ── Buckets Storage ────────────────────────────────────────────────────────
-- 1. Bucket "audio"  → public = true
-- 2. Bucket "images" → public = true
