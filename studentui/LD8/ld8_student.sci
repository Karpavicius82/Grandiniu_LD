// ============================================================================
// LD8 studento srautas: paleidimas, pagrindinis mygtukas, pagalba.
// ============================================================================

function ld8_student_main(root)
    global LD8;
    if typeof(LD8) == "st" then
        if isfield(LD8, "fig") then
            if is_handle_valid(LD8.fig) then show_window(LD8.fig); return; end
        end
    end
    bench_core_require();
    [ok, st, cfg] = student_enroll("LD8");
    if ~ok then return; end
    LD8 = struct("root", root, "cfg", cfg, "student", st);
    student_remember(st); ld8_start();
endfunction

function ld8_start()
    global LD8;
    // Darbo pradžia inicializuoja būseną (kaip ld7_start): cfg/student išlieka.
    if ~isfield(LD8, "step") then
        cfg = LD8.cfg; st = LD8.student;
        ld8_init_state();
        LD8.cfg = cfg; LD8.student = st;
    end
    needgui = %t;
    if isfield(LD8, "ui") then
        if isfield(LD8.ui, "headless") then
            if LD8.ui.headless then needgui = %f; end
        end
        if isfield(LD8.ui, "circuitFrame") then needgui = %f; end  // jau pastatyta
    end
    if needgui & ~isfield(LD8, "fig") then
        ld8_build_gui();
    end
    ld8_set_status("Sveiki! Pradėkite nuo [E01]: sujunkite nuoseklią grandinę.", "info", "Seką rasite: Pagalba → [B04] Kaip sujungti.");
endfunction

function ld8_student_primary()
    global LD8;
    if LD8.demoMode then ld8_toggle_solution(); return; end
    ld8_save_answers();
    if LD8.step == 6 & and(LD8.done) then
        bench_export_current("LD8");
        return;
    end
    // Vienas paspaudimas: patikrinti ir, pavykus, iškart pereiti (LD2 semantika).
    if ~LD8.done(LD8.step) then
        ld8_check_step();
    end
    if LD8.done(LD8.step) & LD8.step < 6 then
        ld8_next_step();
    elseif LD8.step == 6 & LD8.done(6) & ~and(LD8.done) then
        pending = find(~LD8.done); ld8_set_step(pending(1));
    end
    ld8_student_sync();
endfunction

function ld8_jump_step(n)
    global LD8;
    if ~ld8_valid_index(n, 6) then return; end
    if n <= LD8.step | LD8.done(n) | LD8.skipped(n) then
        ld8_set_step(n);
    else
        ld8_set_status("Šio etapo dar nepasiekėte.", "info", "Dabartinį etapą patikrinkite ir spauskite TOLIAU.");
    end
endfunction

function ld8_student_sync()
    global LD8;
    if ~isfield(LD8, "ui") then return; end
    if isfield(LD8.ui, "headless") then if LD8.ui.headless then return; end end
    if isfield(LD8.ui, "studentPrimary") & is_handle_valid(LD8.ui.studentPrimary) then
        if LD8.demoMode then
            LD8.ui.studentPrimary.string = "GRĮŽTI Į SAVO DARBĄ";
        elseif LD8.step == 6 & and(LD8.done) then
            LD8.ui.studentPrimary.string = "ĮRAŠYTI ATASKAITĄ";
        elseif LD8.step == 6 & LD8.done(6) then
            LD8.ui.studentPrimary.string = "UŽBAIGTI PRALEISTĄ ETAPĄ";
        elseif LD8.done(LD8.step) then
            LD8.ui.studentPrimary.string = "TOLIAU →";
        else
            LD8.ui.studentPrimary.string = "TIKRINTI";
        end
    end
endfunction
