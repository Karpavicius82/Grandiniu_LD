# LD1–LD3 stendų ergonomikos patikra, 2026-09-13

Tikrinami **patys studento langai**, jų kontaktai, valdikliai ir laidai. Ši patikra nėra išorinio vertintojo aprobacija. Šiuo metu įgyvendinti trys darbai: LD1 (9 etapai), LD2 (12 etapų), LD3 (6 etapai).

**Rezultatas: 228 scenarijai, 4 929 valdiklių ir 2 280 kontaktų patikros, 3 429 laidų atkarpos; 0 aptiktų geometrijos klaidų. Mažiausias tarpas tarp kontaktų – 8,016 px.** [Koordinatės CSV](coordinates-1280x800.csv), [C++ išvada](geometry.log), [LD3 langas](after/LD3-E1.png), [LD2 langas](after/LD2-E10.png), [LD1 langas](after/LD1-E8.png).

## Rastos ir pašalintos kliūtys

| Vieta | Buvo | Pakeista |
|---|---|---|
| LD3 U3 ir maitinimas | 56,32 × 24 px persidengimas, esant 1280 × 800 langui | Įtampos parinktys apačioje; maitinimas, jungiklis ir matavimas atskiroje juostoje |
| LD1 bendros srovės matavimas | Šaltinio ir ampermetro kontaktų centrai skyrėsi tik 16,77 px | Ampermetras virš šaltinio, abu kontaktai prie savo prietaiso |
| LD1 R2 / VR1 ir apatinė šyna | Per maži vertikalūs tarpai, kontaktų ir kodų persidengimai | Perskaičiuotos R2, VR1, šynos ir jų kontaktų koordinatės |
| LD2 gretimi RLC kontaktai | Kai kurių centrų tarpas tik 29,34 px | Perskaičiuoti komponentų plotis ir kontaktų centrai |
| Kontaktų priklausomybė | Kai kurie kontaktai nutolę nuo savo komponento be matomos jungties | Trumpi kontaktų išvadai iki savo komponento; simbolis ir T kodas pačiame kontakte, visas pavadinimas užvedus pelę |
| Laidai | Skirtingas storis pagal orientaciją; laidai piešiami ant kontaktų teksto | Bendras 3 px storis; atkarpos baigiasi ties kontaktų kraštais |
| Sankirtos | Zondai ir grįžtamasis laidas galėjo atrodyti elektriškai sujungti | LD3 zondai tiesūs ir nesikerta; likusiose sankirtose 10 px tarpas aiškiai žymi nesujungtus laidus |
| LD3 perpiešimas | Seni laidai, tekstai ir kontaktai nebuvo ištrinami | Ištrinamas visas ankstesnis stendo sluoksnis; nuolatiniai valdikliai saugomi atskirai |
| LD3 informacijos kiekis | Visi 8 atsakymų laukai vienu metu; nukerpama instrukcija | Rodomi tik dabartinio etapo atsakymai, instrukcija laužoma į eilutes; papildomi veiksmai pasiekiami per „Pagalba“ |
| LD3 įvestis | Tikrinimas neskaitė nepatvirtinto teksto; GUI testas apeidavo laukus | Įvestis paimama paspaudus tikrinimą; neteisingas tekstas išsaugomas; testas naudoja tikrus laukus |
| LD3 paleidimas | Registracijos funkcijos loginis rezultatas naudotas kaip studento duomenys | Atskirai paimami patvirtinimas, studentas ir parametrai; atšaukimas neatveria stendo ir neuždaro Scilab |

## Matavimo taisyklės

- Kontaktas: 36 × 40 loginių kliento px; tarp skirtingų kontaktų – bent 8 px.
- Kiti paspaudžiami valdikliai: bent 24 px aukščio; nėra tarpusavio persidengimų ar išėjimo už tėvinio rėmo.
- Laidas: 3 px; negali eiti per komponento vidų. Sankirta be elektrinio sujungimo turi aiškų tarpą.
- LD1–LD3 turi vienodą kairiojo stendo / dešinės užduoties išdėstymą.
- Koordinačių pradžia – kliento srities apačioje kairėje. Įdėtų rėmų normalizuotos koordinatės perskaičiuojamos per visą tėvinių objektų grandinę. Tai [Scilab dokumentuota koordinačių sistema](https://help.scilab.org/docs/2023.1.0/en_US/uicontrol_properties.html); OS lango dekoracijos ir fizinis ekrano DPI į šį skaičių neįeina.

## Atkartojimas ir įrodymai

C++ tikrintuvas: `core/tests/layout_check.cpp` (CMake taikinys `layoutcheck`). `tools/ergonomics.sci` išrašo tikro lango matomų valdiklių koordinates. `tools/ergonomics.sce` pereina visus 27 etapus, nesujungtą ir sujungtą stendą, leidžiamus LD2 zondų prijungimus, LD3 atvirkštinę laidų galų pasirinkimo tvarką bei pakartotinį perpiešimą.

`tools/test_entrypoints.sce` papildomai tikrina tikrą pagrindinio meniu → darbo paleidiklio → registracijos → lango kelią, įskaitant registracijos atšaukimą. Simuliuojami tik registracijos dialogų atsakymai. Linux GitHub Actions vykdo šias patikras Xvfb ekrane ir išsaugo koordinates, žurnalus bei langų vaizdus.

```bash
python3 tools/test_ergonomics.py \
  --scilab /kelias/iki/scilab \
  --output /tmp/ld-ergonomics
```

Python šiame įrankyje naudojamas tik vidiniam paleidimui ir lango vaizdo fiksavimui. **Studento ir dėstytojo darbo eigai Python nereikalingas.** Dabartiniai studento langai aprašyti Scilab `.sci`; C++ sudaro skaičiavimo / vertinimo branduolį ir šį koordinačių tikrintuvą. Tai nėra visos sąsajos perrašymas į C++.

Patikrų rezultatų ir failų SHA256 sąrašas pateikiamas `verdict.json`. `geometry.tsv.gz` saugo matuotus valdiklius, `geometry.log` – C++ išvadą. Vaizdai kataloguose `before/` ir `after/` skirti vizualiam palyginimui. Funkcinės patikros žurnalai patvirtina darbų atlikimą mygtukais, atsakymų išlaikymą ir HTML eksportą.

## Patikros ribos

Vietinė vaizdo patikra atlikta Linux / Scilab 2026.1.0. Kliento dydžiai: 1280 × 720, 1280 × 800 ir 1600 × 900 – po 76 scenarijus. Tikras dydis patvirtinamas po langų tvarkyklės dekoravimo; netinkamas dydis nutraukia bandymą. Mažesni langai, Windows šriftų vaizdas, 125–200 % DPI, ekrano skaitytuvai ir realių studentų naudojimo bandymas nėra patvirtinti šiuo auditu. Windows kompiliavimo bei eksportavimo CI rezultatas savaime nepatvirtina Windows langų ergonomikos.

Koordinačių patikra negarantuoja teksto įskaitomumo ar dalykinio suprantamumo: todėl ji papildyta tikrų langų vaizdų peržiūra. Kiekvienam naujam LD reikia pridėti jo etapų ir sujungimų scenarijus; bendro C++ tikrintuvo perrašyti nereikia.
