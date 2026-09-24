# LD8 tęstinumo ir studento sąsajos patikra

Peržiūrėti `fc07204` ir `867799f`. Taisomas LD8; LD1–LD7 eiga nepertvarkyta.
C++ fizikos modelis, 64 pastovūs variantai ir 21 kriterijaus rubrika išlaikyti.
Python naudojamas tik vidinei patikrai ir paketų paruošimui.

## Pataisos

- Žurnalas V02 dengė T11 gnybtą 36 × 20 px. Žurnalas perkeltas į laisvą viršutinį
  plotą; gnybtai išlaiko 36 × 40 px paspaudimo zonas. C++ geometrijos tikrintuvas
  dabar vertina ir sąrašus: senasis LD8 geometrijos failas sukelia 39 klaidas.
- Išlaikytas 1280 × 720 px loginis plotas ir nekintantis pagrindinio mygtuko
  išdėstymas. Mažame ekrane naudojamas bendras slenkamas konteineris.
  Jungimo instrukcijoje pašalinta nereikalinga slinkties juosta; nominalo
  užuomina rodo nominalą, o elemento rodmuo – tikrą variantui priskirtą varžą.
- Įprastas paleidimas įjungia atsiskaitymą. Netuščias klaidingas atsakymas
  išsaugomas C++ vertinimui; tuščias laukas stabdo perėjimą. Mokymosi režimas
  tikrina atsakymus. Mokymosi / pavyzdžio žyma išlieka perjungus režimą atgal,
  todėl toks bandymas neįtraukiamas į galutinę pažymių suvestinę.
- Laidų pakeitimai, matavimai, įrašomi atsakymai ir perėjimai automatiškai
  išsaugomi. Uždarymas išsaugo ir įvedimą be Enter. Pagalboje yra juodraščio
  atkūrimas ir duomenų peržiūra; atkuriant maitinimas visada išjungiamas.
  Seno juodraščio be režimo žymos negalima netyčia paversti atsiskaitymu.
- Pakeitus nuoseklios grandinės laidus anuliuojamas ir priklausomo 2 etapo
  užbaigimas. Pradėti iš naujo galima tik patvirtinus dialogą.
- Bendras studento pristatymo testas realiai atidaro visus 8 stendus
  (ankstesnė Scilab kilpa vis dar tikrino 7).

## Patikros metodas

`tools/test_ld8.py` vykdo faktinių Scilab mygtukų callback, registracijos,
Help meniu ir failo pasirinkimo atsakymus pateikiant automatiškai. OS pelės
įvykiai neimituojami. Trys pilni variantai: 1, 17, 64. Tikrinami visų trijų
schemų MNA rodmenys, laidų pašalinimas ir sujungimas atvirkščia kryptimi,
trūkstami ir neteisingi atsakymai, įvedimas su kableliu, atkūrimas po uždarymo,
pavyzdžio izoliacija ir mokymosi žymos išlikimas.

13 geometrijos atvejų apima šešis etapus, abi laidų paspaudimo kryptis ir
langų callback sutartį, nekeisdami įprasto lango dydžio. C++ tikrina kontaktų
tarpus, valdiklių persidengimą, komponentus kertančius laidus ir nepažymėtas
laidų sankirtas. 146 ataskaitų palyginimai apima tolerancijų ribas, klaidingą
atsakymą ir mokymosi bandymo neįtraukimą į suvestinę.

Galutinės keturių platformų patikros ir paketų kontrolinės sumos bus
užfiksuotos kartu su patikrintais paketais. Windows CI nepakeičia konkretaus
Windows 11 kompiuterio DPI / vaizdo tvarkyklės bandymo. Ši patikra nėra išorinė
aprobacija ar vykdomųjų failų pasirašymas.
