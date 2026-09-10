function ld1_apply_solution_state()
    global LD1;
    n=LD1.step;
    LD1.pendingTerminal="";
    LD1.lastMeasurement=%nan;
    LD1.lastMeasurementUnit="";
    LD1.lastMeasurementStep=0;
    LD1.ui.typeSeries.value=0; LD1.ui.typeParallel.value=0; LD1.ui.typeMixed.value=0;
    LD1.ui.yes.value=0; LD1.ui.no.value=0;

    if n<=4 then
        if LD1.panel<>"series" then ld1_build_panel("series"); end
        LD1.wires=ld1_series_canonical_wires();
        LD1.savedSeriesWires=LD1.wires;
        ld1_apply_meter_mode_quiet("A");
        if n==4 then LD1.VR1=500; else LD1.VR1=1000; end
        LD1.ui.vrSlider.value=LD1.VR1; LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
        [R,I]=ld1_series_theory(LD1.VR1);
        if n==1 then
            ld1_set_power_quiet(%f);
            LD1.ui.typeSeries.value=1;
            ld1_set_instruction("PAVYZDYS – 1 ETAPAS",[
                "Pilnai sujungta nuosekli grandinė. Maitinimas išjungtas.";
                "+→R1(1); R1(2)→VR1(1); VR1(2)→+/mA; COM→−.";
                "Multimetras A (DC), nes srovė matuojama nuosekliai.";
                "Grandinės tipas: NUOSEKLI.";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite jungimą."]);
        elseif n==2 then
            ld1_set_power_quiet(%f);
            LD1.ui.qEdit(1).string=ld1_num(R,3); LD1.ui.qEdit(2).string=ld1_num(I,3);
            ld1_set_instruction("PAVYZDYS – 2 ETAPAS",[
                "VR1 = 1000 Ω.";
                "Rbendr = R1 + 1000 = "+ld1_num(R,3)+" Ω.";
                "I = 10/Rbendr = "+ld1_num(I,3)+" mA.";
                "Šiame etape matavimo dar nereikia.";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir perskaičiuokite patys."]);
        else
            ld1_set_power_quiet(%t);
            [mval,munit,mok]=ld1_solution_measure(n);
            if mok then mtxt=ld1_num(mval,3)+" "+munit; else mtxt="VIDINĖ MATAVIMO KLAIDA"; end
            LD1.ui.yes.value=1;
            if n==4 then
                LD1.ui.qEdit(1).string=ld1_num(R,3); LD1.ui.qEdit(2).string=ld1_num(I,3);
            end
            ld1_set_instruction("PAVYZDYS – "+string(n)+" ETAPAS",[
                "Ampermetras įjungtas nuosekliai, maitinimas 10 V.";
                "Teorinė srovė = "+ld1_num(I,3)+" mA.";
                "Virtualus ampermetras realiai apskaičiavo: "+mtxt+".";
                "Todėl atsakymas į palyginimą: TAIP.";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite veiksmus."]);
        end
    elseif n>=5 & n<=7 then
        if LD1.panel<>"parallel" then ld1_build_panel("parallel"); end
        LD1.wires=ld1_parallel_voltage_canonical_wires();
        LD1.savedParallelWires=LD1.wires;
        LD1.savedParallelVoltageWires=LD1.wires;
        LD1.kclPrepared=%f;
        ld1_set_parallel_meter_layout(%f);
        ld1_apply_meter_mode_quiet("V");
        if n==7 then LD1.VR1=500; else LD1.VR1=1000; end
        LD1.ui.vrSlider.value=LD1.VR1; LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
        Rb=ld1_parallel_theory(LD1.VR1);
        if n==5 then
            ld1_set_power_quiet(%f);
            LD1.ui.typeParallel.value=1;
            ld1_set_instruction("PAVYZDYS – 5 ETAPAS",[
                "Pilnai sujungta lygiagreti grandinė; maitinimas išjungtas.";
                "+→A1, −→B1; R3 tarp A2-B2.";
                "R2 ir VR1 nuosekliai tarp A3-B3.";
                "Voltmetras: +/V→A4, COM→B4; režimas V (DC).";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite jungimą."]);
        elseif n==6 then
            ld1_set_power_quiet(%t);
            [mval,munit,mok]=ld1_solution_measure(6);
            if mok then mtxt=ld1_num(mval,3)+" "+munit; else mtxt="VIDINĖ MATAVIMO KLAIDA"; end
            LD1.ui.qEdit(1).string=ld1_num(Rb,3); LD1.ui.yes.value=1;
            ld1_set_instruction("PAVYZDYS – 6 ETAPAS",[
                "Rš2 = R2 + 1000 Ω.";
                "Rbendr = (R3·Rš2)/(R3+Rš2) = "+ld1_num(Rb,3)+" Ω.";
                "Virtualus voltmetras tarp A-B realiai apskaičiavo: "+mtxt+".";
                "Todėl UAB ≈ 10 V → TAIP.";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite veiksmus."]);
        else
            ld1_set_power_quiet(%t);
            [mval,munit,mok]=ld1_solution_measure(7);
            if mok then mtxt=ld1_num(mval,3)+" "+munit; else mtxt="VIDINĖ MATAVIMO KLAIDA"; end
            LD1.ui.no.value=1;
            ld1_set_instruction("PAVYZDYS – 7 ETAPAS",[
                "VR1 pakeistas į 500 Ω; kitų laidų nekeista.";
                "Voltmetras vis dar tarp A-B ir realiai apskaičiavo: "+mtxt+".";
                "Idealiame 10 V šaltinyje UAB lieka apie 10 V.";
                "Todėl klausimas „ar UAB pakito?“ → NE.";
                "Spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite veiksmus."]);
        end
    elseif n==8 then
        if LD1.panel<>"parallel" then ld1_build_panel("parallel"); end
        LD1.kclTargetA=LD1.demoSnapshot.kclTargetA;
        if LD1.kclTargetA=="" then LD1.kclTargetA="NODE_A1"; end
        LD1.kclPrepared=%t;
        LD1.wires=ld1_parallel_kcl_canonical_wires();
        LD1.savedParallelWires=LD1.wires;
        ld1_set_parallel_meter_layout(%t);
        ld1_apply_meter_mode_quiet("A");
        LD1.VR1=0; LD1.ui.vrSlider.value=0; LD1.ui.vrText.string="0 Ω";
        ld1_set_power_quiet(%t);
        [I1,I2,It]=ld1_parallel_currents(0);
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
        LD1.ui.qEdit(1).string=ld1_num(I1,3);
        LD1.ui.qEdit(2).string=ld1_num(I2,3);
        LD1.ui.qEdit(3).string=ld1_num(It,3);
        LD1.ui.yes.value=1;
        [mval,munit,mok]=ld1_solution_measure(8);
        if mok then mtxt=ld1_num(mval,3)+" "+munit; else mtxt="VIDINĖ MATAVIMO KLAIDA"; end
        ld1_set_instruction("PAVYZDYS – 8 ETAPAS",[
            "Ampermetras yra BENDRAME laide PRIEŠ mazgą A.";
            "Tiksliai: šaltinio +→+/mA; COM→"+targetA+"; šaltinio −→B1.";
            "R3 yra A-B šaka; R2+VR1 yra kita A-B šaka; VR1=0 Ω.";
            "I1=10/R3="+ld1_num(I1,3)+" mA; I2=10/R2="+ld1_num(I2,3)+" mA; suma="+ld1_num(It,3)+" mA.";
            "Virtualus ampermetras realiai apskaičiavo: "+mtxt+"."]);
    else
        ld1_update_results_table(%t);
        ld1_set_instruction("PAVYZDYS – 9 ETAPAS",[
            "Rodoma pilnai atlikto IDEALAUS darbo suvestinė.";
            "Kiekvienoje eilutėje formulė paaiškina, iš kur gautas skaičius.";
            "Tai nėra jūsų rezultatai – jūsų duomenys liko išsaugoti.";
            "NEATLIKTA jūsų suvestinėje reiškia praleistą etapą.";
            "Spauskite GRĮŽTI Į SAVO DARBĄ, kad grįžtų jūsų suvestinė."]);
    end

    ld1_update_actual_values();
    if n<9 then
        LD1.ui.meterDisplay.string="—";
        if ~isnan(LD1.lastMeasurement) then
            LD1.ui.meterDisplay.string=ld1_num(LD1.lastMeasurement,3)+" "+LD1.lastMeasurementUnit;
        else
            ld1_refresh_meter_idle_display();
        end
        ld1_redraw_panel();
    end
endfunction

function ld1_toggle_solution()
    global LD1;
    if LD1.demoMode then
        ld1_restore_solution_state();
        return;
    end
    ld1_snapshot_solution_state();
    LD1.demoMode=%t;
    LD1.ui.solution.string="GRĮŽTI Į SAVO DARBĄ";
    ld1_apply_solution_state();
    ld1_set_solution_lock(%t);
    ld1_set_status("RODOMAS TEISINGAS PAVYZDYS – jūsų darbas nepakeistas.","warn","Peržiūrėkite laidus, režimą, VR1, formules ir rodmenį. Tada spauskite GRĮŽTI Į SAVO DARBĄ ir atkartokite.");
endfunction
