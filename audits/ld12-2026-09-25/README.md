# LD12 patikra ir pataisos

Pradiniai commitai: `da8207a` ir `a3f59a8`. Darbas atliekamas atskiroje šakoje
`codex/ld12-verified-delivery`, išlaikant patikrintas LD8–LD11 pataisas.
Pagrindinis kito proceso katalogas nekeičiamas.

## Pataisyta

- Persidengiantys trikampio grįžtamieji laidai ir nereikalingi maršrutų posūkiai.
  Trys šaltinio–imtuvo eilutės dabar išrikiuotos, grįžtamieji laidai atskirti.
  Kiekvienas gnybtas turi aiškią jungtį su savo objektu; pašalintas tariamas
  neprijungtas jungiklio objektas. B02 valdo bendrą trifazį jungiklį.
- RLC / rezonanso kopijuoti tekstai, neteisingi pagalbos numeriai, neįstatytas
  `%g`, srovės formulėse praleistas V/Ω → mA koeficientas 1000.
  Etapai numeruoti 1–6, pagalboje pateikta šešių laidų seka su T numeriais
  ir gnybtų pavadinimais. Registras turi 44 kodus, visos nuorodos patikrintos.
- Vienintelis matavimas būdavo nukopijuojamas į trijų fazių ataskaitos įrašus;
  linijinė srovė eksportuojant būdavo apskaičiuojama net jos nematavus.
  Dabar žurnale yra septyni atskirai užfiksuojami taškai. Eksportuojami tik
  jų rodmenys; trūkstamų įrašų programa neprideda. Seni HTML priimami.
- B15 vienu paspaudimu patikrina laidus, įjungia grandinę ir pamatuoja visus
  reikiamus taškus. B12–B14 parenka imtuvą; B16 – trikampio liniją L1.
  Kortelės skiria Uf/If nuo Ul/Il, pasirinktas imtuvas paryškinamas.
  B03 leidžia matuoti rankiniu būdu. Pakartojimai nesukuria dublikatų.
  Visos septynios žurnalo eilutės telpa be slinkimo normaliame lange.
- C++ kind 6 kvietė MNA tik žvaigždei, bet rezultato nenaudojo. Dabar abi
  topologijos išsprendžiamos MNA, o išvestys gaunamos iš mazgų įtampų ir šakų
  srovių. Atskirai tikrinamos nepriklausomos analitinės trifazės formulės.
- Numatytas tikras atsiskaitymo režimas; mokymosi / pavyzdžio naudojimas
  pažymimas. Klaidingi originalūs atsakymai išsaugomi vertinimui, tušti
  stabdo eigą. Per ankstyvas ataskaitos pateikimas per Pagalbą sustabdomas.
- Automatinis išsaugojimas, uždarymas be Enter, atkūrimas per Pagalbą,
  įrašymo klaidos atkūrimas, pasenusių callback atmetimas, pavyzdžio izoliacija.
  Juodraštis patikrinamas prieš pakeičiant darbą. Senas vienos fazės juodraštis
  išlaiko savo matavimą ir prašo atlikti trūkstamus. Pagalbos uždarymo mygtukas
  uždaro savo langą. Pradėjimui iš naujo reikia patvirtinimo.
- Linux langų tvarkyklė po ankstesnių dialogų kartais padidindavo klientinę
  sritį 10 px (aptikta LD12 ir bendrame bandyme LD6). Bendra baigiamoji
  lango funkcija po parodymo nustato galutinį pastovų kliento dydį,
  nekurdamas antro slinkimo rėmo mažame ekrane.
- Pridėta studento instrukcija ir 64 variantų CSV. Bankas ir 19 taškų maksimumas
  nepakeisti. Python reikalingas tik vidiniam testavimui.

## Patikros apimtis

15 CTest rinkinių. LD12 C++ ABI tikrinamas 64 variantams × 3 dažniams ×
10 išvesčių pagal nepriklausomas formules, taip pat netinkami įėjimai ir CSV.
82 vertinimo atvejai apima visus variantus, kiekvieną trūkstamą matavimą,
sugadintus laidus, tuščią darbą ir paklaidų ribas.
769 tikros Scilab HTML ataskaitos: visi 12 × 64 variantai ir viena klaidinga LD2.

LD12 GUI: tikri variantų 1, 17, 64 mygtukų keliai, 26 pastovaus dydžio
geometrijos scenarijai, 122 Scilab / C++ vertinimo palyginimai, originalių
atsakymų ir metaduomenų atsekamumas bei SHA256 prieš ir po vertinimo.
Tikrinami ir vienoje linijoje persidengiantys laidai. Papildomai tikrinami
8 sugadinti juodraščiai, senas juodraštis, tušti / kableliu įvesti atsakymai,
įrašymo klaida, uždarymas, pavyzdys, vėluojantys mygtukų įvykiai ir ankstyvas
ataskaitos pateikimas. Visi testų studentai išgalvoti.

Bendras bandymas atidaro visus 12 langų, tikrina 1280 × 720 loginį paviršių,
mažo ekrano slinkimą, LD2/LD3 eigas ir ataskaitos / aplanko mygtukus.
Šio leidimo CI fokusas yra LD12: visų darbų branduolio ir ataskaitų testai,
visų langų paleidimas, pilnas LD12 GUI; atskirų LD1–LD11 GUI scenarijų
pakartotinai nevykdome. Jų ankstesni auditai lieka šakoje.

Automatizuojamos tikros Scilab valdiklių callback funkcijos. Tai nėra visų
OS pelės įvykių, DPI ir ekranų patikra ar išorinė aprobacija. Windows CI
naudoja Server 2022, ne konkretų Win11 kompiuterį. Ataskaitos nėra
skaitmeniškai pasirašytos ir neįrodo studento autorystės.

Pirminėje CI Scilab eiga ir geometrija praėjo, bet papildomo persidengimų
patikrinimo Python kintamasis `a` užgožė komandų parametrus. Vidinis testas
pataisytas naudojant `wire_a` / `wire_b`; jo visa paskesnė vertinimo dalis
patikrinta su jau išsaugotomis tikromis ataskaitomis. Studento kodas nesikeitė.

Galutiniai platformų rezultatai ir paketų SHA256 bus pridėti po CI.
