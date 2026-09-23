# Studento eiga ir ataskaitų perdavimas

Pakeitimų kodas: `34eb59c`. C++ branduolys 0.3.0; Python naudojamas tik vidinei patikrai ir paketavimui.

LD1–LD7 darbo sritis vienoda: 1280 × 720 loginiai px. Langas nekeičiamas tarp etapų. Mažesniame ekrane išlieka visas tokio pat dydžio turinys slenkamame rėme; kontaktai nemažinami. Tikro lango dydis priklauso nuo ekrano laisvos vietos ir OS lango rėmo, todėl negalima jo sutapatinti su fizinių ekrano taškų skaičiumi esant DPI masteliui.

LD1 Pagalba sutrumpinta iki penkių punktų. Kasdieniai veiksmai atskirti nuo papildomų nustatymų. Ataskaitą išsaugojus pateikiami trys mygtukai: atverti HTML, atverti aplanką, grįžti į darbą. HTML kuria C++: užduočių pavadinimai, pasirinkimų tekstai, vienetai ir aiškūs skyriai. Studentų įrašai išlieka nepakeisti; etalonai į studento HTML nerodomi.

Automatinis LD1 naudoja rubriką LD1-2: 15 balų už studento atsakymus. Penki automatiniai matavimai ir du jungimai tikrinami diagnostikai, tačiau gauna 0 balų svorį. Senos LD1-1 ataskaitos tebėra vertinamos iš 22. Dėstytojo abu vertintuvai geriausią bandymą parenka pagal pažymį iš 10. Mokymosi ir pavyzdžio pagalbos bandymai gauna komentarus, bet nepatenka į atsiskaitymų suvestinę.

Vietinės Linux patikros: 10 C++ testų rinkinių, 449 Scilab eksportuotos ataskaitos; LD1 trys variantai ir devyni etapai, keturi eksportai, trys klaidingi atsakymai, juodraščio atkūrimas bei rankinis režimas. Devyniose LD1 geometrijos situacijose: 90 valdiklių, 30 kontaktų, 134 laidų atkarpos, mažiausias kontaktų tarpas 8,7872 px, klaidų 0. Atskirai atverti visi septyni stendai, patikrintos 1024 × 768 ir 900 × 600 ekranų slinkties konstrukcijos, pilna LD2/LD3 eiga, tikri ataskaitų mygtukai ir jų C++ įvertinimai. Atvėrimo mygtukų callback patikroje OS atvėrimas pakeičiamas kelio fiksavimu; tai ne visų OS failų asociacijų patikra.

Windows 11 konkretaus kompiuterio lūžis ir visi DPI/vaizdo tvarkyklių deriniai šiuo bandymu nepatvirtinami. macOS paketai nėra Apple notarizuoti; apsaugos išjungimas nėra paleidimo instrukcijos dalis. Išorinio vertintojo dalykinė aprobacija lieka atskira sąlyga.

Galutinė CI patikra **PASS** to paties `34eb59c` kodo: [Windows Server 2022 ir Ubuntu 22.04](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/35854144025), [macOS 15 Intel ir Apple Silicon](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/35854144069). Kiekvienoje aplinkoje praėjo 10 C++ testų rinkinių, 449 tikrų Scilab ataskaitų generavimas ir vertinimas, LD1/LD4–LD7 sąsajos regresijos bei visų septynių langų, LD2/LD3 eigų ir ataskaitų mygtukų patikra. Rezultatų JSON pateikti `ci/`; paketų ir vykdomųjų failų SHA256 – `acceptance.json`. ZIP vykdymo šaltiniai palyginti su darbo katalogu (Windows CRLF normalizuotas tik palyginimui), abiejų Mac bibliotekų procesoriaus architektūra patikrinta.
