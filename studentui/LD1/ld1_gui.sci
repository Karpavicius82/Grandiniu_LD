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
    // Kontekstinis stendas: rodome tik tuos lizdus, kuriuos studentui šiame etape reikia liesti.
    // Tai mažina vizualinę apkrovą ir apsaugo jau patikrintas jungtis nuo atsitiktinio sugadinimo.
    global LD1;
    tf=%f;
    if isfield(LD1,"demoMode") & LD1.demoMode then
        // Pavyzdžio režime stendas tik peržiūrimas: laidai ir komponentai matomi,
        // bet studentas negali netyčia pakeisti teisingo pavyzdžio.
        return;
    end
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
    // Mažas pilkas, nepaspaudžiamas lizdo žymuo. Jis išlaiko aiškų elektrinį
    // ryšį su laidu, bet nekonkuruoja su šiame etape aktyviais kontaktais.
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
    // v1.7: mažesni kontaktai, kad stende liktų daugiau erdvės ir mažėtų kolizijos.
    w=0.042; h=0.050;
    if id=="M_N" then w=0.060; end
    pos=[x-w/2 y-h/2 w h];
    cb="ld1_terminal_click("""+id+""")";

    // 8 etape dvi reikalingos poros pažymimos spalvomis.
    if LD1.step==8 & (id=="SRC_P" | id=="M_P") then
        bg=[0.95 0.55 0.15]; fg=[0.08 0.08 0.08];
    elseif LD1.step==8 & (id=="M_N" | id==LD1.kclTargetA) then
        bg=[0.58 0.38 0.78]; fg=[1 1 1];
    elseif LD1.pendingTerminal==id then
        bg=[1.00 0.82 0.28]; fg=[0.08 0.08 0.08];
    else
        bg=[0.08 0.39 0.37]; fg=[1 1 1];
    end

    ht=uicontrol(LD1.ui.circuitFrame,"style","pushbutton","units","normalized", ..
        "position",pos,"string",ld1_terminal_button_text(id), ..
        "fontsize",9,"fontweight","bold","backgroundcolor",bg, ..
        "foregroundcolor",fg,"margins",[0 0 0 0],"tooltipstring",ld1_terminal_label(id), ..
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

    // v1.7: komponentai sumažinti ~20 %, tekstas paliktas lengvai skaitomas.
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
    ld1_board_text([0.24 0.825 0.66 0.038], ..
        "MAZGAS A (A1–A4 bendri)", ..
        10,%t,"center",[1 1 1],[0.12 0.25 0.40]);
    ld1_board_text([0.24 0.145 0.66 0.038], ..
        "MAZGAS B (B1–B4 bendri)", ..
        10,%t,"center",[1 1 1],[0.12 0.25 0.40]);

    ld1_board_box([0.04 0.415 0.095 0.145],"DC ŠALTINIS","10 V • "+state,[0.94 0.97 1.00]);
    ld1_board_box([0.410 0.445 0.082 0.115],"R3",string(LD1.cfg.R3)+" Ω",[0.98 0.96 0.88]);
    ld1_board_text([0.405 0.57 0.095 0.027],"ŠAKA 1",9,%t,"center",[1 1 1],[0.28 0.31 0.34]);
    ld1_board_box([0.600 0.605 0.090 0.075],"R2",string(LD1.cfg.R2)+" Ω",[0.98 0.96 0.88]);
    ld1_board_box([0.600 0.365 0.090 0.095],"VR1",string(LD1.VR1)+" Ω",[0.98 0.96 0.88]);
    ld1_board_text([0.575 0.695 0.14 0.030],"ŠAKA 2: R2 + VR1",9,%t,"center",[1 1 1],[0.28 0.31 0.34]);

    if LD1.step==8 then
        // Kompaktiškas ampermetras bendrame + laide. Jis nebesikerta su šaltiniu ar A kontaktais.
        ld1_board_box([0.215 0.605 0.085 0.070],"A",ld1_meter_board_status(),[0.91 0.96 0.92]);
        targetA=ld1_terminal_button_text(LD1.kclTargetA);
    else
        ld1_board_box([0.795 0.42 0.12 0.14],"V",ld1_meter_board_status(),[0.91 0.96 0.92]);
    end
endfunction

function ld1_set_parallel_meter_layout(forCurrent)
    // V režime voltmetras dešinėje tarp A-B.
    // 8 etape kompaktiškas ampermetras yra bendrame + laide prieš mazgą A.
    if forCurrent then
        ld1_set_xy("M_P",20.0,64.0);
        ld1_set_xy("M_N",31.5,64.0);
    else
        ld1_set_xy("M_P",79.0,60.0);
        ld1_set_xy("M_N",92.0,40.0);
    end
endfunction

function ld1_redraw_panel_classic()
    global LD1;
    ld1_clear_board_controls();

    // Studentų laidai braižomi pirmi, kad komponentai ir gnybtai liktų virš jų.
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
                ld1_draw_wire(p1,p2,[0.22 0.40 0.42]);
            end
        end
    end

    if LD1.panel=="series" then
        ld1_draw_series_board();
    else
        ld1_draw_parallel_board();
    end

    // Gnybtai kuriami paskutiniai: jie visada aiškiai matomi ir paspaudžiami.
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
    // Scilab 2025.1 teksto valdiklis automatiškai nelaužo ilgų eilučių.
    // Todėl instrukcija rodoma atskiromis trumpomis eilutėmis.
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

function ld1_create_gui_classic()
    global LD1;
    f=figure("default_axes","off","dockable","off","menubar","none", ...
        "toolbar","none","visible","off","axes_size",[1280 800]);
    f.infobar_visible="off";
    f.figure_position=[75 75];
    f.figure_name=LD1.cfg.title+"  •  Scilab 2025.1";
    f.resize="on";
    LD1.fig=f;

    LD1.ui.header=uicontrol(f,"style","text","units","normalized", ..
        "position",[0.018 0.938 0.964 0.049],"string",LD1.cfg.title, ..
        "fontsize",19,"fontweight","bold","horizontalalignment","center", ..
        "backgroundcolor",[0.15 0.27 0.42],"foregroundcolor",[1 1 1]);

    // Viršutinė etapų juosta. Peržiūros režimas leidžia dėstytojui/testuotojui
    // pereiti tiesiai į bet kurį etapą jo neatliekant nuo pradžių.
    nav=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.891 0.964 0.039],"backgroundcolor",[0.87 0.91 0.96],"relief","flat");
    LD1.ui.navFrame=nav;
    LD1.ui.progress=uicontrol(nav,"style","text","units","normalized", ..
        "position",[0.01 0.10 0.14 0.80],"string","", ..
        "fontsize",10,"fontweight","bold","horizontalalignment","left", ..
        "backgroundcolor",[0.87 0.91 0.96],"foregroundcolor",[0.12 0.22 0.34]);
    LD1.ui.stepButtons=list();
    for k=1:9
        xx=0.155+(k-1)*0.050;
        LD1.ui.stepButtons(k)=uicontrol(nav,"style","pushbutton","units","normalized", ..
            "position",[xx 0.12 0.043 0.76],"string",string(k),"fontsize",9,"fontweight","bold", ..
            "callback","ld1_jump_step("+string(k)+")");
    end
    LD1.ui.review=uicontrol(nav,"style","checkbox","units","normalized", ..
        "position",[0.625 0.08 0.36 0.84],"string","DĖSTYTOJO / PERŽIŪROS REŽIMAS – laisva navigacija", ..
        "fontsize",9,"value",0,"backgroundcolor",[0.87 0.91 0.96],"callback","ld1_review_toggle()");

    // Kairė: kompaktiškesnis stendas. Dešinei instrukcijų sričiai skirta daugiau pločio.
    LD1.ui.circuitFrame=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.105 0.600 0.770],"backgroundcolor",[1 1 1],"relief","groove");
    LD1.ui.boardHandles=list();
    LD1.ui.resultsTable=uicontrol(LD1.ui.circuitFrame,"style","table","units","normalized", ..
        "position",[0.04 0.10 0.92 0.78], ..
        "string",["Bandymas" "Formulė / kilmė" "Skaičiuota" "Multimetro rodmuo" "Vertinimas"; emptystr(1,5)]);
    LD1.ui.resultsTable.visible="off";

    ctrl=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.632 0.105 0.350 0.770],"backgroundcolor",[0.97 0.97 0.97],"relief","groove");
    LD1.ui.ctrlFrame=ctrl;

    // 1) Instrukcija – 5 atskiros eilutės, kad Scilab 2025.1 jų neužklotų.
    inf=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.735 0.93 0.245],"backgroundcolor",[1 1 1],"relief","groove");
    LD1.ui.instructionFrame=inf;
    LD1.ui.instructionTitle=uicontrol(inf,"style","text","units","normalized", ..
        "position",[0.03 0.81 0.94 0.15],"string","", ..
        "fontsize",13,"fontweight","bold","horizontalalignment","left", ..
        "verticalalignment","middle","backgroundcolor",[1 1 1],"foregroundcolor",[0.07 0.12 0.18]);
    LD1.ui.instructionLine=list();
    iy=[0.65 0.51 0.37 0.23 0.09];
    for k=1:5
        LD1.ui.instructionLine(k)=uicontrol(inf,"style","text","units","normalized", ..
            "position",[0.03 iy(k) 0.94 0.125],"string","", ..
            "fontsize",10,"horizontalalignment","left","verticalalignment","middle", ..
            "backgroundcolor",[1 1 1],"foregroundcolor",[0.10 0.12 0.15]);
    end

    // 2) Stendo valdymas.
    sf=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.330 0.93 0.385],"backgroundcolor",[0.97 0.97 0.97],"relief","groove");
    LD1.ui.standFrame=sf;
    ld1_label(sf,[0.03 0.91 0.94 0.07],"STENDO VALDYMAS",13,%t);
    ld1_label(sf,[0.03 0.81 0.25 0.065],"Maitinimas:",10,%t);
    LD1.ui.sourceDisplay=ld1_label(sf,[0.30 0.81 0.28 0.065],"0 V DC",10,%f);
    LD1.ui.power=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.65 0.795 0.32 0.085],"string","IŠJUNGTA", ..
        "fontsize",10,"fontweight","bold","backgroundcolor",[0.94 0.82 0.82], ..
        "callback","ld1_toggle_power()");

    ld1_label(sf,[0.03 0.70 0.14 0.06],"VR1:",10,%t);
    LD1.ui.vrText=ld1_label(sf,[0.18 0.70 0.28 0.06],"1000 Ω",11,%t);
    LD1.ui.vrSlider=uicontrol(sf,"style","slider","units","normalized", ..
        "position",[0.03 0.625 0.94 0.055],"min",LD1.cfg.VR1_min, ..
        "max",LD1.cfg.VR1_max,"value",1000,"sliderstep",[LD1.cfg.VR1_step 100], ..
        "snaptoticks","on","callback","ld1_vr_changed()");
    LD1.ui.vr0=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.545 0.27 0.065],"string","0 Ω","fontsize",9,"callback","ld1_set_vr(0)");
    LD1.ui.vr500=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.365 0.545 0.27 0.065],"string","500 Ω","fontsize",9,"callback","ld1_set_vr(500)");
    LD1.ui.vr1000=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.70 0.545 0.27 0.065],"string","1 kΩ","fontsize",9,"callback","ld1_set_vr(1000)");

    ld1_label(sf,[0.03 0.455 0.25 0.06],"Multimetras:",10,%t);
    LD1.ui.modeA=uicontrol(sf,"style","radiobutton","units","normalized", ..
        "position",[0.28 0.452 0.24 0.065],"string","A (DC)","fontsize",10, ..
        "groupname","meter","value",1,"callback","ld1_meter_mode(""A"")");
    LD1.ui.modeV=uicontrol(sf,"style","radiobutton","units","normalized", ..
        "position",[0.56 0.452 0.24 0.065],"string","V (DC)","fontsize",10, ..
        "groupname","meter","value",0,"callback","ld1_meter_mode(""V"")");
    LD1.ui.meterDisplay=uicontrol(sf,"style","text","units","normalized", ..
        "position",[0.03 0.355 0.94 0.085],"string","NEPRIJUNGTA", ..
        "fontsize",14,"fontweight","bold","horizontalalignment","center", ..
        "backgroundcolor",[0.06 0.09 0.07],"foregroundcolor",[0.55 1.00 0.58]);

    LD1.ui.measure=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.265 0.45 0.070],"string","MATUOTI", ..
        "fontsize",10,"fontweight","bold","callback","ld1_measure()");
    LD1.ui.checkWiring=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.265 0.45 0.070],"string","PATIKRINTI SUJUNGIMĄ", ..
        "fontsize",9,"callback","ld1_check_wiring()");
    LD1.ui.undoWire=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.180 0.45 0.065],"string","ATŠAUKTI LAIDĄ", ..
        "fontsize",9,"callback","ld1_remove_last_wire()");
    LD1.ui.clearWires=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.180 0.45 0.065],"string","IŠVALYTI LAIDUS", ..
        "fontsize",9,"callback","ld1_clear_wires()");
    LD1.ui.wiringGuide=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.095 0.45 0.065],"string","KAIP SUJUNGTI", ..
        "fontsize",9,"fontweight","bold","callback","ld1_show_wiring_guide()");
    LD1.ui.restoreStage=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.095 0.45 0.065],"string","ATKURTI ETAPO STENDĄ", ..
        "fontsize",8,"fontweight","bold","callback","ld1_restore_current_stage_board()");

    // 3) Studentų atsakymai.
    af=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.105 0.93 0.205],"backgroundcolor",[0.98 0.98 0.98],"relief","groove");
    LD1.ui.answerFrame=af;
    ld1_label(af,[0.03 0.84 0.94 0.13],"JŪSŲ ATSAKYMAS",12,%t);
    LD1.ui.qLabel=list(); LD1.ui.qEdit=list();
    qy=[0.63 0.41 0.19];
    for k=1:3
        LD1.ui.qLabel(k)=uicontrol(af,"style","text","units","normalized", ..
            "position",[0.03 qy(k) 0.46 0.14],"string","", ..
            "fontsize",9,"horizontalalignment","left","verticalalignment","middle", ..
            "backgroundcolor",[0.98 0.98 0.98]);
        LD1.ui.qEdit(k)=uicontrol(af,"style","edit","units","normalized", ..
            "position",[0.52 qy(k) 0.30 0.15],"string","","fontsize",9);
    end
    LD1.ui.typeSeries=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.03 0.04 0.29 0.14],"string","Nuosekli","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.typeParallel=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.34 0.04 0.32 0.14],"string","Lygiagreti","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.typeMixed=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.69 0.04 0.25 0.14],"string","Mišri","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.yesNoQuestion=uicontrol(af,"style","text","units","normalized", ..
        "position",[0.03 0.025 0.56 0.15],"string","", ..
        "fontsize",8,"fontweight","bold","horizontalalignment","left", ..
        "verticalalignment","middle","backgroundcolor",[0.98 0.98 0.98]);
    LD1.ui.yes=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.62 0.035 0.16 0.14],"string","Taip","fontsize",9,"groupname","yesno","value",0);
    LD1.ui.no=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.80 0.035 0.16 0.14],"string","Ne","fontsize",9,"groupname","yesno","value",0);

    // 4) Patvirtinimas ir navigacija.
    LD1.ui.checkStep=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.035 0.060 0.93 0.035],"string","PATIKRINTI IR UŽFIKSUOTI ETAPĄ", ..
        "fontsize",9,"fontweight","bold","callback","ld1_check_step()");
    LD1.ui.prev=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.035 0.010 0.18 0.035],"string","← ATGAL","fontsize",8,"callback","ld1_prev_step()");
    LD1.ui.solution=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.225 0.010 0.25 0.035],"string","PAVYZDYS / SPRENDIMAS","fontsize",8,"fontweight","bold","callback","ld1_toggle_solution()");
    LD1.ui.help=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.485 0.010 0.22 0.035],"string","TEORIJA","fontsize",8,"callback","ld1_show_help()");
    LD1.ui.next=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.715 0.010 0.25 0.035],"string","TOLIAU →","fontsize",8,"callback","ld1_next_step()");

    // Dviejų eilučių statusas: klaida + konkretus taisymo veiksmas.
    LD1.ui.statusFrame=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.012 0.785 0.077],"backgroundcolor",[0.90 0.93 0.97],"relief","flat");
    LD1.ui.statusMain=uicontrol(LD1.ui.statusFrame,"style","text","units","normalized", ..
        "position",[0.01 0.52 0.98 0.42],"string","", ..
        "fontsize",10,"fontweight","bold","horizontalalignment","left","verticalalignment","middle", ..
        "backgroundcolor",[0.90 0.93 0.97],"foregroundcolor",[0.10 0.18 0.28]);
    LD1.ui.statusFix=uicontrol(LD1.ui.statusFrame,"style","text","units","normalized", ..
        "position",[0.01 0.07 0.98 0.40],"string","", ..
        "fontsize",9,"horizontalalignment","left","verticalalignment","middle", ..
        "backgroundcolor",[0.90 0.93 0.97],"foregroundcolor",[0.10 0.18 0.28]);
    LD1.ui.restart=uicontrol(f,"style","pushbutton","units","normalized", ..
        "position",[0.818 0.020 0.164 0.055],"string","PRADĖTI IŠ NAUJO", ..
        "fontsize",10,"callback","ld1_restart()");
endfunction

function ld1_update_terminal_highlight()
    // v1.3 perpiešia gnybtus, todėl paryškinimas visada atnaujinamas kartu su stendu.
    ld1_redraw_panel();
endfunction

function ld1_hide_all_answers()
    global LD1;
    for k=1:3
        ld1_show(LD1.ui.qLabel(k),%f);
        ld1_show(LD1.ui.qEdit(k),%f);
        LD1.ui.qEdit(k).string="";
    end
    ld1_show(LD1.ui.typeSeries,%f); ld1_show(LD1.ui.typeParallel,%f); ld1_show(LD1.ui.typeMixed,%f);
    ld1_show(LD1.ui.yesNoQuestion,%f);
    ld1_show(LD1.ui.yes,%f); ld1_show(LD1.ui.no,%f);
    LD1.ui.typeSeries.value=0; LD1.ui.typeParallel.value=0; LD1.ui.typeMixed.value=0;
    LD1.ui.yes.value=0; LD1.ui.no.value=0;
endfunction

function ld1_show_numeric_field(k,label)
    global LD1;
    LD1.ui.qLabel(k).string=label;
    ld1_show(LD1.ui.qLabel(k),%t);
    ld1_show(LD1.ui.qEdit(k),%t);
endfunction

function ld1_show_yes_no(question)
    global LD1;
    LD1.ui.yesNoQuestion.string=question;
    ld1_show(LD1.ui.yesNoQuestion,%t);
    ld1_show(LD1.ui.yes,%t);
    ld1_show(LD1.ui.no,%t);
endfunction
