# Tikslūs darbo momentiniai archyvai

Čia saugomos tikslios pokalbio metu parengtų paketų ZIP kopijos, suskaidytos į Base64 tekstines dalis, kad būtų galima išlaikyti ir dvejetainius failus (pvz., XLSX).

Atkūrimas:

```bash
python tools/restore_snapshots.py
```

Skriptas sujungia `part_*.b64`, atkuria ZIP, patikrina SHA-256 ir patikrina ZIP struktūrą.

Kontrolinės sumos:

- LD1 v1.7: `84841d6187caadf415e37e376bbcd8d055073e69260c441205e2fe6477b051c5`
- LD2 v2.0: `2b87894ec3da67f501ec7ffa222907396e183cbee8f044dba649d2adb338f88b`
- LD2 auditas 2026-09-06: `ed284a2485e3aa7496897cacd8bc29298ee5a86f9cb0e1c8454b7203cac3d347`

`LD1/` ir `LD2/` katalogai skirti patogiam šaltinių naršymui. `snapshots/` yra nekintamos tiksliai perduotų paketų kopijos.
