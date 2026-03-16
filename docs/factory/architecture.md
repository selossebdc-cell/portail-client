# Architecture — Portail Client V2

> Gate 1 — Phase MODEL
> Date : 2026-03-16

---

## 1. Vue d'ensemble

```
┌─────────────────────────────────────────────────┐
│              espace.csbusiness.fr                │
│              (GitHub Pages - statique)           │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────┐    ┌──────────────┐              │
│  │  LOGIN   │───▶│ Rôle = admin?│              │
│  │ email+mdp│    └──────┬───────┘              │
│  └──────────┘       oui │    non               │
│                    ┌────▼───┐ ┌────▼────┐      │
│                    │ ADMIN  │ │ PORTAIL │      │
│                    │Dashboard│ │ Client  │      │
│                    └────┬───┘ └────┬────┘      │
│                         │          │            │
└─────────────────────────┼──────────┼────────────┘
                          │          │
                    ┌─────▼──────────▼─────┐
                    │     SUPABASE         │
                    │  (PostgreSQL + Auth)  │
                    │  - clients           │
                    │  - actions           │
                    │  - brain_dumps       │
                    │  - sessions          │
                    │  - tutos             │
                    │  - contracts         │
                    │  - weekly_recaps     │
                    └──────────────────────┘
```

## 2. Modèle de données (Supabase / PostgreSQL)

### Table `profiles` (extension de auth.users)
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'admin')),
  program TEXT,           -- "Accélération 6 mois" / "Transformation 9 mois"
  total_sessions INTEGER, -- 18 ou 19 selon programme
  start_date DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `actions` (checklist client)
```sql
CREATE TABLE actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  phase INTEGER NOT NULL,        -- 1 à 6 (phases de la roadmap)
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  due_date DATE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `brain_dumps` (champ libre client)
```sql
CREATE TABLE brain_dumps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,   -- lu par Catherine
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `sessions` (historique des séances)
```sql
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  session_number INTEGER NOT NULL,
  title TEXT,
  date DATE,
  summary TEXT,              -- résumé / CR
  status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `tutos` (contenus pédagogiques)
```sql
CREATE TABLE tutos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_html TEXT,         -- contenu HTML du tuto
  loom_url TEXT,             -- lien vidéo Loom si applicable
  category TEXT,             -- "Outils", "Process", "Stratégie"
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `contracts` (infos contrat + paiements)
```sql
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  program_name TEXT NOT NULL,
  total_amount DECIMAL(10,2),
  payment_schedule JSONB,    -- [{date, amount, status, stripe_link}]
  documents JSONB,           -- [{name, url}] (CGV, bon de commande, etc.)
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Table `weekly_recaps` (récaps DG)
```sql
CREATE TABLE weekly_recaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  week_start DATE NOT NULL,
  content_html TEXT NOT NULL,  -- HTML généré par l'agent DG
  tasks JSONB,                 -- [{title, is_completed}] pour les checkboxes
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 3. Row Level Security (RLS)

```sql
-- Chaque client ne voit que ses propres données
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE brain_dumps ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutos ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;

-- Politique client : ne voit que ses données
CREATE POLICY "client_own_data" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "client_own_actions" ON actions
  FOR ALL USING (client_id = auth.uid());

CREATE POLICY "client_own_brain_dumps" ON brain_dumps
  FOR ALL USING (client_id = auth.uid());

CREATE POLICY "client_own_sessions" ON sessions
  FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "client_own_tutos" ON tutos
  FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "client_own_contracts" ON contracts
  FOR SELECT USING (client_id = auth.uid());

-- Politique admin : Catherine voit tout
CREATE POLICY "admin_all_profiles" ON profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_all_actions" ON actions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- (idem pour brain_dumps, sessions, tutos, contracts)

-- weekly_recaps : admin uniquement
ALTER TABLE weekly_recaps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admin_recaps" ON weekly_recaps
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
```

## 4. Structure des fichiers (frontend)

```
portail-client-v2/
├── index.html              ← Page login unique
├── app.html                ← SPA principale (post-login)
├── css/
│   ├── variables.css       ← Charte CS Consulting (tokens)
│   ├── base.css            ← Reset + typo + layout
│   ├── components.css      ← Boutons, cards, badges, tabs
│   ├── client.css          ← Styles portail client
│   └── admin.css           ← Styles dashboard admin
├── js/
│   ├── supabase-config.js  ← Init Supabase client
│   ├── auth.js             ← Login, logout, session check
│   ├── router.js           ← Routing client/admin selon rôle
│   ├── client/
│   │   ├── actions.js      ← Onglet Actions (checklist)
│   │   ├── brain-dump.js   ← Onglet Brain Dump
│   │   ├── sessions.js     ← Onglet Sessions
│   │   ├── tutos.js        ← Onglet Tutos
│   │   └── contract.js     ← Onglet Mon contrat
│   └── admin/
│       ├── dashboard.js    ← Onglet Mes clients
│       ├── recap.js        ← Onglet Récap semaine
│       └── links.js        ← Onglet Dashboards (liens)
├── docs/
│   └── factory/            ← Specs Spec-to-Code Factory
└── README.md
```

## 5. Flux utilisateur

### 5.1 Client
```
Ouvre espace.csbusiness.fr
  → Login (email + mdp)
  → Supabase Auth vérifie
  → Charge profil → rôle = "client"
  → Affiche portail avec 5 onglets :
    [Actions] [Brain Dump] [Sessions] [Tutos] [Mon contrat]
  → Client navigue, coche des actions, écrit des brain dumps
  → Tout se sauvegarde en temps réel dans Supabase
```

### 5.2 Catherine (admin)
```
Ouvre espace.csbusiness.fr
  → Login (catherine@csbusiness.fr + mdp)
  → Supabase Auth vérifie
  → Charge profil → rôle = "admin"
  → Affiche dashboard avec 3 onglets :
    [Mes clients] [Récap semaine] [Dashboards]
  → Voit tous les clients, brain dumps non lus, actions en retard
  → Peut cliquer sur un client → voir son portail en mode admin
  → Récap semaine : HTML du DG avec checkboxes
```

## 6. Intégration Agent DG → Récap

L'agent DG génère un récap et l'insère dans Supabase :

```python
# Dans l'agent DG, après génération du briefing :
import requests

SUPABASE_URL = "https://xxx.supabase.co"
SUPABASE_KEY = "service_role_key"  # clé serveur (pas anon)

def push_weekly_recap(html_content, tasks):
    requests.post(
        f"{SUPABASE_URL}/rest/v1/weekly_recaps",
        headers={
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json",
        },
        json={
            "week_start": "2026-03-17",
            "content_html": html_content,
            "tasks": tasks,  # [{"title": "...", "is_completed": false}]
        },
    )
```

## 7. Sécurité

| Mesure | Détail |
|--------|--------|
| Auth | Supabase Auth (bcrypt, JWT) |
| RLS | Chaque table avec politique client/admin |
| HTTPS | GitHub Pages + CNAME custom |
| Clé API | `anon` key dans le JS (sécurisée par RLS) |
| Service key | Uniquement côté serveur (agent DG) — jamais dans le JS |
| Reset mdp | Supabase email reset intégré |

## 8. Décisions d'architecture (ADR)

### ADR-001 : HTML/JS vanilla plutôt que React/Vue
- **Contexte** : Catherine n'a pas d'équipe dev, Claude Code maintient le code
- **Décision** : Pas de framework JS — HTML + CSS + JS vanilla
- **Raison** : Pas de build step, déployable direct sur GitHub Pages, lisible, maintenable par Claude Code
- **Conséquence** : Pas de state management complexe, routing minimal fait main

### ADR-002 : Supabase plutôt que Firebase/custom backend
- **Contexte** : Besoin d'auth + base de données + RLS, budget 0 €
- **Décision** : Supabase plan gratuit
- **Raison** : PostgreSQL (requêtes SQL classiques), auth intégrée, RLS natif, API REST auto, 50K lignes gratuites
- **Conséquence** : Dépendance Supabase (atténuée par export régulier)

### ADR-003 : Single Page App plutôt que multi-pages
- **Contexte** : Portail client + dashboard admin sur la même URL
- **Décision** : 2 fichiers HTML (index.html = login, app.html = app) avec routing JS
- **Raison** : Un seul déploiement, détection du rôle côté JS, pas de serveur
- **Conséquence** : Router JS minimal à écrire

### ADR-004 : Une seule URL (espace.csbusiness.fr) pour tout
- **Contexte** : Catherine veut un point d'entrée unique
- **Décision** : Client et admin partagent la même URL, routage par rôle
- **Raison** : TDAH-friendly, un seul bookmark, un seul déploiement
- **Conséquence** : Le JS doit gérer le routage admin/client après auth
