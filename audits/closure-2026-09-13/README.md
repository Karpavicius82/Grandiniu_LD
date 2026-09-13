# Automatinio vertinimo patikra, 2026-09-13

Tikrinama bazė: `b5797d2459ed5d23bc9015504c9987f34057ee01`. LD1, LD2 ir LD3 naudoja bendrą C++ branduolį, vieno HTML failo pateikimą ir tą patį automatinį vertintuvą. Tai veikiančių trijų darbų patikra; ji neskelbia likusių dešimties darbų arba išorinės aprobacijos užbaigtais.

**Studento → ataskaitos → dėstytojo eiga patikrinta automatiškai.** Iš Scilab eksportuota ir per C++ sąsają įvertinta 193 ataskaitos: po 64 pilnus LD1, LD2 ir LD3 variantus bei vienas LD2 su neteisingu ir tuščiu atsakymu. Pilni darbai surinko atitinkamai 22/22, 50/50 ir 15/15; darbas su dviem klaidomis — 48/50. Tikrinti tikri ataskaitų eksportuotojai, UTF-8 vardai ir keliai, juodraščiai ir jų atkūrimas. Rezultatas: `automatic.json`.

Atskiras 650 pilnų analitinių LD1/LD2 ataskaitų mišinys įvertintas per **4,054 s** šiame Linux kompiuteryje (Release, GCC 14.2). Patikrinti pakartotinis vertinimas, neteisingi ir tušti atsakymai, 17 netinkamų / specialių importo atvejų, konfliktuojantys ID, kopijos, keli bandymai, atskiri LD3 atvejai. Tai nėra visų 13 darbų 650 failų mišinys: neįgyvendintų metodikų našumas dar neišmatuotas.

Visų trijų stendų Linux langų patikra taip pat praėjo su 1, 17 ir 64 variantais: LD1 9 etapai, LD2 12 etapų, LD3 6 etapai. Vykdytos tikrų matomų valdiklių funkcijos atskirame Scilab procese; tai nėra OS pelės įvykių ar Windows DPI patikra. Žurnalai: `modelis.log`, `langai.log`.

## Uždarytos konkrečios spragos

* LD1 skaitinė įvestis nebevykdo `evstr`; įrašytas tekstas išsaugomas nepakeistas, neperrašomas etalonu.
* Abu pirminiai stendai ir pridėtas LD3 pateikia bendrą HTML ataskaitą. Vertintojas pats pasirenka banko reikšmes ir ignoruoja studento pateiktą „pažymį“.
* Dėstytojo sąsajos CI testas laukia ir antrojo vertinimo pabaigos prieš skaitydamas žurnalą. Ankstesnė atsitiktinė nesėkmė buvo užfiksuota [GitHub vykdyme 34716377124](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34716377124): HTTP 503 reiškė „dar vertinama“.
* Uždarant dėstytojo sąsają vertinimo gija atšaukiama ir sujungiama su pagrindine gija prieš sunaikinant bendrą būseną. Ji nebepalieka nuorodos į sunaikintą `UiState`. Testas uždaro programą iškart pradėjęs naują 100 ataskaitų paketą.

Vietoje praėjo visi 5 CTest rinkiniai: vertinimas, tikro C ABI skaičiavimai / atominis įrašymas / atšaukimas, instrukcijų registras, dėstytojo komandinė programa ir HTTP sąsaja. ASan/UBSan Debug surinkimas praėjo visus 4 jam taikomus rinkinius, įskaitant uždarymą vykstant vertinimui. Šioje patikroje `detect_leaks=0`, todėl ji nepatvirtina atminties nuotėkių nebuvimo. Vietinio HTTP prievado testui reikėjo vykdymo už ribotos aplinkos; įprastoje aplinkoje jis praėjo.

Windows Server 2022 / MSVC ir Ubuntu 22.04 patikra **PRAĖJO abiejose OS**, įskaitant tikrą Scilab eksportą ir C++ vertinimą: [vykdymas 34754800285](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34754800285). Šiame vykdyme generuojami OS atitinkantys paketai su `ldcore`, `ldcheck` ir `mokytojas`. Windows 10/11 langų DPI ir tikrų naudotojų patikra lieka atskiras priėmimo veiksmas.

## Naudojimas

Scilab vykdykite `studentui/DESTYTOJUI.sce` ir pasirinkite ataskaitų aplanką. Rezultatai — `vertinimai.html` su kiekvieno kriterijaus komentarais, `suvestine.csv` ir išsamus `vertinimai.json`.

Alternatyvi savarankiška C++ dėstytojo programa: `studentui/bin/mokytojas --ui`. Jai Scilab nereikia. Vietinėje naršyklės sąsajoje įrašomas studentų failų aplanko kelias; ji sukuria `IVERTINIMAI.csv`, studentų × darbų matricą `ZURNALAS.csv` ir atskirus atsiliepimus. Naudokite programą atskirame dėstytojo rezultatų kataloge. Drive importui gali reikėti papildomos Drive prieigos; vietinių failų eiga jos nereikalauja.

Laisvo teksto išvados parodomos, tačiau už jų turinį ši skaitinė rubrika balų neskiria. Rubrikas, likusių LD metodikas, projekto licenciją ir išorinę aprobaciją dar reikia užbaigti. Skaitiniai savitestai negali jų pakeisti.

## Atkūrimas

```sh
cmake -S core -B build -DLD_DEPS=/tmp/ld-architecture-deps -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure --timeout 120
cmake --install build --prefix studentui
python tools/test_automatic_reports.py --scilab /path/to/scilab --runtime studentui
```

Priklausomybės paruošiamos `tools/fetch_core_deps.py`; jų versijos ir SHA256 fiksuoti. Visi bandymai naudoja dirbtinius studentus ir atskirus laikinus aplankus.
