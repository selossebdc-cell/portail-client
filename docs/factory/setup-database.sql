-- =============================================================
-- Portail Client V2 — Setup base de données Supabase
-- À exécuter dans Supabase SQL Editor (une seule fois)
-- =============================================================

-- 1. Table PROFILES (extension de auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'admin')),
  program TEXT,
  total_sessions INTEGER,
  start_date DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table ACTIONS (checklist client)
CREATE TABLE actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  phase INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  due_date DATE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table BRAIN_DUMPS (champ libre client)
CREATE TABLE brain_dumps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table SESSIONS (historique des séances)
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  session_number INTEGER NOT NULL,
  title TEXT,
  date DATE,
  summary TEXT,
  status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Table TUTOS (contenus pédagogiques)
CREATE TABLE tutos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_html TEXT,
  loom_url TEXT,
  category TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Table CONTRACTS (infos contrat + paiements)
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  program_name TEXT NOT NULL,
  total_amount DECIMAL(10,2),
  payment_schedule JSONB,
  documents JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Table WEEKLY_RECAPS (récaps DG)
CREATE TABLE weekly_recaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  week_start DATE NOT NULL,
  content_html TEXT NOT NULL,
  tasks JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================

-- Activer RLS sur toutes les tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE brain_dumps ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutos ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_recaps ENABLE ROW LEVEL SECURITY;

-- Fonction helper : est-ce que l'utilisateur est admin ?
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE SQL SECURITY DEFINER;

-- ---- PROFILES ----
CREATE POLICY "Clients voient leur propre profil"
  ON profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Admin voit tous les profils"
  ON profiles FOR SELECT
  USING (is_admin());

CREATE POLICY "Admin modifie tous les profils"
  ON profiles FOR ALL
  USING (is_admin());

-- ---- ACTIONS ----
CREATE POLICY "Client voit ses actions"
  ON actions FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Client modifie ses actions"
  ON actions FOR UPDATE
  USING (client_id = auth.uid());

CREATE POLICY "Admin gère toutes les actions"
  ON actions FOR ALL
  USING (is_admin());

-- ---- BRAIN_DUMPS ----
CREATE POLICY "Client voit ses brain dumps"
  ON brain_dumps FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Client crée ses brain dumps"
  ON brain_dumps FOR INSERT
  WITH CHECK (client_id = auth.uid());

CREATE POLICY "Admin gère tous les brain dumps"
  ON brain_dumps FOR ALL
  USING (is_admin());

-- ---- SESSIONS ----
CREATE POLICY "Client voit ses sessions"
  ON sessions FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Admin gère toutes les sessions"
  ON sessions FOR ALL
  USING (is_admin());

-- ---- TUTOS ----
CREATE POLICY "Client voit ses tutos"
  ON tutos FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Admin gère tous les tutos"
  ON tutos FOR ALL
  USING (is_admin());

-- ---- CONTRACTS ----
CREATE POLICY "Client voit son contrat"
  ON contracts FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Admin gère tous les contrats"
  ON contracts FOR ALL
  USING (is_admin());

-- ---- WEEKLY_RECAPS ----
CREATE POLICY "Admin voit les récaps"
  ON weekly_recaps FOR ALL
  USING (is_admin());

-- =============================================================
-- TRIGGER : Créer un profil automatiquement à l'inscription
-- =============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
