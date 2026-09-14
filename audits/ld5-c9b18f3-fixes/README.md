# LD5 pataisų priėmimo patikra

Pradinis kodas: `c9b18f3`. Patikrintos pataisos: `517d5a0a3fa7a660fcf3e70ffc94380c780498b3`.
[Windows ir Linux CI rezultatas](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34880604834): **PASS**, Scilab 2026.1.0.

## Pataisos

- Voltmetras perkeltas po RV; zondų laidai nebekerta prietaiso korpuso. T01–T12 užrašai centruoti ir skaitomi tiek jungiant, tiek užrakinus kontaktus. Kontaktų paspaudimo zonos 36 × 40 px.
- Padėties pakeitimas iškart atnaujina ampermetrą ir voltmetrą. Matavimus skaičiuoja bendras C++ MNA branduolys. Matavimo įrašas ir gyvas rodmuo sutampa.
- Parinkta P1/P2/P3 padėtis išryškinama; RV laukelis rodo aktyvią varžą. Žurnale įvardytos padėtys ir procentai. Instrukcijose bei peržiūroje liko tik tikrieji šeši LD5 etapai.
- Studentas gali įvesti kablelį arba tašką ir spausti pagrindinį mygtuką be Enter. Visų devynių atsakymų tikrinimas suderintas su C++ vertintuvu, įskaitant tolerancijų ribas ir pasirinkimus.
- Ataskaita išsaugo patikrintą pirmo etapo sujungimą. Nepatvirtinti laidai ir pavyzdžio duomenys neįtraukiami kaip atlikto sujungimo įrodymas. Sugadintos laidų poros negauna balo.
- Laido pašalinimas, atkūrimas, pavyzdžio peržiūra ir grįžimas į savo darbą nepalieka klaidingų užbaigimo požymių. Juodraštis atkuria atsakymus bei žurnalą prieš perpiešiant langą, su išjungtu maitinimu.
- Išvadų laukelių pavadinimai sutrumpinti, kad neliktų nereikalingos teksto slinkties.

## Įrodymai

Kiekvienoje OS patikrinta:

| Patikra | Rezultatas |
| --- | --- |
| Tikri LD5 langai, variantai 1, 17 ir 64, po 6 etapus | PASS |
| Pagrindiniu mygtuku išsaugotos trys HTML ataskaitos | Visos 16/16 |
| Stendo ir C++ sprendimų palyginimas ties tolerancijų ribomis | 108/108 sutampa |
| Visų LD5 variantų atlikimas ir realių ataskaitų vertinimas | 64/64 po 16/16 |
| Bendro branduolio regresija: faktinės LD1–LD5 ataskaitos | 321; numatyti rezultatai sutampa |
| CTest, įskaitant atskirą LD5 vertinimo testą | 7/7 testų rinkiniai |
| 6 etapai × 3 lango dydžiai × 2 laidų galų pasirinkimo tvarkos | 36 scenarijai, 0 geometrijos klaidų |

Geometrija tikrinta **1280 × 720, 1280 × 800 ir 1600 × 900 kliento pikseliais**.
Mažiausias atstumas tarp kontaktų paspaudimo zonų: **47,84 px**.
`linux/` ir `windows/` pateikia CI žurnalus, koordinates ir rezultatus; Linux kataloge yra ir langų nuotraukos.
`automatic.json` ir `ctest.log` paimti iš to paties CI vykdymo. `packages.json` susieja patikros rezultatus su paketų SHA256.

Tai automatizuotas tikrų Scilab valdiklių callback funkcijų vykdymas, įskaitant jų matomumo ir įjungimo būsenas.
Operacinės sistemos pelės įvykiai ir fiziniai ekranai su visomis DPI skalėmis netestuoti. Išorinis aprobavimas šia patikra nesuteikiamas.

## Pakartojimas

```bash
python tools/test_ld5.py --scilab /kelias/iki/scilab --checker build/layoutcheck --grader build/ldcheck --core build/ldcore.so --output /tmp/ld5-patikra
ctest --test-dir build --output-on-failure
```

Windows naudojamas `Scilex.exe` kelias; vidinė patikros programa tame pačiame kataloge parenka GUI palaikantį `WScilex-cli.exe` be `-nw` argumento. C++ programų keliai Windows sistemoje: `build/Release/layoutcheck.exe`, `build/Release/ldcheck.exe`, `build/Release/ldcore.dll`.
Python naudojamas tik vidinei patikrai ir paketų surinkimui; studentui ir dėstytojui jo nereikia.

Paketų vykdomieji failai paimti iš sėkmingo CI. Windows pakete išlaikytos ten patikrintos CRLF eilutės, Linux pakete – LF. Galutiniams paketams pridėtas patikros manifestas, vykdomasis kodas nekeistas. Bendras `Grandiniu_LD-studentui.zip` turi abiejų OS C++ failus ir 74 Scilab bei shell šaltinių failus; studentų ataskaitos ir juodraščiai nepakuojami.
