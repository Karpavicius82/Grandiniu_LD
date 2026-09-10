function [ok,msg,fix] = ld1_validate_parallel_total_current_topology()
    // 2-7-3 pav. logika: ampermetras bendrame teigiamame laide prieš mazgą A.
    global LD1;
    ok=%f; msg="";
    targetA=ld1_terminal_button_text(LD1.kclTargetA);
    fix="Kitų 6 laidų nelieskite. Prijunkite TIK: šaltinio +→+/mA ir COM→"+targetA+". Jei abejojate – ATKURTI ETAPO STENDĄ.";
    if LD1.meterMode<>"A" then msg="Bendrai srovei matuoti pasirinktas neteisingas multimetro režimas."; fix="Pasirinkite A (DC), tada junkite šaltinio +→+/mA ir COM→"+targetA+"."; return; end
    if size(LD1.wires,1)<6 then
        msg="Trūksta vieno ar kelių bazinių 8 etapo laidų."; fix="Spauskite ATKURTI ETAPO STENDĄ. Programa grąžins 6 bazinius laidus; tada pridėsite tik 2 ampermetro laidus."; return;
    elseif size(LD1.wires,1)>8 then
        msg="8 etape yra per daug laidų."; fix="Spauskite ATKURTI ETAPO STENDĄ ir pridėkite tik dvi jungtis: +→+/mA bei COM→"+targetA+"."; return;
    end
    mpCount=ld1_terminal_wire_count("M_P"); mnCount=ld1_terminal_wire_count("M_N");
    if mpCount==0 & mnCount==0 then
        msg="Ampermetras dar visai neprijungtas.";
        fix="Atlikite dvi jungtis iš eilės: 1) šaltinio +→+/mA; 2) COM→"+targetA+". Tada PATIKRINTI SUJUNGIMĄ."; return;
    elseif mpCount==0 then
        msg="Trūksta ampermetro +/mA pusės jungties.";
        fix="Prijunkite šaltinio + prie ampermetro +/mA (oranžiniai kontaktai). COM jungties nekeiskite."; return;
    elseif mnCount==0 then
        msg="Trūksta ampermetro COM pusės jungties.";
        fix="Prijunkite ampermetro COM prie "+targetA+" (violetiniai kontaktai). +/mA jungties nekeiskite."; return;
    end
    if size(LD1.wires,1)<>8 then
        msg="Prijungti abu ampermetro gnybtai, bet bendras laidų skaičius nėra 8.";
        fix="Spauskite ATKURTI ETAPO STENDĄ. Tada pridėkite tik: šaltinio +→+/mA ir COM→"+targetA+"."; return;
    end

    [parent,roots]=ld1_wire_roots();
    sp=roots(ld1_term_index("SRC_P")); sn=roots(ld1_term_index("SRC_N"));
    a=roots(ld1_term_index("NODE_A1")); b=roots(ld1_term_index("NODE_B1"));
    mp=roots(ld1_term_index("M_P")); mn=roots(ld1_term_index("M_N"));

    if sp==sn then msg="Maitinimo šaltinis užtrumpintas."; fix="Išjunkite maitinimą ir spauskite ATKURTI ETAPO STENDĄ. Tada prijunkite tik dvi pažymėtas poras."; return; end
    if sp==a then
        msg="Šaltinio + vis dar turi tiesioginį kelią į mazgą A, todėl srovė apeina ampermetrą."; fix="Pašalinkite tiesioginį +→A laidą. Turi likti tik +→+/mA→COM→"+targetA+"."; return;
    end
    if b<>sn then
        msg="Mazgas B nebėra sujungtas su šaltinio − (0 V)."; fix="Atkurkite B grįžtamąjį laidą: B1→šaltinio −. Paprasčiausia – ATKURTI ETAPO STENDĄ."; return;
    end
    if ~(mp==sp & mn==a) then
        msg="Ampermetro +/mA ir COM prijungti ne ta tvarka arba ne į bendrą + laidą."; fix="Oranžiniai: šaltinio +↔+/mA. Violetiniai: COM↔"+targetA+". Ampermetras turi būti prieš srovės išsišakojimą."; return;
    end
    if mp==mn then msg="Ampermetras užtrumpintas laidu."; fix="Pašalinkite laidą tarp +/mA ir COM. Jungti reikia per grandinę: šaltinio +→+/mA, COM→"+targetA+"."; return; end
    if ~ld1_parallel_resistor_core(roots,a,b) then
        msg="Viena iš dviejų lygiagrečių šakų sugadinta."; fix="R3 turi likti tarp A2-B2, o R2+VR1 tarp A3-B3. Spauskite ATKURTI ETAPO STENDĄ, tada junkite tik ampermetro 2 laidus."; return;
    end

    ok=%t; msg="Teisingai: visa bendra srovė teka per ampermetrą ir tik tada mazge A pasidalija į I1 ir I2."; fix="";
endfunction

function ld1_check_wiring()
    global LD1;
    if LD1.panel=="series" then
        [ok,msg,fix]=ld1_validate_series_topology();
    elseif LD1.meterMode=="V" then
        [ok,msg,fix]=ld1_validate_parallel_voltage_topology();
    else
        [ok,msg,fix]=ld1_validate_parallel_total_current_topology();
    end
    if ok then ld1_set_status(msg,"ok",""); else ld1_set_status(msg,"error",fix); end
endfunction

function ld1_set_power_quiet(on)
    global LD1;
    LD1.powerOn=on;
    if on then
        LD1.ui.power.string="ĮJUNGTA";
        LD1.ui.power.backgroundcolor=[0.72 0.92 0.74];
        LD1.ui.sourceDisplay.string=string(LD1.cfg.E)+" V DC";
    else
        LD1.ui.power.string="IŠJUNGTA";
        LD1.ui.power.backgroundcolor=[0.94 0.82 0.82];
        LD1.ui.sourceDisplay.string="0 V DC";
    end
endfunction

function [v,u,ok] = ld1_solution_measure(stepNo)
    global LD1;
    [v,u,ok,msg]=ld1_meter_read();
    if ok then
        LD1.lastMeasurement=v;
        LD1.lastMeasurementUnit=u;
        LD1.lastMeasurementStep=stepNo;
    else
        LD1.lastMeasurement=%nan;
        LD1.lastMeasurementUnit="";
        LD1.lastMeasurementStep=0;
    end
endfunction

function ld1_set_solution_lock(on)
    global LD1;
    tf=~on;
    ld1_enable(LD1.ui.power,tf);
    ld1_enable(LD1.ui.vrSlider,tf);
    ld1_enable(LD1.ui.vr0,tf);
    ld1_enable(LD1.ui.vr500,tf);
    ld1_enable(LD1.ui.vr1000,tf);
    ld1_enable(LD1.ui.modeA,tf);
    ld1_enable(LD1.ui.modeV,tf);
    ld1_enable(LD1.ui.measure,tf);
    ld1_enable(LD1.ui.checkWiring,tf);
    ld1_enable(LD1.ui.undoWire,tf);
    ld1_enable(LD1.ui.clearWires,tf);
    ld1_enable(LD1.ui.wiringGuide,tf);
    ld1_enable(LD1.ui.restoreStage,tf);
    ld1_enable(LD1.ui.checkStep,tf);
    ld1_enable(LD1.ui.prev,tf & LD1.step>1);
    ld1_enable(LD1.ui.next,tf);
    ld1_enable(LD1.ui.review,tf);
    for k=1:3
        ld1_enable(LD1.ui.qEdit(k),tf);
    end
    ld1_enable(LD1.ui.typeSeries,tf);
    ld1_enable(LD1.ui.typeParallel,tf);
    ld1_enable(LD1.ui.typeMixed,tf);
    ld1_enable(LD1.ui.yes,tf);
    ld1_enable(LD1.ui.no,tf);
    for k=1:9
        ld1_enable(LD1.ui.stepButtons(k),tf);
    end
    if ~on then
        ld1_update_step_navigation();
        if LD1.step==1 | LD1.step==5 then
            ld1_set_wiring_edit_mode("full");
        elseif LD1.step==8 then
            ld1_set_wiring_edit_mode("meter");
        else
            ld1_set_wiring_edit_mode("locked");
        end
    end
endfunction

function ld1_snapshot_solution_state()
    global LD1;
    ld1_save_step_inputs();
    S=struct();
    S.panel=LD1.panel;
    S.wires=LD1.wires;
    S.savedSeriesWires=LD1.savedSeriesWires;
    S.savedParallelWires=LD1.savedParallelWires;
    S.savedParallelVoltageWires=LD1.savedParallelVoltageWires;
    S.savedParallelVoltageVR=LD1.savedParallelVoltageVR;
    S.kclPrepared=LD1.kclPrepared;
    S.kclTargetA=LD1.kclTargetA;
    S.VR1=LD1.VR1;
    S.meterMode=LD1.meterMode;
    S.powerOn=LD1.powerOn;
    S.pendingTerminal=LD1.pendingTerminal;
    S.lastMeasurement=LD1.lastMeasurement;
    S.lastMeasurementUnit=LD1.lastMeasurementUnit;
    S.lastMeasurementStep=LD1.lastMeasurementStep;
    S.q=emptystr(1,3);
    for k=1:3
        S.q(k)=string(LD1.ui.qEdit(k).string);
    end
    S.typeSeries=LD1.ui.typeSeries.value;
    S.typeParallel=LD1.ui.typeParallel.value;
    S.typeMixed=LD1.ui.typeMixed.value;
    S.yes=LD1.ui.yes.value;
    S.no=LD1.ui.no.value;
    S.instructionTitle=string(LD1.ui.instructionTitle.string);
    S.instructionLines=emptystr(1,5);
    for k=1:5
        S.instructionLines(k)=string(LD1.ui.instructionLine(k).string);
    end
    S.resultsString=LD1.ui.resultsTable.string;
    S.checkStepString=string(LD1.ui.checkStep.string);
    LD1.demoSnapshot=S;
endfunction
