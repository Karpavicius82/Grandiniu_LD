# LD11 – galios ir kompensacijos tyrimas

Paleiskite `STENDAS.sce` → LD11, įveskite eilės numerį, vardą, pavardę ir grupę.
Programa paskirs vieną iš 64 pastovių variantų. Studentui Python nereikalingas.

1. Sujunkite keturis laidus pagal **Pagalba → Kaip sujungti**. Apskaičiuokite
   pradinį cos φ; formulėje induktyvumą naudokite henrais (H).
2. Spauskite **Įjungti ir matuoti**: programa įrašys U, I ir vatmetro P.
   Žurnalo vienetai: V, mA, mW. Todėl U·I gaunama mVA.
3. Apskaičiuokite kompensuojantį Ck; atsakymas – µF (F × 10⁶).
4. Keturi pradiniai laidai išliks. Pridėkite du laidus prie Ck pagal užduotį,
   tada spauskite **Įjungti ir matuoti**.
5. Apskaičiuokite S2, Q2, cos φ2 ir ΔS. Naudokite visas žurnale pateiktas
   šešias I ir P trupmenos skiltis. Q2 skaičiuokite stabilia formule
   **|Q − QC|**, kur **QC = 0,001·ω·Ck[µF]·U²**, ω = 2π·50.
   Q – antro etapo reaktyvioji galia mvar. Beveik nuliniam Q2 leidžiama
   0,001 mvar + 2 % paklaida. Formulė √(S2²−P2²) netinka naudojant
   suapvalintus beveik vienodus skaičius.
6. Įrašykite išvadas ir spauskite **Įrašyti ataskaitą**. Dėstytojui siųskite
   HTML failą; C++ dėstytojo programa jį patikrins ir įvertins automatiškai.

Darbas išsaugomas po įvedimų, jungimų, matavimų, pereinant etapą ir uždarant
langą (įskaitant įvedimą be Enter). Tęsti: **Pagalba → Tęsti išsaugotą darbą**.
Juodraštis `.sod` skirtas tęsimui, `.html` – pateikimui dėstytojui.

Numatytas atsiskaitymo režimas leidžia pateikti savo atsakymus, kuriuos vertina
C++ programa. Pagalboje galima įjungti mokymosi režimą ar pavyzdį; naudojimas
pažymimas ataskaitoje. Pavyzdys neperrašo savo darbo.

`VARIANTAI.csv` nurodyti kiekvieno dydžio vienetai. Bankas ir 20 taškų
vertinimo kriterijai išlieka; priimamos ir ankstesnės teisingos ataskaitos,
kurių Ck grįžtamasis laidas jungtas prie GEN_N vietoje to paties mazgo RL_B.
