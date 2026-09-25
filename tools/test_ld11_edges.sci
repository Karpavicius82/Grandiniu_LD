// Extra student-side regressions, called on a live stand by test_ld11.sce.
function ld11_edge_checks()
    global LD11;
    ld11_restart(); assert_checkequal(LD11.ui.studentBack.enable,"off");
    ld11_set_step(2); ld11_measure_all(); assert_checkequal(size(LD11.journal,1),0); assert_checkfalse(LD11.powerOn);
    LD11.wires=ld11_canonical_wires(1); ld11_measure_all(); measured=LD11.journal;
    assert_checkequal(size(measured,1),1); ld11_measure_all(); assert_checkequal(LD11.journal,measured);
    ld11_set_step(3); assert_checkequal(LD11.wireMode,1);
    own_base=LD11.wires; ld11_set_step(4); assert_checkequal(LD11.wires,own_base);
    bench_ld11_click("RL_A"); bench_ld11_click("C_A"); bench_ld11_click("RL_B"); bench_ld11_click("C_B");
    own_comp=LD11.wires; ld11_measure_all(); assert_checkequal(size(LD11.journal,1),2);
    ld11_set_step(1); assert_checkequal(LD11.wires,own_base);
    ld11_set_step(4); assert_checkequal(LD11.wires,own_comp);
    ld11_set_step(5); ld11_toggle_solution(); demo_journal=LD11.journal; ld11_toggle_power(); ld11_toggle_switch();
    assert_checktrue(LD11.powerOn & LD11.switchOn); assert_checkequal(LD11.journal,demo_journal); ld11_toggle_solution();
    assert_checkequal(LD11.ui.studentBack.enable,"on");
    LD11.ui.answerEdits(7).string="17,345"; ld11_restore_stage();
    assert_checkequal(LD11.ui.answerEdits(7).string,"17,345");
    snap=bench_read_snapshot(LD11.autosave_paths($),"LD11");
    assert_checkequal(snap.state.answers(5,2),"17,345");
    ld11_toggle_solution();
    snap=bench_read_snapshot(LD11.autosave_paths($),"LD11");
    assert_checktrue(snap.state.practice_used); if snap.state.demoMode then error("LD11_EDGE: draft saved in demo mode"); end
    assert_checkequal(snap.state.answers(5,2),"17,345");
    for k=1:4; assert_checkequal(LD11.ui.controls(k).enable,"off"); end
    bench_ld11_primary(); if LD11.demoMode then error("LD11_EDGE: primary did not exit demo"); end
    assert_checkequal(LD11.ui.answerEdits(7).string,"17,345");
    // The helper closes itself even while the stand is the current figure.
    ld11_show_wiring_guide(); helpfig=gcf(); closebutton=findobj(helpfig,"tag","H01");
    scf(LD11.fig); bench_button(closebutton(1));
    assert_checktrue(is_handle_valid(LD11.fig)); if is_handle_valid(helpfig) then error("LD11_EDGE: help close left its window open"); end
    // Import rejection must leave the current student's state intact.
    good=bench_snapshot("LD11"); original=LD11.answers; original_student=LD11.student;
    for defect=1:6
        bad=good;
        select defect
        case 1 then bad.state.wireMode=99;
        case 2 then bad.state.wires=["T99" "GEN_P"];
        case 3 then bad.state.done=%t;
        case 4 then bad.state.journal=[12 %nan 1 1 1];
        case 5 then bad.state.practice_used="false";
        case 6 then bad.state.ui=struct();
        end
        rejected=%f; try bench_restore_snapshot(bad); catch rejected=%t; end
        assert_checktrue(rejected); assert_checkequal(LD11.answers,original);
        assert_checkequal(LD11.student,original_student); assert_checktrue(is_handle_valid(LD11.fig));
    end
    bench_restore_snapshot(good); assert_checkequal(LD11.ui.answerEdits(7).string,"17,345");
    // Power and switch buttons state the next action; powered wires cannot change.
    ld11_set_step(1); LD11.powerOn=%f; LD11.switchOn=%f; LD11.wires=ld11_canonical_wires(1); ld11_render_stage();
    assert_checktrue(strindex(LD11.ui.controls(3).string,"Įjungti")<>[]);
    bench_ld11_action("ld11_toggle_power()"); assert_checktrue(strindex(LD11.ui.controls(3).string,"Išjungti")<>[]);
    bench_ld11_action("ld11_toggle_switch()"); assert_checktrue(strindex(LD11.ui.controls(4).string,"Atverti")<>[]);
    before_wires=LD11.wires;bench_ld11_click("GEN_P");bench_ld11_click("K1");assert_checkequal(LD11.wires,before_wires);
    // A write failure must preserve both the open window and its last good draft.
    previous=LD11.autosave_paths($);
    // Block the actual draft directory instead of changing the process environment:
    // restoring a Unicode LD_DATA_DIR through setenv did not recover on Windows.
    draft_folder=fullfile(bench_documents(),"Juodrasciai");
    draft_backup=draft_folder+"-test-backup-"+bench_id();
    [ok,msg]=movefile(draft_folder,draft_backup); if ~ok then error(msg); end
    mputl("test",draft_folder);
    ld11_close(); still_open=is_handle_valid(LD11.fig); save_error=LD11.autosave_error;
    [old_folder,old_name,old_extension]=fileparts(previous);
    backup_exists=isfile(fullfile(draft_backup,old_name+old_extension));
    mdelete(draft_folder);
    [ok,msg]=movefile(draft_backup,draft_folder); if ~ok then error(msg); end
    assert_checktrue(still_open); assert_checktrue(save_error<>"");
    assert_checktrue(backup_exists); assert_checktrue(isfile(previous));
    LD11.done(:)=%t; LD11.step=6; ld11_render_stage();
    ld11_close(); if is_handle_valid(LD11.fig) then error("LD11_EDGE: close failed: "+LD11.autosave_error); end
    saved=LD11; count=size(listfiles(bench_documents()+"/*.html"),"*");
    // Delayed buttons cannot write a new report, mutate data or open another window.
    ld11_student_primary();ld11_toggle_power();ld11_toggle_switch();ld11_set_step(1);
    ld11_terminal_click("GEN_P");ld11_measure();ld11_measure_all();ld11_restore_stage();ld11_restart();ld11_toggle_solution();
    ld11_show_actions();ld11_show_wiring_guide();ld11_show_stand_map();ld11_answers_changed();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),count);
    assert_checkequal(LD11.answers,saved.answers);assert_checkequal(LD11.wires,saved.wires);
    assert_checkequal(LD11.step,saved.step);assert_checkequal(LD11.autosave_paths,saved.autosave_paths);
endfunction
