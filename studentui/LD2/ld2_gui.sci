// ============================================================================
// LD2 GUI. Sąmoningai naudojami tik uicontrol elementai pagrindiniame lange.
// Grafikai atidaromi atskiruose languose, kad Scilab 2025.1 nesumaišytų
// axes ir uicontrol koordinačių.
// ============================================================================

function ld2_main(root)
    global LD2;
    oldid=-1;
    try oldid=LD2.ui.figure.figure_id; catch end
    if or(winsid()==oldid) then
        pick=x_choose(["PALIKTI DABARTINĮ STENDĄ";"UŽDARYTI IR PALEISTI NAUJĄ"], ...
            "LD2 langas jau atvertas. Prireikus pirma išsaugokite jo darbą.");
        if pick<>2 then return; end
        delete(LD2.ui.figure);
    end
    cfg = ld2_default_config();
    state = ld2_initial_state(cfg);
    LD2 = struct("root", root, "cfg", cfg, "state", state, "ui", struct("dummy",0,"headless",%f,"suppress_render",%f), ...
        "example_active",%f,"example_backup",struct("dummy",0));
    ld2_build_gui();
    ld2_go_step(1, %t);
endfunction

function ld2_build_gui()
    global LD2;
    f = figure("default_axes","off","dockable","off","menubar","none","toolbar","none");
    f.figure_name = "LD Nr. 2. Kintamosios srovės grandinių tyrimas • Scilab 2025.1";
    f.figure_position = [15 20];
    f.axes_size = [1360 820];
    f.menubar_visible = "off";
    f.toolbar_visible = "off";
    f.infobar_visible = "off";
    f.default_axes = "off";

    LD2.ui.figure = f;
    LD2.ui.dynamic = [];
    LD2.ui.term_handles = struct("dummy",0);
    LD2.ui.answer_edits = [];
    LD2.ui.answer_step = 0;
    LD2.ui.choice_yes = [];
    LD2.ui.choice_no = [];

    // Viršutinė antraštė
    uicontrol(f, "style","frame", "units","normalized", ...
        "position",[0.017 0.935 0.966 0.052], ...
        "backgroundcolor",[0.09 0.23 0.40]);
    uicontrol(f, "style","text", "units","normalized", ...
        "position",[0.03 0.944 0.94 0.032], ...
        "string","LD Nr. 2. KINTAMOSIOS SROVĖS GRANDINIŲ TYRIMAS", ...
        "fontname","Arial", "fontunits","pixels", "fontsize",17, "fontweight","bold", ...
        "horizontalalignment","center", ...
        "backgroundcolor",[0.09 0.23 0.40], "foregroundcolor",[1 1 1]);

    // Etapų juosta
    nav = uicontrol(f, "style","frame", "units","normalized", ...
        "position",[0.017 0.883 0.966 0.044], ...
        "backgroundcolor",[0.88 0.93 0.98]);
    LD2.ui.step_buttons = [];
    x0 = 0.012;
    bw = 0.047;
    gap = 0.006;
    for k = 1:12
        cb = msprintf("ld2_step_button(%d)", k);
        b = uicontrol(nav, "style","pushbutton", "units","normalized", ...
            "position",[x0+(k-1)*(bw+gap) 0.13 bw 0.74], ...
            "string",string(k), "fontname","Arial", "fontunits","pixels", "fontsize",10, "fontweight","bold", ...
            "callback",cb, "backgroundcolor",[0.94 0.94 0.94]);
        LD2.ui.step_buttons = [LD2.ui.step_buttons b];
    end
    LD2.ui.teacher = uicontrol(nav, "style","checkbox", "units","normalized", ...
        "position",[0.665 0.12 0.31 0.76], ...
        "string","DĖSTYTOJO / PERŽIŪROS REŽIMAS", ...
        "fontname","Arial", "fontunits","pixels", "fontsize",10, "fontweight","bold", ...
        "callback","ld2_teacher_toggle()", ...
        "backgroundcolor",[0.88 0.93 0.98]);

    // Pagrindinės darbo sritys
    LD2.ui.stand = uicontrol(f, "style","frame", "units","normalized", ...
        "position",[0.017 0.115 0.605 0.758], ...
        "backgroundcolor",[1 1 1]);
    LD2.ui.right = uicontrol(f, "style","frame", "units","normalized", ...
        "position",[0.637 0.115 0.346 0.758], ...
        "backgroundcolor",[0.97 0.97 0.97]);

    // Būsenos eilutė ir paleidimas iš naujo
    LD2.ui.status = uicontrol(f, "style","text", "units","normalized", ...
        "position",[0.017 0.025 0.650 0.070], ...
        "string","Laboratorija paruošta.", "fontname","Arial", "fontunits","pixels", "fontsize",11, ...
        "fontweight","bold", "horizontalalignment","left", ...
        "backgroundcolor",[0.88 0.93 0.98], ...
        "foregroundcolor",[0.05 0.18 0.32]);
    uicontrol(f,"style","pushbutton","units","normalized","position",[0.683 0.025 0.095 0.070], ...
        "string","IŠSAUGOTI","fontname","Arial","fontunits","pixels","fontsize",12,"callback","ld2_save_work()");
    uicontrol(f,"style","pushbutton","units","normalized","position",[0.786 0.025 0.095 0.070], ...
        "string","ATVERTI DARBĄ","fontname","Arial","fontunits","pixels","fontsize",11,"callback","ld2_load_work()");
    uicontrol(f,"style","pushbutton","units","normalized","position",[0.889 0.025 0.094 0.070], ...
        "string","IŠ NAUJO","fontname","Arial","fontunits","pixels","fontsize",12,"callback","ld2_restart()");
endfunction

function ld2_track(h)
    global LD2;
    LD2.ui.dynamic = [LD2.ui.dynamic h];
endfunction

function ld2_clear_dynamic()
    global LD2;
    if ~isfield(LD2.ui,"dynamic") then LD2.ui.dynamic=[]; end
    n = size(LD2.ui.dynamic, "*");
    if n > 0 then
        for k = n:-1:1
            delete(LD2.ui.dynamic(k));
        end
    end
    LD2.ui.dynamic = [];
    LD2.ui.term_handles = struct("dummy",0);
    LD2.ui.answer_edits = [];
    LD2.ui.answer_step = 0;
    LD2.ui.choice_yes = [];
    LD2.ui.choice_no = [];
endfunction

function h = ld2_frame(parent, pos, bg)
    h = uicontrol(parent, "style","frame", "units","normalized", ...
        "position",pos, "backgroundcolor",bg);
    ld2_track(h);
endfunction

function h = ld2_text(parent, pos, str, fs, bold, align, bg, fg)
    if size(strindex(str,ascii(10)),"*")>0 then str="<html>"+strsubst(str,ascii(10),"<br>")+"</html>"; end
    h = uicontrol(parent, "style","text", "units","normalized", ...
        "position",pos, "string",str, "fontname","Arial", "fontunits","pixels", "fontsize",max([11 fs]), ...
        "horizontalalignment",align, "backgroundcolor",bg, ...
        "foregroundcolor",fg);
    if bold then h.fontweight = "bold"; end
    ld2_track(h);
endfunction

function h = ld2_button(parent, pos, str, cb, fs, bg)
    h = uicontrol(parent, "style","pushbutton", "units","normalized", ...
        "position",pos, "string",str, "fontname","Arial", "fontunits","pixels", "fontsize",max([11 fs]), ...
        "callback",cb, "backgroundcolor",bg);
    ld2_track(h);
endfunction

function h = ld2_edit(parent, pos, value)
    h = uicontrol(parent, "style","edit", "units","normalized", ...
        "position",pos, "string",value, "fontname","Arial", "fontunits","pixels", "fontsize",13, ...
        "horizontalalignment","right", "backgroundcolor",[0.94 0.96 0.96],"relief","solid");
    ld2_track(h);
endfunction

function ld2_render_step()
    global LD2;
    if isfield(LD2.ui,"suppress_render") then
        if LD2.ui.suppress_render then return; end
    end
    if isfield(LD2.ui,"headless") then
        if LD2.ui.headless then return; end
    end
    ld2_save_answers();
    ld2_clear_dynamic();
    ld2_render_instructions();
    ld2_render_controls();
    ld2_render_answers();
    ld2_render_action_row();
    ld2_render_stand();
    ld2_update_nav_colors();
endfunction

function ld2_render_instructions()
    global LD2;
    fr=ld2_frame(LD2.ui.right,[0.025 0.742 0.950 0.245],[1 1 1]);
    ttl=ld2_step_title(LD2.state.step);
    if LD2.example_active then ttl="PAVYZDYS • "+ttl; end
    ld2_text(fr,[0.025 0.81 0.95 0.15],ttl,13,%t,"left",[1 1 1],[0.04 0.15 0.25]);
    lines=ld2_wrap_lines(ld2_instruction_lines(LD2.state.step),62);
    h=uicontrol(fr,"style","listbox","units","normalized", ...
        "position",[0.025 0.035 0.95 0.75],"string",lines, ...
        "fontname","Arial","fontunits","pixels","fontsize",12, ...
        "backgroundcolor",[1 1 1],"foregroundcolor",[0.06 0.08 0.10]);
    ld2_track(h);
endfunction

function ld2_render_controls()
    global LD2;
    p = LD2.ui.right;
    step = LD2.state.step;
    fr = ld2_frame(p, [0.025 0.423 0.950 0.300], [0.985 0.985 0.985]);
    ld2_text(fr, [0.035 0.860 0.93 0.105], "STENDO VALDYMAS", ...
        12, %t, "left", [0.985 0.985 0.985], [0.05 0.12 0.20]);

    phase = ld2_phase_for_step(step);
    if phase <> "OVERVIEW" then
        ld2_text(fr, [0.035 0.725 0.25 0.10], "Generatorius:", ...
            10, %t, "left", [0.985 0.985 0.985], [0.05 0.05 0.05]);
        if LD2.state.power then
            ps = "ĮJUNGTA"; pbg = [0.72 0.94 0.72];
        else
            ps = "IŠJUNGTA"; pbg = [0.94 0.82 0.82];
        end
        LD2.ui.power_btn = ld2_button(fr, [0.67 0.705 0.285 0.13], ...
            ps, "ld2_power_toggle()", 10, pbg);
        select phase
        case "RC" then e=LD2.cfg.E_RC;
        case "RL" then e=LD2.cfg.E_RL;
        case "RLC" then e=LD2.cfg.E_RLC;
        end
        ld2_text(fr, [0.285 0.725 0.35 0.10], ...
            msprintf("%.3f V RMS", e), 10, %f, "left", ...
            [0.985 0.985 0.985], [0.05 0.05 0.05]);
    end

    if step == 1 then
        ld2_button(fr, [0.035 0.62 0.44 0.17], "PARAMETRAI", ...
            "ld2_edit_parameters()", 11, [0.86 0.92 0.98]);
        ld2_button(fr, [0.525 0.62 0.44 0.17], "METODIKOS PATAISYMAI", ...
            "ld2_show_method_fixes()", 10, [0.93 0.90 0.78]);
        ld2_button(fr, [0.035 0.36 0.44 0.17], "RC / RL FORMULĖS", ...
            "ld2_show_theory()", 10, [0.94 0.94 0.94]);
        ld2_button(fr, [0.525 0.36 0.44 0.17], "RLC REZONANSO FORMULĖS", ...
            "ld2_show_resonance_theory()", 10, [0.94 0.94 0.94]);
        return;
    end

    // Sujungimo etapuose prietaisų rodmenys nerodomi: taip nelieka kolizijų.
    if step == 2 | step == 5 | step == 8 then
        ld2_text(fr, [0.035 0.555 0.93 0.105], ...
            "Generatorius turi likti IŠJUNGTAS, kol tikrinamas sujungimas.", ...
            9.5, %t, "left", [0.985 0.985 0.985], [0.45 0.18 0.02]);
        ld2_button(fr, [0.035 0.390 0.93 0.13], "TIKRINTI SUJUNGIMĄ", ...
            "ld2_check_wiring()", 10, [0.82 0.91 0.99]);
        ld2_button(fr, [0.035 0.220 0.45 0.13], "ATŠAUKTI LAIDĄ", ...
            "ld2_undo_wire()", 9.2, [0.95 0.95 0.95]);
        ld2_button(fr, [0.515 0.220 0.45 0.13], "IŠVALYTI VISUS LAIDUS", ...
            "ld2_clear_phase_wires()", 9.2, [0.96 0.90 0.90]);
        ld2_text(fr, [0.035 0.065 0.93 0.10], ...
            "PAVYZDYS pateikia sunumeruotą visų laidų sąrašą.", ...
            9.0, %f, "left", [0.985 0.985 0.985], [0.10 0.10 0.10]);
        return;
    end

    // Skaičiavimo etapuose valdymo skydas neapkraunamas nereikalingais matuokliais.
    if step == 3 | step == 6 then
        if step==3 then
            p1=msprintf("E=%.1f V, f=%.1f Hz, R8=%.0f Ω, C2=%.3f µF", ...
                LD2.cfg.E_RC,LD2.cfg.F_RC,LD2.cfg.R8,LD2.cfg.C2*1e6);
        else
            p1=msprintf("E=%.1f V, f=%.1f Hz, R9=%.0f Ω, L1=%.3f H", ...
                LD2.cfg.E_RL,LD2.cfg.F_RL,LD2.cfg.R9,LD2.cfg.L1);
        end
        ld2_text(fr,[0.035 0.560 0.93 0.12],p1,9.8,%t,"left", ...
            [0.985 0.985 0.985],[0.05 0.05 0.05]);
        ld2_button(fr,[0.035 0.365 0.45 0.15],"ATVERTI FORMULES", ...
            "ld2_show_theory()",10,[0.90 0.94 0.98]);
        ld2_button(fr,[0.515 0.365 0.45 0.15],"PAVYZDYS SU SKAIČIAIS", ...
            "ld2_show_solution()",9.5,[0.90 0.94 0.98]);
        ld2_text(fr,[0.035 0.170 0.93 0.12], ...
            "Atsakymus įrašykite dešinėje apačioje nurodytais vienetais.", ...
            9.5,%f,"left",[0.985 0.985 0.985],[0.10 0.10 0.10]);
        return;
    end

    // RLC dažnio tyrimo etapai turi atskirą kompaktišką išdėstymą.
    if phase == "RLC" & step >= 9 then
        ld2_text(fr, [0.035 0.590 0.20 0.10], "Dažnis:", ...
            10, %t, "left", [0.985 0.985 0.985], [0.05 0.05 0.05]);
        LD2.ui.freq_edit = ld2_edit(fr, [0.21 0.575 0.25 0.13], ld2_num(LD2.state.freq,3));
        ld2_text(fr, [0.47 0.590 0.08 0.10], "Hz", ...
            10, %f, "left", [0.985 0.985 0.985], [0.05 0.05 0.05]);
        ld2_button(fr, [0.59 0.570 0.37 0.14], "NUSTATYTI DAŽNĮ", ...
            "ld2_apply_frequency()", 9.2, [0.88 0.92 0.96]);

        LD2.ui.freq_slider = uicontrol(fr, "style","slider", "units","normalized", ...
            "position",[0.035 0.470 0.925 0.085], ...
            "min",max([1 LD2.cfg.F_MIN]), "max",LD2.cfg.F_MAX, ...
            "value",max([1 LD2.state.freq]), "callback","ld2_frequency_slider()");
        ld2_track(LD2.ui.freq_slider);
        ld2_button(fr, [0.035 0.345 0.205 0.10], "−1 Hz", ...
            "ld2_frequency_delta(-1)", 8.8, [0.94 0.94 0.94]);
        ld2_button(fr, [0.275 0.345 0.205 0.10], "−10 Hz", ...
            "ld2_frequency_delta(-10)", 8.8, [0.94 0.94 0.94]);
        ld2_button(fr, [0.515 0.345 0.205 0.10], "+10 Hz", ...
            "ld2_frequency_delta(10)", 8.8, [0.94 0.94 0.94]);
        ld2_button(fr, [0.755 0.345 0.205 0.10], "+1 Hz", ...
            "ld2_frequency_delta(1)", 8.8, [0.94 0.94 0.94]);

        ld2_text(fr, [0.035 0.215 0.10 0.09], "V~", 10, %t, "left", ...
            [0.985 0.985 0.985], [0.05 0.05 0.05]);
        LD2.ui.volt_display = ld2_text(fr, [0.13 0.205 0.32 0.105], ...
            ld2_volt_display_text(), 9.7, %t, "center", ...
            [0.04 0.08 0.06], [0.35 1.00 0.55]);
        ld2_button(fr, [0.48 0.200 0.23 0.115], "MATUOTI U", ...
            "ld2_measure_voltage()", 9.0, [0.90 0.94 0.98]);
        ld2_button(fr, [0.73 0.200 0.23 0.115], "MATUOTI I", ...
            "ld2_measure_current()", 9.0, [0.90 0.94 0.98]);

        if step == 9 then
            ld2_button(fr, [0.035 0.045 0.29 0.115], "ĮRAŠYTI TAŠKĄ", ...
                "ld2_record_resonance_point()", 8.6, [0.83 0.93 0.84]);
            ld2_button(fr, [0.355 0.045 0.29 0.115], "NUIMTI ZONDUS", ...
                "ld2_remove_voltage_probes()", 8.4, [0.95 0.95 0.95]);
            ld2_button(fr, [0.675 0.045 0.29 0.115], "IŠVALYTI TAŠKUS", ...
                "ld2_clear_resonance_points()", 8.4, [0.96 0.90 0.90]);
        elseif step == 10 then
            ld2_button(fr, [0.035 0.045 0.45 0.115], "NUIMTI ZONDUS", ...
                "ld2_remove_voltage_probes()", 8.8, [0.95 0.95 0.95]);
            ld2_button(fr, [0.515 0.045 0.45 0.115], "ĮRAŠYTI TAŠKĄ", ...
                "ld2_record_peak_point()", 8.8, [0.95 0.95 0.95]);
        elseif step == 11 then
            ld2_button(fr, [0.035 0.045 0.29 0.115], "ĮRAŠYTI f1", ...
                "ld2_record_f1()", 8.8, [0.83 0.93 0.84]);
            ld2_button(fr, [0.355 0.045 0.29 0.115], "ĮRAŠYTI f2", ...
                "ld2_record_f2()", 8.8, [0.83 0.93 0.84]);
            ld2_button(fr, [0.675 0.045 0.29 0.115], "NUIMTI ZONDUS", ...
                "ld2_remove_voltage_probes()", 8.4, [0.95 0.95 0.95]);
        else
            ld2_button(fr, [0.035 0.045 0.45 0.115], "SKENUOTI 0–10 kHz", ...
                "ld2_run_sweep()", 8.4, [0.83 0.93 0.84]);
            ld2_button(fr, [0.515 0.045 0.45 0.115], "EKSPORTUOTI CSV", ...
                "ld2_export_csv()", 8.8, [0.90 0.94 0.98]);
        end
        return;
    end

    // Kiti etapai: abu matavimo prietaisai.
    if phase <> "OVERVIEW" then
        y0 = 0.47;
        ld2_text(fr, [0.035 y0 0.12 0.10], "A~", 10, %t, "left", ...
            [0.985 0.985 0.985], [0.05 0.05 0.05]);
        LD2.ui.amp_display = ld2_text(fr, [0.15 y0-0.005 0.35 0.115], ...
            ld2_amp_display_text(), 10, %t, "center", [0.04 0.08 0.06], [0.35 1.00 0.55]);
        ld2_button(fr, [0.52 y0-0.005 0.44 0.115], "MATUOTI I", ...
            "ld2_measure_current()", 9.5, [0.90 0.94 0.98]);

        y1 = y0 - 0.145;
        ld2_text(fr, [0.035 y1 0.12 0.10], "V~", 10, %t, "left", ...
            [0.985 0.985 0.985], [0.05 0.05 0.05]);
        LD2.ui.volt_display = ld2_text(fr, [0.15 y1-0.005 0.35 0.115], ...
            ld2_volt_display_text(), 10, %t, "center", [0.04 0.08 0.06], [0.35 1.00 0.55]);
        ld2_button(fr, [0.52 y1-0.005 0.44 0.115], "MATUOTI U", ...
            "ld2_measure_voltage()", 9.5, [0.90 0.94 0.98]);
    end

    if step == 4 | step == 7 then
        ld2_button(fr, [0.035 0.075 0.45 0.12], "NUIMTI ZONDUS", ...
            "ld2_remove_voltage_probes()", 9, [0.95 0.95 0.95]);
        ld2_button(fr, [0.515 0.075 0.45 0.12], "ATŠAUKTI LAIDĄ", ...
            "ld2_undo_wire()", 9, [0.95 0.95 0.95]);
    end
endfunction

function ld2_render_answers()
    global LD2;
    p = LD2.ui.right;
    step = LD2.state.step;
    fr = ld2_frame(p, [0.025 0.104 0.950 0.303], [1 1 1]);
    heading="JŪSŲ ATSAKYMAI / MATAVIMAI";
    if LD2.example_active then heading="PAVYZDŽIO ATSAKYMAI / MATAVIMAI"; end
    ld2_text(fr, [0.035 0.865 0.93 0.10], heading, ...
        11.5, %t, "left", [1 1 1], [0.05 0.12 0.20]);

    [labels, n] = ld2_answer_spec(step);
    LD2.ui.answer_edits = [];
    LD2.ui.answer_step = step;
    if n > 0 then
        rowh = 0.092;
        y = 0.745;
        for k = 1:n
            ld2_text(fr, [0.035 y 0.57 rowh], labels(k), ...
                9.5, %f, "left", [1 1 1], [0.05 0.05 0.05]);
            vs = LD2.state.answers_text(step,k);
            e = ld2_edit(fr, [0.64 y+0.005 0.31 rowh], vs);
            LD2.ui.answer_edits = [LD2.ui.answer_edits e];
            y = y - 0.103;
        end
    else
        lines = ld2_summary_lines_for_step(step);
        y = 0.72;
        for k = 1:min([size(lines,"*") 6])
            ld2_text(fr, [0.035 y 0.93 0.105], lines(k), ...
                9.5, %f, "left", [1 1 1], [0.06 0.06 0.06]);
            y = y - 0.12;
        end
        if step==12 then
            ld2_button(fr,[0.035 0.045 0.45 0.12],"IŠVADOS", ...
                "ld2_edit_conclusions()",11,[0.90 0.94 0.98]);
            ld2_button(fr,[0.515 0.045 0.45 0.12],"ATSAKYMŲ SUVESTINĖ", ...
                "ld2_show_summary_window()",11,[0.90 0.94 0.98]);
        end
    end
endfunction

function ld2_render_action_row()
    global LD2;
    p = LD2.ui.right;
    fr = ld2_frame(p, [0.025 0.009 0.950 0.080], [0.97 0.97 0.97]);
    if LD2.example_active then sample_label="MANO DARBAS"; else sample_label="PAVYZDYS"; end
    ld2_button(fr, [0.00 0.53 0.31 0.43], sample_label, ...
        "ld2_show_solution()", 8.7, [0.91 0.94 0.98]);
    ld2_button(fr, [0.345 0.53 0.31 0.43], "TEORIJA / PAGALBA", ...
        "ld2_help_current()", 8.7, [0.94 0.94 0.94]);
    ld2_button(fr, [0.69 0.53 0.31 0.43], "PATIKRINTI ETAPĄ", ...
        "ld2_check_step()", 8.7, [0.80 0.92 0.82]);
    ld2_button(fr, [0.00 0.02 0.31 0.40], "← ATGAL", ...
        "ld2_prev()", 8.7, [0.95 0.95 0.95]);
    ld2_button(fr, [0.345 0.02 0.31 0.40], "GRAFIKAS", ...
        "ld2_plot_current()", 8.3, [0.95 0.95 0.95]);
    ld2_button(fr, [0.69 0.02 0.31 0.40], "TOLIAU →", ...
        "ld2_next()", 8.7, [0.95 0.95 0.95]);
endfunction

function [labels,n]=ld2_answer_spec(step)
    labels=emptystr(0,1);
    select step
    case 3 then labels=["XC, Ω";"|Z|, Ω";"I, mA";"UR8, V";"UC2, V";"P, mW";"φI, ° (srovės fazė)"];
    case 4 then labels=["E iš matuotų UR ir UC, V";"I = UR8/R8, mA"];
    case 6 then labels=["XL, Ω";"|Z|, Ω";"I, mA";"UR9, V";"UL1, V";"P, mW";"φI, ° (srovės fazė)"];
    case 7 then labels=["E iš matuotų UR ir UL, V";"I = UR9/R9, mA"];
    case 9 then labels=["fr teorinis, Hz";"fr iš taškų maksimumo, Hz";"Periodas T = 1000/fr, ms";"UR13 maksimumas, V"];
    case 10 then labels=["UL maksimumas, V";"UC maksimumas, V";"ULC minimumas, V";"f ties UL maksimumu, Hz";"f ties UC maksimumu, Hz";"f ties ULC minimumu, Hz"];
    case 11 then labels=["UR13 slenkstis, V";"Užfiksuotas f1, Hz";"Užfiksuotas f2, Hz";"BW = f2-f1, Hz";"Q = fr/BW"];
    end
    n=size(labels,"*");
endfunction

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
          "Numatytosios R8/R9/R13/L3/C4 vertės yra redaguojamos."];
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
    if ~ok then txt="— mA"; return; end
    if ~LD2.state.power then txt="— mA"; return; end
    x=LD2.state.amp_live;
    if isnan(x) then txt="— mA"; else txt=ld2_num(x*1000,3)+" mA"; end
endfunction

function txt = ld2_volt_display_text()
    global LD2;
    phase = ld2_phase_for_step(LD2.state.step);
    target = ld2_detect_voltage_target(phase);
    if target == "" then txt="— V"; return; end
    if ~LD2.state.power then txt="— V"; return; end
    x=LD2.state.volt_live;
    if LD2.state.volt_live_target<>target then x=%nan; end
    if isnan(x) then txt="— V"; else txt=ld2_num(x,3)+" V"; end
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

// ---------------------------------------------------------------------------
// Stendo braižymas
// ---------------------------------------------------------------------------

function ld2_render_stand()
    global LD2;
    step=LD2.state.step;
    phase=ld2_phase_for_step(step);
    p=LD2.ui.stand;
    if phase=="OVERVIEW" then
        ld2_draw_overview(p);
    else
        ld2_draw_phase_stand(p, phase, step);
    end
endfunction

function ld2_draw_overview(parent)
    global LD2;
    ld2_text(parent,[0.03 0.90 0.94 0.06], ...
        "LD2 STRUKTŪRA: RC → RL → NUOSEKLUS RLC REZONANSAS", ...
        14,%t,"left",[1 1 1],[0.05 0.18 0.32]);
    ld2_component_card(parent,[0.05 0.51 0.26 0.27],"I DALIS","NUOSEKLI RC", ...
        ["XC=1/(2πfC)"; "Z=R−jXC"; "I pirmauja U"],[0.91 0.95 1.00]);
    ld2_component_card(parent,[0.37 0.51 0.26 0.27],"II DALIS","NUOSEKLI RL", ...
        ["XL=2πfL"; "Z=R+jXL"; "I atsilieka nuo U"],[0.94 0.97 0.91]);
    ld2_component_card(parent,[0.69 0.51 0.26 0.27],"III DALIS","RLC REZONANSAS", ...
        ["XL=XC"; "fr=1/(2π√LC)"; "I ir UR – maksimumas"],[1.00 0.96 0.88]);
    ld2_text(parent,[0.06 0.30 0.88 0.08], ...
        "Svarbu: šaltinio ir elementų įtampos AC grandinėse sudedamos kaip fazoriai.", ...
        12,%t,"center",[1 1 1],[0.38 0.16 0.03]);
    ld2_text(parent,[0.06 0.20 0.88 0.06], ...
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

function active = ld2_active_terminals(step)
    select step
    case 2 then
        active=["GEN_H";"GEN_L";"AM_H";"AM_L";"R8_1";"R8_2";"C2_1";"C2_2"];
    case 4 then
        active=["VM_H";"VM_L";"R8_M1";"R8_M2";"C2_M1";"C2_M2";"GEN_MH";"GEN_ML"];
    case 5 then
        active=["GEN_H";"GEN_L";"AM_H";"AM_L";"R9_1";"R9_2";"L1_1";"L1_2"];
    case 7 then
        active=["VM_H";"VM_L";"R9_M1";"R9_M2";"L1_M1";"L1_M2";"GEN_MH";"GEN_ML"];
    case 8 then
        active=["GEN_H";"GEN_L";"AM_H";"AM_L";"C4_1";"C4_2";"L3_1";"L3_2";"R13_1";"R13_2"];
    case 9 then
        active=["VM_H";"VM_L";"R13_M1";"R13_M2"];
    case 10 then
        active=["VM_H";"VM_L";"L3_M1";"L3_M2";"C4_M1";"C4_M2";"LC_M1";"LC_M2"];
    case 12 then
        active=["VM_H";"VM_L";"R13_M1";"R13_M2"];
    case 11 then
        active=["VM_H";"VM_L";"R13_M1";"R13_M2"];
    else
        active=emptystr(0,1);
    end
endfunction

function tf = ld2_in_string_list(id, listv)
    tf=%f;
    for k=1:size(listv,"*")
        if id==listv(k) then tf=%t; return; end
    end
endfunction

function ld2_draw_phase_stand(parent, phase, step)
    global LD2;
    c=ld2_get_phase_connections(phase);
    active=ld2_active_terminals(step);
    ld2_text(parent,[0.03 0.91 0.64 0.055], ...
        phase+" GRANDINĖ  •  mėlyna/violetinė – laisva  •  žalia – prijungta", ...
        11.0,%t,"left",[1 1 1],[0.05 0.18 0.32]);
    ld2_text(parent,[0.70 0.91 0.27 0.055], ...
        msprintf("Laidų: %d",size(c,1)),10,%t,"right",[1 1 1],[0.05 0.18 0.32]);

    for k=1:size(c,1)
        ld2_draw_connection(parent,phase,c(k,1),c(k,2));
    end

    if phase=="RC" then
        ld2_draw_chain_common(parent,"RC", ...
            msprintf("R8 = %.0f Ω",LD2.cfg.R8), ...
            msprintf("C2 = %.3f µF",LD2.cfg.C2*1e6), ...
            "R8","C2",active,c);
    elseif phase=="RL" then
        ld2_draw_chain_common(parent,"RL", ...
            msprintf("R9 = %.0f Ω",LD2.cfg.R9), ...
            msprintf("L1 = %.3f H",LD2.cfg.L1), ...
            "R9","L1",active,c);
    else
        ld2_draw_rlc_chain(parent,active,c);
    end


    ld2_render_measurement_history(parent);
    ld2_render_stand_tools(parent);
endfunction

function ld2_draw_chain_common(parent,phase,labelR,labelX,prefixR,prefixX,active,c)
    global LD2;
    // Komponentai
    ld2_component_box(parent,[0.04 0.40 0.15 0.20],"GENERATORIUS", ...
        ld2_source_text(phase),[0.90 0.95 1.00]);
    ld2_component_box(parent,[0.27 0.55 0.12 0.14],"A~", ...
        "AMPERMETRAS",[0.91 0.97 0.92]);
    ld2_component_box(parent,[0.48 0.55 0.13 0.14],labelR, ...
        "AKTYVIOJI VARŽA",[1.00 0.97 0.87]);
    ld2_component_box(parent,[0.70 0.55 0.13 0.14],labelX, ...
        "REAKTYVUS ELEMENTAS",[1.00 0.97 0.87]);
    ld2_component_box(parent,[0.42 0.14 0.20 0.14],"V~ VOLTMETRAS", ...
        "RMS",[0.91 0.97 0.92]);

    ids=["GEN_H";"GEN_L";"GEN_MH";"GEN_ML";"AM_H";"AM_L"; ...
         prefixR+"_1";prefixR+"_2";prefixR+"_M1";prefixR+"_M2"; ...
         prefixX+"_1";prefixX+"_2";prefixX+"_M1";prefixX+"_M2";"VM_H";"VM_L"];
    labs=["~";"0";"M~";"M0";"A";"COM"; ...
          "1";"2";"M1";"M2";"1";"2";"M1";"M2";"V";"COM"];
    for k=1:size(ids,"*")
        [x,y]=ld2_terminal_xy(phase,ids(k));
        ld2_draw_terminal(parent,ids(k),labs(k),[x y],active,c);
    end

endfunction

function s=ld2_source_text(phase)
    global LD2;
    select phase
    case "RC" then s=msprintf("%.1f V RMS • %.1f Hz",LD2.cfg.E_RC,LD2.cfg.F_RC);
    case "RL" then s=msprintf("%.1f V RMS • %.1f Hz",LD2.cfg.E_RL,LD2.cfg.F_RL);
    case "RLC" then s=msprintf("%.1f V RMS • %.1f Hz",LD2.cfg.E_RLC,LD2.state.freq);
    end
endfunction

function ld2_draw_rlc_chain(parent,active,c)
    global LD2;
    ld2_component_box(parent,[0.025 0.40 0.13 0.20],"GENERATORIUS", ...
        ld2_source_text("RLC"),[0.90 0.95 1.00]);
    ld2_component_box(parent,[0.22 0.55 0.10 0.13],"A~", ...
        "AMPERMETRAS",[0.91 0.97 0.92]);
    ld2_component_box(parent,[0.39 0.55 0.10 0.13], ...
        msprintf("C4 = %.2f nF",LD2.cfg.C4*1e9),"KONDENSATORIUS",[1.00 0.97 0.87]);
    ld2_component_box(parent,[0.56 0.55 0.10 0.13], ...
        msprintf("L3 = %.2f mH",LD2.cfg.L3*1e3),"RITĖ",[1.00 0.97 0.87]);
    ld2_component_box(parent,[0.73 0.55 0.10 0.13], ...
        msprintf("R13 = %.0f Ω",LD2.cfg.R13),"REZISTORIUS",[1.00 0.97 0.87]);
    ld2_component_box(parent,[0.42 0.14 0.20 0.14],"V~ VOLTMETRAS", ...
        "RMS",[0.91 0.97 0.92]);

    ids=["GEN_H";"GEN_L";"GEN_MH";"GEN_ML";"AM_H";"AM_L"; ...
         "C4_1";"C4_2";"C4_M1";"C4_M2"; ...
         "L3_1";"L3_2";"L3_M1";"L3_M2"; ...
         "R13_1";"R13_2";"R13_M1";"R13_M2"; ...
         "LC_M1";"LC_M2";"VM_H";"VM_L"];
    labs=["~";"0";"M~";"M0";"A";"COM"; ...
          "1";"2";"M1";"M2";"1";"2";"M1";"M2"; ...
          "1";"2";"M1";"M2";"LC1";"LC2";"V";"COM"];
    for k=1:size(ids,"*")
        [x,y]=ld2_terminal_xy("RLC",ids(k));
        ld2_draw_terminal(parent,ids(k),labs(k),[x y],active,c);
    end
endfunction

function ld2_component_box(parent,pos,main,sub,bg)
    fr=ld2_frame(parent,pos,bg);
    equal=strindex(main," = ");
    if size(equal,"*")>0 then
        name=part(main,1:equal(1)-1);
        val=part(main,(equal(1)+3):length(main));
        ld2_text(fr,[0.02 0.62 0.96 0.28],name,14,%t,"center",bg,[0.04 0.09 0.14]);
        ld2_text(fr,[0.02 0.20 0.96 0.28],val,12,%f,"center",bg,[0.08 0.12 0.18]);
    else
        ld2_text(fr,[0.02 0.60 0.96 0.29],main,12,%t,"center",bg,[0.04 0.09 0.14]);
        dot=strindex(sub," • ");
        if size(dot,"*")>0 then
            s1=part(sub,1:dot(1)-1); s2=part(sub,(dot(1)+3):length(sub));
            ld2_text(fr,[0.02 0.31 0.96 0.22],s1,11,%f,"center",bg,[0.1 0.1 0.1]);
            ld2_text(fr,[0.02 0.06 0.96 0.22],s2,11,%f,"center",bg,[0.1 0.1 0.1]);
        else
            if main=="A~" then sub="C = COM"; end
            if main=="V~ VOLTMETRAS" then sub="V ir C (COM) • RMS"; end
            ld2_text(fr,[0.02 0.10 0.96 0.32],sub,11,%f,"center",bg,[0.1 0.1 0.1]);
        end
    end
endfunction

function [x,y]=ld2_terminal_xy(phase,id)
    // Koordinatės yra lizdo centro kairiojo-apatinio kampo pozicija.
    if phase=="RC" | phase=="RL" then
        select id
        case "GEN_H" then x=0.187; y=0.545;
        case "GEN_L" then x=0.187; y=0.415;
        case "GEN_MH" then x=0.075; y=0.70;
        case "GEN_ML" then x=0.075; y=0.335;
        case "AM_H" then x=0.247; y=0.600;
        case "AM_L" then x=0.392; y=0.600;
        case "R8_1" then x=0.452; y=0.600;
        case "R8_2" then x=0.612; y=0.600;
        case "R8_M1" then x=0.492; y=0.495;
        case "R8_M2" then x=0.572; y=0.495;
        case "C2_1" then x=0.672; y=0.600;
        case "C2_2" then x=0.832; y=0.600;
        case "C2_M1" then x=0.712; y=0.495;
        case "C2_M2" then x=0.792; y=0.495;
        case "R9_1" then x=0.452; y=0.600;
        case "R9_2" then x=0.612; y=0.600;
        case "R9_M1" then x=0.492; y=0.495;
        case "R9_M2" then x=0.572; y=0.495;
        case "L1_1" then x=0.672; y=0.600;
        case "L1_2" then x=0.832; y=0.600;
        case "L1_M1" then x=0.712; y=0.495;
        case "L1_M2" then x=0.792; y=0.495;
        case "VM_H" then x=0.435; y=0.285;
        case "VM_L" then x=0.585; y=0.285;
        else x=0.01; y=0.01;
        end
    else
        select id
        case "GEN_H" then x=0.147; y=0.545;
        case "GEN_L" then x=0.147; y=0.415;
        case "GEN_MH" then x=0.055; y=0.70;
        case "GEN_ML" then x=0.055; y=0.335;
        case "AM_H" then x=0.187; y=0.597;
        case "AM_L" then x=0.322; y=0.597;
        case "C4_1" then x=0.357; y=0.597;
        case "C4_2" then x=0.492; y=0.597;
        case "C4_M1" then x=0.400; y=0.485;
        case "C4_M2" then x=0.455; y=0.485;
        case "L3_1" then x=0.527; y=0.597;
        case "L3_2" then x=0.662; y=0.597;
        case "L3_M1" then x=0.570; y=0.485;
        case "L3_M2" then x=0.625; y=0.485;
        case "R13_1" then x=0.697; y=0.597;
        case "R13_2" then x=0.832; y=0.597;
        case "R13_M1" then x=0.740; y=0.485;
        case "R13_M2" then x=0.795; y=0.485;
        case "LC_M1" then x=0.380; y=0.425;
        case "LC_M2" then x=0.645; y=0.425;
        case "VM_H" then x=0.435; y=0.285;
        case "VM_L" then x=0.585; y=0.285;
        else x=0.01; y=0.01;
        end
    end
endfunction

function ld2_draw_terminal(parent,id,label,xy,active,c)
    global LD2;
    if label=="COM" then label="C"; end
    used=ld2_terminal_used(c,id);
    isactive=ld2_in_string_list(id,active);
    selected=(LD2.state.selected_terminal==id);
    ismeasure=(size(strindex(id,"_M"),"*")>0 | id=="LC_M1" | id=="LC_M2" | id=="VM_H" | id=="VM_L");
    if used then
        bg=[0.20 0.62 0.35]; fg=[1 1 1];
    elseif selected then
        bg=[1.00 0.72 0.12]; fg=[0.10 0.10 0.10];
    elseif ismeasure then
        bg=[0.54 0.33 0.77]; fg=[1 1 1];
    else
        bg=[0.17 0.49 0.80]; fg=[1 1 1];
    end
    pos=[xy(1) xy(2) 0.028 0.038];
    if isactive & ~used then
        cb=msprintf("ld2_terminal_click(""%s"")",id);
        h=uicontrol(parent,"style","pushbutton","units","normalized", ...
            "position",pos,"string",label,"fontname","Arial", "fontunits","pixels", "fontsize",11,"fontweight","bold", ...
            "callback",cb,"tooltipstring",ld2_terminal_name(id), ...
            "margins",[0 0 0 0],"backgroundcolor",bg,"foregroundcolor",fg);
        ld2_track(h);
    else
        ld2_text(parent,pos,label,8.2,%t,"center",bg,fg);
    end
endfunction

function ld2_draw_connection(parent,phase,a,b)
    // Spalva parenkama pagal grandinės vietą.
    if a=="VM_H" | a=="VM_L" | b=="VM_H" | b=="VM_L" then
        col=[0.52 0.35 0.44];
    elseif a=="GEN_L" | b=="GEN_L" then
        col=[0.41 0.49 0.51];
    else
        col=[0.22 0.40 0.42];
    end
    [x1,y1]=ld2_terminal_xy(phase,a);
    [x2,y2]=ld2_terminal_xy(phase,b);
    x1=x1+0.014; y1=y1+0.019;
    x2=x2+0.014; y2=y2+0.019;

    if a=="VM_H" | a=="VM_L" then
        vm=a; other=b;
    elseif b=="VM_H" | b=="VM_L" then
        vm=b; other=a;
    else
        vm=""; other="";
    end

    if vm<>"" then
        if other=="GEN_MH" then
            [vx,vy]=ld2_terminal_xy(phase,vm); vx=vx+0.014; vy=vy+0.019;
            [gx,gy]=ld2_terminal_xy(phase,other); gx=gx+0.014; gy=gy+0.019;
            lane=0.355; if vm=="VM_L" then lane=0.325; end
            ld2_wire_segment(parent,vx,vy,vx,lane,col);
            ld2_wire_segment(parent,vx,lane,0.012,lane,col);
            ld2_wire_segment(parent,0.012,lane,0.012,0.710,col);
            ld2_wire_segment(parent,0.012,0.710,gx,0.710,col);
            ld2_wire_segment(parent,gx,0.710,gx,gy,col);
            return;
        end
        if vm=="VM_H" then lane=0.355; else lane=0.325; end
        ld2_wire_segment(parent,x1,y1,x1,lane,col);
        ld2_wire_segment(parent,x1,lane,x2,lane,col);
        ld2_wire_segment(parent,x2,lane,x2,y2,col);
    elseif (a=="GEN_L" | b=="GEN_L") then
        lane=0.380;
        ld2_wire_segment(parent,x1,y1,x1,lane,col);
        ld2_wire_segment(parent,x1,lane,x2,lane,col);
        ld2_wire_segment(parent,x2,lane,x2,y2,col);
    else
        lane=max([y1 y2]);
        if abs(y1-y2)<0.01 then
            ld2_wire_segment(parent,x1,y1,x2,y2,col);
        else
            ld2_wire_segment(parent,x1,y1,x1,lane,col);
            ld2_wire_segment(parent,x1,lane,x2,lane,col);
            ld2_wire_segment(parent,x2,lane,x2,y2,col);
        end
    end
endfunction

function ld2_wire_segment(parent,x1,y1,x2,y2,col)
    t=0.003;
    if abs(x2-x1)>=abs(y2-y1) then
        x=min([x1 x2]); w=max([abs(x2-x1) t]);
        y=(y1+y2)/2-t/2; h=t;
    else
        x=(x1+x2)/2-t/2; w=t;
        y=min([y1 y2]); h=max([abs(y2-y1) t]);
    end
    ld2_text(parent,[x y w h],"",1,%f,"left",col,col);
endfunction

function ld2_render_stand_tools(parent)
    global LD2;
    phase=ld2_phase_for_step(LD2.state.step);
    if phase=="RC" | phase=="RL" then
        ld2_button(parent,[0.025 0.010 0.29 0.045],"VARŽŲ VEKTORIAI", ...
            "ld2_plot_impedance()",11,[0.91 0.95 0.99]);
        ld2_button(parent,[0.350 0.010 0.29 0.045],"ĮTAMPŲ VEKTORIAI", ...
            "ld2_plot_voltage_current()",11,[0.91 0.95 0.99]);
        ld2_button(parent,[0.675 0.010 0.29 0.045],"OSCILOGRAMA", ...
            "ld2_plot_scope_current()",11,[0.91 0.95 0.99]);
    elseif phase=="RLC" then
        ld2_button(parent,[0.025 0.010 0.29 0.045],"NAUDOTI RASTĄ fr", ...
            "ld2_goto_found_resonance()",11,[0.91 0.95 0.99]);
        ld2_button(parent,[0.350 0.010 0.29 0.045],"OSCILOGRAMA / PERIODAS", ...
            "ld2_plot_scope_current()",11,[0.91 0.95 0.99]);
        ld2_button(parent,[0.675 0.010 0.29 0.045],"VISŲ MATAVIMŲ ŽURNALAS", ...
            "ld2_show_journal()",11,[0.91 0.95 0.99]);
    end
endfunction
