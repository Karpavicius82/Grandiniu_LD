# Antroji LD8 ergonomikos ir patikrinamumo peržiūra

Pradinė versija: `73471d8` (`codex/ld8-verified-delivery`). Pagrindiniame
kataloge tuo metu buvo kuriamas LD9, todėl ši peržiūra atlikta atskiroje
`/tmp/ld8-release-worktree` darbo kopijoje. Ankstesni patikros įrodymai palikti
`audits/ld8-2026-09-24`.

## Atkurti trūkumai ir pataisos

Trumpas bandymas tikrame Scilab lange prieš pataisas pateikė:

```text
RAW_AFTER_RESTORE=
SAVED_PRACTICE=F
MAIN_ALIVE_AFTER_HELP_CLOSE=F HELP_ALIVE=T
REPORTS_AFTER_CLOSED_PRIMARY=1
```

- „Atkurti stendą“ prarado įvedimą be Enter. Dabar jis išsaugomas prieš
  perpiešimą, kartu atnaujinant juodraštį.
- Pavyzdžio naudojimas iš karto nepatekdavo į išsaugotą darbo būseną.
  Žyma dabar išsaugoma prieš įjungiant pavyzdį; grįžus vėl išsaugomas savas
  darbas. Pavyzdžio matavimai nepakeičia studento matavimų.
- Pagalbos lango `close()` užverdavo tuo metu aktyvią figūrą, įskaitant
  pagrindinį stendą. Mygtukas dabar užveria konkrečiai savo langą.
- Po uždarymo apdorotas pagrindinio mygtuko įvykis galėjo sukurti papildomą
  ataskaitą. Uždaryto stendo veiksmai dabar ignoruojami prieš keičiant būseną.

Papildomai: importuojamo LD8 juodraščio būsena tikrinama prieš keičiant
atvirą darbą; atmestas importas jo nepakeičia. Patikrinami režimai, atsakymų
ir etapų matmenys, laidų galai, dublikatai, matavimų žurnalas ir saugomi
režimo požymiai. Neleidžiama importuoti GUI ar vykdymo laukų.

Maitinimo ir jungiklio mygtukai rodo kitą veiksmą. Pavyzdyje neveikiantys
jungimo mygtukai išjungti; pirmame etape išjungtas „Atgal“. Jungimo pagalboje
naudojami gnybtų kodai ir lietuviški objektų pavadinimai. Ilgi studento
rekvizitai pasiekiami ir užuominoje. Formulėse aiškiai parodytas daugiklis
1000 pereinant tarp amperų ir ekrane rodomų miliamperų; skaitinės reikšmės
ir vertinimo tolerancijos nepakeistos.

## Patikros apimtis

- 19 geometrijos scenarijų: šeši etapai, abiejų krypčių sujungimai, kitokia
  laidų įvedimo tvarka ir dydžio callback. Tikrinami maršrutų galai, kontaktų
  paspaudimo plotai, tarpai, valdiklių persidengimas ir laidų sankirtos.
- `tools/test_ld8_edges.sci`: įvedimo išlikimas, pavyzdžio žyma diske,
  pagalbos lango uždarymas esant aktyviam stendui, šeši netinkami juodraščiai,
  jungimas esant maitinimui, išsaugojimo klaida ir pavėluoti mygtukų įvykiai.
- 3 pilnos studento GUI eigos (variantai 1, 17, 64), 146 ataskaitų vertinimo
  palyginimai. Tikri Scilab callback; OS pelės įvykiai neimituojami.
- Ataskaitų SHA256 prieš ir po vertinimo, studento rekvizitų, varianto,
  pateikimo ID, banko, rubrikos ir originalių atsakymų išlikimas C++ rezultate.

Tai patikrina duomenų kilmės žymas ir atkuriamą vertinimą. Studentų HTML
failai nėra skaitmeniškai pasirašyti; vien jų turinys nepatvirtina autoriaus
ar savarankiško darbo. Mažame ekrane išlaikomas 1280 × 720 loginis plotas
su slinkimu; konkrečių įrenginių DPI, klaviatūros naršymas ir ekranų
skaitytuvai šiais callback bandymais nėra sertifikuojami.

## Galutinis rezultatas

Patikrinta versija: `f49ee60ec3cb529b43a5e3824e2c9d0591303e1d`.
[Linux](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36008371352),
[Windows](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36012493838)
ir [macOS ARM / Intel](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36008371413): **PASS**.
Windows testų versija: `811cda449612b331ecea3732d180a4bc41be1d10`;
jos `studentui` ir `core` medis identiškas aukščiau nurodytai programos
versijai. Pirmasis Windows bandymas nepraėjo naujo gedimo atkūrimo testo:
jo metu `LD_DATA_DIR` buvo keičiamas ir atkuriamas su Unicode keliu.
Pakartojimas su tikslia diagnostika nustatė nesėkmingą juodraščio įrašymą
atkūrus šį kintamąjį. Testas pakeistas tiesioginiu juodraščių katalogo
blokavimu ir atkūrimu, nekeičiant aplinkos kintamųjų. Nei studento UI,
nei C++ kodas dėl šios testavimo pataisos nekeisti. Nesėkmingi CI bandymai
`36008371352` (tik Windows darbas) ir `36010170293` nelaikomi PASS.

Kiekvienoje platformoje: 11 CTest rinkinių, 513 faktinių Scilab ataskaitų,
146 LD8 vertinimo palyginimai, trys pilnos LD8 GUI eigos, 19 geometrijos
scenarijų ir papildomos klaidų atkūrimo patikros. Bendras pristatymo
bandymas atidarė visus aštuonis laboratorinių darbų langus.

Platformų kataloguose pateikti JSON rezultatai ir geometrijos įrodymai.
`verified-packages.json` susieja CI versiją, originalius ZIP ir C++ failų
SHA256. `distributed-sha256.json` fiksuoja pateikiamų paketų SHA256.
107 Scilab ir paleidimo failai bei aštuoni variantų bankai sutikrinti su
patikrintos šakos turiniu. macOS ZIP palikti nepakeisti iš CI; bendras
Windows / Linux paketas sudarytas iš sutikrintų platformų paketų.

Linux katalogo PNG vaizdai užfiksuoti galutinės versijos CI bandyme.
Windows Server 2022 CI nėra konkretaus Windows 11 kompiuterio,
antivirusinės reputacijos ar archyvo pristatymo el. paštu sertifikavimas.
Patikros apima macOS 15 abiejų architektūrų CI ir Ubuntu 22.04; kitų OS
versijų suderinamumas vien šiais rezultatais netvirtinamas.

Pataisos ir paketai saugomi `codex/ld8-verified-delivery` šakoje. Pagrindinio
katalogo vykstantys LD9 pakeitimai ir paketai šios peržiūros metu nekeisti.
