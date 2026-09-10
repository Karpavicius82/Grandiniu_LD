function ok = ld1_configure_missing_values()
    global LD1;
    ok=%t;
    if LD1.cfg.R1>0 & LD1.cfg.R2>0 & LD1.cfg.R3>0 then return; end

    title=["LD Nr. 1 – stendo rezistorių parametrai";
           "Įveskite R1, R2 ir R3 NOMINALIAS varžas OMAIS (Ω).";
           "Pavyzdys: jei ant modulio parašyta 1 kΩ, įveskite 1000."];
    labels=["R1 [Ω]";"R2 [Ω]";"R3 [Ω]"];
    defaults=["";"";""];
    if LD1.cfg.R1>0 then defaults(1)=string(LD1.cfg.R1); end
    if LD1.cfg.R2>0 then defaults(2)=string(LD1.cfg.R2); end
    if LD1.cfg.R3>0 then defaults(3)=string(LD1.cfg.R3); end

    while %t
        vals=x_mdialog(title,labels,defaults);
        if isempty(vals) then ok=%f; return; end

        r1=ld1_parse_number(vals(1));
        r2=ld1_parse_number(vals(2));
        r3=ld1_parse_number(vals(3));
        if isnan(r1) | isnan(r2) | isnan(r3) | r1<=0 | r2<=0 | r3<=0 then
            messagebox("Įveskite tris teigiamas skaitines varžų reikšmes OMAIS.","LD1 parametrai","error");
            defaults=vals;
            continue;
        end

        if min([r1 r2 r3])<10 then
            warn=ld1_multiline(["Bent viena įvesta varža yra mažesnė nei 10 Ω.";
                "Patikrinkite vienetus: 1 kΩ = 1000 Ω, o ne 1 Ω.";
                "";
                "Įvesta: R1="+string(r1)+" Ω, R2="+string(r2)+" Ω, R3="+string(r3)+" Ω.";
                "Ar šios reikšmės tikrai teisingos?"]);
            answ=messagebox(warn,"Patikrinkite varžų vienetus","question",["Taip, teisingos" "Taisyti"],"modal");
            if answ<>1 then defaults=vals; continue; end
        end

        LD1.cfg.R1=r1; LD1.cfg.R2=r2; LD1.cfg.R3=r3;
        return;
    end
endfunction

function ld1_init_state()
    global LD1;
    LD1.step=1;
    LD1.panel="series";
    LD1.powerOn=%f;
    LD1.VR1=1000;
    LD1.meterMode="A";
    LD1.realistic=LD1.cfg.realistic_default;
    LD1.reviewMode=%f;
    LD1.demoMode=%f;
    LD1.demoSnapshot=struct();
    LD1.skipped=zeros(1,9)==1;
    LD1.pendingTerminal="";
    LD1.wires=emptystr(0,2);
    LD1.savedSeriesWires=emptystr(0,2);
    LD1.savedParallelWires=emptystr(0,2);
    LD1.savedParallelVoltageWires=emptystr(0,2);
    LD1.savedParallelVoltageVR=1000;
    LD1.kclPrepared=%f;
    LD1.kclTargetA="NODE_A1";
    LD1.lastMeasurement=%nan;
    LD1.lastMeasurementUnit="";
    LD1.lastMeasurementStep=0;
    LD1.parallelBaseVoltage=%nan;
    LD1.done=zeros(1,9)==1;
    LD1.stepQ=emptystr(9,3);
    LD1.stepType=zeros(1,9);
    LD1.stepYesNo=zeros(1,9);
    LD1.stepMeas=%nan*ones(1,9);
    LD1.stepMeasUnit=emptystr(9,1);
    LD1.actual=struct("R1",0,"R2",0,"R3",0,"VR1",1000);
    LD1.res=struct( ..
        "Rseries1000",%nan,"Iseries1000",%nan,"Mseries1000",%nan,"Errseries1000",%nan, ..
        "Rseries500",%nan,"Iseries500",%nan,"Mseries500",%nan,"Errseries500",%nan, ..
        "Rparallel1000",%nan,"Uparallel1000",%nan, ..
        "UparallelChanged",%nan, ..
        "I1",%nan,"I2",%nan,"It",%nan,"MIt",%nan,"KclErr",%nan);
    ld1_update_actual_values();
endfunction

function ld1_init_terminals()
    global LD1;
    LD1.term=struct();
    LD1.term.ids=["SRC_P";"SRC_N";"R1_1";"R1_2";"R2_1";"R2_2";"R3_1";"R3_2"; ..
                  "VR1_1";"VR1_2";"M_P";"M_N"; ..
                  "NODE_A1";"NODE_A2";"NODE_A3";"NODE_A4"; ..
                  "NODE_B1";"NODE_B2";"NODE_B3";"NODE_B4"];
    LD1.term.xy=%nan*ones(size(LD1.term.ids,"*"),2);
    LD1.term.active=emptystr(0,1);
    LD1.term.handles=list();
    LD1.term.handleIds=emptystr(0,1);
endfunction

function ld1_start()
    global LD1;
    if ~ld1_configure_missing_values() then
        disp("LD1 nepaleista: nenurodytos R1, R2, R3 vertės.");
        return;
    end
    ld1_init_state();
    ld1_init_terminals();
    ld1_create_gui();
    ld1_build_panel("series");
    ld1_set_step(1);
endfunction

function ld1_switch_panel(kind)
    global LD1;
    if isfield(LD1,"panel") then
        if LD1.panel=="series" then LD1.savedSeriesWires=LD1.wires; else LD1.savedParallelWires=LD1.wires; end
    end
    ld1_build_panel(kind);
    if kind=="series" then LD1.wires=LD1.savedSeriesWires; else LD1.wires=LD1.savedParallelWires; end
    ld1_redraw_panel();
endfunction

function ld1_refresh_meter_idle_display()
    global LD1;
    if ~isfield(LD1,"ui") then return; end
    if ~isfield(LD1.ui,"meterDisplay") then return; end
    if ~isnan(LD1.lastMeasurement) then
        LD1.ui.meterDisplay.string=ld1_num(LD1.lastMeasurement,3)+" "+LD1.lastMeasurementUnit;
        return;
    end
    if ld1_terminal_wire_count("M_P")>0 & ld1_terminal_wire_count("M_N")>0 then
        LD1.ui.meterDisplay.string="PARUOŠTA";
    else
        LD1.ui.meterDisplay.string="NEPRIJUNGTA";
    end
endfunction

function ld1_invalidate_measurement()
    global LD1;
    LD1.lastMeasurement=%nan;
    LD1.lastMeasurementUnit="";
    LD1.lastMeasurementStep=0;
    if isfield(LD1,"stepMeas") & LD1.step>=1 & LD1.step<=9 then
        LD1.stepMeas(LD1.step)=%nan;
        LD1.stepMeasUnit(LD1.step)="";
    end
    ld1_refresh_meter_idle_display();
endfunction

function fix = ld1_current_connection_fix()
    global LD1;
    if LD1.step<=4 then
        fix="Išjunkite maitinimą. Tiksliai: +→R1(1); R1(2)→VR1(1); VR1(2)→+/mA; COM→−. Jei etapas >1, spauskite ATKURTI ETAPO STENDĄ.";
    elseif LD1.step<=7 then
        fix="Išjunkite maitinimą. Naudokite atskirus A/B lizdus: +→A1, −→B1; R3 tarp A2-B2; R2+VR1 tarp A3-B3; V tarp A4-B4.";
    elseif LD1.step==8 then
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
        fix="8 etape kitų 6 laidų nelieskite. Prijunkite tik: šaltinio +→+/mA ir COM→"+targetA+". Jei būsena sugadinta – ATKURTI ETAPO STENDĄ.";
    else
        fix="Šiame etape laidų jungti nereikia.";
    end
endfunction

function W = ld1_series_canonical_wires()
    W=["SRC_P" "R1_1";
       "R1_2" "VR1_1";
       "VR1_2" "M_P";
       "M_N" "SRC_N"];
endfunction

function W = ld1_parallel_voltage_canonical_wires()
    W=["SRC_P" "NODE_A1";
       "SRC_N" "NODE_B1";
       "NODE_A2" "R3_1";
       "R3_2" "NODE_B2";
       "NODE_A3" "R2_1";
       "R2_2" "VR1_1";
       "VR1_2" "NODE_B3";
       "M_P" "NODE_A4";
       "M_N" "NODE_B4"];
endfunction

function W = ld1_parallel_kcl_base_wires()
    W=["SRC_N" "NODE_B1";
       "NODE_A2" "R3_1";
       "R3_2" "NODE_B2";
       "NODE_A3" "R2_1";
       "R2_2" "VR1_1";
       "VR1_2" "NODE_B3"];
endfunction

function W = ld1_parallel_kcl_canonical_wires()
    global LD1;
    target=LD1.kclTargetA;
    if target=="" then target="NODE_A1"; end
    anodes=["NODE_A1";"NODE_A2";"NODE_A3";"NODE_A4"];
    freeA=emptystr(0,1);
    for k=1:size(anodes,"*")
        if anodes(k)<>target then freeA($+1,1)=anodes(k); end
    end
    aR3=freeA(1); aR2=freeA(2);
    W=["SRC_N" "NODE_B1";
       aR3 "R3_1";
       "R3_2" "NODE_B2";
       aR2 "R2_1";
       "R2_2" "VR1_1";
       "VR1_2" "NODE_B3";
       "SRC_P" "M_P";
       "M_N" target];
endfunction

function ld1_apply_meter_mode_quiet(mode)
    global LD1;
    LD1.meterMode=mode;
    if mode=="A" then
        LD1.ui.modeA.value=1; LD1.ui.modeV.value=0;
    else
        LD1.ui.modeA.value=0; LD1.ui.modeV.value=1;
    end
endfunction
