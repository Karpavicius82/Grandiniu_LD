// ================================================================
// LD1 GUI v1.7
// Tikslas: aiški, didelė ir Scilab 2025.1 suderinama sąsaja.
// Sąmoningai nenaudojame Axes objekto stendo viduje: visas stendas
// sudarytas iš standartinių uicontrol elementų.
// ================================================================

function s = ld1_multiline(lines)
    // Patikimai rodo kelių eilučių tekstą Scilab 2025.1 uicontrol("text").
    if size(lines,"*")==0 then
        s="";
    else
        s=strcat(lines, ascii(10));
    end
endfunction

function label = ld1_terminal_label(id)
    select id
    case "SRC_P" then label="Maitinimo šaltinis +10 V";
    case "SRC_N" then label="Maitinimo šaltinis 0 V";
    case "R1_1" then label="R1 kairysis gnybtas";
    case "R1_2" then label="R1 dešinysis gnybtas";
    case "R2_1" then label="R2 viršutinis gnybtas";
    case "R2_2" then label="R2 apatinis gnybtas";
    case "R3_1" then label="R3 viršutinis gnybtas";
    case "R3_2" then label="R3 apatinis gnybtas";
    case "VR1_1" then label="VR1 viršutinis gnybtas";
    case "VR1_2" then label="VR1 apatinis gnybtas";
    case "M_P" then label="Multimetro + / mA gnybtas";
    case "M_N" then label="Multimetro COM gnybtas";
    case "NODE_A1" then label="Mazgas A – kontaktas A1 (bendras su A2–A4)";
    case "NODE_A2" then label="Mazgas A – kontaktas A2 (bendras su A1, A3, A4)";
    case "NODE_A3" then label="Mazgas A – kontaktas A3 (bendras su A1, A2, A4)";
    case "NODE_A4" then label="Mazgas A – kontaktas A4 (bendras su A1–A3)";
    case "NODE_B1" then label="Mazgas B – kontaktas B1 (bendras su B2–B4)";
    case "NODE_B2" then label="Mazgas B – kontaktas B2 (bendras su B1, B3, B4)";
    case "NODE_B3" then label="Mazgas B – kontaktas B3 (bendras su B1, B2, B4)";
    case "NODE_B4" then label="Mazgas B – kontaktas B4 (bendras su B1–B3)";
    else label=id;
    end
endfunction

function txt = ld1_terminal_button_text(id)
    select id
    case "SRC_P" then txt="+";
    case "SRC_N" then txt="-";
    case "R1_1" then txt="1";
    case "R1_2" then txt="2";
    case "R2_1" then txt="1";
    case "R2_2" then txt="2";
    case "R3_1" then txt="1";
    case "R3_2" then txt="2";
    case "VR1_1" then txt="1";
    case "VR1_2" then txt="2";
    case "M_P" then txt="+";
    case "M_N" then txt="COM";
    case "NODE_A1" then txt="A1";
    case "NODE_A2" then txt="A2";
    case "NODE_A3" then txt="A3";
    case "NODE_A4" then txt="A4";
    case "NODE_B1" then txt="B1";
    case "NODE_B2" then txt="B2";
    case "NODE_B3" then txt="B3";
    case "NODE_B4" then txt="B4";
    else txt="•";
    end
endfunction

function ld1_set_xy(id,x,y)
    global LD1;
    i=ld1_term_index(id);
    if i>0 then LD1.term.xy(i,:)=[x y]; end
endfunction

function ld1_clear_board_controls()
    global LD1;
    if isfield(LD1.ui,"boardHandles") then
        for k=1:length(LD1.ui.boardHandles)
            try
                delete(LD1.ui.boardHandles(k));
            catch
            end
        end
    end
    LD1.ui.boardHandles=list();
    LD1.term.handles=list();
    LD1.term.handleIds=emptystr(0,1);
endfunction

function ld1_track_board_handle(h)
    global LD1;
    LD1.ui.boardHandles($+1)=h;
endfunction

function h = ld1_board_text(pos,txt,fs,bold,align,bg,fg)
    global LD1;
    if argn(2)<3 then fs=12; end
    if argn(2)<4 then bold=%f; end
    if argn(2)<5 then align="left"; end
    if argn(2)<6 then bg=[1 1 1]; end
    if argn(2)<7 then fg=[0.08 0.10 0.13]; end
    h=uicontrol(LD1.ui.circuitFrame,"style","text","units","normalized", ..
        "position",pos,"string",txt,"fontsize",fs, ..
        "horizontalalignment",align,"verticalalignment","middle", ..
        "backgroundcolor",bg,"foregroundcolor",fg);
    if bold then h.fontweight="bold"; end
    ld1_track_board_handle(h);
endfunction

function h = ld1_board_box(pos,title,subtitle,bg)
    global LD1;
    if argn(2)<4 then bg=[0.95 0.97 0.99]; end
    h=uicontrol(LD1.ui.circuitFrame,"style","frame","units","normalized", ..
        "position",pos,"backgroundcolor",bg,"relief","groove");
    tx=uicontrol(h,"style","text","units","normalized", ..
        "position",[0.05 0.54 0.90 0.34],"string",title, ..
        "fontsize",12,"fontweight","bold","horizontalalignment","center", ..
        "backgroundcolor",bg,"foregroundcolor",[0.08 0.12 0.18]);
    st=uicontrol(h,"style","text","units","normalized", ..
        "position",[0.05 0.13 0.90 0.29],"string",subtitle, ..
        "fontsize",10,"horizontalalignment","center", ..
        "backgroundcolor",bg,"foregroundcolor",[0.16 0.20 0.25]);
    ld1_track_board_handle(h);
endfunction

function h = ld1_board_segment(x1,y1,x2,y2,color)
    // Plonas stačiakampis naudojamas kaip laido atkarpa.
    global LD1;
    t=0.006;
    if abs(y2-y1) < 0.001 then
        x=min(x1,x2); w=max(abs(x2-x1),0.002);
        pos=[x y1-t/2 w t];
    else
        y=min(y1,y2); hh=max(abs(y2-y1),0.002);
        pos=[x1-t/2 y t hh];
    end
    h=uicontrol(LD1.ui.circuitFrame,"style","text","units","normalized", ..
        "position",pos,"string","","backgroundcolor",color);
    ld1_track_board_handle(h);
endfunction

function ld1_draw_wire(p1,p2,color)
    // Ortagonalus 3 atkarpų laidas. Koordinatės normalized 0..1.
    x1=p1(1); y1=p1(2); x2=p2(1); y2=p2(2);
    xm=(x1+x2)/2;
    ld1_board_segment(x1,y1,xm,y1,color);
    ld1_board_segment(xm,y1,xm,y2,color);
    ld1_board_segment(xm,y2,x2,y2,color);
endfunction

function tf = ld1_terminal_should_show(id)
    global LD1;
    tf=%f;
    if isfield(LD1,"demoMode") & LD1.demoMode then return; end
    if LD1.panel=="series" then
        tf=(LD1.step==1);
    else
        if LD1.step==5 then
            tf=%t;
        elseif LD1.step==8 then
            tf=(id=="SRC_P" | id=="M_P" | id=="M_N" | id==LD1.kclTargetA);
        else
            tf=%f;
        end
    end
endfunction

function ld1_create_locked_terminal(id)
    global LD1;
    xy=ld1_get_xy(id);
    if isnan(xy(1)) then return; end
    x=xy(1)/100; y=xy(2)/100;
    w=0.014; h=0.020;
    if id=="M_N" then w=0.020; end
    ht=uicontrol(LD1.ui.circuitFrame,"style","text","units","normalized", ..
        "position",[x-w/2 y-h/2 w h],"string","", ..
        "backgroundcolor",[0.55 0.60 0.66],"foregroundcolor",[1 1 1]);
    ld1_track_board_handle(ht);
endfunction

function ld1_create_terminal(id)
    global LD1;
    xy=ld1_get_xy(id);
    if isnan(xy(1)) then return; end
    x=xy(1)/100; y=xy(2)/100;
    w=0.028; h=0.036;
    if id=="M_N" then w=0.048; end
    pos=[x-w/2 y-h/2 w h];
    cb="ld1_terminal_click("""+id+""")";

    if LD1.step==8 & (id=="SRC_P" | id=="M_P") then
        bg=[0.95 0.55 0.15]; fg=[0.08 0.08 0.08];
    elseif LD1.step==8 & (id=="M_N" | id==LD1.kclTargetA) then
        bg=[0.58 0.38 0.78]; fg=[1 1 1];
    elseif LD1.pendingTerminal==id then
        bg=[1.00 0.82 0.28]; fg=[0.08 0.08 0.08];
    else
        bg=[0.20 0.48 0.78]; fg=[1 1 1];
    end

    ht=uicontrol(LD1.ui.circuitFrame,"style","pushbutton","units","normalized", ..
        "position",pos,"string",ld1_terminal_button_text(id), ..
        "fontsize",9,"fontweight","bold","backgroundcolor",bg, ..
        "foregroundcolor",fg,"tooltipstring",ld1_terminal_label(id), ..
        "callback",cb);
    LD1.term.handles($+1)=ht;
    LD1.term.handleIds($+1,1)=id;
    ld1_track_board_handle(ht);
endfunction

function ld1_draw_connection_count()
    global LD1;
    n=size(LD1.wires,1);
    if n==0 then
        txt="Prijungtų laidų: 0";
    elseif n==1 then
        txt="Prijungtų laidų: 1";
    else
        txt="Prijungtų laidų: "+string(n);
    end
    ld1_board_text([0.73 0.905 0.24 0.05],txt,11,%t,"right",[1 1 1],[0.16 0.25 0.35]);
endfunction
