# Grandinių virtualūs laboratoriniai darbai (Scilab)

Interaktyvūs elektros grandinių laboratoriniai darbai su vienoda, paprastesne LD1 ir LD2 sąsaja.

## Studentui

Linux aplinkoje paleiskite:

```bash
./PALEISTI.sh
```

Scilab aplinkoje vykdykite šakninį `STENDAS.sce`. Pasirinkęs darbą studentas
įveda eilės numerį (1–64), vardą ir pavardę bei grupę. Prieš pradedant
parodomos variantui priskirtos reikšmės. Stende rodoma vieno etapo užduotis;
mygtukas **Patikrinti** po teisingo atsakymo tampa **Toliau**.

LD1 turi naujus 64 pastovius virtualius variantus. LD2 išlaiko originalų
`LD2-64-A-2026` priskyrimą. Vardas, grupė ir variantas išlieka eksportuose;
LD2 juos išlaiko ir išsaugotame darbe. Pakeitus tik vardą ar grupę atliktas darbas išlieka.

[Naudojimas ir variantai](studentui/README.md) · [Paruoštas ZIP paketas](dist/Grandiniu_LD-studentui.zip)

## Automatinė patikra

```bash
./PATIKRINTI.sh
```

Komanda pati jungia grandines, atlieka matavimus, įveda atsakymus ir tikrina
etapus. Rankomis spręsti nereikia. Testų langai atidaromi atskirame Scilab
procese ir uždaromi pasibaigus patikrai.

- Visi 64 LD1 variantai tikrinami skaitiniu grandinės sprendikliu.
- Visi 64 LD2 variantai atlieka visus 12 etapų (768 etapų).
- Su 1, 17 ir 64 variantais visi LD1 ir LD2 etapai atliekami per tikrų
  langų valdiklių funkcijas; tikrinamas ir duomenų išlaikymas, eksportas bei sesijos atkūrimas.

Patikra praėjo su **Scilab 2026.1.0 Linux**. Žurnalai ir tikrintų failų hash:
[`studentui/tests/results/`](studentui/tests/results/). Windows vaizdas šiai
sąsajai dar netikrintas.

## Turinys

- `studentui/` – išbandyta bendra studento sąsaja, LD1 ir LD2 variantai bei automatinė patikra.
- `LD1/` – pradinis LD1 v1.7 šaltinis.
- `LD2/` – vystomas LD2 v2.0 šaltinis.
- `audits/` – LD2 nepriklausomo kryžminio audito medžiaga, naudota prieš v2.0.
- `dist/` – paruoštas savarankiškas studento versijos ZIP paketas.

Studento versijos vykdomojo kodo pagrindas – pilni LD1 v1.7 ir LD2 v1.1
paketai, papildyti originaliu LD2 v2 variantų moduliu. Abu šakniniai
paleidikliai naudoja `studentui/` versiją. Pradiniai šaltiniai išlaikyti atskirai.

## Pastaba

Studentų sugeneruotos ataskaitos ir asmens duomenys į saugyklą neįtraukiami.
