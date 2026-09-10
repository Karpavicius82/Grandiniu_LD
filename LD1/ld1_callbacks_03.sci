function ld1_terminal_click(id)
    global LD1;
    if LD1.pendingTerminal=="" then
        LD1.pendingTerminal=id;
        ld1_set_status("Pasirinkta: "+ld1_terminal_label(id)+". Dabar pasirinkite antrą gnybtą.","info",ld1_current_connection_fix());
    elseif LD1.pendingTerminal==id then
        LD1.pendingTerminal="";
        ld1_set_status("Gnybto pasirinkimas atšauktas.","info",ld1_current_connection_fix());
    else
        a=LD1.pendingTerminal; b=id;
        existed=ld1_wire_exists(a,b);
        if ~existed then
            if ld1_terminal_wire_count(a)>0 then
                LD1.pendingTerminal="";
                if LD1.step==8 & a=="VR1_2" then
                    fix="VR1(2) šiame etape jau teisingai jungiasi į B3. Ampermetro COM junkite į "+ld1_terminal_button_text(LD1.kclTargetA)+", ne į VR1.";
                else
                    fix=ld1_current_connection_fix();
                end
                ld1_set_status(ld1_terminal_label(a)+" jau turi laidą – ant vieno fizinio lizdo antro laido nedėkite.","warn",fix);
                ld1_redraw_panel();
                return;
            end
            if ld1_terminal_wire_count(b)>0 then
                LD1.pendingTerminal="";
                if LD1.step==8 & b=="VR1_2" then
                    fix="VR1(2) šiame etape jau teisingai jungiasi į B3. Ampermetro COM junkite į "+ld1_terminal_button_text(LD1.kclTargetA)+", ne į VR1.";
                else
                    fix=ld1_current_connection_fix();
                end
                ld1_set_status(ld1_terminal_label(b)+" jau turi laidą – pasirinkite nurodytą laisvą lizdą.","warn",fix);
                ld1_redraw_panel();
                return;
            end
        end
        ld1_add_wire(a,b);
        LD1.pendingTerminal="";
        ld1_invalidate_measurement();
        if existed then
            ld1_set_status("Laidas pašalintas: "+ld1_terminal_label(a)+" ↔ "+ld1_terminal_label(b)+".","info",ld1_current_connection_fix());
        else
            ld1_set_status("Laidas prijungtas: "+ld1_terminal_label(a)+" ↔ "+ld1_terminal_label(b)+".","ok",ld1_current_connection_fix());
        end
        if LD1.panel=="series" then LD1.savedSeriesWires=LD1.wires; else LD1.savedParallelWires=LD1.wires; end
    end
    ld1_redraw_panel();
endfunction

function ld1_remove_last_wire()
    global LD1;
    if LD1.step==8 & size(LD1.wires,1)<=6 then
        ld1_set_status("8 etapo šeši baziniai laidai yra užrakinti.","info","Atšaukti galima tik jūsų pridėtus ampermetro laidus. Prijunkite: +→+/mA ir COM→"+ld1_terminal_button_text(LD1.kclTargetA)+".");
        return;
    end
    if size(LD1.wires,1)==0 then
        ld1_set_status("Nėra laidų, kuriuos būtų galima atšaukti.","info",ld1_current_connection_fix());
        return;
    end
    a=LD1.wires($,1); b=LD1.wires($,2);
    if size(LD1.wires,1)==1 then LD1.wires=emptystr(0,2); else LD1.wires=LD1.wires(1:$-1,:); end
    LD1.pendingTerminal="";
    ld1_invalidate_measurement();
    if LD1.panel=="series" then LD1.savedSeriesWires=LD1.wires; else LD1.savedParallelWires=LD1.wires; end
    ld1_redraw_panel();
    ld1_set_status("Atšauktas paskutinis laidas: "+ld1_terminal_label(a)+" ↔ "+ld1_terminal_label(b)+".","info");
endfunction

function ld1_clear_wires()
    global LD1;
    if LD1.step<>1 & LD1.step<>5 then
        ld1_set_status("Šiame etape visa schema nuo atsitiktinio išvalymo užrakinta.","info","Jei reikia teisingos pradinės būsenos, spauskite ATKURTI ETAPO STENDĄ.");
        return;
    end
    LD1.wires=emptystr(0,2);
    LD1.pendingTerminal="";
    ld1_invalidate_measurement();
    if LD1.panel=="series" then LD1.savedSeriesWires=LD1.wires; else LD1.savedParallelWires=LD1.wires; end
    ld1_redraw_panel();
    ld1_set_status("Visi stendo laidai pašalinti.","info");
endfunction

function ld1_force_power_off()
    global LD1;
    LD1.powerOn=%f;
    LD1.ui.power.string="IŠJUNGTA";
    LD1.ui.power.backgroundcolor=[0.94 0.82 0.82];
    LD1.ui.sourceDisplay.string="0 V DC";
    ld1_invalidate_measurement();
endfunction

function tf = ld1_id_in_list(id, ids)
    tf=~isempty(find(ids==id));
endfunction

function ld1_remove_wires_touching(ids)
    global LD1;
    if size(LD1.wires,1)==0 then return; end
    keep=[];
    for k=1:size(LD1.wires,1)
        a=LD1.wires(k,1); b=LD1.wires(k,2);
        if ~ld1_id_in_list(a,ids) & ~ld1_id_in_list(b,ids) then
            keep($+1)=k;
        end
    end
    if isempty(keep) then LD1.wires=emptystr(0,2); else LD1.wires=LD1.wires(keep,:); end
endfunction

function ld1_remove_direct_source_to_A()
    global LD1;
    anodes=["NODE_A1";"NODE_A2";"NODE_A3";"NODE_A4"];
    LD1.kclTargetA="";
    if size(LD1.wires,1)>0 then
        keep=[];
        for k=1:size(LD1.wires,1)
            a=LD1.wires(k,1); b=LD1.wires(k,2);
            direct=(a=="SRC_P" & ld1_id_in_list(b,anodes)) | (b=="SRC_P" & ld1_id_in_list(a,anodes));
            if direct then
                if a=="SRC_P" then LD1.kclTargetA=b; else LD1.kclTargetA=a; end
            else
                keep($+1)=k;
            end
        end
        if isempty(keep) then LD1.wires=emptystr(0,2); else LD1.wires=LD1.wires(keep,:); end
    end
    if LD1.kclTargetA=="" then
        for k=1:size(anodes,"*")
            if ld1_terminal_wire_count(anodes(k))==0 then LD1.kclTargetA=anodes(k); break; end
        end
    end
    if LD1.kclTargetA=="" then LD1.kclTargetA="NODE_A1"; end
endfunction

function ld1_prepare_kcl_stage()
    global LD1;
    LD1.savedParallelVoltageWires=LD1.wires;
    LD1.savedParallelVoltageVR=LD1.VR1;

    ld1_force_power_off();
    ld1_remove_wires_touching(["M_P";"M_N"]);
    ld1_remove_direct_source_to_A();

    LD1.VR1=0;
    LD1.ui.vrSlider.value=0;
    LD1.ui.vrText.string="0 Ω";
    ld1_update_actual_values();

    LD1.meterMode="A";
    LD1.ui.modeA.value=1; LD1.ui.modeV.value=0;
    ld1_set_parallel_meter_layout(%t);
    LD1.pendingTerminal="";
    LD1.kclPrepared=%t;
    LD1.savedParallelWires=LD1.wires;
    ld1_redraw_panel();
endfunction

function ld1_restore_voltage_stage_wiring()
    global LD1;
    if size(LD1.savedParallelVoltageWires,1)>0 then LD1.wires=LD1.savedParallelVoltageWires; end
    LD1.VR1=LD1.savedParallelVoltageVR;
    LD1.ui.vrSlider.value=LD1.VR1;
    LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
    ld1_update_actual_values();
    LD1.meterMode="V";
    LD1.ui.modeA.value=0; LD1.ui.modeV.value=1;
    ld1_set_parallel_meter_layout(%f);
    LD1.powerOn=%f;
    LD1.ui.power.string="IŠJUNGTA";
    LD1.ui.power.backgroundcolor=[0.94 0.82 0.82];
    LD1.ui.sourceDisplay.string="0 V DC";
    LD1.lastMeasurement=%nan; LD1.lastMeasurementUnit=""; LD1.lastMeasurementStep=0;
    LD1.pendingTerminal="";
    LD1.savedParallelWires=LD1.wires;
    LD1.kclPrepared=%f;
    ld1_redraw_panel();
endfunction

function ld1_toggle_power()
    global LD1;
    LD1.powerOn=~LD1.powerOn;
    ld1_invalidate_measurement();
    if LD1.powerOn then
        LD1.ui.power.string="ĮJUNGTA";
        LD1.ui.power.backgroundcolor=[0.72 0.92 0.74];
        LD1.ui.sourceDisplay.string=string(LD1.cfg.E)+" V DC";
        ld1_set_status("Maitinimo šaltinis įjungtas: E = "+string(LD1.cfg.E)+" V. Naujam rodmeniui paspauskite MATUOTI.","ok");
    else
        LD1.ui.power.string="IŠJUNGTA";
        LD1.ui.power.backgroundcolor=[0.94 0.82 0.82];
        LD1.ui.sourceDisplay.string="0 V DC";
        ld1_set_status("Maitinimo šaltinis išjungtas. Ankstesnis matavimo rodmuo panaikintas.","info");
    end
    ld1_redraw_panel();
endfunction
