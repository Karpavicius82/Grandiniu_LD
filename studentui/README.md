# Laboratorinių darbų stendai studentui

Abu darbai naudoja tą pačią sąsają: kairėje grandinė ir prietaisai, dešinėje
vieno etapo užduotis ir atsakymai. **Patikrinti** po teisingo atsakymo tampa
**Toliau**. Papildomi veiksmai yra skiltyje **Pagalba**.

## Paleidimas

Linux: `./PALEISTI.sh`. Scilab aplinkoje: vykdykite `STENDAS.sce` ir pasirinkite darbą.
Atskirai galima vykdyti `LD1/LD1.sce` arba `LD2/LD2.sce`.
Paleidiklis ieško įdiegto Scilab; prireikus nurodykite `SCILAB_BIN=/visas/kelias/bin/scilab`.

Prieš pradedant studentas įveda **eilės numerį sąraše (1–64), vardą ir pavardę,
grupę**. Tada parodomos jo variantui priskirtos reikšmės. Patvirtinus jos
naudojamos visuose to darbo etapuose. Vardas, grupė ir varianto numeris matomi
lango viršuje; visos reikšmės pasiekiamos per **Pagalba → Studentas ir priskirtos reikšmės**.

Tas pats eilės numeris visada priskiria tą patį variantą. Keičiant tik vardą ar
grupę atsakymai ir matavimai išlieka. Keičiant numerį, studentui patvirtinus,
pradedamas naujas darbas, kad skirtingų variantų matavimai nesusimaišytų.
Registracijos atšaukimas neatidaro tuščio stendo.

## Variantai

- **LD1-64-A-2026** – naujas šios sąsajos virtualių variantų rinkinys, sukurtas
  pagal vartotojo prašymą. Aštuonios R1 reikšmės × aštuonios R2 reikšmės;
  R3 parenkama pastoviu ciklu iš to paties rinkinio. E = 10 V, VR1 etapai
  lieka 1000, 500 ir 0 Ω. Lentelė: `LD1/VARIANTAI.csv`.
- **LD2-64-A-2026** – grąžintas originalus 64 variantų priskyrimas iš
  `Karpavicius82/Grandiniu_LD`, commit `77e443a471616d9f237307900200f1b5912aadbf`,
  failo `LD2/ld2_variants.sci`. Priskyrimo formulės nepakeistos.
  Lentelė: `LD2/VARIANTAI.csv`.

Tai virtualių darbų parametrai. Jie nėra fizinio laboratorinio modulio vardinės reikšmės.

## Valdymas ir išsaugojimas

- Laidui prijungti spauskite du matomus gnybtus. **Atšaukti laidą** grąžina paskutinį jungimą.
- Šaltinį įjunkite jo kortelėje, matuokite pačiame prietaise.
- LD2 zondus perjunkite per **Nuimti zondus**. Dažnis įvedamas Hz; galima keisti po 1 Hz.
- Neteisingo atsakymo nurodymas rodomas stendo apačioje; LD2 tikrinimo klaida nebeatveria blokuojančio lango.
- Pavyzdys neįskaito rezultatų; **Grįžti į savo darbą** atkuria studento įrašus.
- LD1 baigus eksportuojamas `LD1-Vnn_rezultatai.csv` su studento duomenimis ir parametrais.
- LD2 **Pagalba → Išsaugoti darbą** išlaiko studento duomenis, variantą, laidus,
  atsakymus ir matavimus `.sod` faile. CSV eksportas prideda `LD2_studentas.csv`.
  Atveriant darbą patikrinama, ar parametrai atitinka išsaugotą variantą.

## Automatinė patikra

Vartotojui spręsti užduočių nereikia:

```bash
./PATIKRINTI.sh
```

Komanda pati atlieka bandymus ir pateikia **PASS** arba **FAIL**. Testų langai
pažymėti **PATIKRA** ir uždaromi pasibaigus bandymui. Naudojamas atskiras Scilab
procesas. Įprastai atidarant studento stendą ši testų seka nevykdoma.
Vienai patikros daliai skirtas 10 minučių laiko limitas; pasibaigus laikui
pateikiama nesėkmė, o ne sėkmės pranešimas.

- `./PATIKRINTI.sh modelis`: visi 64 LD1 variantai tikrinami skaitiniu grandinės
  sprendikliu; visi 64 LD2 variantai nuosekliai atlieka 12 etapų (768 etapų).
  Tikrinamos ir netinkamos registracijos įvestys bei bazinės LD2 regresijos.
- `./PATIKRINTI.sh langai`: variantai 1, 17 ir 64 atlieka LD1 9 ir LD2 12 etapų
  per realių valdiklių funkcijas. Patikrinami įvedimo laukai, mygtukų prieinamumas,
  matavimai, neteisingi atsakymai, pavyzdžio grąžinimas, eksporto ir sesijos
  įrašymas bei atkūrimas, duomenų išlaikymas ir naujo varianto pradžia.
- Žurnalai: `tests/results/modelis.log`, `tests/results/langai.log` ir
  `GUI_PATIKRA_LAST.txt`. Juose aiškiai pažymėtas paskutinis pasiektas etapas.

Valdiklių testas vykdo jų tikras callback funkcijas; jis nesimuliuoja operacinės
sistemos pelės ir klaviatūros įvykių. Vaizdo ir langų tvarkyklės patikrą tai papildo,
jos nepakeičia. `PERZIURA.sce` ir `PERZIURA_LD2.sce` yra tik sąsajos peržiūros,
kuriose registracija praleidžiama; studento darbui naudokite įprastą paleidimą.

## Kilmė ir aplinka

Pagrindas – pilni vietiniai LD1 v1.7 ir LD2 v1.1 paketai; LD2 variantų modulis
grąžintas iš v2 šaltinio. GitHub saugykloje ši versija laikoma `studentui/`,
o pradiniai LD1 ir LD2 šaltiniai išlaikyti atskirai.
Sąsaja yra `student_style.sci`, `student_profile.sci`, `LD1/ld1_student.sci`,
`LD2/ld2_student.sci`. Skaičiavimų ir etapų tikrintuvai išlaikyti.

Tikrinama su Scilab 2026.1.0 Linux. Windows vaizdas šioje aplinkoje netikrintas.
Šiame kompiuteryje rastas Scilab yra `/tmp`; išvalius laikiną katalogą reikės
įdiegto Scilab arba naujo programos kelio.
Aktualios šios sąsajos patikros laikomos šio paketo `tests` kataloge.
Pradinių paketų auditai nevertina vėlesnių sąsajos pakeitimų.
