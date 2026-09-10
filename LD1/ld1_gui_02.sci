function txt = ld1_meter_board_status()
    global LD1;
    txt=LD1.meterMode+" (DC)";
    if ~isnan(LD1.lastMeasurement) then
        txt=txt+"  •  "+ld1_num(LD1.lastMeasurement,3)+" "+LD1.lastMeasurementUnit;
    else
        if ld1_terminal_wire_count("M_P")>0 & ld1_terminal_wire_count("M_N")>0 then
            txt=txt+"  •  PARUOŠTA";
        else
            txt=txt+"  •  NEPRIJUNGTA";
        end
    end
endfunction

function ld1_draw_series_board()
    global LD1;
    state="IŠJUNGTAS";
    if LD1.powerOn then state="ĮJUNGTAS"; end

    ld1_board_text([0.03 0.915 0.50 0.045], ..
        "NUOSEKLI GRANDINĖ", ..
        12,%t,"left",[1 1 1],[0.10 0.23 0.38]);
    if isfield(LD1,"demoMode") & LD1.demoMode then
        ld1_board_text([0.30 0.915 0.42 0.045],"PAVYZDINIS SPRENDIMAS – TIK PERŽIŪRAI",10,%t,"center",[1.00 0.96 0.78],[0.50 0.28 0.00]);
    end
    ld1_draw_connection_count();

    ld1_board_box([0.055 0.435 0.125 0.155],"DC ŠALTINIS","10 V • "+state,[0.94 0.97 1.00]);
    ld1_board_box([0.385 0.645 0.145 0.095],"R1",string(LD1.cfg.R1)+" Ω",[0.98 0.96 0.88]);
    ld1_board_box([0.705 0.455 0.11 0.145],"VR1",string(LD1.VR1)+" Ω",[0.98 0.96 0.88]);
    ld1_board_box([0.415 0.215 0.17 0.11],"MULTIMETRAS",ld1_meter_board_status(),[0.91 0.96 0.92]);
endfunction

function ld1_draw_parallel_board()
    global LD1;
    state="IŠJUNGTAS";
    if LD1.powerOn then state="ĮJUNGTAS"; end

    ld1_board_text([0.03 0.915 0.42 0.045], ..
        "LYGIAGRETI GRANDINĖ", ..
        12,%t,"left",[1 1 1],[0.10 0.23 0.38]);
    if isfield(LD1,"demoMode") & LD1.demoMode then
        ld1_board_text([0.32 0.915 0.40 0.045],"PAVYZDINIS SPRENDIMAS – TIK PERŽIŪRAI",10,%t,"center",[1.00 0.96 0.78],[0.50 0.28 0.00]);
    end
    ld1_draw_connection_count();

    busColor=[0.18 0.35 0.55];
    ld1_board_segment(0.24,0.78,0.90,0.78,busColor);
    ld1_board_segment(0.24,0.22,0.90,0.22,busColor);
    ld1_board_text([0.24 0.825 0.66 0.038],"MAZGAS A (A1–A4 bendri)",10,%t,"center",[1 1 1],[0.12 0.25 0.40]);
    ld1_board_text([0.24 0.145 0.66 0.038],"MAZGAS B (B1–B4 bendri)",10,%t,"center",[1 1 1],[0.12 0.25 0.40]);

    ld1_board_box([0.04 0.415 0.095 0.145],"DC ŠALTINIS","10 V • "+state,[0.94 0.97 1.00]);
    ld1_board_box([0.410 0.445 0.082 0.115],"R3",string(LD1.cfg.R3)+" Ω",[0.98 0.96 0.88]);
    ld1_board_text([0.405 0.57 0.095 0.027],"ŠAKA 1",9,%t,"center",[1 1 1],[0.28 0.31 0.34]);
    ld1_board_box([0.600 0.605 0.090 0.075],"R2",string(LD1.cfg.R2)+" Ω",[0.98 0.96 0.88]);
    ld1_board_box([0.600 0.365 0.090 0.095],"VR1",string(LD1.VR1)+" Ω",[0.98 0.96 0.88]);
    ld1_board_text([0.575 0.695 0.14 0.030],"ŠAKA 2: R2 + VR1",9,%t,"center",[1 1 1],[0.28 0.31 0.34]);

    if LD1.step==8 then
        ld1_board_box([0.215 0.605 0.085 0.070],"A",ld1_meter_board_status(),[0.91 0.96 0.92]);
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
    else
        ld1_board_box([0.795 0.42 0.12 0.14],"V",ld1_meter_board_status(),[0.91 0.96 0.92]);
    end
endfunction

function ld1_set_parallel_meter_layout(forCurrent)
    if forCurrent then
        ld1_set_xy("M_P",20.0,64.0);
        ld1_set_xy("M_N",31.5,64.0);
    else
        ld1_set_xy("M_P",79.0,60.0);
        ld1_set_xy("M_N",92.0,40.0);
    end
endfunction

function ld1_redraw_panel()
    global LD1;
    ld1_clear_board_controls();

    pal=[0.12 0.40 0.78; ..
         0.80 0.24 0.20; ..
         0.15 0.58 0.30; ..
         0.78 0.48 0.12; ..
         0.48 0.32 0.72; ..
         0.20 0.60 0.65];
    if size(LD1.wires,1)>0 then
        for k=1:size(LD1.wires,1)
            a=LD1.wires(k,1); b=LD1.wires(k,2);
            if ld1_is_active_term(a) & ld1_is_active_term(b) then
                p1=ld1_get_xy(a)/100; p2=ld1_get_xy(b)/100;
                ci=modulo(k-1,size(pal,1))+1;
                ld1_draw_wire(p1,p2,pal(ci,:));
            end
        end
    end

    if LD1.panel=="series" then
        ld1_draw_series_board();
    else
        ld1_draw_parallel_board();
    end

    for k=1:size(LD1.term.active,"*")
        if ld1_terminal_should_show(LD1.term.active(k)) then
            ld1_create_terminal(LD1.term.active(k));
        else
            ld1_create_locked_terminal(LD1.term.active(k));
        end
    end
endfunction

function ld1_build_panel(kind)
    global LD1;
    LD1.panel=kind;
    LD1.pendingTerminal="";
    LD1.wires=emptystr(0,2);
    LD1.term.xy=%nan*ones(size(LD1.term.ids,"*"),2);

    if kind=="series" then
        LD1.term.active=["SRC_P";"SRC_N";"R1_1";"R1_2";"VR1_1";"VR1_2";"M_P";"M_N"];
        ld1_set_xy("SRC_P",20.5,58); ld1_set_xy("SRC_N",20.5,46);
        ld1_set_xy("R1_1",35.0,69.5); ld1_set_xy("R1_2",56.0,69.5);
        ld1_set_xy("VR1_1",75.5,63.0); ld1_set_xy("VR1_2",75.5,42.0);
        ld1_set_xy("M_P",39.0,26.5); ld1_set_xy("M_N",61.0,26.5);
    else
        LD1.term.active=["SRC_P";"SRC_N"; ..
            "NODE_A1";"NODE_A2";"NODE_A3";"NODE_A4"; ..
            "NODE_B1";"NODE_B2";"NODE_B3";"NODE_B4"; ..
            "R2_1";"R2_2";"R3_1";"R3_2";"VR1_1";"VR1_2";"M_P";"M_N"];

        ld1_set_xy("SRC_P",15.5,58); ld1_set_xy("SRC_N",15.5,38);
        ld1_set_xy("NODE_A1",38,78); ld1_set_xy("NODE_A2",48,78);
        ld1_set_xy("NODE_A3",65,78); ld1_set_xy("NODE_A4",86,78);
        ld1_set_xy("NODE_B1",38,22); ld1_set_xy("NODE_B2",48,22);
        ld1_set_xy("NODE_B3",65,22); ld1_set_xy("NODE_B4",86,22);
        ld1_set_xy("R3_1",45.1,59); ld1_set_xy("R3_2",45.1,41);
        ld1_set_xy("R2_1",64.5,69.5); ld1_set_xy("R2_2",64.5,55.0);
        ld1_set_xy("VR1_1",64.5,49.0); ld1_set_xy("VR1_2",64.5,31);
        ld1_set_parallel_meter_layout(%f);
    end

    ld1_redraw_panel();
endfunction

function h = ld1_label(parent,pos,txt,fs,bold)
    if argn(2)<4 then fs=12; end
    if argn(2)<5 then bold=%f; end
    h=uicontrol(parent,"style","text","units","normalized","position",pos, ..
        "string",txt,"fontsize",fs,"horizontalalignment","left", ..
        "verticalalignment","middle","backgroundcolor",[0.97 0.97 0.97], ..
        "foregroundcolor",[0.08 0.10 0.13]);
    if bold then h.fontweight="bold"; end
endfunction

function ld1_set_instruction(title,lines)
    global LD1;
    LD1.ui.instructionTitle.string=title;
    n=size(lines,"*");
    for k=1:5
        if k<=n then
            LD1.ui.instructionLine(k).string=lines(k);
            ld1_show(LD1.ui.instructionLine(k),%t);
        else
            LD1.ui.instructionLine(k).string="";
            ld1_show(LD1.ui.instructionLine(k),%f);
        end
    end
endfunction
