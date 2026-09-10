function lines = ld2_summary_lines_for_step(step)
    global LD2;
    select step
    case 1 then
        rr = ld2_resonance_values(LD2.cfg.R13,LD2.cfg.L3,LD2.cfg.C4);
        lines = [ ...
          msprintf("RC: E=%.1f V, f=%.1f Hz, R8=%.0f Ω, C2=%.3f µF", ...
              LD2.cfg.E_RC,LD2.cfg.F_RC,LD2.cfg.R8,LD2.cfg.C2*1e6); ...
          msprintf("RL: E=%.1f V, f=%.1f Hz, R9=%.0f Ω, L1=%.3f H", ...
              LD2.cfg.E_RL,LD2.cfg.F_RL,LD2.cfg.R9,LD2.cfg.L1); ...
          msprintf("RLC: E=%.1f V, R13=%.0f Ω, L3=%.3f mH, C4=%.3f nF", ...
              LD2.cfg.E_RLC,LD2.cfg.R13,LD2.cfg.L3*1e3,LD2.cfg.C4*1e9); ...
          msprintf("Pagal šiuos parametrus fr=%.2f Hz.", rr.F0); ...
          "Priskirti dydžiai nekinta: kitas variantas tik [B01]."];
    case 2 then
        [ok,missing]=ld2_validate_main("RC");
        lines = [msprintf("Prijungta laidų: %d iš 4.", size(LD2.state.rc_connections,1)); ...
                 "Mėlyni lizdai – pagrindinė grandinė."; ...
                 "Žali lizdai – jau teisingai prijungti."; ...
                 "Grandinės būsena: " + ld2_bool_text(ok)];
    case 4 then
        lines = [ ...
          "A~: " + ld2_value_or_dash(LD2.state.rc_I*1000,"mA"); ...
          "UR8: " + ld2_value_or_dash(LD2.state.rc_UR,"V"); ...
          "UC2: " + ld2_value_or_dash(LD2.state.rc_UC,"V"); ...
          "Ušaltinio: " + ld2_value_or_dash(LD2.state.rc_UE,"V")];
    case 5 then
        [ok,missing]=ld2_validate_main("RL");
        lines = [msprintf("Prijungta laidų: %d iš 4.", size(LD2.state.rl_connections,1)); ...
                 "Mėlyni lizdai – pagrindinė grandinė."; ...
                 "Žali lizdai – jau teisingai prijungti."; ...
                 "Grandinės būsena: " + ld2_bool_text(ok)];
    case 7 then
        lines = [ ...
          "A~: " + ld2_value_or_dash(LD2.state.rl_I*1000,"mA"); ...
          "UR9: " + ld2_value_or_dash(LD2.state.rl_UR,"V"); ...
          "UL1: " + ld2_value_or_dash(LD2.state.rl_UL,"V"); ...
          "Ušaltinio: " + ld2_value_or_dash(LD2.state.rl_UE,"V")];
    case 8 then
        [ok,missing]=ld2_validate_main("RLC");
        lines = [msprintf("Prijungta laidų: %d iš 5.", size(LD2.state.rlc_connections,1)); ...
                 "Grandinė: generatorius–A~–C4–L3–R13–grįžimas."; ...
                 "Grandinės būsena: " + ld2_bool_text(ok)];
    case 12 then
        rcok = ~isnan(LD2.state.rc_I) & ~isnan(LD2.state.rc_UR) & ~isnan(LD2.state.rc_UC);
        rlok = ~isnan(LD2.state.rl_I) & ~isnan(LD2.state.rl_UR) & ~isnan(LD2.state.rl_UL);
        rok = size(LD2.state.sweep_f,"*") > 0;
        lines = [ ...
          "RC matavimai: " + ld2_bool_text(rcok); ...
          "RL matavimai: " + ld2_bool_text(rlok); ...
          "RLC rezonanso taškai: " + string(size(LD2.state.res_f,"*")); ...
          "0–10 kHz skenavimas: " + ld2_bool_text(rok); ...
          "GRAFIKAS rodo lentelę; ŽURNALAS – matavimų kilmę."];
    else
        lines = ["Šiame etape atsakymų laukai rodomi aukščiau."; ...
                 "PAVYZDYS nepakeičia jūsų darbo."];
    end
endfunction

function s = ld2_bool_text(v)
    if v then s="ATLIKTA / TEISINGA"; else s="NEATLIKTA"; end
endfunction

function txt = ld2_amp_display_text()
    global LD2;
    phase = ld2_phase_for_step(LD2.state.step);
    [ok,missing] = ld2_validate_main(phase);
    if ~ok then txt="NEPRIJUNGTA"; return; end
    if ~LD2.state.power then txt="PARUOŠTA"; return; end
    x=LD2.state.amp_live;
    if isnan(x) then txt="PARUOŠTA"; else txt=ld2_num(x*1000,3)+" mA"; end
endfunction

function txt = ld2_volt_display_text()
    global LD2;
    phase = ld2_phase_for_step(LD2.state.step);
    target = ld2_detect_voltage_target(phase);
    if target == "" then txt="NEPRIJUNGTA"; return; end
    if ~LD2.state.power then txt="PARUOŠTA"; return; end
    x=LD2.state.volt_live;
    if LD2.state.volt_live_target<>target then x=%nan; end
    if isnan(x) then txt="PARUOŠTA"; else txt=ld2_num(x,3)+" V"; end
endfunction

function ld2_update_nav_colors()
    global LD2;
    for k=1:12
        b=LD2.ui.step_buttons(k);
        if k==LD2.state.step then
            b.backgroundcolor=[0.25 0.52 0.82];
            b.foregroundcolor=[1 1 1];
        elseif LD2.state.completed(k)==1 then
            b.backgroundcolor=[0.72 0.93 0.74];
            b.foregroundcolor=[0.05 0.25 0.08];
        elseif LD2.state.skipped(k)==1 then
            b.backgroundcolor=[1.00 0.92 0.62];
            b.foregroundcolor=[0.40 0.24 0.00];
        else
            b.backgroundcolor=[0.94 0.94 0.94];
            b.foregroundcolor=[0.05 0.05 0.05];
        end
    end
    LD2.ui.teacher.value = ld2_bool_num(LD2.state.teacher_mode);
endfunction

function n = ld2_bool_num(v)
    if v then n=1; else n=0; end
endfunction

function ld2_render_stand()
    global LD2;
    p=LD2.ui.stand; k=LD2.state.step; phase=ld2_phase_for_step(k);
    board=ld2_frame(p,[0.01 0.235 0.98 0.505],[1 1 1]);
    if phase=="OVERVIEW" then ld2_draw_overview(board);
    else
        c=ld2_get_phase_connections(phase); active=ld2_active_terminals(k);
        ld2_draw_board(board,phase,active,c);
    end
    ld2_render_stand_tools(p);
    if k==2 | k==5 | k==8 then rows=ld2_connection_list_text(ld2_required_main(phase));
    elseif k==1 then rows=["B01 – priskirti variantą; B02 – visa metodika; B03 – atliktas pavyzdys.";"B05 – išsaugoti tęsiamą darbą; B07 – išsaugoti ataskaitą."];
    else rows=ld2_history_lines(k); end
    if LD2.example_active then title="PAVYZDŽIO DUOMENYS (ne studento matavimai)";
    else title="JUNGIMAI / UŽFIKSUOTI DUOMENYS (slenkamas sąrašas)"; end
    ld2_text(p,[0.025 0.164 0.95 0.028],title,11,%t,"left",[1 1 1],[.06 .20 .34]);
    h=uicontrol(p,"style","listbox","units","normalized","position",[0.025 0.024 0.95 0.134], ...
        "string",ld2_wrap_lines(rows,104),"fontname","Arial","fontunits","pixels","fontsize",12, ...
        "backgroundcolor",[.965 .985 1]);
    ld2_track(h);
endfunction

function ld2_draw_overview(parent)
    global LD2;
    ld2_text(parent,[0.03 0.90 0.94 0.06], ...
        "LD2 STRUKTŪRA: RC → RL → NUOSEKLUS RLC REZONANSAS", ...
        14,%t,"left",[1 1 1],[0.05 0.18 0.32]);
    ld2_component_card(parent,[0.05 0.29 0.26 0.56],"I DALIS","NUOSEKLI RC", ...
        ["XC=1/(2πfC)"; "Z=R−jXC"; "I pirmauja U"],[0.91 0.95 1.00]);
    ld2_component_card(parent,[0.37 0.29 0.26 0.56],"II DALIS","NUOSEKLI RL", ...
        ["XL=2πfL"; "Z=R+jXL"; "I atsilieka nuo U"],[0.94 0.97 0.91]);
    ld2_component_card(parent,[0.69 0.29 0.26 0.56],"III DALIS","RLC REZONANSAS", ...
        ["XL=XC"; "fr=1/(2π√LC)"; "I ir UR – maksimumas"],[1.00 0.96 0.88]);
    ld2_text(parent,[0.035 0.14 0.93 0.09], ...
        "Svarbu: šaltinio ir elementų įtampos AC grandinėse sudedamos kaip fazoriai.", ...
        12,%t,"center",[1 1 1],[0.38 0.16 0.03]);
    ld2_text(parent,[0.035 0.035 0.93 0.075], ...
        "IŠSAUGOTI išlaiko darbą kitam kartui. PAVYZDYS nekeičia jūsų rezultatų.", ...
        10,%f,"center",[1 1 1],[0.12 0.12 0.12]);
endfunction

function ld2_component_card(parent,pos,head,name,lines,bg)
    fr=ld2_frame(parent,pos,bg);
    ld2_text(fr,[0.05 0.78 0.90 0.14],head,10,%t,"center",bg,[0.12 0.25 0.38]);
    ld2_text(fr,[0.05 0.58 0.90 0.16],name,14,%t,"center",bg,[0.03 0.10 0.18]);
    y=0.38;
    for k=1:size(lines,"*")
        ld2_text(fr,[0.06 y 0.88 0.12],lines(k),10,%f,"center",bg,[0.08 0.08 0.08]);
        y=y-0.14;
    end
endfunction
