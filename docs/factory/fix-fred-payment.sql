-- Fix paiement Fred : solde 3000 EUR = en attente attestation URSSAF
UPDATE contracts SET payment_schedule = '[
  {"date": "2026-01-22", "amount": 2500, "status": "paid", "label": "Acompte signature"},
  {"date": "2026-02-22", "amount": 2500, "status": "paid", "label": "2e echeance"},
  {"date": "2026-03-22", "amount": 3000, "status": "pending", "label": "Solde", "status_label": "En attente attestation URSSAF"}
]'::jsonb
WHERE client_id = '83e6c2be-f9cc-47d8-9232-e80e1626fa62';
