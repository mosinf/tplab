-- TP Lab — schéma de base de données pour Supabase
-- ============================================================
-- À coller dans Supabase : Database → SQL Editor → New query → Run
-- ============================================================

CREATE TABLE IF NOT EXISTS students (
  id TEXT PRIMARY KEY,
  group_id INT NOT NULL,
  name TEXT NOT NULL,
  position INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS students_group_id_idx ON students(group_id);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  date DATE NOT NULL,
  day TEXT NOT NULL,
  slot TEXT NOT NULL,
  room TEXT NOT NULL,
  groups JSONB NOT NULL,
  teacher TEXT,
  attendance JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS sessions_date_idx ON sessions(date);

CREATE TABLE IF NOT EXISTS teachers (
  name TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security : on autorise les opérations anonymes (la clé anon est publique
-- et l'application est destinée à un usage interne entre enseignants connus).
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tplab_anon_all" ON students;
DROP POLICY IF EXISTS "tplab_anon_all" ON sessions;
DROP POLICY IF EXISTS "tplab_anon_all" ON teachers;

CREATE POLICY "tplab_anon_all" ON students FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "tplab_anon_all" ON sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "tplab_anon_all" ON teachers FOR ALL USING (true) WITH CHECK (true);

-- Réplication temps réel (pour la synchronisation instantanée entre enseignants)
ALTER PUBLICATION supabase_realtime ADD TABLE students;
ALTER PUBLICATION supabase_realtime ADD TABLE sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE teachers;
