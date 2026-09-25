# LD9 studento eigos, ergonomikos ir vertinimo auditas

Pradinė LD9 versija `4104f4d`. Darbas atliktas atskiroje
`codex/ld9-verified-delivery` šakoje, į ją įtraukus ir ankstesnes LD8
pataisas (`fc1b319`). Pagrindinis katalogas ir jame esanti studento LD4
ataskaita nekeisti.

## Rastos spragos ir pataisos

- Įprastas LD9 paleidimas nenustatė atsiskaitymo ir automatinio išsaugojimo.
  Ankstesnis GUI testas prieš eksportą pats įjungdavo atsiskaitymo žymą.
  Dabar tikrinama numatytoji tikro studento eiga; neteisingi, bet netušti
  atsakymai atsiskaityme išlieka ir perduodami dėstytojo vertintojui.
- Įjungtas automatinis išsaugojimas ir darbo atkūrimas per tikrą Pagalbos
  mygtuką. Uždarant langą išsaugomas įvedimas be Enter; nepavykus įrašyti
  darbas lieka atviras, ankstesnis juodraštis neprarandamas.
- „Atkurti stendą“ nebepraranda nepatvirtinto įvedimo. Pavyzdžio naudojimo
  žyma išsaugoma prieš jį įjungiant, savas darbas atkuriamas išėjus.
- Pagalbos langas užveria konkrečiai save. Vėluojantys uždaryto stendo
  veiksmai nebekeičia būsenos, nekuria papildomų ataskaitų ar langų.
- Prieš atkuriant juodraštį tikrinami laukai, atsakymai, etapų požymiai,
  dažnio ir taikinio indeksai, gnybtai, pasikartojantys laidai ir matavimai.
  Atmetamas juodraštis nepakeičia atviro darbo. Leidžiami ir studento dar
  neteisingai sujungti laidai, jei jų duomenų struktūra tinkama.
- Pridėtas B17: vienu paspaudimu nustatomas etapo dažnis ir atliekami keturi
  tikri C++ modelio matavimai. Netinkama grandinė nematuojama, pakartojimas
  nedubliuoja žurnalo. Rankiniai matavimo valdikliai išsaugoti.
- Voltmetras įvardija taikinį, atitinkamas elementas pažymėtas schemoje.
  Maitinimo ir jungiklio mygtukai rodo kitą veiksmą; pavyzdyje neaktyvūs
  veiksmai išjungti. Pirmame etape „Atgal“ neaktyvus.
- Žurnalas sutrauktas į šešias eilutes, po dvi kiekvienam dažniui. Visos
  reikšmės matomos vienu metu. Generatorius neberodo pažodinio `<br>`.
- Patikslinti SI perskaičiavimai, Z formulė su mA, galios vienetai ir Q
  reikšmių skirtumas. Skaičiavimo etape parenkamas užduoties 0,5·f0 dažnis.
- Pridėtas trūkęs 64 variantų CSV; jo reikšmės tikrinamos kartu su C++
  vertinimo testu. Bendras pateikimo bandymas dabar iš tiesų atidaro LD9.

## Patikros ir ribos

Vietoje praėjo 12 CTest rinkinių, 577 tikrų Scilab ataskaitų eksportas ir
C++ vertinimas, trys pilnos LD9 studento eigos (1, 17, 64 variantai),
146 ribinių vertinimo palyginimai bei klaidų atkūrimo patikros.

31 geometrijos scenarijus: šeši etapai su skirtinga laidų įvedimo kryptimi
ir tvarka, 12 dažnio / voltmetro padėčių, dydžio callback. Tikrinami kontaktų
plotai, valdiklių persidengimai ir laidų sankirtos; naudojamas pastovus
1280×720 loginis plotas su slinkimu mažame ekrane. Senas testas dirbtinai
keitė fiksuoto lango dydį; naujas tikrina studentui pateikiamą išdėstymą.
Tikro Linux lango vaizdai papildomai peržiūrėti.

Ataskaitų SHA256 lyginamas prieš ir po vertinimo. Tikrinamas studento,
varianto, banko, pateikimo ID, režimo ir originalių atsakymų išlikimas.
HTML nėra skaitmeniškai pasirašytas ir pats neįrodo autorystės. Testai
vykdo tikrus Scilab mygtukų callback; OS pelės įvykiai neimituojami.
Konkrečių Windows 11 įrenginių, antivirusinės reputacijos, DPI režimų ar
pagalbinių prieinamumo priemonių sertifikavimas į šią patikrą neįtrauktas.

## Galutinis platformų rezultatas

Patikrinta programos versija: `a5c2097f846a6d4e049ac5e1ceb791dccb644a6a`.
[Windows ir Linux](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36020040014)
ir [macOS ARM / Intel](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/36020040143): **PASS**.
Visose keturiose aplinkose praėjo 12 CTest rinkinių, 577 tikrų ataskaitų,
LD9 trijų studento eigų, 146 vertinimo palyginimų, 31 geometrijos scenarijaus
ir papildomų klaidų atkūrimo patikros. Bendras bandymas atidarė visus devynis
stendus. Naudoti Windows Server 2022, Ubuntu 22.04, macOS 15 ARM ir Intel.

`verified-packages.json` sieja CI archyvų ir C++ failų SHA256 su patikrinta
versija. `117` Scilab bei paleidimo failų ir visų
devynių variantų bankų turinys sutikrintas su šaltiniu. Pateikiamų paketų
SHA256 yra `distributed-sha256.json`; macOS ZIP pateikti nepakeisti iš CI.
Linux PNG užfiksuoti galutinės versijos bandyme. Windows / Linux jungtinis
ZIP papildomai patikrintas dėl failų SHA256 ir vykdymo teisių.
