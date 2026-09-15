# LD7 priėmimo patikra

Pradinis ir galutinis kodas: `f5dd729` — pataisų šiam darbui nereikėjo, CI praėjo iš pirmo karto.
[Windows ir Linux CI](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/35014236639): **PASS**. Rezultatas užfiksuotas `verdict.json` ir paketų manifeste.

## Darbo apimtis

- Septintasis laboratorinis „Įtampos, srovės ir galios suderinamumo tyrimas" (dokumento aštuntoji tema): šaltinis E (3–12 V) su vidine varža r (E12 serija 22–82 Ω), reostatas penkiose padėtyse R = 0,33r…3r, kur R3 = r — suderinamumo režimas su Pmax = E²/(4r) ir η = 50 %.
- Trys studento sujungimai: darbinė grandinė E → jungiklis → ampermetras → R su voltmetru prie R; tuščioji eiga (voltmetras prie šaltinio galų); trumpasis jungimas (ampermetras vietoj krovinio). TE modeliuojama 1 MΩ, TJ — 1 µΩ apkrova per tą patį `ld_sources` režimą 1.
- Šeši etapai: sujungimas → penki matavimai (U, I žurnale su P = U·I) → vidinė varža r = ΔU/ΔI → galia, Pmax ir η → TE/TJ → išvados. Registre 47 kodai (T01–T10, B01–B17, E01–E06, A03–A06, V02, H01), padengimas 100 %.
- Rubrika `LD7-1`: 27 taškai — 12 atsakymų, 12 matavimų ir 3 laidų įrodymai. Bankas `LD7-64-A-2026`, ataskaitos revizija 1.
- Kartu pataisyta sena `GUI_PATIKRA` klaida: `bench_ld4_workflow` atstatydavo tuščią `LD_DATA_DIR`, todėl nuo `1b0f00a` pilnas langų rinkinys gedo po LD5. Dabar atstatomas tikrasis kelias; pilnas rinkinys žalias pirmą kartą nuo LD6 įvedimo.

## Patikrų apimtis

| Patikra kiekvienoje OS | Rezultatas: PASS |
| --- | --- |
| Tikri Scilab GUI valdikliai: variantai 1, 17, 64, šeši etapai | 3 užbaigti darbai |
| Pagrindiniu mygtuku sukurtos HTML ataskaitos | 3 × 27/27 |
| Stendo ir C++ vertinimas ties tolerancijų ribomis | 144 sutapimai |
| Visų 64 LD7 variantų faktinės Scilab ataskaitos | 64 × 27/27 |
| LD1–LD7 faktinių ataskaitų regresija | 449 ataskaitos |
| C++ testų rinkiniai, įskaitant LD7 fiziką ir vertinimą | 9/9 |
| MNA: 64 variantai × 7 apkrovos (5 padėtys, TE, TJ) | 448, KCL ir galios balansas |
| Geometrija: šeši etapai × trys dydžiai × abi galų tvarkos + 3 resize | 39, klaidų 0 |

Kliento dydžiai: **1280 × 720, 1280 × 800, 1600 × 900 px**. Mažiausias atstumas tarp gnybtų paspaudimo zonų – **47,84 px**. `coordinates-1280x800.csv` pateikia valdiklių koordinates, abiejų OS kataloguose – pilna suspausta geometrija ir CI žurnalai. Linux nuotraukose matomas tikras Scilab langas (E2–E6 ir trumpasis jungimas V64).

Testai vykdo tikrų valdiklių callback funkcijas. Dydžio keitimo teste vykdoma langui priskirta `resizefcn`, o ne imituojamas OS lango krašto tempimas. Visų fizinių ekranų ir Windows 10/11 DPI kombinacijos netikrintos. Tai techninė patikra; dalykinė ir išorinė aprobacija nesuteigiama. Vietinė HTML ataskaita nepatvirtina autorystės.

## Pakartojimas

```bash
ctest --test-dir build -C Release --output-on-failure
python tools/test_automatic_reports.py --scilab /kelias/iki/scilab --runtime studentui
python tools/test_ld7.py --scilab /kelias/iki/scilab --checker build/layoutcheck --grader build/ldcheck --output /tmp/ld7-patikra
```
