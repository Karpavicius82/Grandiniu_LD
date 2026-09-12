// ============================================================================
// LD3 studento srautas: paleidimas, pagrindinis mygtukas, pagalba.
// ============================================================================

function ld3_start()
    global LD3;
    // Darbo pradžia inicializuoja būseną (kaip ld1_start): cfg/student išlieka.
    if ~isfield(LD3, "step") then
        cfg = LD3.cfg; st = LD3.student;
        ld3_init_state();
        LD3.cfg = cfg; LD3.student = st;
    end
    needgui = %t;
    if isfield(LD3, "ui") then
        if isfield(LD3.ui, "headless") then
            if LD3.ui.headless then needgui = %f; end
        end
        if isfield(LD3.ui, "standFrame") then needgui = %f; end  // jau pastatyta
    end
    if needgui & ~isfield(LD3, "fig") then
        ld3_build_gui();
    end
    ld3_set_status("Sveiki! Pradėkite nuo [E01]: sujunkite matavimo grandinę.","info","Seką parodys [B04] KAIP SUJUNGTI.");
endfunction

function ld3_student_primary()
    global LD3;
    if LD3.demoMode then ld3_toggle_solution(); return; end
    if LD3.step == 6 & LD3.done(6) then
        bench_export_current("LD3");
        return;
    end
    // Vienas paspaudimas: patikrinti ir, pavykus, iškart pereiti (LD2 semantika).
    if ~LD3.done(LD3.step) then
        ld3_check_step();
    end
    if LD3.done(LD3.step) & LD3.step < 6 then
        ld3_next_step();
    end
    ld3_student_sync();
endfunction

function ld3_jump_step(n)
    global LD3;
    if n <= LD3.step | LD3.done(n) | LD3.skipped(n) then
        ld3_set_step(n);
    else
        ld3_set_status("Šio etapo dar nepasiekėte.","info","Dabartinį etapą patikrinkite ir spauskite TOLIAU.");
    end
endfunction

function ld3_student_sync()
    global LD3;
    if ~isfield(LD3, "ui") then return; end
    if isfield(LD3.ui, "headless") then if LD3.ui.headless then return; end end
    if isfield(LD3.ui, "studentPrimary") & is_handle_valid(LD3.ui.studentPrimary) then
        if LD3.step == 6 & LD3.done(6) then
            LD3.ui.studentPrimary.string = "ĮRAŠYTI ATASKAITĄ";
        elseif LD3.done(LD3.step) then
            LD3.ui.studentPrimary.string = "TOLIAU →";
        else
            LD3.ui.studentPrimary.string = "TIKRINTI";
        end
    end
endfunction
