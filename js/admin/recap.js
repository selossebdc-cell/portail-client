async function loadRecaps() {
  const { data, error } = await db
    .from('weekly_recaps')
    .select('*')
    .order('week_start', { ascending: false })
    .limit(10);

  if (error) { console.error('Erreur chargement récaps:', error); return; }
  renderRecaps(data);
}

function renderRecaps(recaps) {
  const container = document.getElementById('recap-content');

  if (!recaps || recaps.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <div class="empty-state__icon">📋</div>
        <div class="empty-state__text">Aucun récap DG pour le moment.<br>Le premier sera généré lundi prochain.</div>
      </div>`;
    return;
  }

  let html = '';

  html += `<div style="display:flex;gap:var(--space-sm);margin-bottom:var(--space-lg);overflow-x:auto">`;
  recaps.forEach((recap, i) => {
    const weekDate = new Date(recap.week_start);
    const label = weekDate.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' });
    const activeClass = i === 0 ? 'btn-primary' : 'btn-secondary';
    html += `<button class="btn ${activeClass} btn-sm" onclick="showRecap(${i})" data-recap-idx="${i}">Sem. ${label}</button>`;
  });
  html += `</div>`;

  recaps.forEach((recap, i) => {
    const hiddenClass = i === 0 ? '' : 'hidden';
    html += `<div class="recap-week ${hiddenClass}" data-recap-week="${i}">`;

    if (recap.content_html) {
      html += `<div class="card">${recap.content_html}</div>`;
    }

    if (recap.tasks && recap.tasks.length > 0) {
      html += `<div class="card"><h3 class="card-title mb-md">Actions de la semaine</h3>`;
      recap.tasks.forEach((task, j) => {
        const checked = task.is_completed ? 'checked' : '';
        const completedClass = task.is_completed ? 'completed' : '';
        html += `
          <div class="checkbox-item ${completedClass}">
            <input type="checkbox" ${checked} onchange="toggleRecapTask('${recap.id}', ${j}, this)">
            <span class="checkbox-label">${task.title}</span>
          </div>`;
      });
      html += '</div>';
    }

    html += '</div>';
  });

  container.innerHTML = html;
}

function showRecap(idx) {
  document.querySelectorAll('.recap-week').forEach(el => el.classList.add('hidden'));
  document.querySelector(`[data-recap-week="${idx}"]`).classList.remove('hidden');

  document.querySelectorAll('[data-recap-idx]').forEach(btn => {
    btn.className = btn.dataset.recapIdx == idx ? 'btn btn-primary btn-sm' : 'btn btn-secondary btn-sm';
  });
}

async function toggleRecapTask(recapId, taskIndex, checkbox) {
  const { data: recap } = await db
    .from('weekly_recaps')
    .select('tasks')
    .eq('id', recapId)
    .single();

  if (!recap) return;

  const tasks = recap.tasks;
  tasks[taskIndex].is_completed = checkbox.checked;

  await db
    .from('weekly_recaps')
    .update({ tasks })
    .eq('id', recapId);

  checkbox.closest('.checkbox-item').classList.toggle('completed', checkbox.checked);
}
