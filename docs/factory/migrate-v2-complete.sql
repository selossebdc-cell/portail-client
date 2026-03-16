-- =============================================================
-- Portail Client V2 — Migration complète CDC
-- À exécuter dans Supabase SQL Editor (une seule fois)
-- Inclut : alter-v1-columns + alter-v2-features + nouveaux ajouts CDC
-- =============================================================

-- ═══ PROFILES : nouveaux champs ═══
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS company TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS booking_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS whatsapp_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS objectives JSONB;

-- ═══ ACTIONS : statuts enrichis + tags + liens ═══
ALTER TABLE actions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'todo';
ALTER TABLE actions ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS link_url TEXT;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS link_label TEXT;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS origin_session INTEGER;

-- Migrer is_completed → status
UPDATE actions SET status = 'done' WHERE is_completed = true AND (status IS NULL OR status = 'todo');

-- ═══ SESSIONS : CR + decisions ═══
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS cr_url TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS decisions JSONB DEFAULT '[]'::jsonb;

-- ═══ CONTRACTS : dates ═══
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS end_date DATE;

-- ═══ TUTOS : enrichissement pour 2 onglets (Tutos & Guides + Mon projet) ═══
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS icon TEXT;
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS tuto_type TEXT DEFAULT 'guide';
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS steps INTEGER;
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- ═══ NOUVELLE TABLE : TOOLS ═══
CREATE TABLE IF NOT EXISTS tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('adopted', 'in_progress', 'planned', 'abandoned')),
  icon TEXT,
  url TEXT,
  added_by UUID REFERENCES profiles(id),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tools ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Client voit ses outils"
  ON tools FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Client ajoute ses outils"
  ON tools FOR INSERT
  WITH CHECK (client_id = auth.uid());

CREATE POLICY "Client modifie ses outils"
  ON tools FOR UPDATE
  USING (client_id = auth.uid());

CREATE POLICY "Admin gère tous les outils"
  ON tools FOR ALL
  USING (is_admin());

-- ═══ NOUVELLE TABLE : BRAIN_DUMP_REPLIES ═══
CREATE TABLE IF NOT EXISTS brain_dump_replies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brain_dump_id UUID REFERENCES brain_dumps(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE brain_dump_replies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Client voit les réponses à ses brain dumps"
  ON brain_dump_replies FOR SELECT
  USING (brain_dump_id IN (SELECT id FROM brain_dumps WHERE client_id = auth.uid()));

CREATE POLICY "Admin gère toutes les réponses"
  ON brain_dump_replies FOR ALL
  USING (is_admin());

-- =============================================================
-- DONNÉES FRED — enrichissement V1 → V2
-- =============================================================

-- Profil Fred : company + objectives + booking + dates
UPDATE profiles SET
  company = 'FU Solutions / V8 Equipment',
  booking_url = 'https://fantastical.app/consulting-strategique/mon-modele-copie',
  end_date = '2026-07-22',
  objectives = '["Centraliser mes outils digitaux", "Structurer FU Solutions (holding)", "Gagner 6h de temps dirigeant par semaine"]'::jsonb
WHERE id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62';

-- Actions Fred : tags + liens + origin_session
UPDATE actions SET tags = '["urgent"]'::jsonb, origin_session = 7
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Microsoft 365%';

UPDATE actions SET tags = '["tuto"]'::jsonb, origin_session = 6
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Dashlane%';

UPDATE actions SET tags = '["urgent"]'::jsonb, link_url = 'https://claude.ai/upgrade', link_label = 'Aller sur claude.ai', origin_session = 6
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Claude%';

UPDATE actions SET tags = '["session"]'::jsonb, origin_session = 7
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Outlook%';

-- Sessions Fred : decisions
UPDATE sessions SET decisions = '["Routines : top 1-3 du jour + 2 blocs focus", "Time-blocking : 6h temps dirigeant par semaine", "banana.io pour photos produits Leboncoin"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 1;

UPDATE sessions SET decisions = '["Cloud unique = Dropbox 2 To", "Agent IA personnalise Claude/Gemini", "Methode 25 min adoptee"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 2;

UPDATE sessions SET decisions = '["Firefox remplace Chrome comme navigateur principal", "Feishu abandonne", "200 Go Dropbox a organiser"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 3;

UPDATE sessions SET decisions = '["Centraliser factures sur V8", "Labels Gmail pour tri automatique", "4 containers Firefox (test 1 semaine)", "Structure FU Solutions : holding avec 3 branches"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 4;

UPDATE sessions SET decisions = '["fu@fusolution.fr = adresse email principale", "Google Agenda centralise avec code couleur par entite", "Google Drive FU Solutions cree", "OneNote readopte", "WhatsApp desktop installe", "17 acces anciens collaborateurs revoques"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 5;

UPDATE sessions SET decisions = '["Outlook desktop = client mail principal", "Dashlane = gestionnaire de mots de passe", "Microsoft 365 Personnel (99 EUR/an) sous FU Solutions", "Dropbox reste le cloud principal", "Catherine prepare le CdC automatisation factures"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 6;

UPDATE sessions SET decisions = '["Outlook = 4 boites mail centralisees", "OVH acces recupere + audit 12 domaines inutiles (~300 EUR/an)", "Firefox = navigateur par defaut", "Favoris Firefox ranges par activite", "Microsoft 365 Personnel a acheter sous FU Solutions", "Portail client CS Business ajoute en favori Firefox"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 7;

-- Contrat Fred : dates
UPDATE contracts SET start_date = '2026-01-22', end_date = '2026-07-22'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62';

-- Tutos Fred : icones + types
UPDATE tutos SET icon = '🔐', tuto_type = 'guide', steps = 8
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Dashlane%';

UPDATE tutos SET icon = '📬', tuto_type = 'guide', steps = 3
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Outlook%';

UPDATE tutos SET icon = '🦊', tuto_type = 'guide'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Firefox%';

UPDATE tutos SET icon = '🎓', tuto_type = 'video'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%attestations%';

-- Tools Fred : outils adoptés/en cours
INSERT INTO tools (client_id, name, description, status, icon, sort_order) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Outlook', 'Client mail principal — 4 boites mail centralisees', 'adopted', '📧', 1),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Firefox', 'Navigateur par defaut avec containers par activite', 'adopted', '🦊', 2),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Dashlane', 'Gestionnaire de mots de passe — import en cours', 'in_progress', '🔐', 3),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Microsoft 365', 'Suite Office + OneDrive — a acheter', 'planned', '📎', 4),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Dropbox', 'Cloud principal — 2 To', 'adopted', '📦', 5),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'OneNote', 'Prise de notes reunions', 'adopted', '📝', 6),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Claude AI', 'Agent IA personnalise — abonnement a prendre', 'planned', '🤖', 7),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Feishu', 'Abandonne au profit de OneNote', 'abandoned', '💬', 8),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Google Agenda', 'Agenda centralise avec code couleur par entite', 'adopted', '📅', 9);
