// ═══ Onglet Automatisations ═══

async function loadAutomations(clientId) {
  const { data: contract } = await db
    .from('contracts')
    .select('automations_included, automations')
    .eq('client_id', clientId)
    .single();

  renderAutomations(contract);
}

function renderAutomations(contract) {
  var container = document.getElementById('automations-list');
  var included = (contract && contract.automations_included) || 1;
  var automations = (contract && contract.automations) || [];

  var html = '';

  // Intro
  html += '<div style="margin-bottom:24px;padding:20px;background:rgba(194,122,90,0.05);border:1px solid rgba(194,122,90,0.15);border-radius:12px">' +
    '<div style="display:flex;align-items:center;gap:12px;margin-bottom:8px">' +
      '<span style="font-size:1.6rem">⚡</span>' +
      '<div>' +
        '<div style="font-family:Playfair Display,serif;font-size:1.1rem">Tes automatisations</div>' +
        '<div style="font-size:0.8rem;color:#b0b0b0">' + included + ' automatisation' + (included > 1 ? 's' : '') + ' incluse' + (included > 1 ? 's' : '') + ' dans ton programme</div>' +
      '</div>' +
    '</div>' +
  '</div>';

  // Automatisations existantes
  if (automations.length > 0) {
    automations.forEach(function(auto, i) {
      var isIncluded = i < included;
      var statusColor, statusLabel, statusIcon;

      switch (auto.status) {
        case 'delivered':
          statusColor = '#4ade80'; statusLabel = 'Livree'; statusIcon = '✓'; break;
        case 'in_progress':
          statusColor = '#60a5fa'; statusLabel = 'En cours'; statusIcon = '◐'; break;
        case 'planned':
          statusColor = '#fb923c'; statusLabel = 'Planifiee'; statusIcon = '○'; break;
        case 'proposal':
          statusColor = '#d4956f'; statusLabel = 'Devis envoye'; statusIcon = '📄'; break;
        default:
          statusColor = '#666666'; statusLabel = auto.status || 'A definir'; statusIcon = '○';
      }

      html += '<div style="padding:16px 20px;background:#1a1a1a;border:1px solid #2a2a2a;border-radius:12px;margin-bottom:10px">' +
        '<div style="display:flex;justify-content:space-between;align-items:flex-start">' +
          '<div style="flex:1">' +
            '<div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">' +
              '<span style="font-size:0.9rem;font-weight:600;color:#e0e0e0">' + auto.name + '</span>' +
              (isIncluded
                ? '<span style="font-size:0.65rem;padding:2px 8px;background:rgba(74,222,128,0.1);color:#4ade80;border-radius:4px;font-weight:600">INCLUSE</span>'
                : '<span style="font-size:0.65rem;padding:2px 8px;background:rgba(194,122,90,0.1);color:#d4956f;border-radius:4px;font-weight:600">OPTION</span>') +
            '</div>' +
            (auto.description ? '<div style="font-size:0.8rem;color:#b0b0b0;margin-bottom:4px">' + auto.description + '</div>' : '') +
            (auto.value ? '<div style="font-size:0.75rem;color:#666666">Valeur : ' + auto.value.toLocaleString('fr-FR') + ' EUR HT</div>' : '') +
          '</div>' +
          '<div style="text-align:right;flex-shrink:0;margin-left:12px">' +
            '<span style="font-size:0.75rem;color:' + statusColor + ';font-weight:500">' + statusIcon + ' ' + statusLabel + '</span>' +
          '</div>' +
        '</div>' +
      '</div>';
    });
  } else {
    html += '<div style="padding:20px;background:#1a1a1a;border:1px solid #2a2a2a;border-radius:12px;text-align:center">' +
      '<div style="font-size:1.2rem;margin-bottom:8px">⚡</div>' +
      '<div style="font-size:0.85rem;color:#b0b0b0">Ton automatisation sera definie au fil de l\'accompagnement.</div>' +
      '<div style="font-size:0.8rem;color:#666666;margin-top:4px">Catherine te proposera la plus adaptee a ton activite.</div>' +
    '</div>';
  }

  // Section "Envie d'aller plus loin ?"
  html += '<div style="margin-top:24px;padding:20px;background:linear-gradient(135deg,rgba(194,122,90,0.08),rgba(194,122,90,0.03));border:1px solid rgba(194,122,90,0.2);border-radius:16px;text-align:center">' +
    '<div style="font-family:Playfair Display,serif;font-size:1rem;margin-bottom:8px">Envie d\'aller plus loin ?</div>' +
    '<div style="font-size:0.85rem;color:#b0b0b0;margin-bottom:12px">Des automatisations supplementaires peuvent etre developpees pour ton activite.<br>Chaque automatisation est sur-mesure et chiffree selon tes besoins.</div>' +
    '<a href="mailto:catherine@csbusiness.fr?subject=Demande%20automatisation%20suppl%C3%A9mentaire&body=Bonjour%20Catherine%2C%0A%0AJ%27aimerais%20discuter%20d%27une%20automatisation%20suppl%C3%A9mentaire.%0A%0AMon%20besoin%20%3A%20%5BA%20COMPLETER%5D%0A%0AMerci%20!" class="tuto-btn" style="display:inline-flex;align-items:center;gap:6px">Demander un devis</a>' +
  '</div>';

  container.innerHTML = html;
}
