# LD11 patikra ir pataisos

Pradinė LD11 versija: `987d387` (įskaitant ankstesnę L_mH validavimo pataisą).
Atskira šaka `codex/ld11-verified-delivery` apima patikrintas LD8–LD10 pataisas.
Pagrindinis kito proceso darbo katalogas nekeičiamas.

## Rastos ir pataisytos problemos

- C++ RL∥C modelio Q ir fazės kampo ženklai buvo priešingi pasyvios apkrovos
  konvencijai. Dabar induktyvus Q teigiamas, talpinis neigiamas.
- Ck grįžtamasis laidas persidengdavo su ritės grįžtamuoju laidu. Naujas
  sujungimas C_B–RL_B aiškiai atskiria šakas. Ankstesnis elektriškai lygiavertis
  C_B–GEN_N sujungimas tebepriimamas; jo vaizdavimas atskirtas nuo kitų laidų.
- Etapų režimų seka pataisyta; pereinant prie Ck išlieka keturi pradiniai laidai,
  studentui reikia pridėti tik du. Grįžtant tarp etapų išlieka abu sujungimai.
- Mygtukas „Įjungti ir matuoti“ patikrina sujungimą, nustato etapo režimą,
  įjungia grandinę ir įrašo U, I, P. Rankiniai veiksmai išlieka; dubliuotų
  matavimų nepridedama. Pakeitus pradinius matavimus atšaukiami priklausomi atsakymai.
- Beveik nulinis Q2 iš suapvalintų S2 ir P2 buvo nestabilus. Žurnale I ir P
  pateikiami šešiais skaitmenimis po kablelio; Q2 instrukcija naudoja |Q−QC|.
  Tik Q2 tolerancija suderinta iki 0,001 mvar + 2 % abiejuose tikrintuvuose.
  64 variantų bankas ir 20 taškų maksimumas išlieka.
- Tikras paleidimas dabar įjungia atsiskaitymo režimą: išsaugomi originalūs,
  net klaidingi studento atsakymai dėstytojui; tušti atsakymai stabdo eigą.
  Mokymosi ir pavyzdžio naudojimas atsekamas; pavyzdys neperrašo savo darbo.
- Automatiškai išsaugomi įvedimai, sujungimai, matavimai, etapai ir uždarymas,
  net nepaspaudus Enter. Įrašymo klaida palieka langą atvirą. Pagalba leidžia
  tęsti juodraštį, matyti jungimo instrukciją, režimą ir paskirtus parametrus.
- Juodraščio struktūra tikrinama prieš perrašant dabartinį darbą. Pasenę
  mygtukų įvykiai po uždarymo ignoruojami; pradėjimui iš naujo reikia patvirtinimo.
- Pataisyti ritės, vienetų ir režimų tekstai, netinkamos rezonanso užuominos,
  HTML etiketės. Pridėtas 64 variantų CSV ir trumpa studento instrukcija.
- Bendras pristatymo bandymas atidaro visus 11 vienodo dydžio stendų.

## Patikros apimtis

14 CTest rinkinių. LD11 C++ ABI lyginamas su nepriklausoma kompleksinės
admitanso formule: 64 variantai × 3 C reikšmės × 10 išvesčių; netinkami
parametrai. 139 LD11 vertinimo atvejai, įskaitant visus 64 variantus su
būtent studentui rodomais suapvalintais skaičiais, seną ir naują laidų jungimą.
705 tikros Scilab HTML ataskaitos (11 × 64 + viena klaidinga LD2), tikrinamos
C++ dėstytojo programa ir per CFFI aplanko vertinimą.

GUI: variantai 1, 17, 64, visi šeši etapai, tikras ataskaitos mygtukas;
23 geometrijos scenarijai, 146 Scilab / C++ vertinimo palyginimai.
Tikrinamas atkūrimas per Pagalbą, šeši sugadinti juodraščiai, įrašymo klaidos
atkūrimas, pavyzdžio izoliacija, pasenę įvykiai, dubliuoti matavimai ir laidų
išlaikymas. Ataskaitose tikrinami originalūs atsakymai, studento ir varianto
metaduomenys, ID, SHA256 prieš ir po vertinimo. Testų studentai išgalvoti.

Langas išlaiko 1280 × 720 loginį paviršių; mažesniam ekranui naudojamas
slinkimas. Tikrinamos tikros Scilab valdiklių callback funkcijos. Tai nėra
OS pelės paspaudimų ar visų DPI ir ekranų bandymas. Windows CI naudoja
Server 2022, ne konkretų Windows 11 įrenginį. Ataskaitos nėra skaitmeniškai
pasirašytos ir neįrodo studento autorystės; bandymai neatstoja išorinės aprobacijos.

Windows pirmoje CI patikroje Scilab eiga praėjo, bet Python testo žurnalo
spausdinimas sustojo dėl cp1252 nepalaikomo φ simbolio. Vidinio testavimo
įrankio stdout nustatytas UTF-8. Studentui skirtas kodas nepasikeitė.
Pakartotinei Windows patikrai naudojamas LD11 filtras: branduolys, visos
705 ataskaitos, visas LD11 GUI ir bendras 11 stendų paketo bandymas;
praėjusių ankstesnių LD GUI testų pakartotinai nevykdome.

## Galutinis platformų rezultatas

Galutinė versija: `68a34ae418f6f56ab4651af3635540edbb8c23af`.
Studento programos ir C++ branduolio failai sutampa su `afa6a527ac766457dfc4a1d5f8906bef6656cfdd`.
Tai patvirtinta Git diff ir visų paketų failų turinio patikra; tarp commitų
keistas tik vidinis testavimas, CI filtras ir audito aprašas.
[Linux](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36135193103/job/108071480498),
[Windows](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36136848507)
ir [macOS ARM / Intel](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36135193136): **PASS**.
Visose keturiose aplinkose praėjo 14 CTest rinkinių, 705 tikrų ataskaitų,
LD11 trijų studento eigų, 146 vertinimo palyginimų, 23 geometrijos scenarijų
ir papildomų klaidų atkūrimo patikros. Bendras bandymas atidarė visus vienuolika
stendų. Naudoti Windows Server 2022, Ubuntu 22.04, macOS 15 ARM ir Intel.

`verified-packages.json` sieja CI archyvų ir C++ failų SHA256 su patikrinta
versija. `137` Scilab bei paleidimo failų ir visų
vienuolikos variantų bankų turinys sutikrintas su šaltiniu. Pateikiamų paketų
SHA256 yra `distributed-sha256.json`; macOS ZIP pateikti nepakeisti iš CI.
Linux PNG užfiksuoti galutinės versijos bandyme. Windows / Linux jungtinis
ZIP papildomai patikrintas dėl failų SHA256 ir vykdymo teisių.
