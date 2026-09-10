function ld1_vr_changed()
    global LD1;
    v=LD1.ui.vrSlider.value;
    v=round(v/LD1.cfg.VR1_step)*LD1.cfg.VR1_step;
    v=max(LD1.cfg.VR1_min,min(LD1.cfg.VR1_max,v));
    LD1.VR1=v;
    LD1.ui.vrSlider.value=v;
    LD1.ui.vrText.string=string(v)+" Ω";
    ld1_update_actual_values();
    ld1_invalidate_measurement();
    ld1_redraw_panel();
    ld1_set_status("VR1 nustatyta į "+string(v)+" Ω. Ankstesnis multimetro rodmuo panaikintas.","info");
endfunction

function ld1_set_vr(v)
    global LD1;
    LD1.ui.vrSlider.value=v;
    ld1_vr_changed();
endfunction

function ld1_meter_mode(mode)
    global LD1;
    LD1.meterMode=mode;
    if mode=="A" then
        LD1.ui.modeA.value=1; LD1.ui.modeV.value=0;
    else
        LD1.ui.modeA.value=0; LD1.ui.modeV.value=1;
    end
    ld1_invalidate_measurement();
    ld1_redraw_panel();
    ld1_set_status("Multimetro režimas: "+mode+". Rodmuo bus rodomas tik prijungus abu gnybtus ir paspaudus MATUOTI.","info");
endfunction

function ld1_measure()
    global LD1;
    if LD1.step==3 | LD1.step==4 then
        [wok,wmsg,wfix]=ld1_validate_series_topology();
        if ~wok then ld1_invalidate_measurement(); LD1.ui.meterDisplay.string="KLAIDA"; ld1_set_status(wmsg,"error",wfix); return; end
    elseif LD1.step==6 | LD1.step==7 then
        [wok,wmsg,wfix]=ld1_validate_parallel_voltage_topology();
        if ~wok then ld1_invalidate_measurement(); LD1.ui.meterDisplay.string="KLAIDA"; ld1_set_status(wmsg,"error",wfix); return; end
    elseif LD1.step==8 then
        [wok,wmsg,wfix]=ld1_validate_parallel_total_current_topology();
        if ~wok then ld1_invalidate_measurement(); LD1.ui.meterDisplay.string="KLAIDA"; ld1_set_status(wmsg,"error",wfix); return; end
    end

    if ld1_terminal_wire_count("M_P")==0 | ld1_terminal_wire_count("M_N")==0 then
        ld1_invalidate_measurement();
        LD1.ui.meterDisplay.string="NEPRIJUNGTA";
        ld1_redraw_panel();
        ld1_set_status("Multimetras nematuoja, nes neprijungti abu jo gnybtai.","error",ld1_current_connection_fix());
        return;
    end
    [v,u,ok,msg]=ld1_meter_read();
    if ~ok then
        ld1_invalidate_measurement();
        LD1.ui.meterDisplay.string="KLAIDA";
        ld1_redraw_panel();
        ld1_set_status(msg,"error",ld1_current_connection_fix());
        return;
    end
    LD1.lastMeasurement=v;
    LD1.lastMeasurementUnit=u;
    LD1.lastMeasurementStep=LD1.step;
    LD1.stepMeas(LD1.step)=v;
    LD1.stepMeasUnit(LD1.step)=u;
    LD1.ui.meterDisplay.string=ld1_num(v,3)+" "+u;
    ld1_redraw_panel();
    ld1_set_status(msg+" Rodmuo: "+ld1_num(v,3)+" "+u+".","ok","Rodmuo užfiksuotas šiame etape. Galite tęsti skaičiavimus arba paspausti PATIKRINTI IR UŽFIKSUOTI ETAPĄ.");
endfunction

function tf = ld1_graph_connected(adj)
    n=size(adj,1);
    if n==0 then tf=%f; return; end
    seen=zeros(1,n)==1;
    q=1; seen(1)=%t; qh=1;
    while qh<=size(q,"*")
        a=q(qh); qh=qh+1;
        nb=find(adj(a,:)>0);
        for kk=1:size(nb,"*")
            b=nb(kk);
            if ~seen(b) then seen(b)=%t; q($+1)=b; end
        end
    end
    tf=and(seen);
endfunction

function [ok,msg,fix] = ld1_validate_series_topology()
    global LD1;
    ok=%f; msg=""; fix="Išjunkite maitinimą ir junkite tiksliai: +→R1(1), R1(2)→VR1(1), VR1(2)→+/mA, COM→−.";
    if LD1.meterMode<>"A" then msg="Srovės matavimui pasirinktas neteisingas multimetro režimas."; fix="Pasirinkite A (DC). Tada palikite ampermetrą nuoseklioje kilpoje."; return; end
    if size(LD1.wires,1)<>4 then
        msg="Nuosekliai grandinei turi būti tiksliai 4 laidai; dabar yra "+string(size(LD1.wires,1))+".";
        fix="Išjunkite maitinimą. Naudokite 4 jungtis: +→R1(1); R1(2)→VR1(1); VR1(2)→+/mA; COM→−. Patogiausia: IŠVALYTI LAIDUS ir KAIP SUJUNGTI."; return;
    end
    [parent,roots]=ld1_wire_roots();
    ids=["SRC_P";"SRC_N";"R1_1";"R1_2";"VR1_1";"VR1_2";"M_P";"M_N"];
    rr=zeros(1,size(ids,"*"));
    for k=1:size(ids,"*") rr(k)=roots(ld1_term_index(ids(k))); end
    u=unique(rr);
    if size(u,"*")<>4 then
        msg="Nuosekli grandinė nesudaro keturių teisingų elektrinių mazgų."; return;
    end
    ep=[roots(ld1_term_index("SRC_P")) roots(ld1_term_index("SRC_N")); ..
        roots(ld1_term_index("R1_1")) roots(ld1_term_index("R1_2")); ..
        roots(ld1_term_index("VR1_1")) roots(ld1_term_index("VR1_2")); ..
        roots(ld1_term_index("M_P")) roots(ld1_term_index("M_N"))];
    deg=zeros(1,4); adj=zeros(4,4);
    for k=1:4
        if ep(k,1)==ep(k,2) then msg="Vienas elementas užtrumpintas laidu."; fix="IŠVALYTI LAIDUS ir sujunkite pagal KAIP SUJUNGTI. Nė vieno elemento gnybtų nejunkite tiesiogiai tarpusavyje."; return; end
        a=find(u==ep(k,1)); b=find(u==ep(k,2)); a=a(1); b=b(1);
        deg(a)=deg(a)+1; deg(b)=deg(b)+1; adj(a,b)=1; adj(b,a)=1;
    end
    if ~and(deg==2) | ~ld1_graph_connected(adj) then
        msg="R1, VR1, ampermetras ir šaltinis nesudaro vienos uždaros nuoseklios kilpos."; return;
    end
    ok=%t; msg="Nuosekli grandinė sujungta teisingai."; fix="";
endfunction

function tf = ld1_two_series_between(pair1,pair2,p,n)
    tf=%f;
    for a1=1:2
        a2=3-a1;
        for b1=1:2
            b2=3-b1;
            if pair1(a1)==p & pair1(a2)==pair2(b1) & pair2(b2)==n then tf=%t; return; end
            if pair1(a1)==n & pair1(a2)==pair2(b1) & pair2(b2)==p then tf=%t; return; end
        end
    end
endfunction

function tf = ld1_parallel_resistor_core(roots,p,n)
    r3=ld1_endpoint_root_set("R3_1","R3_2",roots);
    r2=ld1_endpoint_root_set("R2_1","R2_2",roots);
    vr=ld1_endpoint_root_set("VR1_1","VR1_2",roots);
    tf=ld1_unordered_pair_equal(r3,[p n]) & ld1_two_series_between(r2,vr,p,n);
endfunction

function [ok,msg,fix] = ld1_validate_parallel_voltage_topology()
    global LD1;
    ok=%f; msg="";
    fix="Išjunkite maitinimą. +→A1, −→B1; A2→R3(1), R3(2)→B2; A3→R2(1), R2(2)→VR1(1), VR1(2)→B3; V+→A4, COM→B4.";
    if LD1.meterMode<>"V" then msg="UAB matavimui pasirinktas neteisingas multimetro režimas."; fix="Pasirinkite V (DC). Voltmetro + turi būti A mazge, COM – B mazge."; return; end
    if size(LD1.wires,1)<>9 then
        msg="5–7 etapų lygiagrečiai schemai turi būti 9 laidai; dabar yra "+string(size(LD1.wires,1))+".";
        fix="Spauskite KAIP SUJUNGTI ir patikrinkite 9 jungtis. Jei tai ne 5 etapas, greičiausia išeitis – ATKURTI ETAPO STENDĄ."; return;
    end
    [parent,roots]=ld1_wire_roots();
    p=roots(ld1_term_index("SRC_P")); n=roots(ld1_term_index("SRC_N"));
    if p==n then msg="Maitinimo šaltinis užtrumpintas."; fix="Išjunkite maitinimą, pašalinkite laidą tarp A ir B / šaltinio + ir −, tada spauskite KAIP SUJUNGTI."; return; end
    if ~ld1_parallel_resistor_core(roots,p,n) then
        msg="Lygiagrečios šakos sujungtos neteisingai."; return;
    end
    mp=ld1_endpoint_root_set("M_P","M_N",roots);
    if ~ld1_unordered_pair_equal(mp,[p n]) then
        msg="Voltmetras neprijungtas tarp tų pačių A ir B mazgų."; fix="Voltmetro +/V junkite į A4, COM – į B4. Kitų šakų nekeiskite."; return;
    end
    ok=%t; msg="Lygiagreti grandinė ir voltmetras sujungti teisingai."; fix="";
endfunction
