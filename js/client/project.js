// ═══ Mon projet — KPI, avancement, dashboards ═══

async function loadProject(clientId) {
  const { data, error } = await db
    .from('tutos')
    .select('*')
    .eq('client_id', clientId)
    .in('tuto_type', ['dashboard', 'project', 'roadmap'])
    .order('sort_order', { ascending: true });

  if (error) { console.error('Erreur chargement projet:', error); return; }
  renderProject(data);
}

function renderProject(items) {
  const container = document.getElementById('project-list');

  if (!items || items.length === 0) {
    container.innerHTML = '<div class="braindump-intro" style="text-align:center">' +
      '<h3>Mon projet</h3>' +
      '<p>Tes tableaux de bord et KPI apparaitront ici au fil de ton accompagnement.</p>' +
    '</div>';
    return;
  }

  let html = '';
  items.forEach(function(item) {
    var icon = item.icon || '📊';
    var hasUrl = item.loom_url && item.loom_url.length > 0;
    var desc = item.content_html || '';
    var tag = hasUrl ? 'a' : 'div';

    html += '<' + tag + (hasUrl ? ' href="' + item.loom_url + '" target="_blank"' : '') + ' style="display:flex;align-items:center;gap:16px;padding:20px 24px;background:#1a1a1a;border:1px solid #2a2a2a;border-radius:12px;margin-bottom:12px;text-decoration:none;color:inherit;transition:all 0.2s' + (!hasUrl ? ';opacity:0.7' : '') + '"' + (hasUrl ? ' onmouseover="this.style.borderColor=\'#C27A5A\'" onmouseout="this.style.borderColor=\'#2a2a2a\'"' : '') + '>' +
      '<div class="tuto-icon">' + icon + '</div>' +
      '<div style="flex:1">' +
        '<div style="font-weight:600;font-size:1rem;color:#e0e0e0">' + item.title + '</div>' +
        '<div style="font-size:0.8rem;color:#666666;margin-top:2px">' + desc + '</div>' +
      '</div>' +
      (hasUrl ? '<span style="color:#d4956f;font-size:0.9rem">Ouvrir →</span>' : '<span style="font-size:0.75rem;color:#666666;font-style:italic">Bientot dispo</span>') +
    '</' + tag + '>';
  });

  container.innerHTML = html;
}
