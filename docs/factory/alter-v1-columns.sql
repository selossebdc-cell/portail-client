-- =============================================================
-- Portail Client V2 — Ajout colonnes V1 manquantes
-- À exécuter dans Supabase SQL Editor
-- =============================================================

-- ACTIONS : tags, lien
ALTER TABLE actions ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS link_url TEXT;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS link_label TEXT;

-- SESSIONS : decisions
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS decisions JSONB DEFAULT '[]'::jsonb;

-- CONTRACTS : dates
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS end_date DATE;

-- TUTOS : icon, type, steps
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS icon TEXT;
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS tuto_type TEXT DEFAULT 'guide';
ALTER TABLE tutos ADD COLUMN IF NOT EXISTS steps INTEGER;

-- =============================================================
-- Mise à jour données Fred avec les infos V1
-- =============================================================

-- Actions : ajouter tags et liens
UPDATE actions SET tags = '["urgent"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Microsoft 365%';

UPDATE actions SET tags = '["tuto"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Dashlane%';

UPDATE actions SET tags = '["urgent"]'::jsonb, link_url = 'https://claude.ai/upgrade', link_label = 'Aller sur claude.ai'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Claude%';

UPDATE actions SET tags = '["session"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Outlook%telephone%';

-- Sessions : ajouter decisions
UPDATE sessions SET decisions = '["Routines : top 1-3 du jour + 2 blocs focus", "Time-blocking : 6h temps dirigeant par semaine", "banana.io pour photos produits Leboncoin"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 1;

UPDATE sessions SET decisions = '["Cloud unique = Dropbox 2 To", "Agent IA personnalise Claude/Gemini", "Methode 25 min adoptee"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 2;

UPDATE sessions SET decisions = '["Firefox remplace Chrome comme navigateur principal", "Feishu abandonne", "200 Go Dropbox a organiser"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 3;

UPDATE sessions SET decisions = '["Centraliser factures sur V8", "Labels Gmail pour tri automatique", "4 containers Firefox (test 1 semaine)", "Structure FU Solutions : holding avec 3 branches"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 4;

UPDATE sessions SET decisions = '["fu@fusolution.fr = adresse email principale", "Google Agenda centralise avec code couleur par entite", "Google Drive FU Solutions cree pour fichiers partages equipe", "OneNote readopte pour la prise de notes", "WhatsApp desktop installe", "17 acces anciens collaborateurs revoques sur Drive"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 5;

UPDATE sessions SET decisions = '["Outlook desktop = client mail principal (comeback)", "Dashlane = gestionnaire de mots de passe", "Microsoft 365 Personnel (99 EUR/an) sous FU Solutions", "Dropbox reste le cloud principal (pas de migration OneDrive)", "Catherine prepare le CdC automatisation factures"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 6;

UPDATE sessions SET decisions = '["Outlook = 4 boites mail centralisees (toutes configurees)", "OVH acces recupere (FF4801) + audit 12 domaines inutiles (~300 EUR/an)", "Firefox = navigateur par defaut (Chrome retire)", "Favoris Firefox ranges par activite (5 dossiers, memes couleurs que containers)", "Microsoft 365 Personnel a acheter sous FU Solutions", "Portail client CS Business ajoute en favori Firefox"]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND session_number = 7;

-- Contrat : dates
UPDATE contracts SET start_date = '2026-01-22', end_date = '2026-07-22'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62';

-- Tutos : icones, type, steps
UPDATE tutos SET icon = '🔐', tuto_type = 'guide', steps = 8
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Dashlane%';

UPDATE tutos SET icon = '📬', tuto_type = 'guide', steps = 3
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Outlook%';

UPDATE tutos SET icon = '🦊', tuto_type = 'guide'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%Firefox%';

UPDATE tutos SET icon = '🎓', tuto_type = 'video'
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62' AND title LIKE '%attestations%';
