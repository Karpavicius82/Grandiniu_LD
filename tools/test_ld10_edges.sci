// Extra student-side regressions, called on a live stand by test_ld10.sce.
function ld10_edge_checks()
    global LD10;
    ld10_restart(); assert_checkequal(LD10.ui.studentBack.enable,"off");
    ld10_set_step(2); ld10_measure_all(); assert_checkequal(size(LD10.journal,1),0); assert_checkfalse(LD10.powerOn);
    LD10.wires=ld10_canonical_wires(); ld10_measure_all(); measured=LD10.journal;
    assert_checkequal(size(measured,1),4); ld10_measure_all(); assert_checkequal(LD10.journal,measured);
    ld10_restart();
    ld10_set_step(3); ld10_toggle_solution(); demo_journal=LD10.journal; ld10_toggle_power(); ld10_toggle_switch();
    assert_checktrue(LD10.powerOn & LD10.switchOn); assert_checkequal(LD10.journal,demo_journal); ld10_toggle_solution();
    ld10_set_step(5); assert_checkequal(LD10.ui.studentBack.enable,"on");
    assert_checkequal([LD10.freqPoint LD10.target],[1 4]);
    LD10.ui.answerEdits(8).string="17,345"; ld10_restore_stage();
    assert_checkequal(LD10.ui.answerEdits(8).string,"17,345");
    snap=bench_read_snapshot(LD10.autosave_paths($),"LD10");
    assert_checkequal(snap.state.answers(5,5),"17,345");
    ld10_toggle_solution();
    snap=bench_read_snapshot(LD10.autosave_paths($),"LD10");
    assert_checktrue(snap.state.practice_used); if snap.state.demoMode then error("LD10_EDGE: draft saved in demo mode"); end
    assert_checkequal(snap.state.answers(5,5),"17,345");
    for k=1:9; assert_checkequal(LD10.ui.controls(k).enable,"off"); end
    bench_ld10_primary(); if LD10.demoMode then error("LD10_EDGE: primary did not exit demo"); end
    assert_checkequal(LD10.ui.answerEdits(8).string,"17,345");
    // The helper closes itself even while the stand is the current figure.
    ld10_show_wiring_guide(); helpfig=gcf(); closebutton=findobj(helpfig,"tag","H01");
    scf(LD10.fig); bench_button(closebutton(1));
    assert_checktrue(is_handle_valid(LD10.fig)); if is_handle_valid(helpfig) then error("LD10_EDGE: help close left its window open"); end
    // Import rejection must leave the current student's state intact.
    good=bench_snapshot("LD10"); original=LD10.answers; original_student=LD10.student;
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
        assert_checktrue(rejected); assert_checkequal(LD10.answers,original);
        assert_checkequal(LD10.student,original_student); assert_checktrue(is_handle_valid(LD10.fig));
    end
    bench_restore_snapshot(good); assert_checkequal(LD10.ui.answerEdits(8).string,"17,345");
    // Power and switch buttons state the next action; powered wires cannot change.
    ld10_set_step(1); LD10.wires=ld10_canonical_wires(); ld10_render_stage();
    assert_checktrue(strindex(LD10.ui.controls(8).string,"Įjungti")<>[]);
    bench_ld10_action("ld10_toggle_power()"); assert_checktrue(strindex(LD10.ui.controls(8).string,"Išjungti")<>[]);
    bench_ld10_action("ld10_toggle_switch()"); assert_checktrue(strindex(LD10.ui.controls(9).string,"Atverti")<>[]);
    before_wires=LD10.wires;bench_ld10_click("GEN_P");bench_ld10_click("K1");assert_checkequal(LD10.wires,before_wires);
    // A write failure must preserve both the open window and its last good draft.
    previous=LD10.autosave_paths($);
    // Block the actual draft directory instead of changing the process environment:
    // restoring a Unicode LD_DATA_DIR through setenv did not recover on Windows.
    draft_folder=fullfile(bench_documents(),"Juodrasciai");
    draft_backup=draft_folder+"-test-backup-"+bench_id();
    [ok,msg]=movefile(draft_folder,draft_backup); if ~ok then error(msg); end
    mputl("test",draft_folder);
    ld10_close(); still_open=is_handle_valid(LD10.fig); save_error=LD10.autosave_error;
    [old_folder,old_name,old_extension]=fileparts(previous);
    backup_exists=isfile(fullfile(draft_backup,old_name+old_extension));
    mdelete(draft_folder);
    [ok,msg]=movefile(draft_backup,draft_folder); if ~ok then error(msg); end
    assert_checktrue(still_open); assert_checktrue(save_error<>"");
    assert_checktrue(backup_exists); assert_checktrue(isfile(previous));
    LD10.done(:)=%t; LD10.step=6; ld10_render_stage();
    ld10_close(); if is_handle_valid(LD10.fig) then error("LD10_EDGE: close failed: "+LD10.autosave_error); end
    saved=LD10; count=size(listfiles(bench_documents()+"/*.html"),"*");
    // Delayed buttons cannot write a new report, mutate data or open another window.
    ld10_student_primary();ld10_toggle_power();ld10_toggle_switch();ld10_set_step(1);
    ld10_terminal_click("GEN_P");ld10_measure();ld10_measure_all();ld10_restore_stage();ld10_restart();ld10_toggle_solution();
    ld10_show_actions();ld10_show_wiring_guide();ld10_show_stand_map();ld10_answers_changed();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),count);
    assert_checkequal(LD10.answers,saved.answers);assert_checkequal(LD10.wires,saved.wires);
    assert_checkequal(LD10.step,saved.step);assert_checkequal(LD10.autosave_paths,saved.autosave_paths);
endfunction
