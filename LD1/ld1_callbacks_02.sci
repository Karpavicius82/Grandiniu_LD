function ld1_save_step_inputs()
    global LD1;
    if ~isfield(LD1,"ui") then return; end
    if LD1.step<1 | LD1.step>9 then return; end
    for k=1:3
        LD1.stepQ(LD1.step,k)=string(LD1.ui.qEdit(k).string);
    end
    t=0;
    if LD1.ui.typeSeries.value<>0 then t=1; end
    if LD1.ui.typeParallel.value<>0 then t=2; end
    if LD1.ui.typeMixed.value<>0 then t=3; end
    LD1.stepType(LD1.step)=t;
    yn=0;
    if LD1.ui.yes.value<>0 then yn=1; end
    if LD1.ui.no.value<>0 then yn=2; end
    LD1.stepYesNo(LD1.step)=yn;
    if LD1.lastMeasurementStep==LD1.step & ~isnan(LD1.lastMeasurement) then
        LD1.stepMeas(LD1.step)=LD1.lastMeasurement;
        LD1.stepMeasUnit(LD1.step)=LD1.lastMeasurementUnit;
    end
endfunction

function ld1_restore_step_inputs(n)
    global LD1;
    if n<1 | n>9 then return; end
    for k=1:3
        LD1.ui.qEdit(k).string=LD1.stepQ(n,k);
    end
    t=LD1.stepType(n);
    LD1.ui.typeSeries.value=(t==1); LD1.ui.typeParallel.value=(t==2); LD1.ui.typeMixed.value=(t==3);
    yn=LD1.stepYesNo(n);
    LD1.ui.yes.value=(yn==1); LD1.ui.no.value=(yn==2);
    if ~isnan(LD1.stepMeas(n)) then
        LD1.lastMeasurement=LD1.stepMeas(n);
        LD1.lastMeasurementUnit=LD1.stepMeasUnit(n);
        LD1.lastMeasurementStep=n;
    end
endfunction

function ld1_show_wiring_guide()
    global LD1;
    select LD1.step
    case 1 then
        txt=["1 ETAPAS – NUOSEKLI GRANDINĖ";
             "";
             "Maitinimas turi būti IŠJUNGTAS.";
             "1. Šaltinio +  →  R1(1)";
             "2. R1(2)       →  VR1(1)";
             "3. VR1(2)      →  multimetro +/mA";
             "4. Multimetro COM → šaltinio −";
             "5. Multimetras: A (DC).";
             "";
             "Turi būti 4 laidai ir viena uždara nuosekli kilpa."];
    case 2 then
        txt=["2 ETAPAS – JUNGIMAS NEKEIČIAMAS";"Naudokite 1 etapo nuoseklią schemą.";"VR1 = 1000 Ω. Šiame etape tik skaičiuojama."];
    case 3 then
        txt=["3 ETAPAS – SROVĖS MATAVIMAS";"Jungimas toks pats kaip 1 etape.";"Multimetras A (DC), nuosekliai. Įjunkite 10 V ir spauskite MATUOTI."];
    case 4 then
        txt=["4 ETAPAS – VR1 = 500 Ω";"Jungimas toks pats kaip 1 etape.";"Pakeiskite tik VR1 į 500 Ω, apskaičiuokite ir išmatuokite srovę."];
    case 5 then
        txt=["5 ETAPAS – LYGIAGRETI GRANDINĖ";
             "";
             "Maitinimas turi būti IŠJUNGTAS.";
             "1. Šaltinis: +→A1, −→B1";
             "2. Šaka 1: A2→R3(1), R3(2)→B2";
             "3. Šaka 2: A3→R2(1), R2(2)→VR1(1), VR1(2)→B3";
             "4. Voltmetras: +/V→A4, COM→B4";
             "5. Multimetras: V (DC).";
             "";
             "A1=A2=A3=A4 yra tas pats mazgas A; B1=B2=B3=B4 – mazgas B."];
    case 6 then
        txt=["6 ETAPAS – UAB MATAVIMAS";"Jungimas toks pats kaip 5 etape.";"VR1 = 1000 Ω. Voltmetras tarp A ir B: +→A4, COM→B4."];
    case 7 then
        txt=["7 ETAPAS – VR1 KEITIMAS";"Jungimas toks pats kaip 5 etape.";"Pakeiskite tik VR1 (pvz., 500 Ω) ir iš naujo išmatuokite UAB."];
    case 8 then
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
        txt=["8 ETAPAS – BENDROS SROVĖS MATAVIMAS";
             "";
             "SROVĖS KELIAS TURI BŪTI: +10 V → AMPERMETRAS → MAZGAS A → DVI ŠAKOS → MAZGAS B → 0 V.";
             "Programa jau paliko 6 teisingus ir užrakintus laidus.";
             "R3 lieka tarp A-B; R2+VR1 lieka tarp A-B; B lieka sujungtas su šaltinio −.";
             "";
             "Prijunkite TIK 2 laidus:";
             "1. Šaltinio + → ampermetro +/mA.";
             "2. Ampermetro COM → "+targetA+".";
             "";
             "Po sujungimo turi būti 8 laidai. VR1=0 Ω. PATIKRINTI SUJUNGIMĄ → ĮJUNGTI 10 V → MATUOTI.";
             "Jei vis tiek neaišku – PAVYZDYS / SPRENDIMAS parodo pilnai veikiančią schemą."];
    else
        txt=["9 ETAPAS – REZULTATAI";"Laidų jungti nebereikia."];
    end
    messagebox(txt,"LD1 – kaip tiksliai sujungti","info");
endfunction

function ld1_restore_current_stage_board()
    global LD1;
    ld1_force_power_off();
    LD1.pendingTerminal="";

    if LD1.step==1 then
        if LD1.panel<>"series" then ld1_switch_panel("series"); end
        LD1.wires=emptystr(0,2);
        LD1.savedSeriesWires=LD1.wires;
        ld1_apply_meter_mode_quiet("A");
        LD1.VR1=1000;
    elseif LD1.step>=2 & LD1.step<=4 then
        if LD1.panel<>"series" then ld1_switch_panel("series"); end
        LD1.wires=ld1_series_canonical_wires();
        LD1.savedSeriesWires=LD1.wires;
        ld1_apply_meter_mode_quiet("A");
        if LD1.step==4 then LD1.VR1=500; else LD1.VR1=1000; end
    elseif LD1.step==5 then
        if LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
        LD1.wires=emptystr(0,2);
        LD1.savedParallelWires=LD1.wires;
        LD1.kclPrepared=%f;
        ld1_set_parallel_meter_layout(%f);
        ld1_apply_meter_mode_quiet("V");
        LD1.VR1=1000;
    elseif LD1.step==6 | LD1.step==7 then
        if LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
        LD1.wires=ld1_parallel_voltage_canonical_wires();
        LD1.savedParallelWires=LD1.wires;
        LD1.savedParallelVoltageWires=LD1.wires;
        LD1.savedParallelVoltageVR=1000;
        LD1.kclPrepared=%f;
        ld1_set_parallel_meter_layout(%f);
        ld1_apply_meter_mode_quiet("V");
        LD1.VR1=1000;
    elseif LD1.step==8 then
        if LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
        LD1.wires=ld1_parallel_kcl_base_wires();
        LD1.savedParallelWires=LD1.wires;
        LD1.savedParallelVoltageWires=ld1_parallel_voltage_canonical_wires();
        LD1.savedParallelVoltageVR=1000;
        LD1.kclTargetA="NODE_A1";
        LD1.kclPrepared=%t;
        ld1_set_parallel_meter_layout(%t);
        ld1_apply_meter_mode_quiet("A");
        LD1.VR1=0;
    else
        ld1_set_status("Rezultatų etape stendo atkurti nereikia.","info");
        return;
    end

    LD1.ui.vrSlider.value=LD1.VR1;
    LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
    ld1_update_actual_values();
    ld1_invalidate_measurement();
    ld1_redraw_panel();
    ld1_set_status("Dabartinio etapo stendas atkurtas į saugią pradinę būseną.","ok",ld1_current_connection_fix());
endfunction

function ld1_prepare_review_stage(n)
    global LD1;
    if n<=4 then
        if LD1.panel<>"series" then ld1_switch_panel("series"); end
        LD1.wires=ld1_series_canonical_wires(); LD1.savedSeriesWires=LD1.wires;
        ld1_apply_meter_mode_quiet("A");
        if n==4 then LD1.VR1=500; else LD1.VR1=1000; end
    elseif n>=5 & n<=7 then
        if LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
        LD1.wires=ld1_parallel_voltage_canonical_wires(); LD1.savedParallelWires=LD1.wires;
        LD1.savedParallelVoltageWires=LD1.wires; LD1.savedParallelVoltageVR=1000;
        LD1.kclPrepared=%f; ld1_set_parallel_meter_layout(%f); ld1_apply_meter_mode_quiet("V");
        LD1.VR1=1000;
    elseif n==8 then
        if LD1.panel<>"parallel" then ld1_switch_panel("parallel"); end
        LD1.wires=ld1_parallel_kcl_base_wires(); LD1.savedParallelWires=LD1.wires;
        LD1.savedParallelVoltageWires=ld1_parallel_voltage_canonical_wires(); LD1.savedParallelVoltageVR=1000;
        LD1.kclTargetA="NODE_A1"; LD1.kclPrepared=%t; ld1_set_parallel_meter_layout(%t); ld1_apply_meter_mode_quiet("A");
        LD1.VR1=0;
    end
    if n<9 then
        LD1.powerOn=%f;
        LD1.ui.power.string="IŠJUNGTA";
        LD1.ui.power.backgroundcolor=[0.94 0.82 0.82];
        LD1.ui.sourceDisplay.string="0 V DC";
        LD1.lastMeasurement=%nan; LD1.lastMeasurementUnit=""; LD1.lastMeasurementStep=0;
        LD1.ui.vrSlider.value=LD1.VR1; LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
        ld1_update_actual_values(); ld1_redraw_panel();
    end
endfunction
