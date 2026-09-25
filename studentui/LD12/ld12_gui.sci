// Shared Scilab UI; numerical calculation and grading remain in the C++ core.
function h = ld12_button(p, pos, label, cb, fs, bg)
    if argn(2) < 5 then fs = 13; end
    if argn(2) < 6 then bg = [0.94 0.96 0.96]; end
    code = ""; hint = "";
    try
        [code, registered, hint] = ld12_button_info(cb);
    catch
        code = "";
    end
    if code <> "" then label = "[" + code + "] " + label; end
    h = student_button(p, pos, "<html><center>" + label + "</center></html>", cb);
    h.tag = code; h.tooltipstring = hint; h.fontsize = fs; h.backgroundcolor = bg;
    if sum(bg) < 1.5 then h.foregroundcolor = [1 1 1]; end
endfunction

function [term_xy, boxes] = ld12_layout()
    // Stable 1280x720 canvas: three aligned source/load rows and separate returns.
    boxes=struct("SRC",[4.5 20 18.5 54],"R1",[60 60 23 12],"R2",[60 40 23 12],"R3",[60 20 23 12],"V",[35 57 17 8],"A",[35 37 17 8]);
    term_xy=struct("L1",[28.5 66],"L2",[28.5 46],"L3",[28.5 26],"N",[12 13], ...
        "R1_A",[57 66],"R1_B",[86 66],"R2_A",[57 46],"R2_B",[86 46],"R3_A",[57 26],"R3_B",[86 26]);
endfunction

function xy = ld12_terminal_xy(id)
    [tt, bb] = ld12_layout(); xy = tt(id)/100;
endfunction

function txt = ld12_terminal_button_text(id)
    select id
    case "L1" then txt = "L1"; case "L2" then txt = "L2"; case "L3" then txt = "L3"; case "N" then txt = "N";
    case "K1" then txt = "1"; case "K2" then txt = "2";
    case "R1_A" then txt = "a"; case "R1_B" then txt = "b";
    case "R2_A" then txt = "a"; case "R2_B" then txt = "b";
    case "R3_A" then txt = "a"; case "R3_B" then txt = "b";
    end
endfunction

function ld12_track_board(h)
    global LD12;
    if h <> [] then
        for item = matrix(h, 1, -1); LD12.ui.boardHandles($+1) = item; end
    end
endfunction

function ld12_clear_board()
    global LD12;
    for k = 1:length(LD12.ui.boardHandles)
        h = LD12.ui.boardHandles(k);
        if is_handle_valid(h) then delete(h); end
    end
    LD12.ui.boardHandles = list(); LD12.term.handles = list(); LD12.term.handleIds = emptystr(0, 1);
    LD12.ui.dynamic = LD12.ui.controls;
endfunction

function ld12_polyline(points, col)
    global LD12;
    for k = 1:size(points, 1)-1
        ld12_track_board(student_wire(LD12.ui.circuitFrame, points(k,:), points(k+1,:), col));
    end
endfunction

function route = ld12_route(a,b)
    route=[];
    pairs=["L1" "R1_A";"L2" "R2_A";"L3" "R3_A";"R1_B" "R2_B";"R2_B" "R3_B";"R3_B" "N";"R1_B" "L2";"R2_B" "L3";"R3_B" "L1"];
    routes=list([.285 .66;.57 .66],[.285 .46;.57 .46],[.285 .26;.57 .26], ...
        [.86 .66;.86 .46],[.86 .46;.86 .26],[.86 .26;.90 .26;.90 .13;.12 .13], ...
        [.86 .66;.90 .66;.90 .56;.285 .56;.285 .46], ...
        [.86 .46;.93 .46;.93 .36;.285 .36;.285 .26], ...
        [.86 .26;.975 .26;.975 .74;.285 .74;.285 .66]);
    for k=1:size(pairs,1)
        if and([a b]==pairs(k,:)) | and([b a]==pairs(k,:)) then route=routes(k); return; end
    end
endfunction

function ld12_render_wires()
    global LD12;
    if ~isfield(LD12, "ui") then return; end
    if isfield(LD12.ui, "headless") then if LD12.ui.headless then return; end; end
    if ~isfield(LD12.ui, "circuitFrame") then return; end
    if ~is_handle_valid(LD12.ui.circuitFrame) then return; end
    drawing = LD12.fig.immediate_drawing; LD12.fig.immediate_drawing = "off";
    ld12_clear_board(); p = LD12.ui.circuitFrame;
    ports = [];
    for id = matrix(ld12_terminal_ids(), 1, -1); ports($+1,:) = [ld12_terminal_xy(id) 36 40]; end
    p.user_data = struct("ports", ports);
    student_begin_wires(p);
    for k = 1:size(LD12.wires, 1)
        a = LD12.wires(k,1); b = LD12.wires(k,2);
        p1 = ld12_terminal_xy(a); p2 = ld12_terminal_xy(b);
        pts = ld12_route(a, b);
        if pts == [] then
            if abs(p1(1)-p2(1)) < 1e-9 | abs(p1(2)-p2(2)) < 1e-9 then pts = [p1; p2];
            else
                xm = (p1(1)+p2(1))/2; pts = [p1; xm p1(2); xm p2(2); p2];
            end
        end
        ld12_polyline(pts, [0.22 0.40 0.42]);
    end
    [tt,bb]=ld12_layout(); ids=["SRC" "R1" "R2" "R3" "V" "A"];
    names=["3~ ŠALTINIS";"R1";"R2";"R3";"Uf · R"+string(LD12.phase);"If · R"+string(LD12.phase)];
    if LD12.phase==4 then names(5)="Ul · L1–L2"; names(6)="Il · L1"; end
    [u,i,valid,reason]=ld12_measure_values(); voltText="— V"; ampText="— mA";
    if valid then voltText=msprintf("%.4f V",u); ampText=msprintf("%.3f mA",i); end
    vals=[msprintf("<html><center>Ul = %g V<br>50 Hz<br>RMS</center></html>",LD12.cfg.Ul), ...
        msprintf("%g Ω",LD12.cfg.R),msprintf("%g Ω",LD12.cfg.R),msprintf("%g Ω",LD12.cfg.R),voltText,ampText];
    // Every source/load terminal has a visible lead to its own object.
    for k=1:3
        xy=ld12_terminal_xy("L"+string(k));ld12_track_board(student_wire(p,xy,[.23 xy(2)],[.41 .49 .51],"lead:SRC"));
    end
    ld12_track_board(student_wire(p,[.12 .13],[.12 .20],[.41 .49 .51],"lead:SRC"));
    for k=1:6
        r=bb(ids(k))/100;bg=[.94 .97 .97];
        if k>=2 & k<=4 then
            bg=[.98 .96 .88];if LD12.phase==k-1 then bg=[.95 .87 .95];end
            for suffix=["A" "B"]
                xy=ld12_terminal_xy(ids(k)+"_"+suffix);edge=[r(1) xy(2)];if suffix=="B" then edge(1)=r(1)+r(3);end
                ld12_track_board(student_wire(p,xy,edge,[.41 .49 .51],"lead:"+ids(k)));
            end
        end
        fr=student_frame(p,r,bg);fr.tag="component:"+ids(k);ld12_track_board(fr);
        h=student_text(fr,[.04 .62 .92 .34],names(k),12,%t,bg);h.horizontalalignment="center";
        h=student_text(fr,[.02 .03 .96 .57],vals(k),13,%t,bg);h.horizontalalignment="center";h.tag="reading:"+ids(k);
        if k==5 then h.tooltipstring="Uf — pasirinkto imtuvo įtampa; linijos režime Ul tarp L1 ir L2.";end
        if k==6 then h.tooltipstring="If — pasirinkto imtuvo srovė; linijos režime Il šaltinio linijoje L1.";end
    end
    tids = ld12_terminal_ids();
    for id = matrix(tids, 1, -1)
        bg = [0.08 0.39 0.37]; if id == LD12.pending then bg = [0.60 0.39 0.06]; end
        cb = "ld12_terminal_click(""" + id + """)";
        h = student_terminal(p, ld12_terminal_xy(id), ld12_terminal_button_text(id), ld12_terminal_code(id), cb, ld12_terminal_name(id), bg);
        h.horizontalalignment = "center";
        if ~ld12_wiring_editable() then h.enable = "off"; end
        LD12.term.handles($+1) = h; LD12.term.handleIds($+1, 1) = id; LD12.ui.dynamic($+1) = h; ld12_track_board(h);
    end
    ld12_track_board(student_end_wires(p));
    for k = 1:2
        h = LD12.ui.controls(k); h.backgroundcolor = [0.94 0.96 0.96]; h.foregroundcolor = [0.08 0.20 0.22];
        if LD12.wireMode == k then h.backgroundcolor = [0.08 0.39 0.37]; h.foregroundcolor = [1 1 1]; end
    end
    for k = 3:5
        h = LD12.ui.controls(k); h.backgroundcolor = [0.94 0.96 0.96]; h.foregroundcolor = [0.08 0.20 0.22];
        if LD12.phase == k-2 then h.backgroundcolor = [0.52 0.25 0.48]; h.foregroundcolor = [1 1 1]; end
    end
    for k=1:7
        LD12.ui.controls(k).enable="on";
        if LD12.demoMode then LD12.ui.controls(k).enable="off"; end
    end
    LD12.ui.controls(8).enable="off";
    if ~LD12.demoMode & or(LD12.step==[2 4]) then LD12.ui.controls(8).enable="on"; end
    LD12.ui.measureAll.enable=LD12.ui.controls(8).enable;
    LD12.ui.lineButton.enable="off";
    if ~LD12.demoMode & LD12.wireMode==2 then LD12.ui.lineButton.enable="on"; end
    LD12.ui.lineButton.backgroundcolor=[.94 .96 .96];
    if LD12.phase==4 then LD12.ui.lineButton.backgroundcolor=[.95 .87 .95]; end
    power_label="Įjungti";if LD12.powerOn then power_label="Išjungti";end
    switch_label="Uždaryti";if LD12.switchOn then switch_label="Atverti";end
    LD12.ui.controls(6).string="[B01] "+power_label;
    LD12.ui.controls(7).string="[B02] "+switch_label;
    ld12_font(p);
    LD12.fig.immediate_drawing = drawing;
endfunction

function ld12_render_journal()
    global LD12;
    if ~isfield(LD12,"ui") then return;end
    if ~isfield(LD12.ui,"journalList") then return;end
    if ~is_handle_valid(LD12.ui.journalList) then return;end
    rows=emptystr(0,1);
    for tag=1:2
        m=ld12_journal_rows(tag); label="Y";if tag==2 then label="Δ";end
        for channel=1:4
            if m==[] then continue;end
            idx=find(m(:,4)==channel);if idx==[] then continue;end
            k=idx(1);point="R"+string(channel);u="Uf";i="If";
            if channel==4 then point="L1";u="Ul";i="Il";end
            rows($+1)=msprintf("%s · %s: %s=%.4f V · %s=%.3f mA",label,point,u,m(k,1),i,m(k,2));
        end
    end
    if rows==[] then rows="Matavimų dar nėra. Y — žvaigždė; Δ — trikampis.";end
    LD12.ui.journalList.string=rows;
endfunction

function ld12_render_stage()
    global LD12;
    if ~isfield(LD12, "ui") then return; end
    if isfield(LD12.ui, "headless") then if LD12.ui.headless then return; end; end
    if ~isfield(LD12.ui, "answerEdits") then return; end
    if ~is_handle_valid(LD12.fig) then return; end
    row = 0;
    for k = 1:10
        [st, sl] = ld12_answer_slot(k); h = LD12.ui.answerEdits(k); lab = LD12.ui.answerLabels(k);
        h.visible = "off"; lab.visible = "off";
        if st == LD12.step then
            yy = 0.60 - row*0.085; row = row + 1;
            lab.position = [0.07 yy 0.53 0.075]; h.position = [0.63 yy 0.30 0.075];
            h.string = LD12.answers(st, sl); h.visible = "on"; lab.visible = "on";
            h.enable = "on"; if LD12.demoMode then h.enable = "off"; end
        end
    end
    LD12.ui.instructionLine(1).string = student_wrap(ld12_step_instruction(LD12.step), 38);
    LD12.ui.progress.string = string(LD12.step) + " / 6 etapas";
    if LD12.demoMode then LD12.ui.progress.string = "PAVYZDYS"; end
    LD12.ui.identity.string = student_caption(LD12.student);
    LD12.ui.identity.tooltipstring=student_caption(LD12.student);
    ld12_render_wires();
    ld12_render_journal(); ld12_student_sync();
endfunction

function ld12_resize(id)
    global LD12;
    if typeof(LD12) <> "st" then return; end
    if ~isfield(LD12, "fig") then return; end
    if ~is_handle_valid(LD12.fig) then return; end
    if LD12.fig.figure_id <> id then return; end
    // Recompute fixed pixel terminal targets and crossing gaps. Keep raw edits.
    ld12_render_wires();
endfunction

function ld12_build_gui()
    global LD12;
    f = figure("resize", "off", "default_axes", "off", "dockable", "off", "menubar", "none", "toolbar", "none", "visible", "off");
    f.axes_size = [1280 720]; f.figure_position = [10 10]; f.infobar_visible = "off";
    f.figure_name = "LD12 · Trikampiu ir žvaigžde jungiamų imtuvų tyrimas"; f.background = color(246,248,249); LD12.fig = f;
    LD12.ui = struct("headless", %f, "boardHandles", list(), "dynamic", [], "controls", []);
    LD12.term = struct("handles", list(), "handleIds", emptystr(0, 1));
    student_text(f, [0.03 0.925 0.65 0.05], "LD12 / Trifazės grandinės: žvaigždė ir trikampis", 20, %t, [0.965 0.973 0.977]);
    LD12.ui.progress = student_text(f, [0.705 0.93 0.15 0.044], "", 14, %f, [0.965 0.973 0.977]);
    LD12.ui.identity = student_text(f, [0.03 0.895 0.94 0.025], "", 12, %f, [0.965 0.973 0.977]);
    student_button(f, [0.87 0.93 0.105 0.044], "Pagalba", "ld12_show_actions()");
    p = student_frame(f, [0.025 0.12 0.655 0.77]); LD12.ui.circuitFrame = p;
    right = student_frame(f, [0.70 0.12 0.275 0.77]); LD12.ui.right = right;
    student_text(p,[.35 .18 .46 .025],"Laidas: abu gnybtai. Pakartoję — pašalinsite.",11,%f);
    // Septyni įrašai: po tris imtuvus ir atskira trikampio linija.
    LD12.ui.journalList = uicontrol(p, "style", "listbox", "units", "normalized", ...
        "position", [0.02 0.76 0.59 0.235], "string", "Matavimai", ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 12, "tag", "V02");
    controls = [];
    modes = ["ŽVAIGŽDĖ";"TRIKAMPIS"];
    for k = 1:2
        cb = "ld12_set_mode(" + string(k) + ")";
        controls($+1) = ld12_button(p, [0.02+(k-1)*0.18 0.015 0.17 0.065], modes(k), cb, 12);
    end
    phases = ["R1";"R2";"R3"];
    for k = 1:3
        cb = "ld12_set_phase(" + string(k) + ")";
        controls($+1) = ld12_button(p, [0.39+(k-1)*0.13 0.015 0.12 0.065], phases(k), cb, 11);
    end
    controls($+1) = ld12_button(p, [.64 .865 .16 .05], "Maitinimas", "ld12_toggle_power()", 12);
    controls($+1) = ld12_button(p, [.82 .865 .16 .05], "Jungiklis", "ld12_toggle_switch()", 12);
    controls($+1) = ld12_button(p, [.64 .805 .34 .05], "Matuoti", "ld12_measure()", 13, [0.08 0.39 0.37]);
    LD12.ui.instructionLine(1) = student_text(right, [0.07 0.72 0.86 0.22], "", 14, %f);
    LD12.ui.instructionLine(1).verticalalignment = "top";
    labels = ["[A01.01] Uf = Ul/√3, V"; ...
        "[A02.01] If = 1000·Uf/R, mA"; ...
        "[A03.01] Trikampio Uf, V"; ...
        "[A04.01] If = 1000·Ul/R, mA"; ...
        "[A05.01] Il = √3·If, mA";"[A05.02] PΔ = √3·Ul·Il, mW";"[A05.03] PY = 3·Uf·If, mW"; ...
        "[A06.01] Žvaigždėje If = Il?";"[A06.02] Trikampyje Il = √3·If?";"[A06.03] PΔ = 3·PY?"];
    LD12.ui.answerEdits = []; LD12.ui.answerLabels = [];
    for k = 1:10
        LD12.ui.answerLabels($+1) = student_text(right, [0.07 0.5 0.53 0.075], student_wrap(labels(k), 22), 14, %f);
        [st, sl] = ld12_answer_slot(k);
        h = uicontrol(right, "style", "edit", "units", "normalized", "position", [0.63 0.5 0.30 0.075], ...
            "string", "", "fontunits", "pixels", "fontsize", 14, "fontname", "DejaVu Sans", ...
            "tag", ld12_answer_code(st, sl), "callback", "ld12_answers_changed()", "backgroundcolor", [0.94 0.96 0.96]);
        LD12.ui.answerEdits($+1) = h;
    end
    LD12.ui.studentPrimary = ld12_button(right, [0.07 0.085 0.86 0.075], "Tikrinti", "ld12_student_primary()", 15, [0.08 0.39 0.37]);
    controls($+1) = LD12.ui.studentPrimary;
    LD12.ui.studentBack = ld12_button(right, [0.07 0.015 0.37 0.045], "← Atgal", "ld12_jump_step(LD12.step-1)", 12);
    controls($+1)=LD12.ui.studentBack;
    controls($+1) = ld12_button(right, [0.48 0.015 0.45 0.045], "Žemėlapis", "ld12_show_stand_map()", 12);
    LD12.ui.measureAll=ld12_button(p,[.64 .93 .34 .06],"Įjungti ir matuoti visus","ld12_measure_all()",12,[.08 .39 .37]);
    LD12.ui.lineButton=ld12_button(p,[.78 .015 .20 .065],"Linija L1","ld12_set_phase(4)",11);
    controls($+1)=LD12.ui.measureAll;controls($+1)=LD12.ui.lineButton;
    LD12.ui.controls = controls; LD12.ui.dynamic = controls;
    LD12.ui.statusMain = student_text(f, [0.025 0.055 0.95 0.035], "", 13, %t, [0.94 0.96 0.96]);
    LD12.ui.statusFix = student_text(f, [0.025 0.020 0.95 0.035], "", 12, %f, [0.94 0.96 0.96]);
    ld12_font(f);
    student_finish_window(f); ld12_render_stage();
    f.closerequestfcn="ld12_close()";
    f.resizefcn = "ld12_resize(" + string(f.figure_id) + ")";
endfunction

function ld12_show_actions()
    global LD12;
    if ~isfield(LD12,"fig") then return; end
    if ~is_handle_valid(LD12.fig) then return; end
    choice=x_choose(["Tęsti išsaugotą darbą";"[B04] Kaip sujungti";"[B08] Išsaugoti ataskaitą";"Mokymosi / atsiskaitymo režimas";"Daugiau veiksmų";"Studentas ir priskirtos reikšmės"],"LD12 · Pagalba");
    select choice
    case 1 then bench_open_snapshot("LD12");
    case 2 then ld12_show_wiring_guide();
    case 3 then
        ld12_save_answers();
        if and(LD12.done) then bench_export_current("LD12");
        else ld12_set_status("Ataskaitai užbaikite visus 6 etapus.","info","Darbo juodraštis išsaugomas automatiškai; tęskite pagrindiniu mygtuku.");end
    case 4 then bench_mode("LD12"); ld12_student_sync(); bench_autosave("LD12");
    case 6 then ld12_text_window("Studentas ir priskirtos reikšmės",[student_caption(LD12.student);"";student_parameter_lines("LD12",LD12.cfg)]);
    case 5 then
        extra=x_choose(["[B05] Žemėlapis";"[B07] Pavyzdys";"[B06] Atkurti stendą";"[B09] Pradėti iš naujo"],"LD12 · Daugiau veiksmų");
        select extra
        case 1 then ld12_show_stand_map();
        case 2 then ld12_toggle_solution();
        case 3 then ld12_restore_stage();
        case 4 then
            if messagebox("Pradėti darbą iš naujo? Atsakymai bus išvalyti.","LD12","question",["Pradėti" "Grįžti"],"modal")==1 then ld12_restart(); end
        end
    end
endfunction

// Java logical font exists on both Windows and Linux; no external font install.
function ld12_font(parent)
    for h = matrix(parent.children, 1, -1)
        if h.type == "uicontrol" then
            h.fontname = "SansSerif";
            ld12_font(h);
        end
    end
endfunction
