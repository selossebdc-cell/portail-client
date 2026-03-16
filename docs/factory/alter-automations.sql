-- ═══ Automatisations + Fix contrat Fred ═══

-- Nouvelles colonnes sur contracts
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS automations_included INTEGER DEFAULT 1;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS automations JSONB DEFAULT '[]'::jsonb;

-- Fred : 1 automatisation incluse (valeur 2 500 EUR), pas encore définie
UPDATE contracts SET
  automations_included = 1,
  automations = '[
    {
      "name": "Automatisation factures fournisseurs",
      "description": "Centralisation et classement automatique des factures depuis les emails vers Dropbox/Excel",
      "status": "planned",
      "value": 2500
    }
  ]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62';

-- Fix paiement Fred : le solde est "due" (échéance 22 mars), pas OPCO
-- Le statut dynamique dans le code gère déjà : date passée = "En retard", date future = "Échéance [date]"
-- Pas besoin de toucher au payment_schedule, le JS calcule correctement

-- Ressources "Mon projet" pour Fred
INSERT INTO tutos (client_id, title, content_html, loom_url, icon, tuto_type, sort_order) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Organisation fichiers Dropbox', 'Arborescence cible pour Dropbox : par entite (V8, FU Solutions, Perso) avec dossiers standardises.', NULL, '📂', 'project', 1),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Schema Firefox — Favoris par activite', 'Vue visuelle des favoris Firefox organises par containers et couleurs.', NULL, '🦊', 'project', 2),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Architecture emails — 4 boites Outlook', 'Mapping des 4 adresses mail centralisees dans Outlook avec labels et regles.', NULL, '📧', 'project', 3),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Structure FU Solutions (holding)', 'Organigramme des 3 branches : V8 Equipment, Fu-Fight, Sourcing + gouvernance.', NULL, '🏢', 'project', 4);
