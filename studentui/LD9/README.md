# LD9 – nuosekli RLC grandinė

Paleiskite bendrą `STENDAS.sce` ir pasirinkite LD9 arba atverkite `LD9.sce`.
Įrašykite eilės numerį, vardą, pavardę ir grupę. Programa paskirs vieną iš
64 pastovių variantų. Python studentui nereikalingas.

1. Sujunkite šešis laidus, spausdami jų galų gnybtus. Seką rodo
   **Pagalba → Kaip sujungti**. Įrašykite apskaičiuotą rezonanso dažnį.
2. Kiekviename iš trijų matavimo etapų spauskite **Įjungti ir matuoti visus 4**.
   Programa nustatys etapo dažnį, įjungs grandinę ir užpildys žurnalą.
   Norint matuoti atskirai, pasirinkite UR, UL, UC arba U ir spauskite **Matuoti**.
   Voltmetro antraštė ir paryškintas elementas rodo pasirinktą matavimo vietą.
3. Rezonanso etape įrašykite kokybę Q ir įtampų skirtumą. Skaičiavimo etape
   naudokite žurnalo **0,5·f0** tašką. Srovė nurodyta **mA**, įtampa – **V**;
   todėl varža **Z = 1000·U/I**. Reaktyvioji galia gali būti neigiama.
4. Užbaikite išvadas ir spauskite **Įrašyti ataskaitą**. Gautą HTML failą
   persiųskite dėstytojui. Dėstytojo C++ programa jį vertina automatiškai.

Darbas automatiškai išsaugomas po įvedimų, sujungimų, matavimų ir pereinant
etapą. Langą uždarant išsaugomas ir įvedimas be Enter. Darbą atkurkite per
**Pagalba → Tęsti išsaugotą darbą**. Juodraštis `.sod` skirtas darbo tęsimui;
dėstytojui siunčiama `.html` ataskaita.

Numatytas atsiskaitymo režimas: programa tikrina, ar atlikti būtini veiksmai
ir užpildyti laukai, o atsakymų teisingumą vertina dėstytojo programa.
Mokymosi režimas ir pavyzdys pasiekiami per Pagalbą; jų naudojimas pažymimas
ataskaitoje. Pavyzdžio matavimai nepakeičia savo darbo.

`VARIANTAI.csv` stulpelių pavadinimai nurodo vienetus. L_H ir C_F reikšmės
pateiktos SI vienetais; L_mH ir C_nF – stende rodomais vienetais.
