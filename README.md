# Grandinių virtualūs laboratoriniai darbai (Scilab)

Interaktyvūs elektros grandinių laboratoriniai darbai: Scilab sąsaja, bendras C++ branduolys ir automatinis LD1–LD7 ataskaitų vertinimas.

LD7: šaltinis E su vidine varža r, reostatas penkiose padėtyse; išorinė charakteristika U(I), galios kreivė P(R), suderinamumo režimas R = r, tuščiosios eigos ir trumpojo jungimo matavimai; 64 variantai, šeši etapai ir automatinis 27 kriterijų vertinimas. [LD7 Windows ir Linux priėmimo patikra](audits/ld7-f5dd729/README.md).

LD6: E1, nuoseklus, priešpriešinis ir lygiagretus šaltinių jungimas; 64 variantai, šeši etapai ir automatinis 25 kriterijų vertinimas. [Studento eiga](studentui/README.md) · [LD6 pataisų patikra](audits/ld6-1b0f00a-fixes/README.md).

[LD5 pataisos ir Windows/Linux patikra](audits/ld5-c9b18f3-fixes/README.md): gnybtai, gyvi rodmenys, studento eiga ir automatinis ataskaitų vertinimas.

**Studentas pateikia vieną HTML ataskaitą. Dėstytojas pasirenka darbų aplanką ir gauna balus, klaidų komentarus bei CSV suvestinę.** [Naudojimas, rubrika ir surinkimas](core/README.md). [Naujausia automatinio vertinimo patikra](audits/closure-2026-09-13/README.md).

Windows / Linux paketai su C++ branduoliu kuriami [GitHub Actions](https://github.com/Karpavicius82/Grandiniu_LD/actions/workflows/native.yml). macOS Intel ir Apple Silicon tikrinami [atskiroje patikroje](https://github.com/Karpavicius82/Grandiniu_LD/actions/workflows/macos.yml). Šaltinių kopijai pirmiausia reikia surinkti branduolį pagal `core/README.md`.

[Stendų ergonomikos auditas](audits/ergonomics-2026-09-13/README.md): LD1–LD3 kontaktų koordinatės, 36 × 40 px paspaudimo zonos, bent 8 px tarpai, laidų sankirtos, langų vaizdai ir C++ patikra. Linux CI tikrina tikrus Scilab langus.

## Studentui

Linux aplinkoje paleiskite:

```bash
./PALEISTI.sh
```

Scilab aplinkoje vykdykite šakninį `STENDAS.sce`. Pasirinkęs darbą studentas
įveda eilės numerį (1–64), vardą ir pavardę bei grupę. Prieš pradedant
parodomos variantui priskirtos reikšmės. Stende rodoma vieno etapo užduotis;
atsiskaitymo režime **Įrašyti ir toliau** išsaugo tikrus atsakymus. Mokymosi režime **Patikrinti** leidžia gauti grįžtamąjį ryšį.

LD1 turi naujus 64 pastovius virtualius variantus. LD2 išlaiko originalų
`LD2-64-A-2026` priskyrimą. Vardas, grupė ir variantas išlieka eksportuose;
LD2 juos išlaiko ir išsaugotame darbe. Pakeitus tik vardą ar grupę atliktas darbas išlieka.

[Naudojimas ir variantai](studentui/README.md) · [Windows ir Linux paketas su C++ branduoliu](dist/Grandiniu_LD-studentui.zip)

Mac: [Apple Silicon paketas](dist/Grandiniu_LD-macOS-arm64.zip) · [Intel paketas](dist/Grandiniu_LD-macOS-x86_64.zip). Pasirinkite savo Scilab architektūrą.

[Naujausia keturių platformų patikra](audits/student-delivery-2026-09-23/README.md): vienodi LD1–LD7 langai, suprantamos ataskaitos ir automatinis vertinimas.

## Automatinė patikra

```bash
./PATIKRINTI.sh
```

Komanda pati jungia grandines, atlieka matavimus, įveda atsakymus ir tikrina
etapus. Rankomis spręsti nereikia. Testų langai atidaromi atskirame Scilab
procese ir uždaromi pasibaigus patikrai.

- Visi 64 LD1 variantai tikrinami skaitiniu grandinės sprendikliu.
- Visi 64 LD2 variantai atlieka visus 12 etapų (768 etapų).
- Su 1, 17 ir 64 variantais visi LD1, LD2 ir LD3 etapai atliekami per tikrų
  langų valdiklių funkcijas; tikrinamas ir duomenų išlaikymas, eksportas bei sesijos atkūrimas.

Naudojamas **Scilab 2026.1.0**. [LD6 Windows ir Linux patikra](audits/ld6-1b0f00a-fixes/README.md)
apima tikrus valdiklius, geometriją ir ataskaitų vertinimą. Paketų šaltinių SHA256:
[`studentui/tests/results/PATIKRA.json`](studentui/tests/results/PATIKRA.json).
Fizinių ekranų ir visų DPI skalių patikra neatlikta.

## Turinys

- `studentui/` – vienintelis aktyvus šaltinis: bendra studento sąsaja, LD1–LD7
  variantai, elementų numerių registrai (T/B/E/F/V/H/W/D/A kodai) ir automatinė patikra.
- `audits/` – LD2 nepriklausomo kryžminio audito medžiaga, naudota prieš v2.0.
- `dist/` – paruoštas savarankiškas studento versijos ZIP paketas.

Studento versijos vykdomojo kodo pagrindas – pilni LD1 v1.7 ir LD2 v1.1
paketai, papildyti originaliu LD2 v2 variantų moduliu. Senieji šakniniai
`LD1/` ir `LD2/` medžiai pašalinti (2026-09) – jų istorija išlieka git'e,
o elementų numerių registro architektūra gyvena `studentui/LD1/ld1_ids.sci`
ir `studentui/LD2/ld2_ids.sci`; kiekviena [kodo] nuoroda instrukcijose
mašiniškai tikrinama (`tools/check_instruction_registry.py`, CI testas
`instruction_registry`).

## Pastaba

Studentų sugeneruotos ataskaitos ir asmens duomenys į saugyklą neįtraukiami.

## Plėtra iki 13 LD

[Techninė C++ / Scilab patikra](audits/architecture-2026-09-11/README.md) aprašo
bendrą branduolį, atkuriamus integracijos ir ataskaitų bandymus, rastus trūkumus
bei atviras Windows ir aprobacijos sąlygas.
[Minimalūs priėmimo kriterijai](audits/architecture-2026-09-11/MINIMALUS_PRIEMIMAS.md)
atskiria patikrintas galimybes nuo dar neįgyvendintų produkto reikalavimų.
