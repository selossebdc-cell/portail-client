// ═══ Tutos & Guides — guides pédagogiques et vidéos uniquement ═══

async function loadTutos(clientId) {
  const { data, error } = await db
    .from('tutos')
    .select('*')
    .eq('client_id', clientId)
    .in('tuto_type', ['guide', 'video'])
    .order('sort_order', { ascending: true });

  if (error) { console.error('Erreur chargement tutos:', error); return; }
  renderTutos(data);
}

function renderTutos(tutos) {
  const container = document.getElementById('tutos-list');

  if (!tutos || tutos.length === 0) {
    container.innerHTML = '<p style="color:#666666; text-align:center; padding:40px 0;">Pas encore de tutos.</p>';
    return;
  }

  let html = '';
  tutos.forEach(function(tuto) {
    var icon = tuto.icon || '📘';
    var hasUrl = tuto.loom_url && tuto.loom_url.length > 0;
    var isVideo = tuto.tuto_type === 'video';
    var progressText = isVideo ? '📹 Video' : (tuto.steps ? tuto.steps + ' etapes' : '');

    html += '<div class="tuto-card">' +
      '<div class="tuto-icon">' + icon + '</div>' +
      '<div class="tuto-info">' +
        '<div class="tuto-name">' + tuto.title + '</div>' +
        '<div class="tuto-desc">' + (tuto.content_html || '') + '</div>' +
        (progressText ? '<div class="tuto-progress">' + progressText + '</div>' : '') +
      '</div>';

    if (hasUrl) {
      var btnLabel = isVideo ? '▶ Regarder' : '▶ Voir';
      html += '<a href="' + tuto.loom_url + '" target="_blank" class="tuto-btn">' + btnLabel + '</a>';
    } else {
      html += '<span style="font-size:0.75rem;color:#666666;font-style:italic;white-space:nowrap">Bientot dispo</span>';
    }

    html += '</div>';
  });

  container.innerHTML = html;
}
