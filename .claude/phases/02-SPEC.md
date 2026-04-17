# SPEC — Système centralisé de gestion des tâches

**Status**: GATE 1 (Architecture + Decisions)

## Architecture: Single Source of Truth

```
┌─────────────────────┐
│  Supabase tasks     │ ← UNIQUE SOURCE OF TRUTH
│  (PostgreSQL)       │
└──────────┬──────────┘
           │
    ┌──────┼──────┬──────────┬──────────┐
    │      │      │          │          │
    ▼      ▼      ▼          ▼          ▼
  App    Portail Pixou      CEO       Sio
  Mobile  Admin   Agent      Agent     Agent
  (dico) (React) (Python)   (Python)  (Python)
```

**Principe** : Pas de duplication. Toutes les modifications synchro en temps réel via Supabase.

## Data Model

**Table `tasks` (Supabase)**

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT, -- 'clients', 'contenu', 'admin', 'finances', 'dev', 'filles', 'sante', 'perso'
  status TEXT DEFAULT 'todo', -- 'todo', 'done', 'cancelled'
  priority INT DEFAULT 0, -- 0: normal, 1: important, 2: urgent
  type TEXT DEFAULT 'pro', -- 'pro' ou 'perso'
  created_by TEXT, -- 'catherine', 'pixou', 'ceo', 'sio'
  created_at TIMESTAMP DEFAULT now(),
  completed_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT now(),
  notes TEXT,
  detail TEXT,
  updated_by TEXT,
  
  CONSTRAINT valid_status CHECK (status IN ('todo', 'done', 'cancelled')),
  CONSTRAINT valid_type CHECK (type IN ('pro', 'perso'))
);

-- RLS: Tous peuvent lire + modifier (Catherine, Pixou, CEO, Sio)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "allow_all_for_admins" ON tasks
  FOR ALL USING (TRUE)
  WITH CHECK (TRUE);
```

## Interfaces

### 1. App Mobile (`/todo-semaine-JJMMMM.html`)

**Fonctionnalités** :
- Liste tâches en cours (status != 'cancelled')
- Checkbox pour marquer comme done (status = 'done')
- Input + microphone (Web Speech API) pour ajouter
- Sélecteur perso/pro (filtre visible)
- Filtres : Tout, À faire, Fait, Pro, Perso
- Auto-sync Supabase (lecture + écriture)
- Responsive mobile first

**Tech** :
- Vanilla JS + Supabase client JS
- localStorage temporaire (offline-first)
- Web Speech API (dictée FR)

### 2. Portail Admin (`app.html` → onglet "Mes tâches")

**Fonctionnalités** :
- Vue complète des tâches (tous les statuts)
- Filtres : Tout, À faire, Fait, Pro, Perso
- Groupement par catégorie
- Progress bar
- Checkbox pour done/undone
- Ajout rapide avec catégorie
- Sync temps réel avec Supabase

**Tech** :
- Composant intégré dans app.html
- JS: js/admin/my-tasks.js
- Supabase client JS

### 3. Agents Paperclip (Pixou, CEO, Sio)

**Accès** :
- Lire tâches via Supabase
- Écrire/modifier via Supabase (via TOOLS.md)
- Cas d'usage :
  - **Pixou** : notifier Catherine des tâches urgentes
  - **CEO** : ajouter tâches, CR hebdo (lister les tâches de la semaine)
  - **Sio** : ajouter/modifier tâches (assistant futur)

**Tech** :
- Supabase Python client
- Edge Functions (si besoin de logique)

## Flux de données

```
Catherine dicte une tâche sur mobile
        ↓
App mobile → Supabase (INSERT)
        ↓
Supabase trigger (Real-time)
        ↓
Portail admin MAJ (real-time sub)
Agents Paperclip voient la tâche
        ↓
CEO ajoute une note/modifie status
        ↓
Supabase (UPDATE)
        ↓
App mobile MAJ en temps réel
```

## Décisions architecturales

| Décision | Raison |
|----------|--------|
| Supabase = source unique | Pas de sync issues, vérité unique |
| Pas d'HTML hardcoded | Maintenance facile, données toujours à jour |
| RLS permissive (tous admins) | Catherine + agents de confiance seulement |
| localStorage backup (mobile) | Offline-first, meilleure UX |
| Real-time subscriptions | Sync instantanée entre interfaces |
| URL dynamique `/todo-JJMMMM.html` | Date flexible, pas dépendance UI |

## Sécurité & RLS

**Table `tasks`** :
- ✅ Tous (Catherine, Pixou, CEO, Sio) peuvent LIRE
- ✅ Tous peuvent CRÉER
- ✅ Tous peuvent METTRE À JOUR
- ✅ Tous peuvent SUPPRIMER
- ⚠️ **Important** : Hardcoder en app que seuls les admins peuvent accéder

## Impact sur portail V2 existant

**Aucun impact** :
- Onglets clients (Actions, Sessions, Tutos) : inchangés
- RLS clients : inchangées
- Auth : réutilisée
- Design system : réutilisé

**Nouveau** :
- Onglet admin "Mes tâches" (déjà présent ✅)
- App mobile Supabase-ready (nouvelle version)
- TOOLS.md mis à jour (agents accès `tasks`)

## Migration

**Existant** :
- `todo-semaine-4avril.html` → localStorage (déprécié)
- `tasks.html` → Supabase (déprécié)

**Nouveau** :
- `/todo-{JJMMMM}.html` → Supabase (nouvelle version)
- `app.html#tab-mytasks` → Supabase (intégré)

**Plan migration** :
1. Créer nouvelle version `/todo-semaine-17avril.html` connectée Supabase
2. Tester sync app ↔ portail ↔ agents
3. Archiver anciennes versions (pas supprimer)
4. Décider : importer historique localStorage → Supabase ?

## GATE 1 STATUS: ✅ PRÊT POUR PLAN
