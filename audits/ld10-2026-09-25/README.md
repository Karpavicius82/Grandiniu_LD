# LD10 patikra ir pataisos

Pradinė versija: `420926c` (lygiagretė RLC grandinė, srovių rezonansas).
Atskira šaka `codex/ld10-verified-delivery` apima patikrintas LD8 / LD9 pataisas.
Pagrindiniame kataloge vykstantis LD11 darbas nekeičiamas.

## Rastos ir pataisytos problemos

- Tikras paleidimas nenustatė atsiskaitymo režimo; ankstesnis testas jį įjungdavo
  tik prieš eksportą. Dabar tikrinamas tikras numatytas režimas. Klaidingi,
  bet užpildyti atsakymai išlieka dėstytojo vertinimui; tušti laukai stabdo eigą.
- Nebuvo uždarymo išsaugojimo ir dauguma veiksmų neišsaugodavo juodraščio.
  Išsaugomi net nepatvirtinti įvedimai; įrašymo klaida palieka langą atvirą.
  Pagalba leidžia tęsti darbą ir pasirinkti režimą; pradėjimas iš naujo patvirtinamas.
- Importuojama būsena nebuvo tikrinama prieš perrašant dabartinį darbą.
  Dabar tikrinami matmenys, gnybtai, dubliavimai, etapų ir režimo žymos.
- Pasenę mygtukų įvykiai po uždarymo galėjo keisti būseną; dabar ignoruojami.
  Pavyzdžio rodmenys nepakeičia savo darbo; naudojimo žyma išsaugoma.
- Vienu B17 paspaudimu nustatomas etapo dažnis, įjungiama grandinė ir įrašomi
  keturi C++ matavimai. Rankinis matavimas išlieka. Dubliavimai neįrašomi.
- Žurnalas sutrumpintas iki šešių matomų eilučių: visi trys dažniai, U, IR,
  IL, IC, I ir pažanga. Formulėms pateikti SI vienetai; pataisyti klaidingi
  nuoseklios grandinės / voltmetro tekstai, ritės terminas ir HTML rodinys.
- Bendrojoje linijoje nupieštas ampermetras anksčiau rodė pasirinktą šakos
  srovę. Dabar jis visada rodo bendrą I; kairysis virtualaus matavimo rodmuo
  ir paryškinta šaka nurodo pasirinktą vietą. Taip nesumaišomi I ir IR/IL/IC.
- Pridėtas trūkęs 64 variantų CSV su vienetais ir trumpa studento instrukcija.
- Bendras langų testas iš tiesų atidaro visus 10 stendų, o ne tik pirmus 9.

## Patikros apimtis

13 CTest rinkinių. LD10 papildomai tikrinamas per tikrą C++ ABI: 64 variantai
× 3 dažniai × 10 išvesčių, nepriklausoma kompleksinės grandinės formule,
taip pat netinkami parametrai. 72 C++ vertinimo atvejai ir CSV atitikimas.
641 tikra Scilab HTML ataskaita (10 × 64 + viena klaidinga LD2).

LD10 GUI: variantai 1, 17, 64, visi šeši etapai ir tikras ataskaitos mygtukas;
31 geometrijos scenarijus (kanoniniai, atvirkšti, sumaišyti laidai bei visi
12 matavimo režimų); 146 Scilab / C++ vertinimo palyginimai. Uždarymas ir
atkūrimas per Pagalbą, šeši sugadinti juodraščiai, įrašymo klaidos atkūrimas,
pavyzdžio izoliacija, pasenę įvykiai, dubliuoti matavimai. Tikrinami originalūs
atsakymai, studento ir varianto duomenys, ataskaitos ID bei SHA256 prieš ir po
vertinimo. Visi testų studentai išgalvoti.

Langas išlaiko 1280 × 720 loginį paviršių; mažesniame ekrane naudojamas
slinkimas. Tikrinamos tikros Scilab valdiklių callback funkcijos. Tai nėra
operacinės sistemos pelės paspaudimų ar visų DPI / ekranų bandymas.
Windows CI naudoja Server 2022, ne konkretų vartotojo Windows 11 įrenginį.
Ataskaitos nėra skaitmeniškai pasirašytos ir neįrodo studento autorystės.

## Galutinis platformų rezultatas

Patikrinta programos versija: `910dd0946639c5f304c769075fe86560d5fbefc0`.
[Windows ir Linux](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36128739009)
ir [macOS ARM / Intel](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36128739176): **PASS**.
Visose keturiose aplinkose praėjo 13 CTest rinkinių, 641 tikrų ataskaitų,
LD10 trijų studento eigų, 146 vertinimo palyginimų, 31 geometrijos scenarijaus
ir papildomų klaidų atkūrimo patikros. Bendras bandymas atidarė visus dešimt
stendų. Naudoti Windows Server 2022, Ubuntu 22.04, macOS 15 ARM ir Intel.

`verified-packages.json` sieja CI archyvų ir C++ failų SHA256 su patikrinta
versija. `127` Scilab bei paleidimo failų ir visų
dešimties variantų bankų turinys sutikrintas su šaltiniu. Pateikiamų paketų
SHA256 yra `distributed-sha256.json`; macOS ZIP pateikti nepakeisti iš CI.
Linux PNG užfiksuoti galutinės versijos bandyme. Windows / Linux jungtinis
ZIP papildomai patikrintas dėl failų SHA256 ir vykdymo teisių.
