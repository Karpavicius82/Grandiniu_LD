# LD12 – žvaigžde ir trikampiu jungiamų imtuvų tyrimas

Paleiskite `STENDAS.sce` → LD12. Įveskite eilės numerį (1–64), vardą,
pavardę ir grupę. Programa parodys jūsų **Ul** ir **R**. Ul – įtampa tarp
šaltinio linijų, RMS, V; visi trys imtuvai turi vienodą R, Ω.

1. **Žvaigždė Y.** Pagalba → **[B04] Kaip sujungti** rodo visus šešis
   laidus, numerius ir gnybtų pavadinimus. Laidą pridedate paspausdami abu
   gnybtus; pakartoję pašalinate. Apskaičiuokite Uf = Ul/√3.
2. Spauskite **[B15] Įjungti ir matuoti visus**. Programa patikrins laidus,
   įjungs šaltinį ir įrašys R1, R2, R3 matavimus. If[mA] = 1000·Uf[V]/R[Ω].
3. **Trikampis Δ.** Sujunkite pagal [B04]: R1 tarp L1–L2, R2 tarp L2–L3,
   R3 tarp L3–L1. N nejungiamas. Įrašykite Uf = Ul.
4. Spauskite **[B15]**. Įrašomi trys imtuvai ir atskirai linija L1.
   **If teka imtuve, Il – šaltinio linijoje.** Kortelių antraštės rodo,
   kur matuojama; pasirinktas imtuvas paryškintas. Rankiniam matavimui
   rinkitės [B12]–[B14] arba liniją [B16], tada [B03].
5. Apskaičiuokite IlΔ = √3·IfΔ, PΔ = √3·Ul·IlΔ ir PY = 3·UfY·IfY.
   Su V ir mA galia gaunama **mW**. PY naudokite žvaigždės žurnalo duomenis.
6. Išvadoms įrašykite **1 – Taip** arba **2 – Ne**. Užbaikite etapus ir
   spauskite **ĮRAŠYTI ATASKAITĄ**. Dėstytojui siųskite HTML failą.

Vienas paspaudimas matuoja visus reikalingus taškus, todėl nereikia septynių
kartų kartoti rankinių veiksmų. Pakartotiniai matavimai nesidubliuoja.
Fazinės įtampos ir srovės yra vienodo dydžio, jų fazės skiriasi 120°.

Visas langas išlaiko 1280 × 720 loginį dydį. Mažame ekrane naudojamas slinkimas.
Darbas išsaugomas automatiškai, taip pat uždarant langą be Enter.
Tęsti: **Pagalba → Tęsti išsaugotą darbą**. `.sod` yra juodraštis,
`.html` – pateikiama ataskaita. Įrašymo klaida neuždaro darbo lango.

Atsiskaitymo režimas saugo jūsų atsakymus; juos vertina dėstytojo C++ programa.
Mokymosi režimas ir pavyzdžio naudojimas pažymimi ataskaitoje. Pavyzdys
neperrašo jūsų laidų ar atsakymų. Tuščias laukelis neleidžia praleisti etapo.

Dėstytojas gali sudėti HTML į vieną aplanką ir atverti **mokytojas**:
automatiškai gaunami taškai (maks. 19), pažymys ir komentarai pagal kriterijų
numerius. Trūkstami matavimai ataskaitoje nepapildomi apskaičiuotais duomenimis.
64 variantai pateikti `VARIANTAI.csv`; studentui ir dėstytojui Python nereikia.
