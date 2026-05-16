# TODO - Réduction des lignes rouges (complexité) - chaincacao-mbh-2026

- [ ] Étudier `backend/lots/views.py` et repérer les gros blocs à extraire (helpers, patterns get/set status + LotTransfer + blockchain hash).
- [ ] Créer un module utilitaire (ex: `backend/lots/services/lot_actions.py`) pour centraliser :
  - [ ] `generate_demo_hash`
  - [ ] `call_smart_contract_update_status`
  - [ ] helpers “get lot or 404”, “update status + create transfer”, “compute blockchain hash”.
- [ ] Refactorer `backend/lots/views.py` pour utiliser ces helpers (sans changer les routes ni les signatures des endpoints).
- [ ] Nettoyer imports dans `backend/lots/views.py` (réduction du bruit).
- [ ] Exécuter `python backend/manage.py check`.
- [ ] Exécuter `python backend/manage.py makemigrations --check` (optionnel si nécessaire) et `python backend/manage.py test`.

