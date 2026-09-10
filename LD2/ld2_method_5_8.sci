function d=ld2_method_data_5_8(step)
    d=struct("goal", "", "theory",emptystr(0,1), "method",emptystr(0,1), "formulas",emptystr(0,1), "check",emptystr(0,1), "mistakes",emptystr(0,1), "questions",emptystr(0,1), "source",emptystr(0,1));
    select step
    case 5 then
        d.goal="Sujungti nuoseklią RL grandinę ir atskirti ją nuo RC.";
        d.theory=["RL grandinėje kondensatorių pakeičia ritė. Rezistorius ir ritė sujungti nuosekliai, todėl jų srovė ta pati. Ritės induktyvioji varža priklauso nuo dažnio: XL = 2·pi·f·L.";"Šiame modelyje L1 yra ideali ritė be apvijos aktyviosios varžos. Visa aktyvioji varža sutelkta R9. Tikro stendo ritės nuostolius reikėtų įvertinti atskirai – jie čia neapsimetami žinomais.";"RC ir RL gnybtų numeriai specialiai skirtingi. Generatorius bei prietaisai išlaiko T01–T08, tačiau R9 ir L1 turi naujus T17–T24. Tai saugo nuo vienodų „1“ ir „2“ žymų painiojimo."];
        d.method=["1. Patikrinkite [B09]: generatorius IŠJUNGTAS.";"2. W1: T01 → T05. W2: T06 → T17.";"3. W3: T18 → T21. W4: T22 → T02.";"4. [B10] patikrinkite keturių laidų planą. Violetinių T19/T20 ir T23/T24 dar nejunkite.";"5. [B03] leidžia palyginti su atliktu pavyzdžiu. Grįžę [B04] patikrinkite savą jungimą ir [B36] pereikite."];
        d.formulas=["Srovės kelias: T01 → T05 — A~ — T06 → T17 — R9 — T18 → T21 — L1 — T22 → T02.";"ZRL = R9 + j·2·pi·f_RL·L1."];
        d.check=["Keturios numatytos jungtys; srovės kelias vienas."];
        d.mistakes=["Ieškote T09: jis priklauso RC R8. RL rezistorius yra R9, jo pagrindiniai lizdai T17 ir T18.";"Norite prijungti ritę prie matavimo lizdo: naudokite pagrindinius T21 ir T22."];
        d.questions=["Kaip nuo dažnio priklauso ritės ir kondensatoriaus varžos?";"Kokia tikros ritės savybė čia sąmoningai neįtraukta?"];
        d.source=["[S1] p. 4, RL 1–2 punktai.";"[N] idealių elementų prielaidos ir numeravimo sistema."];
    case 6 then
        d.goal="Apskaičiuoti RL reaktyviąją varžą, srovę, įtampas, galią ir fazę.";
        d.theory=["Ritės impedansas yra +jXL, tad Z = R9+jXL. Bendro modulio formulė tokia pati kaip RC, tačiau reaktyviosios dalies ženklas priešingas.";"Ritės įtampa pirmauja jos srovę 90°. Visa RL grandinės srovė atsilieka nuo šaltinio įtampos, todėl atsakymų lauke φI yra neigiama. Originale prašomas grandinės kampas gali būti žymimas φZ; abu kampai turi tą patį modulį ir priešingus ženklus.";"Aktivioji galia išskiriama R9 rezistoriuje. Ritė periodiškai kaupia ir grąžina magnetinio lauko energiją, bet idealios ritės vidutinė aktyvioji galia lygi nuliui.";"Įtampų moduliams E²=UR²+UL². Ši lygybė galioja šiam idealiam nuosekliam RL modeliui, ne bet kuriam netiesiniam ar nesinusiniam bandymui."];
        d.method=["1. [B39] nusirašykite E_RL, f_RL, R9 ir L1. Induktyvumą formulėse naudokite H.";"2. Apskaičiuokite XL, |Z|, I, UR9, UL1, P ir φI.";"3. [A06.01–A06.07] įrašykite skaičius: Ω, Ω, mA, V, V, mW, °.";"4. [B28] ir [B29] peržiūrėkite teigiamą induktyviąją diagramos dalį. [B41] įrašykite savo palyginimą su RC.";"5. [B04] patikrinkite. Jei atsakymas netinka, klaidoje bus nurodytas konkretus A06 laukas."];
        d.formulas=["XL = 2·pi·f_RL·L1.";"Z = R9+jXL; |Z| = sqrt(R9²+XL²).";"I_mA = 1000·E_RL/|Z|.";"UR9 = I·R9; UL1 = I·XL.";"P_mW = 1000·I²·R9.";"φZ = atan(XL/R9)·180/pi; φI = −φZ."];
        d.check=["φI yra tarp −90° ir 0°.";"sqrt(UR9²+UL1²) ≈ E_RL."];
        d.mistakes=["Gautas teigiamas kampas: tai gali būti φZ, tačiau A06.07 prašoma φI = −φZ.";"Įrašėte 500 vietoje 0,5 H: mH reikia padauginti iš 0,001."];
        d.questions=["Kodėl RL ir RC fazių ženklai priešingi?";"Kodėl didinant RL dažnį srovė mažėja?"];
        d.source=["[S1] p. 4, RL 3 ir 6 punktai.";"[N] aiškiai atskirta srovės fazė nuo impedanso kampo."];
    case 7 then
        d.goal="Išmatuoti RL rodmenis ir patikrinti įtampų bei fazių ryšius.";
        d.theory=["Matavimo principas toks pats kaip E04: ampermetras pagrindinėje grandinėje, voltmetras lygiagrečiai pasirinktam elementui. Šioje dalyje R9 matavimo lizdai yra T19/T20, L1 – T23/T24.";"Voltmetras rodo RMS modulį. Sukeitus jo zondus sinusinės įtampos RMS modulis nesikeičia; fazoriaus krypties sutartis diagramoje vis tiek turi būti nurodyta.";"Iš UR9 išvestą srovę lyginkite su A~ rodmeniu. E išveskite iš UR9 ir UL1 fazorių, ne jų paprastos aritmetinės sumos.";"Oscilograma apskaičiuota iš sinusinio modelio ir parodo fazės poslinkį. Ji nevaizduoja realaus skaitmeninio osciloskopo triukšmo ar diskretizavimo paklaidų."];
        d.method=["1. [B09] įjunkite generatorių. [B14] išmatuokite I.";"2. UR9: T07 → T19, T08 → T20. [B15].";"3. [B13]. UL1: T07 → T23, T08 → T24. [B15].";"4. [B13]. Šaltinio E: T07 → T03, T08 → T04. [B15].";"5. [A07.01] įrašykite sqrt(UR9²+UL1²); [A07.02] – 1000·UR9/R9.";"6. [B28], [B29], [B30] palyginkite diagramas. [B41] įrašykite pastebėjimus. [B04]."];
        d.formulas=["E_sk = sqrt(UR9_mat²+UL1_mat²).";"I_sk,mA = 1000·UR9_mat/R9.";"i(t) = sqrt(2)·I·sin(2·pi·f·t+φI), φI<0."];
        d.check=["Žurnale RL I, UR, UL ir UE; du užpildyti skaičiavimo laukai."];
        d.mistakes=["Rodoma sena reikšmė žurnale, bet ekrane PARUOŠTA: žurnalas yra istorija; naujam matavimui B15.";"Norite kondensatoriaus įtampos: RL dalyje C nėra, matuojama L1 per T23/T24."];
        d.questions=["Kaip iš oscilogramos matyti srovės atsilikimas?";"Kuo skiriasi A~ matavimas ir iš UR9/R9 apskaičiuota srovė?"];
        d.source=["[S1] p. 4, RL 4–6 punktai.";"[N] papildyta atskira oscilograma ir matavimo kilmės žurnalas."];
    case 8 then
        d.goal="Sujungti nuoseklų C4–L3–R13 kontūrą dažnio tyrimui.";
        d.theory=["Nuosekliame RLC kontūre bendra reaktyvioji dalis X = XL−XC. Didinant dažnį XL didėja, XC mažėja; tarp jų yra dažnis, kuriame jos susilygina.";"R13 yra kontūro aktyvioji varža. Todėl jos įtampa UR13 = I·R13 tiesiogiai proporcinga kontūro srovei. Stebėdami UR13 maksimumą vėliau ieškosime srovės rezonanso.";"Šiame modelyje generatoriaus vidinė ir ritės apvijos varžos lygios nuliui. Visa kontūro aktyvioji varža RΣ = R13. Todėl rezonanse UR13 = E_RLC. Tikram prietaisui ši lygybė be papildomų nuostolių įvertinimo nebūtinai galiotų.";"T37/T38 yra papildomi bendros C4+L3 įtampos matavimo lizdai. T37 viduje sujungtas su T25, T38 – su T30. Jų nejunkite tarpusavyje laidu, nes taip apeitumėte reaktyviąją porą."];
        d.method=["1. [B09] būsena IŠJUNGTA. Reikia 5 pagrindinių laidų.";"2. W1: T01 → T05. W2: T06 → T25.";"3. W3: T26 → T29. W4: T30 → T33.";"4. W5: T34 → T02. Voltmetro dar nejunkite.";"5. [B10] patikrinkite. Visa srovė turi tekėti per A~, C4, L3 ir R13.";"6. [B03] rodo tą patį penkių laidų planą. Grįžę [B04], paskui [B36]."];
        d.formulas=["Z = R13+j(2·pi·f·L3−1/(2·pi·f·C4)).";"I = E_RLC/|Z|; UR13 = I·R13."];
        d.check=["T01–T05, T06–T25, T26–T29, T30–T33, T34–T02 yra penkios užbaigtos poros."];
        d.mistakes=["Vietoje T26 pasirinktas T28: T28 matavimo lizdas, pagrindinei grandinei naudokite T26.";"Vieną laidą prijungėte prie R13 netinkamo krašto: srovės įėjimas T33, išėjimas T34."];
        d.questions=["Kodėl rezonanso paieškai tinka R13 įtampa?";"Kodėl papildomi matavimo lizdai nėra naujos grandinės šakos su apkrova?"];
        d.source=["[S1] p. 5, RLC schema 2-18-1 ir 1–2 punktai.";"[N] penkių laidų planas ir idealios aktyviosios varžos prielaida."];
    else error("Netinkamas metodikos etapas.");
    end
endfunction
