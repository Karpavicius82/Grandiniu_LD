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
    t = 0.011;
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

function ld3_wire_path(x1, y1, x2, y2, color, orient)
    // Kelias pagal orientaciją: "HVH", "VHV" arba "H" (tiesus).
    if argn(2) < 6 then orient = "HVH"; end
    if abs(y2 - y1) < 0.001 then orient = "H"; end
    if abs(x2 - x1) < 0.001 then orient = "V"; end
    select orient
    case "H" then ld3_board_segment(x1, y1, x2, y2, color);
    case "V" then ld3_board_segment(x1, y1, x2, y2, color);
    case "VHV@36" then
        // Zondo laidas: horizontalė y=36% virš R1, žemiau V poros.
        ld3_board_segment(x1, y1, x1, 0.36, color);
        ld3_board_segment(x1, 0.36, x2, 0.36, color);
        ld3_board_segment(x2, 0.36, x2, y2, color);
    case "V" then
        ld3_board_segment(x1, y1, x2, y2, color);
    case "VHV@33" then
        // Grąžinamasis laidas: horizontalė y=33% — apačioje, žemiau V dėžės.
        ld3_board_segment(x1, y1, x1, 0.33, color);
        ld3_board_segment(x1, 0.33, x2, 0.33, color);
        ld3_board_segment(x2, 0.33, x2, y2, color);
    case "VHV_LOW" then
        // Žemutinis maršrutas: horizontalė arti apatinio taško (apeina dėžutes).
        ym = min(y1, y2) + 0.005;
        ld3_board_segment(x1, y1, x1, ym, color);
        ld3_board_segment(x1, ym, x2, ym, color);
        ld3_board_segment(x2, ym, x2, y2, color);
    case "VHV" then
        ym = (y1 + y2) / 2;
        ld3_board_segment(x1, y1, x1, ym, color);
        ld3_board_segment(x1, ym, x2, ym, color);
        ld3_board_segment(x2, ym, x2, y2, color);
    else  // HVH
        xm = (x1 + x2) / 2;
        ld3_board_segment(x1, y1, xm, y1, color);
        ld3_board_segment(xm, y1, xm, y2, color);
        ld3_board_segment(xm, y2, x2, y2, color);
    end
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

// Lentos išdėstymas — algoritmu, ne ranka: viršutinė eilė E-K-A su VIENODOMIS
// paraštėmis ir VIENODAIS tarpais (terminalai ties 30 % / 70 % tarpo); apatinė
// grupė V-R1 CENTRUOTA pagal lentos vidurį; visos poros simetriškos.
function [term_xy, boxes] = ld3_layout()
    m = 13;                       // paraštė = 100 px (13 % × 768 px)
    wE = 10; wK = 8; wA = 11;     // viršutinės dėžių apimtys %
    G = (100 - 2*m - wE - wK - wA) / 2;   // vienodi tarpai tarp dėžių
    xE = m; xK = xE + wE + G; xA = xK + wK + G;   // kairieji kraštai
    f = 0.30;                     // terminalo vieta tarpe (30 % nuo dėžės)
    yT = 66; dPair = 5;           // eilės aukštis ir poros išsiskirstymas
    term_xy = struct();
    term_xy.E_P = [xE + wE + (1-f)*G, yT + dPair];
    term_xy.E_N = [xE + wE + (1-f)*G, yT - dPair];
    term_xy.K1 = [xK - (1-f)*G, yT];
    term_xy.K2 = [xK + wK + f*G, yT];
    term_xy.A_P = [xA - f*G, yT];
    term_xy.A_N = [xA + wA + 2.6, yT];
    // Apatinė grupė: V kairiau, R1 dešiniau, CENTRUOTA (vidurys 50 %).
    wV = 11; wR = 14; gIn = 12;
    grW = wV + gIn + wR;
    xV = 50 - grW/2; xR = xV + wV + gIn;
    term_xy.V_N = [xV - 5.9, 41];
    term_xy.V_P = [xV + wV + 5.9, 41];
    term_xy.R1B = [xR - 5.9, 27];
    term_xy.R1A = [xR + wR + 5.6, 27];
    boxes = struct();
    boxes.E = [xE 61 wE 13]; boxes.K = [xK 61 wK 13]; boxes.A = [xA 61 wA 13];
    boxes.V = [xV 34 wV 12]; boxes.R1 = [xR 12 wR 12];
endfunction

function xy = ld3_terminal_xy(id)
    [all, boxes] = ld3_layout();
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
    // [Txx] žyma (4.2% pločio, kad nelįstų ant kaimynų); E_N — virš mygtuko.
    if id == "E_N" then
        ld3_board_text([x - 0.021 y + h/2 + 0.004 0.042 0.023], ...
            "[" + tcode + "]", 8, %f, "center", [1 1 1], [0.10 0.30 0.50]);
    else
        ld3_board_text([x - 0.021 y - h/2 - 0.027 0.042 0.023], ...
            "[" + tcode + "]", 8, %f, "center", [1 1 1], [0.10 0.30 0.50]);
    end
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
    // Pirmiausia laidai (po mygtukais – kaip schemoje), tada terminalai.
    orient = struct();
    orient("E_P|K1") = "HVH";   orient("K2|A_P") = "H";
    orient("A_N|R1A") = "VHV";  orient("R1B|E_N") = "VHV@33";
    orient("V_P|R1A") = "VHV@36";  orient("V_N|R1B") = "V";
    for m = 1:size(LD3.wires, 1)
        p1 = ld3_terminal_xy(LD3.wires(m, 1));
        p2 = ld3_terminal_xy(LD3.wires(m, 2));
        key = LD3.wires(m, 1) + "|" + LD3.wires(m, 2);
        o = "HVH";
        if isfield(orient, key) then o = orient(key); end
        ld3_wire_path(p1(1), p1(2), p2(1), p2(2), [0.20 0.30 0.50], o);
        // Skieto taškas abiejose laido galuose.
        for g = 1:2
            if g == 1 then pp = p1; else pp = p2; end
            h = uicontrol(LD3.ui.circuitFrame, "style", "text", "units", "normalized", ...
                "position", [pp(1) - 0.006 pp(2) - 0.005 0.012 0.010], ...
                "string", "", "backgroundcolor", [0.20 0.30 0.50]);
            ld3_track_board(h);
        end
    end
    tids = ld3_terminal_ids();
    for k = 1:size(tids, "*")
        ld3_draw_terminal(tids(k));
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
    [lt_xy, lb] = ld3_layout();
    ld3_board_box(lb.E/100, "E", "0–12 V", [0.98 0.96 0.88]);
    ld3_board_box(lb.K/100, "K", "JUNGLIS", [0.95 0.97 0.99]);
    ld3_board_box(lb.A/100, "A", "mA", [0.95 0.97 0.99]);
    ld3_board_box(lb.R1/100, "R1", msprintf("%d Ω", LD3.cfg.R), [0.98 0.96 0.88]);
    ld3_board_box(lb.V/100, "V", "VOLT.", [0.95 0.97 0.99]);
    ld3_board_text([0.03 0.78 0.30 0.03], "Omo dėsnio stendas: I = U / R", 10, %t, "left");

    // Valdymo juosta lentos apačioje: [V01] slankiklis + [V02] rodmuo + mygtukai.
    LD3.ui.voltSlider = uicontrol(f, "style", "slider", "units", "normalized", ...
        "position", [0.032 0.150 0.145 0.026], "min", 0, "max", 12, "value", 0, ...
        "tag", "V01", "tooltipstring", "[V01] Šaltinio įtampos nustatymas (0–12 V)", ...
        "callback", "ld3_slider_changed()");
    LD3.ui.voltLabel = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.182 0.148 0.052 0.030], "string", "0 V", "tag", "V02", ...
        "tooltipstring", "[V02] Dabartinė šaltinio įtampa", "fontsize", 11, ...
        "fontname", "DejaVu Sans", "backgroundcolor", [1 1 1]);
    LD3.ui.journalList = uicontrol(f, "style", "listbox", "units", "normalized", ...
        "position", [0.030 0.195 0.150 0.075], "string", "Matavimai:", ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9);
    hc1 = ld3_button(f, [0.240 0.148 0.095 0.030], "Maitinimas", "ld3_toggle_power()", 8);
    hc2 = ld3_button(f, [0.340 0.148 0.080 0.030], "Junglis", "ld3_toggle_switch()", 8);
    hc3 = ld3_button(f, [0.425 0.148 0.085 0.030], "MATUOTI", "ld3_measure()", 8, [0.08 0.39 0.37]);

    // Dešinė: instrukcijos ir atsakymai (kaip LD1 dešinioji sritis).
    panel = uicontrol(f, "style", "frame", "units", "normalized", ...
        "position", [0.635 0.105 0.345 0.770], "backgroundcolor", [1 1 1], "relief", "groove");
    LD3.ui.instructionLine(1) = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.650 0.715 0.315 0.145], "string", ld3_step_instruction(LD3.step), ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 10, ...
        "horizontalalignment", "left", "verticalalignment", "top", "backgroundcolor", [1 1 1]);
    etiketes = ["[A02.01] I1 teorinė, mA"; "[A04.01] R1, Ω"; "[A04.02] R2, Ω"; ...
                "[A04.03] R3, Ω"; "[A04.04] Rvid, Ω"; "[A05.01] R (nuolydis), Ω"; ...
                "[A06.01] Tiesinė? (1/2)"; "[A06.02] R pastovi? (1/2)"];
    LD3.ui.answerEdits = [];
    for k = 1:8
        uicontrol(f, "style", "text", "units", "normalized", ...
            "position", [0.650 0.645 - (k - 1) * 0.044 0.185 0.038], "string", etiketes(k), ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9, ...
            "backgroundcolor", [1 1 1], "horizontalalignment", "left");
        h = uicontrol(f, "style", "edit", "units", "normalized", ...
            "position", [0.840 0.645 - (k - 1) * 0.044 0.125 0.038], "string", "", ...
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
