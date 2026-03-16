-- =============================================================
-- Portail Client V2 — Features enrichies (inspirées specs FSY)
-- À exécuter dans Supabase SQL Editor
-- =============================================================

-- SESSIONS : lien CR HTML
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS cr_url TEXT;

-- ACTIONS : statut enrichi + lien vers session d'origine
ALTER TABLE actions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'todo'
  CHECK (status IN ('todo', 'in_progress', 'blocked', 'done', 'abandoned'));
ALTER TABLE actions ADD COLUMN IF NOT EXISTS origin_session INTEGER;
  -- Numéro de la séance où l'action a été assignée

-- Migrer les données existantes : is_completed → status
UPDATE actions SET status = 'done' WHERE is_completed = true AND status = 'todo';

-- =============================================================
-- Mise à jour données Fred — actions liées aux sessions
-- =============================================================

-- Actions actuelles de Fred = issues de la session 7
UPDATE actions SET origin_session = 7
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Microsoft 365%';

UPDATE actions SET origin_session = 6
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Dashlane%';

UPDATE actions SET origin_session = 6
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Claude%';

UPDATE actions SET origin_session = 7
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Outlook%telephone%';
