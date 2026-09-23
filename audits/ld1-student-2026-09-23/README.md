# LD1 studento sąsajos pataisos

Pradinis kodas: `358e4ee`. Naujausias LD7 pakeitimas LD1 nelietė.
Atkurta ankstesnė LD1 klaida: atsiskaitymo režimas leido be jungimų pereiti
į trečią etapą, kuriame gnybtai jau buvo užrakinti. Matavimas nutrūkdavo,
nes vietoje keturių laidų buvo nulis.

Įprastas LD1 paleidimas dabar automatiškai paruošia grandinę ir matavimus.
Studentas įrašo savo atsakymus per UI. Tušti atsakymai stabdo perėjimą,
neteisingi skaičiai išsaugomi vertinimui. Rankinis režimas išlaikytas.
Ataskaitos pastaba ir `evidence.automatic_setup` parodo automatinį paruošimą;
esama 22 taškų rubrika nekeista. Jungimo įrodymas šiame režime neįrodo
savarankiško studento gebėjimo jungti grandinę.

Visi devyni etapai naudoja tą patį **1280 × 720 px** kliento plotą,
langas nekeičiamo dydžio, pagrindinio ir grįžimo mygtukų koordinatės nekinta.
Ankstesnė patikra tik pagal `position` nepastebėjo tikrų Java valdiklių
apkirpimo: pridėtas jų ribų atnaujinimas ir tikro lango vaizdinė patikra.
Rezultatų suvestinė pateikiama keturiomis aiškiai išdėstytomis eilutėmis,
nes Scilab lentelė nepaisė šrifto dydžio ir kirpo eilučių pavadinimus.
Vėluojantys uždaryto lango callback įvykiai nebekreipiasi į pašalintus valdiklius.

`tools/test_ld1_student.py` tikrina įprastą registracijos kelią (dialogo atsakymai
automatizuoti), variantus 1, 17, 64, devynis etapus, tikrus mygtukų callback,
matavimus, juodraščio atkūrimą, klaidingo atsakymo išsaugojimą, rankinį režimą,
keturias faktines HTML ataskaitas ir tris klaidingų atsakymų ataskaitas.
C++ vertintuvas turi skirti atitinkamai 22/22 ir 21/22.
Patikra taip pat lygina lango dydį, mygtukų koordinates ir devynis geometrijos
atvejus. OS pelės įvykiai neimituojami. Python naudojamas tik vidinei patikrai.

Windows paleidiklis atveria grafinį Scilab; `STENDAS.sce` paleidimas išlieka.
C++ branduolys ir vertintuvas neperrašyti. Vartotojo Windows 11 lūžis vietoje
neatkurtas; Windows Server 2022 CI nepakeičia konkretaus Windows 11 kompiuterio
ir jo DPI bei vaizdo tvarkyklės patikros.

Gmail [blokuoja tam tikrus vykdomus failus ir archyvų viduje](https://support.google.com/mail/answer/6590?hl=en).
Pranešimas apie visą archyvą savaime neįrodo viruso ar C++ vykdymo klaidos.
Konfidencialūs failai išorinėms skenavimo paslaugoms nesiųsti. Paketą reikia
platinti atsisiuntimo nuoroda, studento HTML ataskaitą galima perduoti atskirai.

Kiti LD ir jų numeracija šiame pakeitime nepertvarkyti. Galimas laboratorinių
skaičiaus mažinimas turi išlaikyti reikalingus bandymus ir vertinimo kriterijus.
