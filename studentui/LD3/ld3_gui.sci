// ============================================================================
// LD3 grafinė sąsaja: stendas, skydeliai, perpaišymo funkcijos.
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

// Stendo elementų dėžutės: koordinatės atskirai nuo žymių (Scilab nemaišo tipų).
function [coords, labels] = ld3_stand_boxes()
    coords = [0.06 0.66 0.16 0.20;
              0.30 0.66 0.14 0.20;
              0.52 0.66 0.16 0.20;
              0.24 0.24 0.20 0.16;
              0.52 0.28 0.16 0.16];
    labels = ["ŠALTINIS E";"JUNGLIS K";"A (mA)";"R1";"V (V)"];
endfunction

// Gnybtų vietos piešinyje (normalizuota): id → [x y]
function pos = ld3_terminal_pos(id)
    all = struct();
    all.E_P = [0.135 0.66]; all.E_N = [0.135 0.86];
    all.K1 = [0.335 0.66]; all.K2 = [0.405 0.66];
    all.A_P = [0.565 0.66]; all.A_N = [0.635 0.66];
    all.R1A = [0.295 0.40]; all.R1B = [0.385 0.40];
    all.V_P = [0.565 0.44]; all.V_N = [0.635 0.44];
    pos = all(id);
endfunction

function ld3_build_gui()
    global LD3;
    f = figure("figure_name", "LD3 · Omo dėsnio veikimas realioje elektros grandinėje", ...
               "axes_size", [1000 640], "menubar_visible", "off", "toolbar_visible", "off", ...
               "infobar_visible", "off");
    LD3.fig = f;
    ld3_was_headless = %f;
    if isfield(LD3, "ui") then
        if isfield(LD3.ui, "headless") then ld3_was_headless = LD3.ui.headless; end
    end
    LD3.ui = struct();
    LD3.ui.headless = ld3_was_headless;  // workflow'ai skaita abiem režimais

    // Kairysis stendo plotas
    stand = uicontrol(f, "style", "frame", "units", "normalized", "position", [0.01 0.16 0.62 0.80], ...
                      "backgroundcolor", [0.97 0.98 0.98], "relief", "groove");
    LD3.ui.standFrame = stand;
    [coords, labels] = ld3_stand_boxes();
    for k = 1:size(coords, 1)
        uicontrol(f, "style", "text", "units", "normalized", ...
            "position", coords(k, :), ...
            "string", labels(k), "fontname", "DejaVu Sans", "fontunits", "pixels", ...
            "fontsize", 11, "fontweight", "bold", "backgroundcolor", [0.88 0.93 0.95], ...
            "horizontalalignment", "center");
    end
    // Gnybtų mygtukai su [Txx] žymomis
    tids = ld3_terminal_ids();
    LD3.term = struct("handleIds", tids, "handles", []);
    for k = 1:size(tids, "*")
        p = ld3_terminal_pos(tids(k));
        h = uicontrol(f, "style", "pushbutton", "units", "normalized", ...
            "position", [p(1)-0.017 p(2)-0.013 0.034 0.026], "string", msprintf("T%02d", k), ...
            "tag", msprintf("T%02d", k), ...
            "tooltipstring", "[T" + msprintf("%02d", k) + "] " + ld3_terminal_name(tids(k)), ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 7, ...
            "callback", "ld3_terminal_click(""" + tids(k) + """)", ...
            "backgroundcolor", [0.25 0.45 0.30], "foregroundcolor", [1 1 1]);
        LD3.term.handles($+1) = h;
    end
    // Laidams piešti naudojama atskira ašis (ld3_render_wires) – rėmelio čia nereikia.
    // Įtampos slankiklis [V01] ir rodmuo [V02]
    uicontrol(f, "style", "text", "units", "normalized", "position", [0.03 0.10 0.07 0.05], ...
        "string", "[V01]", "fontsize", 9, "backgroundcolor", [0.97 0.98 0.98]);
    LD3.ui.voltSlider = uicontrol(f, "style", "slider", "units", "normalized", ...
        "position", [0.10 0.105 0.20 0.04], "min", 0, "max", 12, "value", 0, ...
        "tag", "V01", "tooltipstring", "[V01] Šaltinio įtampos nustatymas (0–12 V)", ...
        "callback", "ld3_slider_changed()");
    LD3.ui.voltLabel = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.31 0.10 0.07 0.05], "string", "0 V", "tag", "V02", ...
        "tooltipstring", "[V02] Dabartinė šaltinio įtampa", "fontsize", 11, ...
        "backgroundcolor", [0.97 0.98 0.98]);
    // Valdymo mygtukai
    ld3_button(f, [0.40 0.095 0.10 0.055], "Maitinimas", "ld3_toggle_power()", 9);
    ld3_button(f, [0.51 0.095 0.09 0.055], "Junglis", "ld3_toggle_switch()", 9);
    ld3_button(f, [0.61 0.095 0.09 0.055], "MATUOTI", "ld3_measure()", 9, [0.08 0.39 0.37]);

    // Matavimų žurnalas
    LD3.ui.journalList = uicontrol(f, "style", "listbox", "units", "normalized", ...
        "position", [0.03 0.185 0.16 0.10], "string", "Matavimai:", ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9);

    // Dešinysis skydelis: etapai + instrukcija + atsakymai
    panel = uicontrol(f, "style", "frame", "units", "normalized", "position", [0.65 0.16 0.34 0.80], ...
                      "backgroundcolor", [1 1 1], "relief", "groove");
    uicontrol(f, "style", "text", "units", "normalized", "position", [0.66 0.91 0.32 0.04], ...
        "string", "ETAPAI", "fontsize", 10, "fontweight", "bold", "backgroundcolor", [1 1 1]);
    for n = 1:6
        ld3_stage_button(f, [0.665 + (n-1)*0.053 0.855 0.05 0.045], n);
    end
    LD3.ui.instructionLine(1) = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.665 0.60 0.315 0.24], "string", ld3_step_instruction(1), ...
        "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 10, ...
        "horizontalalignment", "left", "backgroundcolor", [1 1 1]);
    // Atsakymų laukai pagal ld3_answer_slot žemėlapį
    etiketes = ["[A02.01] I1 teorinė, mA"; "[A04.01] R1, Ω"; "[A04.02] R2, Ω"; ...
                "[A04.03] R3, Ω"; "[A04.04] Rvid, Ω"; "[A05.01] R (nuolydis), Ω"; ...
                "[A06.01] Tiesinė? (1/2)"; "[A06.02] R pastovi? (1/2)"];
    LD3.ui.answerEdits = [];
    for k = 1:8
        uicontrol(f, "style", "text", "units", "normalized", ...
            "position", [0.665 0.545 - (k-1)*0.048 0.17 0.04], "string", etiketes(k), ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 9, ...
            "backgroundcolor", [1 1 1], "horizontalalignment", "left");
        h = uicontrol(f, "style", "edit", "units", "normalized", ...
            "position", [0.845 0.545 - (k-1)*0.048 0.13 0.04], "string", "", ...
            "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 10, ...
            "horizontalalignment", "right", "backgroundcolor", [0.97 0.98 0.98]);
        LD3.ui.answerEdits($+1) = h;
    end
    // Pagrindinis mygtukas ir pagalba
    LD3.ui.studentPrimary = ld3_button(f, [0.67 0.13 0.30 0.06], "TIKRINTI / TOLIAU", ...
        "ld3_student_primary()", 11, [0.08 0.39 0.37]);
    ld3_button(f, [0.665 0.185 0.14 0.045], "Kaip sujungti", "ld3_show_wiring_guide()", 8);
    ld3_button(f, [0.815 0.185 0.15 0.045], "Žemėlapis", "ld3_show_stand_map()", 8);
    ld3_button(f, [0.665 0.035 0.13 0.045], "Pavyzdys", "ld3_toggle_solution()", 8);
    ld3_button(f, [0.805 0.035 0.17 0.045], "Ataskaita", "bench_export_current(""LD3"")", 8);

    // Būsenos eilutės
    uicontrol(f, "style", "frame", "units", "normalized", "position", [0.01 0.005 0.98 0.085], ...
              "backgroundcolor", [0.90 0.95 0.95], "relief", "groove");
    LD3.ui.statusMain = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.02 0.05 0.96 0.036], "string", "Paruošta.", ...
        "fontsize", 12, "fontweight", "bold", "backgroundcolor", [0.90 0.95 0.95], ...
        "horizontalalignment", "left");
    LD3.ui.statusFix = uicontrol(f, "style", "text", "units", "normalized", ...
        "position", [0.02 0.012 0.96 0.036], "string", "", ...
        "fontsize", 10, "backgroundcolor", [0.90 0.95 0.95], "horizontalalignment", "left");

    // Visi mygtukai (su callbackais) į dynamic — workflow'ai jų ieško pagal callback (LD2 raštas).
    LD3.ui.dynamic = [];
    for k = 1:size(f.children, "*")
        c = f.children(k);
        if type(c) == 9 then  // graphics handle
            try
                if c.type == "uicontrol" & c.style == "pushbutton" & stripblanks(c.callback) ~= "" then
                    LD3.ui.dynamic($+1) = c;
                end
            catch
            end
        end
    end
    ld3_render_stage();
endfunction

function ld3_slider_changed()
    global LD3;
    if isfield(LD3, "ui") & isfield(LD3.ui, "voltSlider") & is_handle_valid(LD3.ui.voltSlider) then
        ld3_set_voltage(LD3.ui.voltSlider.value);
    end
endfunction

function ld3_render_wires()
    // Paprastas atvaizdavimas: laidai kaip linijos ant specialaus ašies.
    global LD3;
    if ~isfield(LD3, "ui") then return; end
    if isfield(LD3.ui, "headless") then if LD3.ui.headless then return; end end
    if isfield(LD3.ui, "wiresAxis") & is_handle_valid(LD3.ui.wiresAxis) then
        delete(LD3.ui.wiresAxis);
    end
    LD3.ui.wiresAxis = newaxes(LD3.fig);
    LD3.ui.wiresAxis.axes_bounds = [0.01 0.04 0.62 0.92];
    LD3.ui.wiresAxis.axes_visible = ["off" "off"];
    LD3.ui.wiresAxis.box = "off";
    for m = 1:size(LD3.wires, 1)
        p1 = ld3_terminal_pos(LD3.wires(m,1));
        p2 = ld3_terminal_pos(LD3.wires(m,2));
        // Į stendo koordinates (apytiksliai, per vidurį viršuje)
        xsegs([p1(1), p2(1)], [p1(2), p2(2)]);
    end
    LD3.ui.wiresAxis.isoview = "on";
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
    // Atsakymų laukai <- atsakymų saugykla
    if isfield(LD3.ui, "answerEdits") then
        for k = 1:size(LD3.ui.answerEdits, "*")
            h = LD3.ui.answerEdits(k);
            if is_handle_valid(h) then
                [st, sl] = ld3_answer_slot(k);
                h.string = LD3.answers(st, sl);
            end
        end
    end
    // Etapų mygtukų spalvos: atliktas žalias, praleistas geltonas, aktyvus mėlynas
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
    ld3_render_wires();
    ld3_render_journal();
endfunction
