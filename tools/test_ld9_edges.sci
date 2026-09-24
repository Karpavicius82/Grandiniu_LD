// Extra student-side regressions, called on a live stand by test_ld9.sce.
function ld9_edge_checks()
    global LD9;
    ld9_restart(); assert_checkequal(LD9.ui.studentBack.enable,"off");
    ld9_set_step(2); ld9_measure_all(); assert_checkequal(size(LD9.journal,1),0); assert_checkfalse(LD9.powerOn);
    LD9.wires=ld9_canonical_wires(); ld9_measure_all(); measured=LD9.journal;
    assert_checkequal(size(measured,1),4); ld9_measure_all(); assert_checkequal(LD9.journal,measured);
    ld9_restart();
    ld9_set_step(3); ld9_toggle_solution(); demo_journal=LD9.journal; ld9_toggle_power(); ld9_toggle_switch();
    assert_checktrue(LD9.powerOn & LD9.switchOn); assert_checkequal(LD9.journal,demo_journal); ld9_toggle_solution();
    ld9_set_step(5); assert_checkequal(LD9.ui.studentBack.enable,"on");
    assert_checkequal([LD9.freqPoint LD9.target],[1 4]);
    LD9.ui.answerEdits(8).string="17,345"; ld9_restore_stage();
    assert_checkequal(LD9.ui.answerEdits(8).string,"17,345");
    snap=bench_read_snapshot(LD9.autosave_paths($),"LD9");
    assert_checkequal(snap.state.answers(5,5),"17,345");
    ld9_toggle_solution();
    snap=bench_read_snapshot(LD9.autosave_paths($),"LD9");
    assert_checktrue(snap.state.practice_used); if snap.state.demoMode then error("LD9_EDGE: draft saved in demo mode"); end
    assert_checkequal(snap.state.answers(5,5),"17,345");
    for k=1:9; assert_checkequal(LD9.ui.controls(k).enable,"off"); end
    bench_ld9_primary(); if LD9.demoMode then error("LD9_EDGE: primary did not exit demo"); end
    assert_checkequal(LD9.ui.answerEdits(8).string,"17,345");
    // The helper closes itself even while the stand is the current figure.
    ld9_show_wiring_guide(); helpfig=gcf(); closebutton=findobj(helpfig,"tag","H01");
    scf(LD9.fig); bench_button(closebutton(1));
    assert_checktrue(is_handle_valid(LD9.fig)); if is_handle_valid(helpfig) then error("LD9_EDGE: help close left its window open"); end
    // Import rejection must leave the current student's state intact.
    good=bench_snapshot("LD9"); original=LD9.answers; original_student=LD9.student;
    for defect=1:6
        bad=good;
        select defect
        case 1 then bad.state.freqPoint=99;
        case 2 then bad.state.wires=["T99" "GEN_P"];
        case 3 then bad.state.done=%t;
        case 4 then bad.state.journal=[12 %nan 1 1 1];
        case 5 then bad.state.practice_used="false";
        case 6 then bad.state.ui=struct();
        end
        rejected=%f; try bench_restore_snapshot(bad); catch rejected=%t; end
        assert_checktrue(rejected); assert_checkequal(LD9.answers,original);
        assert_checkequal(LD9.student,original_student); assert_checktrue(is_handle_valid(LD9.fig));
    end
    bench_restore_snapshot(good); assert_checkequal(LD9.ui.answerEdits(8).string,"17,345");
    // Power and switch buttons state the next action; powered wires cannot change.
    ld9_set_step(1); LD9.wires=ld9_canonical_wires(); ld9_render_stage();
    assert_checktrue(strindex(LD9.ui.controls(8).string,"Įjungti")<>[]);
    bench_ld9_action("ld9_toggle_power()"); assert_checktrue(strindex(LD9.ui.controls(8).string,"Išjungti")<>[]);
    bench_ld9_action("ld9_toggle_switch()"); assert_checktrue(strindex(LD9.ui.controls(9).string,"Atverti")<>[]);
    before_wires=LD9.wires;bench_ld9_click("GEN_P");bench_ld9_click("K1");assert_checkequal(LD9.wires,before_wires);
    // A write failure must preserve both the open window and its last good draft.
    previous=LD9.autosave_paths($);
    // Block the actual draft directory instead of changing the process environment:
    // restoring a Unicode LD_DATA_DIR through setenv did not recover on Windows.
    draft_folder=fullfile(bench_documents(),"Juodrasciai");
    draft_backup=draft_folder+"-test-backup-"+bench_id();
    [ok,msg]=movefile(draft_folder,draft_backup); if ~ok then error(msg); end
    mputl("test",draft_folder);
    ld9_close(); still_open=is_handle_valid(LD9.fig); save_error=LD9.autosave_error;
    [old_folder,old_name,old_extension]=fileparts(previous);
    backup_exists=isfile(fullfile(draft_backup,old_name+old_extension));
    mdelete(draft_folder);
    [ok,msg]=movefile(draft_backup,draft_folder); if ~ok then error(msg); end
    assert_checktrue(still_open); assert_checktrue(save_error<>"");
    assert_checktrue(backup_exists); assert_checktrue(isfile(previous));
    LD9.done(:)=%t; LD9.step=6; ld9_render_stage();
    ld9_close(); if is_handle_valid(LD9.fig) then error("LD9_EDGE: close failed: "+LD9.autosave_error); end
    saved=LD9; count=size(listfiles(bench_documents()+"/*.html"),"*");
    // Delayed buttons cannot write a new report, mutate data or open another window.
    ld9_student_primary();ld9_toggle_power();ld9_toggle_switch();ld9_set_step(1);
    ld9_terminal_click("GEN_P");ld9_measure();ld9_measure_all();ld9_restore_stage();ld9_restart();ld9_toggle_solution();
    ld9_show_actions();ld9_show_wiring_guide();ld9_show_stand_map();ld9_answers_changed();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),count);
    assert_checkequal(LD9.answers,saved.answers);assert_checkequal(LD9.wires,saved.wires);
    assert_checkequal(LD9.step,saved.step);assert_checkequal(LD9.autosave_paths,saved.autosave_paths);
endfunction
