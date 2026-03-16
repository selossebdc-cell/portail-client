-- =============================================================
-- Migration Fred V1 → V2
-- À exécuter dans Supabase SQL Editor
-- Fred UUID : 83e6c2be-f9cc-47d8-9232-e80e1626fa62
-- =============================================================

-- ─── ACTIONS ───
INSERT INTO actions (client_id, phase, title, description, is_completed, sort_order) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 3, 'Acheter Microsoft 365 Personnel (99 EUR/an)', 'Avec l''adresse FU Solutions + changer l''adresse principale Microsoft', false, 1),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 3, 'Compléter Dashlane : importer tes mots de passe', 'Importer depuis Chrome + Excel, ajouter l''extension Firefox — voir tuto Dashlane', false, 2),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 3, 'Souscrire à Claude (20 EUR/mois)', 'Pour configurer ton agent IA personnalisé — claude.ai/upgrade', false, 3),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 3, 'Installer Outlook sur téléphone + iPad', 'Ajouter toutes les adresses mail configurées en session', false, 4);

-- ─── TUTOS ───
INSERT INTO tutos (client_id, title, content_html, loom_url, category, sort_order) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Tuto Dashlane', 'Installer, importer tes mots de passe (Chrome + Excel), configurer sur tous tes appareils. <strong>8 étapes</strong>.', NULL, 'Outils', 1),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Outlook — Catégories couleurs', 'Classer tes mails par activité (V8, Fu-Fight, Sourcing, Perso, Infos) en <strong>3 étapes</strong>.', NULL, 'Outils', 2),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Firefox — Favoris rangés par activité', 'Tes favoris Chrome nettoyés et réorganisés dans Firefox avec les bonnes couleurs.', NULL, 'Outils', 3),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Extraire les attestations de formation', 'Comment récupérer tes attestations de formation pour les dossiers OPCO / financement.', 'https://www.loom.com/share/7afe390e285441a5951b71a8c4b8a5d5', 'Admin', 4);

-- ─── SESSIONS ───
INSERT INTO sessions (client_id, session_number, title, date, summary, status) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 1, 'Setup Dashboard, Gestion interruptions, Leboncoin', '2026-01-22', 'Première session. Quick wins : Notion, time-blocking 6h/sem, mode Ne pas déranger, banana.io pour photos produits. Routines : top 1-3 du jour + 2 blocs focus.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 2, 'Pomodoro validé, Cloud Dropbox, Agent IA', '2026-02-02', 'Méthode Pomodoro 25 min validée comme game changer. Cloud unique = Dropbox 2 To. Agent IA personnalisé Claude/Gemini à construire.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 3, 'Comptabilité, Migration cloud OneDrive, Firefox', '2026-02-10', 'Migration fichiers lancée. Setup Firefox. Arborescence OneDrive planifiée. Firefox remplace Chrome, Feishu abandonné, 200 Go Dropbox à organiser.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 4, 'Organisation emails, centralisation factures, Firefox Containers', '2026-02-22', 'Process de centralisation des factures clarifié. Labels Gmail mis en place. 4 containers Firefox en test. Structure FU Solutions (holding) définie.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 5, 'Centralisation outils & identité FU Solutions', '2026-03-01', 'FU Solutions devient l''email principal. Agenda centralisé avec code couleur. Google Drive FU Solutions créé. OneNote réadopté. Premier event Calendar + Meet créé. 17 accès anciens collaborateurs révoqués.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 6, 'Email Outlook, Cloud, MDP Dashlane, M365, Automatisation factures', '2026-03-09', 'Fred a configuré sa première boîte mail (FredGmail) dans Outlook. Décision : Dashlane comme gestionnaire MDP, Microsoft 365 Personnel à 99 EUR/an, lancement CdC automatisation factures.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 7, 'Cadrage digital : Outlook/OVH, gouvernance actifs, Firefox par défaut', '2026-03-13', 'Toutes les boîtes mail configurées dans Outlook — "c''est un pas de géant". Accès OVH récupéré, 12 domaines inutiles identifiés (~300 EUR/an). Firefox par défaut, favoris réorganisés. Phishing détecté en live.', 'completed'),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 8, 'Microsoft 365, OneDrive/Excel, Dashlane vérification, Agent Claude', '2026-03-17', NULL, 'planned');

-- ─── CONTRAT ───
INSERT INTO contracts (client_id, program_name, total_amount, payment_schedule, documents) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Transition Stratégique — 6 mois', 8000.00,
'[
  {"date": "2026-01-22", "amount": 2500, "status": "paid", "label": "Acompte signature"},
  {"date": "2026-02-22", "amount": 2500, "status": "paid", "label": "2e échéance"},
  {"date": "2026-03-22", "amount": 3000, "status": "due", "label": "Solde"}
]'::jsonb,
'[
  {"name": "Contrat signé", "url": ""},
  {"name": "Facture #1 — Acompte (2 500 EUR)", "url": ""},
  {"name": "Facture #2 — 2e échéance (2 500 EUR)", "url": ""}
]'::jsonb);
