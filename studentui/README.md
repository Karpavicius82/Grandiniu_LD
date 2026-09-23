# Laboratorinių darbų stendai studentui

LD1–LD7 naudoja tą patį išdėstymą: kairėje grandinė ir prietaisai, dešinėje
vieno etapo užduotis ir atsakymai. LD1 ir LD2 atsiskaitymo režime **Įrašyti ir toliau**
išsaugo jūsų atsakymus. Mokymosi režime **Patikrinti** parodo klaidas.
Papildomi veiksmai ir režimo pasirinkimas yra skiltyje **Pagalba**.

**LD1:** stendas automatiškai sujungia grandinę, parenka varžą ir įrašo matavimą.
Studentas pasirenka grandinės tipą, įrašo savo skaičiavimus ir palygina rodmenis.
**Įrašyti ir toliau** išsaugo atsakymą ir perkelia į kitą etapą; **Atgal** leidžia
jį pataisyti. Tuščias atsakymas nepraleidžiamas, neteisingas skaičius nepakeičiamas
teisingu. Visuose darbuose darbo sritis yra 1280 × 720 px, mygtukų vietos
etapuose nekinta. Mažesniame ekrane naudojamos slinkties juostos, kontaktai nemažinami.
Rankinį jungimą galima pasirinkti per **Pagalba → Daugiau → Automatinis / rankinis
stendo valdymas**. Ataskaitoje nurodoma, kad naudotas automatinis paruošimas.
Automatinio LD1 vertinime skiriama iki **15 balų už studento atsakymus** (LD1-2);
automatinis jungimas ir matavimai papildomų balų nesuteikia. Senos LD1-1 ataskaitos
išlieka suderinamos su ankstesne 22 balų rubrika.

LD3 užduotis tikrinama mygtuku **TIKRINTI**. Įtampą parinkite U1 / U2 / U3,
maitinimą ir jungiklį valdykite stendo dešinėje. Papildomi veiksmai – viršutiniame
**Pagalba** meniu; apačioje galima grįžti į ankstesnį etapą arba atverti kontaktų žemėlapį.
Laido tarpas sankirtoje reiškia, kad laidai elektriškai nesujungti.

**LD5 – įtampos daliklis:** sujunkite septynis laidus pagal **Pagalba → Kaip sujungti**.
Gnybtus galima keisti tik pirmame etape; esamą laidą pašalinsite paspaudę abu jo galus.
Toliau įjunkite maitinimą, uždarykite jungiklį ir rinkitės **P1 / P2 / P3**.
Parinkta padėtis išryškinama; RV laukelyje rodoma tos padėties aktyvi varža.
Voltmetras ir ampermetras atsinaujina iškart, **Matuoti** įrašo rodmenis į žurnalą.
Kiekvieną padėtį užtenka išmatuoti vieną kartą. Atsakymuose tinka kablelis arba taškas;
prieš **Tikrinti** nereikia spausti Enter. Po šešto etapo spauskite **Įrašyti ataskaitą**.
Pavyzdžio peržiūra nekeičia jūsų matavimų ir jos negalima pateikti kaip ataskaitos.
LD5 skaičiavimams ir ataskaitų vertinimui naudojamas bendras C++ branduolys.
LD5 turi 64 pastovius variantus: `LD5/VARIANTAI.csv`.

**LD7 – įtampos, srovės ir galios suderinamumas:** šeši etapai, trys sujungimai:
darbinė grandinė E → jungiklis → ampermetras → reostatas R (penkios padėtys P1–P5),
tuščioji eiga (voltmetras prie šaltinio) ir trumpasis jungimas (ampermetras vietoj krovinio).
Keisdami padėtį matuokite [B03]; žurnale kaupiami U, I ir P = U·I. Skaičiuojama vidinė
varža r = ΔU/ΔI, galia kiekvienoje padėtyje, Pmax = E²/(4r) ir naudingumo koeficientas.
64 variantai: `LD7/VARIANTAI.csv`, bankas `LD7-64-A-2026`, ataskaitos revizija 1.

**LD6 – nuoseklus ir lygiagretus šaltinių jungimas:** šeši etapai, keturios
studento jungiamos schemos: E1, nuosekliai, priešpriešiais ir lygiagrečiai.
Režimo mygtukas išsaugo jūsų tos schemos laidus. Jungdami išjunkite maitinimą;
matavimui įjunkite maitinimą, uždarykite jungiklį ir spauskite **Matuoti**.
Kiekvieno šaltinio vidinė varža – 10 Ω. Neigiama šaltinio srovė reiškia, kad
srovė teka į šaltinį. Srovę įrašykite mA, įtampą V; tinka kablelis arba taškas.
**Tikrinti** patikrina ir perkelia į kitą etapą, pabaigoje – **Įrašyti ataskaitą**.
C++ branduolys sprendžia grandinę ir vertina ataskaitą: 25 taškai už atsakymus,
matavimus ir keturių schemų jungimus. 64 variantai: `LD6/VARIANTAI.csv`,
bankas `LD6-64-B-2026`, ataskaitos revizija 2. Ankstesnės revizijos ataskaitos
vertinamos pagal ankstesnę rubriką.

Pabaigoje spauskite **Išsaugoti ataskaitą**. Langas pasiūlo **Atverti ataskaitą** arba **Atverti ataskaitų aplanką**.
Sukurtą vieną HTML failą iš
naudotojo aplanko `Grandiniu_LD_darbai` persiųskite dėstytojui. Nebaigtą
ataskaitą taip pat galima išsaugoti per Pagalbą. LD1 ir LD2 juodraščiai saugomi automatiškai
įrašant atsakymus ir pereinant į kitą etapą; juos atverkite per Pagalbą.

Dėstytojui: vykdykite `DESTYTOJUI.sce` ir pasirinkite aplanką su ataskaitomis.
Programa sukuria `vertinimai.html`, `suvestine.csv` ir `vertinimai.json`.
Mokymosi ar pavyzdžio pagalbą naudoję bandymai gauna komentarus, bet neįtraukiami
į atsiskaitymų suvestinę. Skirtingų rubrikų bandymai lyginami pagal pažymį iš 10.

## Paleidimas

Reikia Scilab 2026.1.0 ir jūsų OS atitinkančio paketo su `bin/ldcore.dll`
(Windows), `bin/ldcore.so` (Linux) arba `bin/ldcore.dylib` (macOS). Kompiliatorius studentui nereikalingas.

macOS: pasirinkite paketą pagal Scilab architektūrą (`arm64` arba `x86_64`),
paleiskite `PALEISTI.command` arba Scilab lange vykdykite `STENDAS.sce`.
Paketai nėra pasirašyti Apple Developer sertifikatu ar notarizuoti.

Linux: `./PALEISTI.sh`. Scilab aplinkoje: vykdykite `STENDAS.sce` ir pasirinkite darbą.
Windows: dukart paspauskite `PALEISTI.bat` arba vykdykite `STENDAS.sce` grafiniame
Scilab lange. `bin/ldcheck.exe` skirtas dėstytojo ataskaitų tikrinimui.
Atskirai galima vykdyti atitinkamą `LD1/LD1.sce`–`LD7/LD7.sce` failą.
Paleidiklis ieško įdiegto Scilab; prireikus nurodykite `SCILAB_BIN=/visas/kelias/bin/scilab`.

Paketą platinkite atsisiuntimo nuoroda. Gmail gali blokuoti archyvą dėl jame esančių
DLL, EXE ar BAT failų ([Google taisyklės](https://support.google.com/mail/answer/6590?hl=en)).
Vien toks pranešimas nepatvirtina nei užkrėtimo, nei Scilab lūžio priežasties.
Neišjunkite apsaugos ir nepervadinkite failų blokavimui apeiti.

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
- LD1 baigus **Išsaugoti ataskaitą** sukuria HTML failą su studento duomenimis,
  atsakymais ir matavimais automatiniam dėstytojo vertinimui.
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
