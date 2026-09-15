# LD6 pataisos ir priėmimo patikra

Pradinis kodas: `1b0f00a` (užklausoje nurodytas `1bf00a`). Pataisos: `e64fa7d`, žurnalo pritaikymas skirtingiems šriftams: `a294a9bab889013acbb4ec5bfc59edda483d9e84`.
[Windows ir Linux CI](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34991244185): **PASS**. Galutinis rezultatas užfiksuotas `verdict.json` ir paketų manifeste.

## Pataisos

- Pridėtas trūkęs lygiagretus jungimas. Visi keturi režimai skaičiuojami C++ MNA: E1, nuosekliai, priešpriešiais, lygiagrečiai. Abiejų šaltinių vidinės varžos po 10 Ω; nevienodos EV lygiagrečiai nebesudaro nesprendžiamos idealių šaltinių grandinės.
- Studentas pats sujungia kiekvieną schemą. Režimo mygtukas išsaugo jo laidus, išjungia maitinimą ir atveria jungiklį. Pavyzdys atskirtas nuo įskaitomų matavimų ir laidų įrodymų.
- E2 ir voltmetras perkelti, laidai nukreipti aplink prietaisus; jų sankirtos su tarpais. T01–T12 priskirti savo elementams ir rodo poliškumą. Gnybtai turi 36 × 40 px paspaudimo zonas, perskaičiuojamas lango dydžio keitimo funkcijoje.
- Vieno etapo užduotis ir atsakymai dešinėje; keturių režimų žurnalas kairėje. Vienetai pateikti kiekvienoje matavimo eilutėje, todėl atskira antraštės eilutė neužima vietos. Pataisyti nukopijuoti LD5 tekstai, šešių etapų eiga ir galutinis ataskaitos mygtukas. Įvestis priima kablelį ir tašką be Enter.
- Išlaikomas priešpriešinės įtampos ir srovės ženklas. Lygiagrečiame režime matomos atskiros šaltinių srovės; neigiamas ženklas reiškia srovę į šaltinį.
- Suderintas studento ir C++ variantų priskyrimas. Naujas bankas `LD6-64-B-2026`, ataskaitos revizija `2`, rubrika `LD6-2`: 11 atsakymų + 10 matavimų + 4 sujungimai = 25 taškai. Ankstesnės revizijos ataskaitos išlaiko 14 taškų rubriką.
- Ataskaita saugo kiekvieno patikrinto režimo laidus. Jų pakeitimas panaikina susijusius įrodymus ir matavimus. Juodraščio atkūrimas išlaiko neapdorotą įvestį ir išjungia maitinimą.

## Patikrų apimtis

| Patikra kiekvienoje OS | Rezultatas: PASS |
| --- | --- |
| Tikri Scilab GUI valdikliai: variantai 1, 17, 64, šeši etapai | 3 užbaigti darbai |
| Pagrindiniu mygtuku sukurtos HTML ataskaitos | 3 × 25/25 |
| Stendo ir C++ vertinimas ties tolerancijų ribomis | 132 sutapimai |
| Visų 64 LD6 variantų faktinės Scilab ataskaitos | 64 × 25/25 |
| LD1–LD6 faktinių ataskaitų regresija | 385 ataskaitos |
| C++ testų rinkiniai, įskaitant LD6 fiziką ir vertinimą | 8/8 |
| MNA: 64 variantai × 4 režimai ir lygių EV atvejai | 258, KCL ir energijos balansas |
| Geometrija: šeši etapai × trys dydžiai × abi galų tvarkos + 3 resize funkcijos bandymai | 39, klaidų 0 |

Kliento dydžiai: **1280 × 720, 1280 × 800, 1600 × 900 px**. Mažiausias atstumas tarp gnybtų paspaudimo zonų – **47,84 px**. `coordinates-1280x800.csv` pateikia valdiklių koordinates, abiejų OS kataloguose – pilną suspaustą geometriją ir CI žurnalus. Linux nuotraukose matomas tikras Scilab langas.

Testai vykdo tikrų valdiklių callback funkcijas. Dydžio keitimo teste vykdoma langui priskirta `resizefcn`, o ne imituojamas OS lango krašto tempimas. Visų fizinių ekranų ir Windows 10/11 DPI kombinacijos netikrintos. Tai techninė patikra; dalykinė ir išorinė aprobacija nesuteikiama. Vietinė HTML ataskaita nepatvirtina autorystės.

## Pakartojimas

```bash
ctest --test-dir build -C Release --output-on-failure
python tools/test_automatic_reports.py --scilab /kelias/iki/scilab --runtime studentui
python tools/test_ld6.py --scilab /kelias/iki/scilab --checker build/layoutcheck --grader build/ldcheck --core build/ldcore.so --output /tmp/ld6-patikra
```

Windows teste nurodomas `Scilex.exe` kelias; programa pasirenka greta esantį grafinį `WScilex-cli.exe` be `-nw`. C++ failai ten yra `build/Release/`. Python skirtas tik vidinei patikrai ir paketų surinkimui, studentui bei dėstytojui jo nereikia.

Paketų vykdomieji failai imami iš to paties sėkmingo CI. Windows pakete išlaikomos patikrintos CRLF eilutės, Linux – LF; jų skirtumas nekeičia šaltinio turinio. SHA256 ir kodą identifikuoja `packages.json` bei `studentui/tests/results/PATIKRA.json`. Bendras ZIP turi abiejų OS vykdomuosius failus. Studentų ataskaitos ir juodraščiai neįtraukiami.
