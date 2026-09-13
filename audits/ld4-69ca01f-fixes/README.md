# LD4 pataisos po 69ca01f peržiūros

Pataisytas ataskaitos mygtukas, tikrų 1 ir 6 etapų sujungimų išsaugojimas,
nominalios teorinės srovės tikrinimas ir vienodos C++ / Scilab paklaidos.
Tuščias darbas gauna 0/27. Pavyzdžio eksportas draudžiamas.
Matavimo taškai surikiuojami pagal įtampą; jų atlikimo tvarka nekeičia pažymio.

Kontaktai 36 × 40 loginių px, su trumpais išvadais iki savo komponento.
Rezistoriai išdėstyti iš kairės į dešinę, voltmetras po tiriama grandine.
Laidai neina per komponentų korpusus; nesujungtų laidų sankirtos pažymėtos tarpu.
Maitinimo mygtukas atskirtas nuo kontaktų. Matavimų lentelė žymi R1 / R2 / R1+R2.
Prietaisų rodmenis atnaujina C++ MNA skaičiavimas.
Windows ir Linux sąsaja naudoja Java loginį SansSerif šriftą.

`tools/test_ld4.py` paleidžia tik LD4: registraciją, visus 7 etapus su
1/17/64 variantais, realius kontaktų pašalinimo ir prijungimo callback,
ataskaitos mygtuką, nepatvirtinto atsakymo paėmimą ir 42 geometrijos scenarijus
(1280×720, 1280×800, 1600×900; abiem laidų galų pasirinkimo tvarkomis).
Tai Scilab valdiklių callback ir koordinačių bandymas, ne OS pelės automatizavimas.

Python naudojamas tik vidiniams bandymams. Studento ir dėstytojo programoms jo nereikia.
Fizinis Windows 125–200 % ekrano mastelis ir išorinė aprobacija šiuo bandymu nepatvirtinami.

Windows vidinis bandymas naudoja `WScilex-cli.exe` be `-nw`, kaip nurodo
[Scilab paleidimo argumentų dokumentacija](https://help.scilab.org/docs/2026.1.0/en_US/startup_options.html).
Tai leidžia naudoti grafinius valdiklius ir išsaugoti terminalo žurnalą.

## Rezultatas

Windows ir Linux: po **42 LD4 geometrijos scenarijus, 0 pažeidimų**;
1/17/64 variantai atlikti per tikrus valdiklių callback ir ataskaitos mygtuką.
Abiejose OS praėjo C++ ir 257 tikrų Scilab ataskaitų eksportavimo / vertinimo patikros.
[Linux CI](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34770173295/job/103758209191),
[Windows CI](https://github.com/Karpavicius82/Grandiniu_LD/actions/runs/34770911844).
Pirmojo CI vykdymo Windows testo paleidiklis turėjo netinkamą argumentą;
jis pataisytas ir pakartotas tik Windows bandymas. Studento runtime abiejuose vykdymuose tas pats.

[Koordinatės](coordinates-1280x800.csv), [nuoseklus jungimas](linux/E6.png),
[rodmenys](linux/rodmenys.png), [paketų kontrolinės sumos](packages.json).
