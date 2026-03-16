// ═══ Badges "Nouveau" — transversal ═══
// Compare localStorage last_seen vs created_at Supabase

const BADGE_STORAGE_KEY = 'portail-badges-';

function getBadgeKey(tabName) {
  return BADGE_STORAGE_KEY + (currentProfile ? currentProfile.id : '') + '-' + tabName;
}

function getLastSeen(tabName) {
  const val = localStorage.getItem(getBadgeKey(tabName));
  return val ? new Date(val) : new Date(0);
}

function markTabSeen(tabName) {
  localStorage.setItem(getBadgeKey(tabName), new Date().toISOString());
  // Remove badge
  const badge = document.getElementById('badge-' + tabName);
  if (badge) badge.style.display = 'none';
}

async function checkAllBadges(clientId) {
  const tabs = [
    { name: 'actions', table: 'actions', field: 'created_at' },
    { name: 'sessions', table: 'sessions', field: 'created_at' },
    { name: 'tutos', table: 'tutos', field: 'created_at' },
    { name: 'contract', table: 'contracts', field: 'created_at' }
  ];

  for (const tab of tabs) {
    const lastSeen = getLastSeen(tab.name);
    const { count } = await db
      .from(tab.table)
      .select('*', { count: 'exact', head: true })
      .eq('client_id', clientId)
      .gt(tab.field, lastSeen.toISOString());

    if (count && count > 0) {
      const badge = document.getElementById('badge-' + tab.name);
      if (badge) {
        badge.textContent = count;
        badge.style.display = '';
      }
    }
  }
}
