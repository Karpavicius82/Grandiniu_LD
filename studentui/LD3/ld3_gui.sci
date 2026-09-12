// ============================================================================
// LD3 grafinė sąsaja — LD1 vizualinė kalba: 1280×800 lenta, antraštė,
// navigacijos juosta, dėžutės su reikšmėmis, gnybtai su [Txx] žymomis,
// laidai trijų segmentų keliais (board_segment), boardHandles valymas.
// ============================================================================

function [ok, code, label, hint] = ld3_button_lookup(cb)
    ok = %f; code = ""; label = ""; hint = "";
    try
        [code, label, hint] = ld3_button_info(cb);
        ok = %t;
    catch
    end
endfunction

function h = ld3_button(parent, pos, str, cb, fs, bg)
    if argn(2) < 5 then fs = 10; end
    if argn(2) < 6 then bg = [0.93 0.93 0.93]; end
    [ok, code, label, hint] = ld3_button_lookup(cb);
    if ok then str = "[" + code + "] " + str; else code = ""; hint = ""; end
    h = uicontrol(parent, "style", "pushbutton", "units", "normalized", ...
        "position", pos, "string", str, "tag", code, "tooltipstring", hint, ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", ...
        "fontsize", fs, "fontweight", "bold", "callback", cb, "backgroundcolor", bg);
endfunction

function h = ld3_stage_button(parent, pos, n, fs)
    if argn(2) < 4 then fs = 9; end
    code = ld3_stage_code(n);
    h = uicontrol(parent, "style", "pushbutton", "units", "normalized", ...
        "position", pos, "string", "[" + code + "]", "tag", code, ...
        "tooltipstring", "[" + code + "] Atidaryti " + string(n) + " etapą", ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", ...
        "fontsize", fs, "fontweight", "bold", "callback", "ld3_jump_step(" + string(n) + ")");
endfunction

// ------------------------------------------------- lentos pagelbininkai -----
function ld3_track_board(h)
    global LD3;
    LD3.ui.boardHandles($+1) = h;
endfunction

function ld3_clear_board()
    // Išvalo piešiamą lentos turinį (ne pačius valdiklių rėmus).
    global LD3;
    if isfield(LD3.ui, "boardHandles") then
        for k = 1:length(LD3.ui.boardHandles)
            try
                if is_handle_valid(LD3.ui.boardHandles(k)) then delete(LD3.ui.boardHandles(k)); end
            catch
            end
        end
    end
    LD3.ui.boardHandles = list();
endfunction

function h = ld3_board_text(pos, txt, fs, bold, align, bg, fg)
    global LD3;
    if argn(2) < 3 then fs = 12; end
    if argn(2) < 4 then bold = %f; end
    if argn(2) < 5 then align = "left"; end
    if argn(2) < 6 then bg = [1 1 1]; end
    if argn(2) < 7 then fg = [0.08 0.10 0.13]; end
    h = uicontrol(LD3.ui.circuitFrame, "style", "text", "units", "normalized", ...
        "position", pos, "string", txt, "fontsize", fs, ...
        "fontname", "DejaVu Sans", ...
        "horizontalalignment", align, "verticalalignment", "middle", ...
        "backgroundcolor", bg, "foregroundcolor", fg);
    if bold then h.fontweight = "bold"; end
    ld3_track_board(h);
endfunction

function h = ld3_board_box(pos, title, subtitle, bg)
    global LD3;
    if argn(2) < 4 then bg = [0.95 0.97 0.99]; end
    h = uicontrol(LD3.ui.circuitFrame, "style", "frame", "units", "normalized", ...
        "position", pos, "backgroundcolor", bg, "relief", "groove");
    tx = uicontrol(h, "style", "text", "units", "normalized", ...
        "position", [0.05 0.54 0.90 0.34], "string", title, ...
        "fontsize", 12, "fontweight", "bold", "horizontalalignment", "center", ...
        "fontname", "DejaVu Sans", ...
        "backgroundcolor", bg, "foregroundcolor", [0.08 0.12 0.18]);
    st = uicontrol(h, "style", "text", "units", "normalized", ...
        "position", [0.05 0.13 0.90 0.29], "string", subtitle, ...
        "fontsize", 10, "horizontalalignment", "center", ...
        "fontname", "DejaVu Sans", ...
        "backgroundcolor", bg, "foregroundcolor", [0.16 0.20 0.25]);
    ld3_track_board(h);
endfunction

function h = ld3_board_segment(x1, y1, x2, y2, color)
    // Plonas stačiakampis kaip laido atkarpa (kaip LD1).
    global LD3;
    t = 0.006;
    if abs(y2 - y1) < 0.001 then
        x = min(x1, x2); w = max(abs(x2 - x1), 0.002);
        pos = [x y1 - t/2 w t];
    else
        y = min(y1, y2); hh = max(abs(y2 - y1), 0.002);
        pos = [x1 - t/2 y t hh];
    end
    h = uicontrol(LD3.ui.circuitFrame, "style", "text", "units", "normalized", ...
        "position", pos, "string", "", "backgroundcolor", color);
    ld3_track_board(h);
endfunction

function ld3_wire_path(x1, y1, x2, y2, color)
    // Trijų segmentų kelias (kaip LD1): H per vidurį, V, H.
    xm = (x1 + x2) / 2;
    ld3_board_segment(x1, y1, xm, y1, color);
    ld3_board_segment(xm, y1, xm, y2, color);
    ld3_board_segment(xm, y2, x2, y2, color);
endfunction

// Gnybto simbolis ant mygtuko (kaip LD1 +/-/1/2…).
function txt = ld3_terminal_button_text(id)
    select id
    case "E_P" then txt = "+";
    case "E_N" then txt = "-";
    case "K1" then txt = "1";
    case "K2" then txt = "2";
    case "A_P" then txt = "+";
    case "A_N" then txt = "-";
    case "R1A" then txt = "a";
    case "R1B" then txt = "b";
    case "V_P" then txt = "+";
    case "V_N" then txt = "-";
    else txt = "•";
    end
endfunction

// Gnybtų vietos lentos procentais (x y iš 100) — tvarka kaip ld3_terminal_ids.
function xy = ld3_terminal_xy(id)
    all = struct();
    all.E_P = [17 69]; all.E_N = [17 63];
    all.K1 = [21 66]; all.K2 = [34 66];
    all.A_P = [37 66]; all.A_N = [52 66];
    all.R1A = [43 27]; all.R1B = [57 27];
    all.V_P = [61 45]; all.V_N = [76 45];
    xy = all(id) / 100;
endfunction

function ld3_draw_terminal(id)
    global LD3;
    xy = ld3_terminal_xy(id); x = xy(1); y = xy(2);
    w = 0.042; h = 0.050;  // kaip LD1 v1.7 kompaktiški kontaktai
    pos = [x - w/2 y - h/2 w h];
    cb = "ld3_terminal_click(""" + id + """)";
    if LD3.pending == id then
        bg = [1.00 0.82 0.28]; fg = [0.08 0.08 0.08];
    else
        bg = [0.08 0.39 0.37]; fg = [1 1 1];
    end
    tcode = ld3_terminal_code(id);
    ht = uicontrol(LD3.ui.circuitFrame, "style", "pushbutton", "units", "normalized", ...
        "position", pos, "string", ld3_terminal_button_text(id), ...
        "fontsize", 9, "fontweight", "bold", "backgroundcolor", bg, ...
        "foregroundcolor", fg, "margins", [0 0 0 0], ...
        "tooltipstring", "[" + tcode + "] " + ld3_terminal_name(id), ...
        "tag", tcode, "callback", cb);
    LD3.term.handles($+1) = ht;
    LD3.term.handleIds($+1, 1) = id;
    LD3.ui.dynamic($+1) = ht;
    ld3_track_board(ht);
    // [Txx] žyma šalia gnybto (kaip LD1 — atskiras mažas tekstas).
    ld3_board_text([x - 0.023 y - h/2 - 0.027 0.046 0.023], ...
        "[" + tcode + "]", 8, %f, "center", [1 1 1], [0.10 0.30 0.50]);
endfunction

function ld3_render_wires()
    global LD3;
    if ~isfield(LD3, "ui") then return; end
    if isfield(LD3.ui, "headless") then if LD3.ui.headless then return; end end
    // Terminalai + laidai per piešiamąjį sluoksnį; elementų dėžutės lieka.
    nkeep = 0;
    keep = list();
    if isfield(LD3.ui, "boardHandles") then
        for k = 1:length(LD3.ui.boardHandles)
            h = LD3.ui.boardHandles(k);
            if is_handle_valid(h) then
                if h.type == "uicontrol" & (h.style == "frame" | (h.style == "text" & h.tag == "")) then
                    // dėžutės (frame) ir etikečių tekstai lieka tik ne tarp gnybtų — paprasčiau: laikom frame
                end
                if h.style == "frame" then keep($+1) = h; nkeep = nkeep + 1; end
            end
        end
    end
    LD3.ui.boardHandles = keep;
    LD3.term.handles = list(); LD3.term.handleIds = emptystr(0, 1);
    tids = ld3_terminal_ids();
    for k = 1:size(tids, "*")
        ld3_draw_terminal(tids(k));
    end
    for m = 1:size(LD3.wires, 1)
        p1 = ld3_terminal_xy(LD3.wires(m, 1));
        p2 = ld3_terminal_xy(LD3.wires(m, 2));
        ld3_wire_path(p1(1), p1(2), p2(1), p2(2), [0.25 0.35 0.55]);
    end
endfunction

function ld3_render_journal()
    global LD3;
    if ~isfield(LD3, "ui") | ~isfield(LD3.ui, "journalList") then return; end
    if isfield(LD3.ui, "headless") then if LD3.ui.headless then return; end end
    if ~is_handle_valid(LD3.ui.journalList) then return; end
    rows = "Matavimai:";
    for m = 1:size(LD3.journal, 1)
        rows($+1) = msprintf("U=%g V · I=%.2f mA", LD3.journal(m,1), LD3.journal(m,2));
    end
    LD3.ui.journalList.string = rows;
endfunction

function ld3_render_stage()
    global LD3;
    if ~isfield(LD3, "ui") then return; end
    if isfield(LD3.ui, "headless") then if LD3.ui.headless then return; end end
    if isfield(LD3.ui, "answerEdits") then
        for k = 1:size(LD3.ui.answerEdits, "*")
            h = LD3.ui.answerEdits(k);
            if is_handle_valid(h) then
                [st, sl] = ld3_answer_slot(k);
                h.string = LD3.answers(st, sl);
            end
        end
    end
    for n = 1:6
        h = findobj("tag", ld3_stage_code(n));
        if h <> [] then
            if LD3.done(n) then h.backgroundcolor = [0.55 0.80 0.55];
            elseif LD3.skipped(n) then h.backgroundcolor = [0.95 0.85 0.45];
            elseif n == LD3.step then h.backgroundcolor = [0.55 0.70 0.90];
            else h.backgroundcolor = [0.85 0.85 0.85]; end
        end
    end
    if isfield(LD3.ui, "voltLabel") & is_handle_valid(LD3.ui.voltLabel) then
        LD3.ui.voltLabel.string = msprintf("%d V", LD3.voltage);
    end
    if isfield(LD3.ui, "voltSlider") & is_handle_valid(LD3.ui.voltSlider) then
        LD3.ui.voltSlider.value = LD3.voltage;
    end
    if isfield(LD3.ui, "progress") & is_handle_valid(LD3.ui.progress) then
        nd = size(find(LD3.done), "*");
        LD3.ui.progress.string = msprintf("%d / %d", nd, 6);
    end
    ld3_render_wires();
    ld3_render_journal();
endfunction

// ----------------------------------------------------------- langas ---------
function ld3_build_gui()
    global LD3;
    f = figure("default_axes", "off", "dockable", "off", "menubar", "none", ...
        "toolbar", "none", "visible", "off", "axes_size", [1280 800]);
    f.infobar_visible = "off";
    f.figure_position = [75 75];
    f.figure_name = "LD3 · Omo dėsnio veikimas realioje elektros grandinėje";
    f.resize = "on";
    LD3.fig = f;
    ld3_was_headless = %f;
    if isfield(LD3, "ui") then
        if isfield(LD3.ui, "headless") then ld3_was_headless = LD3.ui.headless; end
    end
    LD3.ui = struct();
    LD3.ui.headless = ld3_was_headless;
    LD3.ui.boardHandles = list();
    LD3.ui.dynamic = [];

    // Antraštė (kaip LD1).
    uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.018 0.938 0.964 0.049], ...
        "string", "LD3 · OMO DĖSNIO VEIKIMAS REALIOJE ELEKTROS GRANDINĖJE", ...
        "fontsize", 19, "fontweight", "bold", "horizontalalignment", "center", ...
        "fontname", "DejaVu Sans", ...
        "backgroundcolor", [0.15 0.27 0.42], "foregroundcolor", [1 1 1]);

    // Navigacijos juosta: progreso tekstas + [E01]–[E06] (kaip LD1).
    nav = uicontrol(f, "style", "frame", "units", "normalized", ...
        "position", [0.018 0.891 0.964 0.039], "backgroundcolor", [0.87 0.91 0.96], "relief", "flat");
    LD3.ui.progress = uicontrol(nav, "style", "text", "units", "normalized", ...
        "position", [0.01 0.10 0.08 0.80], "string", "0 / 6", ...
        "fontsize", 10, "fontweight", "bold", "horizontalalignment", "left", ...
        "fontname", "DejaVu Sans", ...
        "backgroundcolor", [0.87 0.91 0.96], "foregroundcolor", [0.12 0.22 0.34]);
    for k = 1:6
        xx = 0.155 + (k - 1) * 0.050;
        ld3_stage_button(nav, [xx 0.12 0.043 0.76], k, 9);
    end
    uicontrol(nav, "style", "text", "units", "normalized", ...
        "position", [0.50 0.10 0.48 0.80], ...
        "string", "Bankas LD3-64-A-2026 · ataskaita: [B08]", ...
        "fontsize", 9, "horizontalalignment", "right", ...
        "fontname", "DejaVu Sans", "backgroundcolor", [0.87 0.91 0.96], ...
        "foregroundcolor", [0.12 0.22 0.34]);

    // Kairė: stendo lenta (kaip LD1 circuitFrame).
    LD3.ui.circuitFrame = uicontrol(f, "style", "frame", "units", "normalized", ...
        "position", [0.018 0.105 0.600 0.770], "backgroundcolor", [1 1 1], "relief", "groove");

    // Elementų dėžutės su reikšmėmis (rezistorius rodo varžą — kaip LD1 R1/VR1).
    ld3_board_box([0.03 0.59 0.13 0.14], "ŠALTINIS E", "0–12 V", [0.98 0.96 0.88]);
    ld3_board_box([0.22 0.59 0.11 0.14], "JUNGLIS K", "ATIDARYTA", [0.95 0.97 0.99]);
    ld3_board_box([0.38 0.59 0.13 0.14], "AMPERMETRAS", "mA", [0.95 0.97 0.99]);
    ld3_board_box([0.43 0.14 0.14 0.13], "R1", msprintf("%d Ω", LD3.cfg.R), [0.98 0.96 0.88]);
    ld3_board_box([0.62 0.38 0.13 0.14], "VOLTMETRAS", "V", [0.95 0.97 0.99]);
    ld3_board_text([0.03 0.78 0.30 0.03], "Omo dėsnio stendas: I = U / R", 10, %t, "left");

    // Valdymo juosta lentos apačioje: [V01] slankiklis + [V02] rodmuo + mygtukai.
    LD3.ui.voltSlider = uicontrol(f, "style", "slider", "units", "normalized", ...
        "position", [0.030 0.115 0.180 0.030], "min", 0, "max", 12, "value", 0, ...
        "tag", "V01", "tooltipstring", "[V01] Šaltinio įtampos nustatymas (0–12 V)", ...
        "callback", "ld3_slider_changed()");
    LD3.ui.voltLabel = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.215 0.113 0.060 0.034], "string", "0 V", "tag", "V02", ...
        "tooltipstring", "[V02] Dabartinė šaltinio įtampa", "fontsize", 11, ...
        "fontname", "DejaVu Sans", "backgroundcolor", [1 1 1]);
    LD3.ui.journalList = uicontrol(f, "style", "listbox", "units", "normalized", ...
        "position", [0.030 0.155 0.150 0.075], "string", "Matavimai:", ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9);
    hc1 = ld3_button(f, [0.190 0.113 0.100 0.040], "Maitinimas", "ld3_toggle_power()", 8);
    hc2 = ld3_button(f, [0.295 0.113 0.085 0.040], "Junglis", "ld3_toggle_switch()", 8);
    hc3 = ld3_button(f, [0.385 0.113 0.090 0.040], "MATUOTI", "ld3_measure()", 8, [0.08 0.39 0.37]);

    // Dešinė: instrukcijos ir atsakymai (kaip LD1 dešinioji sritis).
    panel = uicontrol(f, "style", "frame", "units", "normalized", ...
        "position", [0.635 0.105 0.345 0.770], "backgroundcolor", [1 1 1], "relief", "groove");
    LD3.ui.instructionLine(1) = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.650 0.705 0.315 0.155], "string", ld3_step_instruction(LD3.step), ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 10, ...
        "horizontalalignment", "left", "verticalalignment", "top", "backgroundcolor", [1 1 1]);
    etiketes = ["[A02.01] I1 teorinė, mA"; "[A04.01] R1, Ω"; "[A04.02] R2, Ω"; ...
                "[A04.03] R3, Ω"; "[A04.04] Rvid, Ω"; "[A05.01] R (nuolydis), Ω"; ...
                "[A06.01] Tiesinė? (1/2)"; "[A06.02] R pastovi? (1/2)"];
    LD3.ui.answerEdits = [];
    for k = 1:8
        uicontrol(f, "style", "text", "units", "normalized", ...
            "position", [0.650 0.655 - (k - 1) * 0.044 0.185 0.038], "string", etiketes(k), ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9, ...
            "backgroundcolor", [1 1 1], "horizontalalignment", "left");
        h = uicontrol(f, "style", "edit", "units", "normalized", ...
            "position", [0.840 0.655 - (k - 1) * 0.044 0.125 0.038], "string", "", ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 10, ...
            "horizontalalignment", "right", "backgroundcolor", [0.97 0.98 0.98]);
        LD3.ui.answerEdits($+1) = h;
    end
    LD3.ui.studentPrimary = ld3_button(f, [0.650 0.125 0.315 0.055], "TIKRINTI / TOLIAU", ...
        "ld3_student_primary()", 13, [0.08 0.39 0.37]);
    hb1 = ld3_button(f, [0.650 0.190 0.150 0.040], "Kaip sujungti", "ld3_show_wiring_guide()", 8);
    hb2 = ld3_button(f, [0.815 0.190 0.150 0.040], "Žemėlapis", "ld3_show_stand_map()", 8);
    hb3 = ld3_button(f, [0.650 0.240 0.150 0.040], "Pavyzdys", "ld3_toggle_solution()", 8);
    hb4 = ld3_button(f, [0.815 0.240 0.150 0.040], "Ataskaita", "bench_export_current(""LD3"")", 8);
    hb5 = ld3_button(f, [0.815 0.290 0.150 0.040], "Iš naujo", "ld3_restart()", 8);
    hb6 = ld3_button(f, [0.650 0.290 0.150 0.040], "Atkurti stendą", "ld3_restore_stage()", 8);

    // Mygtukai į dinamį sąrašą — workflow'ai ieško pagal callback (LD2 raštas).
    LD3.ui.dynamic($+1) = LD3.ui.studentPrimary;
    for h = [hb1 hb2 hb3 hb4 hb5 hb6 hc1 hc2 hc3]
        LD3.ui.dynamic($+1) = h;
    end

    // Būsenos juosta (kaip LD1 apačia).
    uicontrol(f, "style", "frame", "units", "normalized", "position", [0.018 0.012 0.964 0.080], ...
              "backgroundcolor", [0.90 0.95 0.95], "relief", "groove");
    LD3.ui.statusMain = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.028 0.052 0.945 0.034], "string", "Paruošta.", ...
        "fontsize", 12, "fontweight", "bold", "fontname", "DejaVu Sans", ...
        "backgroundcolor", [0.90 0.95 0.95], "horizontalalignment", "left");
    LD3.ui.statusFix = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.028 0.018 0.945 0.034], "string", "", ...
        "fontsize", 10, "fontname", "DejaVu Sans", ...
        "backgroundcolor", [0.90 0.95 0.95], "horizontalalignment", "left");

    // Terminalai + laidai (piešiamasis sluoksnis).
    LD3.term = struct("handleIds", ld3_terminal_ids(), "handles", list());
    ld3_render_wires();
    f.visible = "on";
    ld3_render_stage();
endfunction

function ld3_slider_changed()
    global LD3;
    if isfield(LD3, "ui") & isfield(LD3.ui, "voltSlider") & is_handle_valid(LD3.ui.voltSlider) then
        ld3_set_voltage(LD3.ui.voltSlider.value);
    end
endfunction
