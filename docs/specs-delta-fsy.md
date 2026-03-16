# Specs Delta — Portail Client V2 : ajouts FSY (Aurélia + Laurie)

> **Contexte** : Le portail V2 est en cours de dev (Supabase + front). Ce document liste les ajouts et modifications nécessaires pour intégrer le client Face Soul Yoga (Aurélia + Laurie), basés sur le portail V1 HTML déjà déployé.

---

## 1. NOUVEAUX CHAMPS — Table `actions`

```sql
ALTER TABLE actions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'todo'
  CHECK (status IN ('todo', 'in_progress', 'blocked', 'done'));
ALTER TABLE actions ADD COLUMN IF NOT EXISTS assignee TEXT;
  -- Valeurs : "Aurélia", "Laurie", "Catherine"
ALTER TABLE actions ADD COLUMN IF NOT EXISTS entity TEXT;
  -- Valeurs : "FSY Studio", "MTM", "Aurélia Del Sol", "Transverse"
ALTER TABLE actions ADD COLUMN IF NOT EXISTS due_date DATE;
ALTER TABLE actions ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'medium'
  CHECK (priority IN ('high', 'medium', 'low'));
```

### Logique des statuts (remplace le checkbox binaire)

| Statut | Code | Couleur | Comportement |
|--------|------|---------|-------------|
| À faire | `todo` | Gris | État par défaut |
| En cours | `in_progress` | Bleu #60a5fa | Clic pour activer |
| Bloqué | `blocked` | Rouge #f87171 | Oblige un commentaire (voir section 3) |
| Fait | `done` | Vert #4ade80 | Action terminée, reste visible dans "Historique" |

**UX** : 4 radio buttons par action (pas de drag & drop). Clic = change le statut + update Supabase.

---

## 2. NOUVELLE TABLE — `action_comments`

```sql
CREATE TABLE action_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_id UUID REFERENCES actions(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE action_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Client voit les commentaires de ses actions"
  ON action_comments FOR SELECT
  USING (action_id IN (SELECT id FROM actions WHERE client_id = auth.uid()));

CREATE POLICY "Client crée des commentaires sur ses actions"
  ON action_comments FOR INSERT
  WITH CHECK (action_id IN (SELECT id FROM actions WHERE client_id = auth.uid()));

CREATE POLICY "Admin gère tous les commentaires"
  ON action_comments FOR ALL
  USING (is_admin());
```

**Comportement** :
- Chaque action a un bouton 💬 qui ouvre un champ texte
- Quand statut = `blocked` → le champ commentaire est obligatoire ("Qu'est-ce qui bloque ?")
- Les commentaires s'affichent sous l'action, triés par date (plus récent en haut)
- Afficher : auteur + date + contenu

---

## 3. NOUVEAU CHAMP — Table `sessions`

```sql
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS cr_url TEXT;
```

**Comportement** : si `cr_url` est renseigné, afficher un bouton "📄 Voir le compte-rendu complet" qui ouvre le lien dans un nouvel onglet. Les CR sont des pages HTML statiques hébergées séparément.

---

## 4. FILTRES SUR LA PAGE ACTIONS

### Filtre par statut
4 boutons en haut de la liste :
```
[Tous] [À faire (X)] [En cours (X)] [Bloqué (X)] [Fait (X)]
```
X = compteur dynamique. "Tous" actif par défaut.

### Filtre par responsable
```
[Tous] [Aurélia] [Laurie] [Catherine]
```

### Filtre par entité
```
[Tous] [FSY Studio] [MTM] [Aurélia Del Sol] [Transverse]
```

Les filtres sont combinables (ET). Persistance en localStorage ou query params.

---

## 5. TIMELINE DE PROGRESSION (nouvel écran ou section dashboard)

### Vue attendue

Barre horizontale avec les mois (mars → août 2026) et les 4 phases en barres colorées.

```
Mars     Avril    Mai      Juin     Juillet  Août
├────────┼────────┼────────┼────────┼────────┤
█████████                                      Phase 0 (3/5)
         █████████████                         Phase 1 (0/5)
                  █████████████                Phase 2 (0/5)
                           █████████████████   Phase 3 (0/4)
         ▲
     AUJOURD'HUI
```

### Données nécessaires

La table `actions` a déjà `phase` (integer 0-3). Le calcul est :
- Total par phase : `SELECT phase, COUNT(*) FROM actions WHERE client_id = X GROUP BY phase`
- Fait par phase : `SELECT phase, COUNT(*) FROM actions WHERE client_id = X AND status = 'done' GROUP BY phase`
- Pourcentage = fait / total

### Jalons

Ajouter une section "Jalons clés" sous la timeline :

| Date | Jalon | Statut |
|------|-------|--------|
| Mai 2026 | Communication migration membres | À venir |
| Juin 2026 | Fermeture Uscreen | À venir |
| Juillet 2026 | MTM evergreen 1er lancement | À venir |
| Août 2026 | Bilan & plan de continuité | À venir |

Option : stocker en dur dans le front pour le MVP, ou nouvelle table `milestones` si on veut le rendre dynamique.

---

## 6. DASHBOARD "MA SEMAINE"

### Section en haut de la page d'accueil

Affiche les **3 actions prioritaires** de la semaine (filtrées par : `status != 'done'` + `priority = 'high'` + triées par `sort_order`).

Chaque action affiche :
- Titre
- Responsable (badge couleur)
- Statut (4 radio buttons inline)
- Dernier commentaire (si existe)

### Bannière prochaine session

```
📅 Prochaine séance : 24 mars 2026 à 10h
Focus : Validation parcours clients + Circle
```

Données depuis la table `sessions` : prochaine session = `SELECT * FROM sessions WHERE status = 'planned' ORDER BY date ASC LIMIT 1`

---

## 7. MULTI-UTILISATEUR FSY

### Profils à créer

| Email | Nom | Rôle | Accès |
|-------|-----|------|-------|
| aurelia@facesoulyoga.com | Aurélia Del Sol | client | Voir + changer statut + commenter |
| laurie@... (à confirmer) | Laurie | client | Idem Aurélia |
| catherine@csbusiness.fr | Catherine Selosse | admin | Tout |

### RLS

Aurélia et Laurie partagent le même `client_id` (le profile ID d'Aurélia). Laurie est un 2e user avec le même `client_id` mais un `id` différent.

**Modification table profiles** :
```sql
-- Ajouter un champ client_id pour lier les collaborateurs au même client
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES profiles(id);
-- Pour Aurélia : client_id = son propre id
-- Pour Laurie : client_id = id d'Aurélia
```

**RLS modifié** :
```sql
-- Remplacer les policies "client_id = auth.uid()" par :
CREATE OR REPLACE FUNCTION get_client_id()
RETURNS UUID AS $$
  SELECT COALESCE(client_id, id) FROM profiles WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER;

-- Exemple pour actions :
CREATE POLICY "Client voit ses actions"
  ON actions FOR SELECT
  USING (client_id = get_client_id());
```

---

## 8. PAIEMENTS — Logique d'affichage

### Calcul du statut d'une échéance

```javascript
// Ne pas afficher "En retard" pour une échéance future
if (payment.status === 'paid') {
  label = 'Payé';
  color = 'green';
} else {
  const dueDate = new Date(payment.date);
  const now = new Date();
  if (dueDate < now) {
    label = 'En retard';
    color = 'red';
  } else {
    label = 'Échéance ' + formatDate(payment.date);
    color = 'default';
  }
}
```

### Données FSY

| Échéance | Montant | Date | Statut |
|----------|---------|------|--------|
| Acompte signature | 2 500 € | 17/02/2026 | Payé |
| 2e échéance | 2 750 € | 17/03/2026 | À venir |
| 3e échéance | 2 750 € | 17/04/2026 | À venir |

Total : 8 000 € TTC. Pas d'OPCO.

---

## 9. DESIGN — Charte à respecter

| Élément | Valeur |
|---------|--------|
| Couleur principale | Terracotta `#C27A5A` |
| Fond | Sombre `#0f0f0f` |
| Fond cartes | `#1a1a1a` |
| Texte principal | Blanc `#FFFFFF` |
| Texte secondaire | `#b0b0b0` |
| Font titres | Playfair Display (serif) |
| Font corps | Inter (sans-serif) |
| Vert (fait/payé) | `#4ade80` |
| Rouge (bloqué/retard) | `#f87171` |
| Bleu (en cours) | `#60a5fa` |
| Orange (moyen) | `#fb923c` |
| Border radius cartes | 12px |
| Responsive | Mobile-first, breakpoint 768px |

---

## 10. DONNÉES FSY À INJECTER

### Actions (19 — feuille de route V2)

Voir fichier : `/02-clients/face-soul-yoga/prep-sessions/feuille-de-route-v2-fsy.md`

Chaque action a : phase (0-3), title, assignee, entity, priority, status (todo), sort_order, due_date (optionnel).

### Sessions (4)

| # | Date | Titre | CR URL |
|---|------|-------|--------|
| 1 | 2026-02-19 | Lancement stratégique & cadrage | — |
| 2 | 2026-03-02 | Migration Kajabi + Bunny, Architecture offre | — |
| 3 | 2026-03-11 | Stratégie offre FSY (evergreen + pricing) | — |
| 4 | 2026-03-16 | Repositionnement des marques & feuille de route | cr-session4-fsy.html |

### Tutos (6)

| Titre | URL | Type |
|-------|-----|------|
| Dashboard KPI — Suivi business | dashboard-kpi-fsy.html | Guide |
| Process création de formation | process-creation-formation-fsy.html | 7 étapes |
| Écosystème outils & données | ecosysteme-outils-fsy.html | Guide |
| Miro — Architecture chatbot | https://miro.com/app/board/uXjVG2eDpcA=/ | Externe |
| Feuille de route V2 | feuille-de-route-fsy.html | Guide |
| CR Session 4 | cr-session4-fsy.html | CR |

### Contrat

Programme : Clarté & Autonomie — 6 mois
Total : 8 000 € TTC
3 échéances (voir section 8)

---

## 11. RÉSUMÉ DES DELTAS vs PORTAIL FRED (V1)

| Feature | Fred (V1) | FSY (V2) |
|---------|-----------|----------|
| Actions statut | Checkbox (fait/pas fait) | 4 états (todo/in_progress/blocked/done) |
| Commentaires | Non | Oui (obligatoire si bloqué) |
| Filtres | Non | Par statut + responsable + entité |
| Responsable | Non (1 seul user) | Oui (Aurélia / Laurie / Catherine) |
| Entité | Non | Oui (FSY Studio / MTM / Del Sol / Transverse) |
| Timeline phases | Non | Oui (barres + jalons) |
| "Ma semaine" | Non (juste checklist) | Oui (3 actions prio + bannière session) |
| CR session | Non | Lien HTML externe (bouton) |
| Multi-user | Non | 2 clients + 1 admin |
| Stockage | localStorage | Supabase (partagé) |
| Paiements | Statut fixe | Calcul dynamique (date vs aujourd'hui) |
| Brain dump | Non | Oui (textarea libre) |
