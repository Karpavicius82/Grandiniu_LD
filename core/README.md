# Bendras C++ branduolys ir automatinis vertinimas

Versija 0.2.0. Įgyvendinti esami **LD1 ir LD2**, išlaikant jų vardus ir 64 variantų bankus. Kitų 11 darbų ši versija dar nevertina. Tai vidiniams priėmimo bandymams skirtas leidimas, ne išorinė aprobacija.

Studentas atveria `STENDAS.sce`, įveda vardą, grupę ir eilės numerį. Atsiskaitymo režime mygtukas **Įrašyti ir toliau** išsaugo ir klaidingus atsakymus. Pabaigoje **Išsaugoti ataskaitą** sukuria vieną HTML failą naudotojo aplanke `Grandiniu_LD_darbai`. Tą failą studentas persiunčia dėstytojui. Ataskaitą galima sukurti ir nebaigus darbo, per Pagalbą. Mokymosi režimas, pavyzdžiai ir juodraščio atvėrimas yra Pagalboje.

Dėstytojas atveria **DESTYTOJUI.sce** arba pasirenka dėstytojo punktą paleidimo lange. Pasirenka studentų darbų aplanką; C++ programa perskaito jo failus ir poaplankius. Naujas `Vertinimai-...` aplankas turi:

* `vertinimai.html`: kiekvienas darbas, balai, studento atsakymai, etalonai, klaidų komentarai;
* `suvestine.csv`: lentelė skaičiuoklei, viena eilutė kiekvienam failui;
* `vertinimai.json`: išsamūs pakartojami rezultatai, versijos ir neapdorotų failų sąrašas.

Originalūs failai nekeičiami. Po kiekvienų 25 failų įrašomas tarpinis rezultatas. Sustabdžius išsaugomi jau įvertinti darbai ir likusių failų sąrašas. Pakartotinis paleidimas sukuria naują rezultatų aplanką ir perskaičiuoja paketą iš pradžių. Tai sąmoningai paprasta atkūrimo eiga, ne slaptas ankstesnio vertinimo pakeitimas.

## Pradinė skaitinė rubrika

`LD1-1`: 22 vienodo svorio kriterijai — 8 skaičiavimai, 2 grandinių tipai, 5 matavimai, 5 palyginimai, 2 sujungimai. `LD2-1`: 50 kriterijų — 33 skaitiniai atsakymai, 8 baziniai matavimai, 3 sujungimai, rezonanso paieška, 3 ekstremumų tyrimai, pusės galios tyrimas ir dažninė lentelė. Instrukcijos / įvadinis etapas taškų neduoda.

Balas: `round(100 * points / max_points) / 10`, nuo 0 iki 10. Nepateiktas arba klaidingas atsakymas gauna 0 tik už konkretų kriterijų. Palyginimo / duomenų apdorojimo užduotis vertinama pagal studento užfiksuotus matavimus; atskiras matavimo kriterijus tikrina jų atitikimą grandinei. Rezonanso paieškai būtini tinkami matavimo taškai abipus ekstremumo. Laisvos išvados išsaugomos ir parodomos, bet jų turinys automatiškai semantiškai nevertinamas ir balų neturi. Rubrikos svorius bei šią laisvo teksto politiką turi peržiūrėti dalyko vertintojas prieš oficialų naudojimą.

LD1 skaičiavimams naudojama 1 % santykinė tolerancija ir 1e-9 absoliuti atsakymo vienetais. LD2 paprastiems atsakymams — 1,5 % ir 0,005 atsakymo vienetais, kaip esamame stende; rezonanso etapų tolerancijos atskiros ir išsaugomos kiekvieno kriterijaus rezultate. Modelio skaitinis tikslumas tikrinamas atskirai nuo vertinimo tolerancijų. SI naudojamas branduolyje; ataskaitos laukų vienetai fiksuoti (`A`, `mA`, `V`, `mW`, `Ohm`, `Hz`, `ms`, `deg`, `1`, `choice`).

Visi bandymai išlieka. Suvestinei `selected_for_summary=true` gauna daugiausia taškų surinkęs tos pačios deklaruotos studento tapatybės ir darbo bandymas; lygių balų atveju — pirmas failas leksikografine tvarka. Tiksli to paties ID kopija pažymima `duplicate`. Skirtingi duomenys tuo pačiu ID sustabdo abiejų automatinį pažymį (`conflict`). Nežinoma versija / sugadintas failas gauna `review` ir paaiškinimą, be pažymio. Vietinė ataskaita nepatvirtina studento autorystės.

## Bendras šablonas kitiems darbams

Vienas ataskaitos apvalkalas ir vienas paketinis vertintuvas naudojami visiems darbams. Naujo LD modulis prideda tik: pastovų banką, užduočių laukus ir vienetus, eksperimentų duomenis, C++ vertinimo taisykles, nepriklausomus etalonus. Mokinio lango, saugojimo, HTML, aplanko importo, suvestinių ir klaidingų failų apdorojimo nereikia rašyti iš naujo. Neįgyvendintas LD aiškiai atmetamas; vien pakeisti jo numerį nepakanka.

Schema `1`: `lab_id`, `lab_revision`, `rubric_version`, `bank_id`, `variant`, `submission_id`, `student`, `mode`, `parameters`, `answers[]`, `observations[]`, `evidence`, `note`. Kiekvienas atsakymas turi stabilų `id`, **nepakeistą `raw` tekstą** ir `unit`; matavimas turi `value` arba `null`. Vienintelio inertiško duomenų bloko pradžia: `<script type="application/json" id="ld-data">`. Įterptame JSON `<` koduojamas `\u003c`; matomas tekstas HTML koduojamas. Kodo ar formulių importas nevykdomas. Importo ribos: 2 MiB failui, 32 gyliai, 256 atsakymų / matavimų laukai, 2048 taškai lentelei, 10 000 failų paketui. Simbolinės nuorodos neskaitomos.

Skaičiavimai: C++17 / Eigen, kompleksinis modifikuotų mazgų metodas, nepriklausomi įtampos ir srovės šaltiniai, R/L/C; nusistovėjusi DC ir sinusoidinė AC, RMS, `exp(+jwt)`. Eilutės ir stulpeliai masteliuojami; neapibrėžta ar blogai sąlygota grandinė grąžina klaidą. ABI: tik skaičiai ir kviečiančiosios pusės masyvai, be išimčių / STL per Scilab ribą. Vietiniai juodraščiai atskiri nuo persiunčiamų ataskaitų.

## Surinkimas ir patikra kūrėjui

Studentui ir dėstytojui reikia Scilab 2026.1.0 ir OS atitinkančio paketo su `bin/ldcore.dll` arba `bin/ldcore.so`. Kompiliatoriaus, Python, serverio ar mokamos API jų kompiuteriuose nereikia. CMake naudoja tik užfiksuotas priklausomybes su SHA256; jų šaltinių ir licencijų pranešimai pateikti `third_party`.

```sh
python tools/fetch_core_deps.py /tmp/ld-deps
cmake -S core -B build -DLD_DEPS=/tmp/ld-deps -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel 2
ctest --test-dir build -C Release --output-on-failure
cmake --install build --config Release --prefix studentui
python tools/test_automatic_reports.py --scilab /path/to/scilab --runtime studentui
```

Komandinė dėstytojo versija: `ldcheck STUDENTU_APLANKAS NAUJAS_REZULTATU_APLANKAS`. Windows naudoja Unicode `wmain`, Scilab siunčia UTF-8 baitus tiesiai į C++ ir nekviečia komandinio interpretatoriaus. GitHub Actions surenka ir tikrina Windows Server 2022 / MSVC bei Ubuntu 22.04. CI neatstoja Windows 10/11 GUI / DPI patikros su tikrais naudotojais.

Atviri viso projekto priėmimo klausimai: 11 likusių metodikų ir jų testai, trifazio darbo pilna studento eiga, Windows 10/11 naudotojo sąsajos / DPI patikra, dėstytojo rankinių pažymio pataisų istorija, projekto licencijos pasirinkimas ir dalykinė / išorinė aprobacija. Jie nepristatomi kaip jau atlikti.
