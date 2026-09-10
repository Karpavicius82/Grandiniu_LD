function ld1_set_step(n)
    global LD1;
    if n<1 | n>9 then return; end

    // Prieš paliekant etapą išsaugomi visi studento įrašai ir matavimas.
    if isfield(LD1,"ui") then ld1_save_step_inputs(); end

    oldStep=LD1.step;
    if oldStep==8 & n<=7 then
        ld1_restore_voltage_stage_wiring();
    end
    LD1.step=n;
    LD1.lastMeasurement=%nan; LD1.lastMeasurementUnit=""; LD1.lastMeasurementStep=0;
    LD1.ui.meterDisplay.string="—";

    if n<=4 & LD1.panel<>"series" then ld1_switch_panel("series"); end
    if n>=5 & n<=8 & LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
    ld1_prepare_step_common();
    if n==1 | n==5 then
        ld1_set_wiring_edit_mode("full");
    elseif n==8 then
        ld1_set_wiring_edit_mode("meter");
    else
        ld1_set_wiring_edit_mode("locked");
    end

    select n
    case 1 then
        LD1.powerOn=%f; LD1.ui.power.string="IŠJUNGTA"; LD1.ui.power.backgroundcolor=[0.94 0.82 0.82]; LD1.ui.sourceDisplay.string="0 V DC";
        ld1_apply_meter_mode_quiet("A");
        LD1.VR1=1000; LD1.ui.vrSlider.value=1000; LD1.ui.vrText.string="1000 Ω"; ld1_update_actual_values();
        ld1_set_instruction("1. SUJUNKITE NUOSEKLIĄ GRANDINĘ", [
            "1) Šaltinio + → R1(1).";
            "2) R1(2) → VR1(1).";
            "3) VR1(2) → multimetro +/mA; COM → šaltinio −.";
            "4) Multimetras A (DC), maitinimas IŠJUNGTAS. Turi būti 4 laidai.";
            "5) Jei neaišku – spauskite KAIP SUJUNGTI. Tada pasirinkite NUOSEKLI."]);
        ld1_show(LD1.ui.typeSeries,%t); ld1_show(LD1.ui.typeParallel,%t); ld1_show(LD1.ui.typeMixed,%t);
        ld1_set_status("Sujunkite vieną uždarą nuoseklią kilpą.","info","Tikslus laidų sąrašas pasiekiamas mygtuku KAIP SUJUNGTI.");
    case 2 then
        LD1.VR1=1000; LD1.ui.vrSlider.value=1000; LD1.ui.vrText.string="1000 Ω"; ld1_update_actual_values();
        ld1_set_instruction("2. TEORINIS SKAIČIAVIMAS", [
            "Jungimo nekeiskite. VR1 = 1 kΩ (1000 Ω).";
            "Apskaičiuokite Rbendr = R1 + VR1.";
            "Apskaičiuokite I = E / Rbendr.";
            "Srovę įrašykite miliamperais (mA).";
            "Šiame etape matuoti nereikia."]);
        ld1_show_numeric_field(1,"Rbendr, Ω"); ld1_show_numeric_field(2,"I skaič., mA");
        ld1_set_status("Apskaičiuokite teorines reikšmes.","info","Jei grįžote iš vėlesnio etapo, ankstesni įrašai bus atkurti automatiškai.");
    case 3 then
        LD1.VR1=1000; LD1.ui.vrSlider.value=1000; LD1.ui.vrText.string="1000 Ω"; ld1_update_actual_values();
        ld1_apply_meter_mode_quiet("A");
        ld1_set_instruction("3. IŠMATUOKITE SROVĘ", [
            "Jungimas toks pats kaip 1 etape; VR1 = 1 kΩ.";
            "1) Įjunkite 10 V maitinimą.";
            "2) Multimetras A (DC), nuosekliai. Paspauskite MATUOTI.";
            "3) Palyginkite rodmenį su 2 etapo skaičiavimu.";
            "4) Pažymėkite Taip arba Ne."]);
        ld1_show_yes_no("Ar I išmatuota ≈ I apskaičiuota?");
        ld1_set_status("Paruošta srovės matavimui.","info","Jei sujungimas sugadintas – spauskite ATKURTI ETAPO STENDĄ, tada įjunkite maitinimą ir MATUOTI.");
    case 4 then
        LD1.VR1=500; LD1.ui.vrSlider.value=500; LD1.ui.vrText.string="500 Ω"; ld1_update_actual_values();
        ld1_apply_meter_mode_quiet("A");
        ld1_set_instruction("4. VR1 = 500 Ω", [
            "Jungimo nekeiskite. VR1 nustatytas į 500 Ω.";
            "1) Apskaičiuokite Rbendr = R1 + VR1.";
            "2) Apskaičiuokite I = E / Rbendr (mA).";
            "3) Įjunkite maitinimą, MATUOTI ir palyginkite reikšmes.";
            "4) Pažymėkite Taip/Ne. Mažesnė Rbendr turi duoti didesnę I."]);
        ld1_show_numeric_field(1,"Rbendr, Ω"); ld1_show_numeric_field(2,"I skaič., mA");
        ld1_show_yes_no("Ar I išmatuota ≈ I apskaičiuota?");
        ld1_set_status("Pakartokite nuoseklios grandinės bandymą su VR1 = 500 Ω.","info","Jungimo keisti nereikia – keičiasi tik VR1 ir srovė.");
    case 5 then
        LD1.kclPrepared=%f;
        ld1_set_parallel_meter_layout(%f);
        LD1.powerOn=%f; LD1.ui.power.string="IŠJUNGTA"; LD1.ui.power.backgroundcolor=[0.94 0.82 0.82]; LD1.ui.sourceDisplay.string="0 V DC";
        ld1_apply_meter_mode_quiet("V");
        LD1.VR1=1000; LD1.ui.vrSlider.value=1000; LD1.ui.vrText.string="1000 Ω"; ld1_update_actual_values();
        ld1_set_instruction("5. SUJUNKITE LYGIAGREČIĄ GRANDINĘ", [
            "1) Šaltinis: +→A1, −→B1. Šaka 1: A2→R3→B2.";
            "2) Šaka 2: A3→R2→VR1→B3 (R2 ir VR1 nuosekliai).";
            "3) Voltmetras: +/V→A4, COM→B4; režimas V (DC).";
            "4) A1=A2=A3=A4; B1=B2=B3=B4. Maitinimas IŠJUNGTAS.";
            "5) Iš viso turi būti 9 laidai. Visą sąrašą rodo KAIP SUJUNGTI."]);
        ld1_show(LD1.ui.typeSeries,%t); ld1_show(LD1.ui.typeParallel,%t); ld1_show(LD1.ui.typeMixed,%t);
        ld1_set_status("Sujunkite dvi lygiagrečias šakas tarp A ir B bei voltmetrą tarp A-B.","info","Jei kontaktai painūs – spauskite KAIP SUJUNGTI: ten nurodytas kiekvienas konkretus lizdas.");
    case 6 then
        ld1_apply_meter_mode_quiet("V");
        LD1.VR1=1000; LD1.ui.vrSlider.value=1000; LD1.ui.vrText.string="1000 Ω"; ld1_update_actual_values();
        ld1_set_instruction("6. APSKAIČIUOKITE IR IŠMATUOKITE", [
            "Jungimas toks pats kaip 5 etape; VR1 = 1 kΩ.";
            "1) Apskaičiuokite bendrą lygiagrečios grandinės varžą.";
            "2) Įjunkite 10 V maitinimą.";
            "3) Voltmetru išmatuokite UAB tarp A ir B – spauskite MATUOTI.";
            "4) Pažymėkite, ar UAB ≈ 10 V."]);
        ld1_show_numeric_field(1,"Rbendr, Ω"); ld1_show_yes_no("Ar UAB ≈ 10 V?");
        ld1_set_status("Paruošta UAB skaičiavimui ir matavimui.","info","Voltmetro +/V turi būti A4, COM – B4. Jei ne – ATKURTI ETAPO STENDĄ.");
    case 7 then
        ld1_apply_meter_mode_quiet("V");
        ld1_set_instruction("7. PAKEISKITE VR1 IR STEBĖKITE UAB", [
            "Jungimo nekeiskite – voltmetras lieka tarp A4 ir B4.";
            "1) Pakeiskite VR1 nuo 1 kΩ, pvz., į 500 Ω.";
            "2) Dar kartą paspauskite MATUOTI.";
            "3) Palyginkite naują UAB su 6 etapo reikšme.";
            "4) Pažymėkite, ar UAB pakito."]);
        ld1_show_yes_no("Ar pakeitus VR1, UAB pakito?");
        ld1_set_status("Pakeiskite tik VR1 ir atlikite naują UAB matavimą.","info","Jei sujungimas pasikeitė netyčia – ATKURTI ETAPO STENDĄ ir kartokite tik VR1 pakeitimą.");
    case 8 then
        if ~LD1.kclPrepared then ld1_prepare_kcl_stage(); end
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
        ld1_set_instruction("8. BENDRA SROVĖ IR KIRCHHOFO DĖSNIS", [
            "Ampermetras turi būti BENDRAME laide prieš srovės išsišakojimą mazge A.";
            "1) Šaltinio + → ampermetro +/mA.";
            "2) Ampermetro COM → "+targetA+". Kitų 6 užrakintų laidų nelieskite.";
            "3) VR1=0 Ω. PATIKRINTI SUJUNGIMĄ → įjungti 10 V → MATUOTI.";
            "4) Skaičiuoti: I1=10/R3; I2=10/R2; I=I1+I2. Tada palyginti su ampermetru."]);
        ld1_show_numeric_field(1,"I1 = 10/R3, mA"); ld1_show_numeric_field(2,"I2 = 10/R2, mA"); ld1_show_numeric_field(3,"I = I1+I2, mA");
        ld1_show_yes_no("Ar ampermetro I ≈ I1 + I2?");
        ld1_set_status("8 etape turite pridėti tik 2 ampermetro laidus.","info","Jei neaišku – PAVYZDYS / SPRENDIMAS parodo pilnai sujungtą ir veikiantį 8 etapą; grįžus jūsų darbas lieka nepakeistas.");
    case 9 then
        LD1.ui.progress.string="9 / 9 – rezultatų suvestinė";
        LD1.ui.standFrame.visible="off";
        LD1.ui.answerFrame.visible="off";
        LD1.ui.instructionFrame.position=[0.035 0.43 0.93 0.55];
        ld1_set_instruction("9. PROGRAMOS SUVESTINĖ – IŠ KUR ATSIRADO SKAIČIAI?", [
            "Tai PAPILDOMA virtualios laboratorijos suvestinė; originaliame apraše atskiro 9 matavimo etapo nėra.";
            "1–2 eilutės: 2–4 etapų nuoseklios grandinės skaičiavimai ir ampermetro rodmenys.";
            "3 eilutė: 6 etapo lygiagrečios grandinės Rbendr ir UAB voltmetro rodmuo.";
            "4 eilutė: 8 etapo I1=E/R3, I2=E/R2, jų suma ir bendros srovės ampermetro rodmuo.";
            "NEATLIKTA = etapas praleistas. PAVYZDYS / SPRENDIMAS = pilnas idealus variantas su formulėmis."]);
        ld1_clear_board_controls();
        ld1_board_text([0.03 0.875 0.94 0.055],"9. JŪSŲ REZULTATAI",15,%t,"left",[1 1 1],[0.10 0.23 0.38]);
        ld1_board_text([0.03 0.815 0.94 0.050],"Lentelė tik SURINKA ankstesnių etapų duomenis – ji nekuria naujų skaičių.",10,%f,"left",[1 1 1],[0.18 0.22 0.28]);
        LD1.ui.resultsTable.position=[0.025 0.12 0.95 0.67];
        LD1.ui.resultsTable.visible="on";
        ld1_update_results_table(%f);
        LD1.ui.checkStep.string="EKSPORTUOTI MANO REZULTATUS CSV";
        LD1.done(9)=%t;
        ld1_set_status("9 etapas – tik aiški ankstesnių rezultatų suvestinė.","ok","Jei norite pamatyti, kaip turi atrodyti pilnai atliktas darbas, spauskite PAVYZDYS / SPRENDIMAS.");
    end

    ld1_restore_step_inputs(n);

    if n<9 then
        ld1_refresh_meter_idle_display();
        ld1_redraw_panel();
    end
    ld1_update_step_navigation();
endfunction
