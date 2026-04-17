# PLAN — Épics, User Stories, Tasks

**Status**: GATE 2 (Granular breakdown)

## Épics

### Epic 1: Database & Backend (Supabase)
Préparer Supabase pour être la source unique de vérité.

**User Stories** :
- US 1.1 : Ajouter colonne `type` (perso/pro) à table `tasks`
- US 1.2 : Configurer RLS pour agents Paperclip
- US 1.3 : Créer Edge Function pour synchro real-time
- US 1.4 : Tester Real-time subscriptions

### Epic 2: App Mobile (Nouvelle version Supabase)
Refactoriser `/todo-semaine-*.html` pour Supabase.

**User Stories** :
- US 2.1 : Charger tâches depuis Supabase (GET)
- US 2.2 : Ajouter tâche (dicte + input) → Supabase
- US 2.3 : Cocher/décocher tâche → Supabase
- US 2.4 : Ajouter sélecteur perso/pro
- US 2.5 : Ajouter filtres (Tout, À faire, Fait, Pro, Perso)
- US 2.6 : Sync real-time (Real-time subscriptions)
- US 2.7 : URL dynamique `/todo-{JJMMMM}.html`
- US 2.8 : Offline support (localStorage backup)

### Epic 3: Portail Admin (Onglet Mes tâches existant)
Connecter onglet existant à Supabase (déjà en cours ✅).

**User Stories** :
- US 3.1 : Vérifier sync avec Epic 2
- US 3.2 : Tester filtres perso/pro
- US 3.3 : Tester mise à jour temps réel

### Epic 4: Intégration Paperclip
Configurer agents pour accéder `tasks`.

**User Stories** :
- US 4.1 : Ajouter `tasks` à TOOLS.md (Pixou, CEO, Sio)
- US 4.2 : Tester lecture tâches (agent Python)
- US 4.3 : Tester écriture tâches (agent Python)
- US 4.4 : CEO CR : template lister tâches de la semaine

## Tasks détaillées

### EPIC 1 : Database & Backend

#### Task 1.1.1 : Modifier table `tasks`
```sql
ALTER TABLE tasks ADD COLUMN type TEXT DEFAULT 'pro' CHECK (type IN ('pro', 'perso'));
```
- [ ] Migration Supabase
- [ ] Backfill données existantes (type = 'pro')
- [ ] Tester

#### Task 1.2.1 : RLS pour agents
```sql
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Pixou, CEO, Sio peuvent tout faire
CREATE POLICY "agent_access" ON tasks
  FOR ALL
  USING (
    (auth.jwt()->>'sub') IN (
      'pixou-id', 'ceo-id', 'sio-id'
    ) OR 
    auth.jwt()->>'email' LIKE '%@csbusiness.fr'
  )
  WITH CHECK (TRUE);
```
- [ ] Identifier les user IDs des agents
- [ ] Créer les policies
- [ ] Tester accès agents

#### Task 1.3.1 : Real-time Edge Function (optionnel)
Si besoin de logique complexe (webhook Paperclip).
- [ ] Créer `/functions/tasks-sync.ts`
- [ ] Trigger sur INSERT/UPDATE/DELETE
- [ ] Notifier agents

### EPIC 2 : App Mobile

#### Task 2.1.1 : Lire tâches depuis Supabase
**Fichier** : `todo-semaine-{JJMMMM}.html` (nouvelle version)

```javascript
// Au chargement
const { data, error } = await db
  .from('tasks')
  .select('*')
  .order('priority', { ascending: false })
  .order('created_at', { ascending: false });
```
- [ ] Importer Supabase JS client
- [ ] Fonction `loadTasks()`
- [ ] Afficher tâches en HTML
- [ ] Tester

#### Task 2.2.1 : Ajouter tâche (input + dictée)
```javascript
async function addTask(title, category, type) {
  const { data, error } = await db
    .from('tasks')
    .insert([{
      title,
      category,
      type, // perso ou pro
      status: 'todo',
      created_by: 'catherine'
    }])
    .select();
  
  renderTasks(); // mettre à jour l'affichage
}
```
- [ ] Connecter bouton + input
- [ ] Connecter microphone (Web Speech API)
- [ ] Auto-addTask() après dictée
- [ ] Tester

#### Task 2.3.1 : Cocher/décocher
```javascript
async function toggleTask(id, currentStatus) {
  const newStatus = currentStatus === 'done' ? 'todo' : 'done';
  await db
    .from('tasks')
    .update({ status: newStatus, completed_at: newStatus === 'done' ? now() : null })
    .eq('id', id);
  
  renderTasks();
}
```
- [ ] Event listener sur checkbox
- [ ] Mettre à jour Supabase
- [ ] Rafraîchir affichage

#### Task 2.4.1 : Sélecteur perso/pro
```html
<select id="taskType">
  <option value="pro">Pro</option>
  <option value="perso">Perso</option>
</select>
```
- [ ] Ajouter select au formulaire
- [ ] Passer `type` à `addTask()`
- [ ] Afficher indicateur visuel (couleur/tag)

#### Task 2.5.1 : Filtres
```javascript
function filterTasks(filter) {
  // filter: 'all', 'todo', 'done', 'pro', 'perso'
  const filtered = allTasks.filter(t => {
    if (filter === 'todo') return t.status !== 'done';
    if (filter === 'done') return t.status === 'done';
    if (filter === 'pro') return t.type === 'pro';
    if (filter === 'perso') return t.type === 'perso';
    return true;
  });
  renderTasks(filtered);
}
```
- [ ] Boutons filtres
- [ ] Event listeners
- [ ] Active state CSS

#### Task 2.6.1 : Real-time sync
```javascript
const subscription = db
  .channel('tasks')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'tasks' },
    payload => {
      loadTasks(); // ou update individuelle
    }
  )
  .subscribe();
```
- [ ] Supabase Realtime client
- [ ] Écouter INSERT/UPDATE/DELETE
- [ ] Auto-refresh l'affichage

#### Task 2.7.1 : URL dynamique
```javascript
// Déterminer la date de la semaine
const today = new Date();
const weekStart = new Date(today.setDate(today.getDate() - today.getDay()));
const dateStr = `${weekStart.getDate()}${monthStr}`;

// URL actuelle : /todo-semaine-17avril.html
// Nouvelle : /todo-{dateStr}.html
```
- [ ] Script JS pour calculer date
- [ ] Générer filename dynamique
- [ ] Ou déployer une version "todo-current.html"

#### Task 2.8.1 : Offline support
```javascript
// localStorage fallback
const tasksCache = localStorage.getItem('tasks-cache') || '[]';
const cachedTasks = JSON.parse(tasksCache);

// Quand online, synchro
if (navigator.onLine) {
  syncCachedTasks();
}
```
- [ ] Détecter online/offline
- [ ] Cache localStorage
- [ ] Queue des modifications
- [ ] Synchro quand online

### EPIC 3 : Portail Admin
*(déjà en cours, vérifier)*
- [ ] Task 3.1 : Tester sync real-time avec app mobile
- [ ] Task 3.2 : Vérifier filtres perso/pro
- [ ] Task 3.3 : Vérifier suppression/édition tâches

### EPIC 4 : Paperclip Integration

#### Task 4.1.1 : Ajouter tasks à TOOLS.md
```yaml
# TOOLS.md (Paperclip config)
supabase_tables:
  tasks:
    select: true # Pixou, CEO, Sio peuvent lire
    insert: true # Peuvent ajouter
    update: true # Peuvent modifier
    delete: true # Peuvent supprimer
```
- [ ] Mettre à jour TOOLS.md
- [ ] Tester agents → read tasks
- [ ] Tester agents → write tasks

#### Task 4.2.1 : Tester lecture (agent Python)
```python
# Dans agent Pixou
response = supabase.table('tasks').select('*').execute()
tasks = response.data
```
- [ ] Créer script test
- [ ] Lister tâches urgentes
- [ ] Notifier Catherine

#### Task 4.3.1 : Tester écriture (agent Python)
```python
# CEO ajoute une tâche
supabase.table('tasks').insert({
  'title': 'Nouvelle tâche du CEO',
  'category': 'clients',
  'type': 'pro',
  'created_by': 'ceo'
}).execute()
```
- [ ] Créer tâche test
- [ ] Vérifier dans portail + mobile

#### Task 4.4.1 : Template CR hebdo (CEO)
**Contenu du CR** :
```
## Récap semaine du {DATE}

### Tâches en cours
[Liste des tâches status='todo']

### Tâches complétées cette semaine
[Liste des tâches status='done' et completed_at > semaine dernière]

### Tâches urgentes
[Liste des tâches priority=2]
```
- [ ] Créer prompt CEO
- [ ] Requête Supabase pour tâches de la semaine
- [ ] Générer rapport formaté

## Timeline estimée

| Epic | Durée | Dépendances |
|------|-------|-------------|
| 1 (Database) | 2h | - |
| 2 (App Mobile) | 6h | Epic 1 |
| 3 (Portail) | 1h | Epic 2 |
| 4 (Paperclip) | 3h | Epic 1 + 2 |
| **Total** | **12h** | - |

## GATE 2 STATUS: ✅ PRÊT POUR BUILD
