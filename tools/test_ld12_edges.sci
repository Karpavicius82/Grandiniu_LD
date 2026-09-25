// Extra student-side regressions, called on a live stand by test_ld12.sce.
function ld12_edge_checks()
    global LD12 LD12_CHOICES;
    ld12_restart(); assert_checkequal(LD12.ui.studentBack.enable,"off");
    bench_ld12_click("L1");bench_ld12_click("L1");assert_checkequal(LD12.pending,"");
    assert_checkequal(size(LD12.wires,1),0);assert_checktrue(strindex(LD12.ui.statusMain.string,"atšauktas")<>[]);
    ld12_set_step(2); ld12_measure_all(); assert_checkequal(size(LD12.journal,1),0); assert_checkfalse(LD12.powerOn);
    LD12.wires=ld12_canonical_wires(1);ld12_measure_all();measured=LD12.journal;
    assert_checkequal(size(measured,1),3);ld12_measure_all();assert_checkequal(LD12.journal,measured);
    own_star=LD12.wires;ld12_set_step(3);assert_checkequal(LD12.wireMode,2);
    bench_ld12_connect(2);own_delta=LD12.wires;ld12_set_step(4);ld12_measure_all();
    assert_checkequal(size(LD12.journal,1),7);
    ld12_set_step(1);assert_checkequal(LD12.wires,own_star);
    ld12_set_step(3);assert_checkequal(LD12.wires,own_delta);
    ld12_set_step(5); ld12_toggle_solution(); demo_journal=LD12.journal; ld12_toggle_power(); ld12_toggle_switch();
    assert_checktrue(LD12.powerOn & LD12.switchOn); assert_checkequal(LD12.journal,demo_journal); ld12_toggle_solution();
    assert_checkequal(LD12.ui.studentBack.enable,"on");
    LD12.ui.answerEdits(7).string="17,345"; ld12_restore_stage();
    assert_checkequal(LD12.ui.answerEdits(7).string,"17,345");
    snap=bench_read_snapshot(LD12.autosave_paths($),"LD12");
    assert_checkequal(snap.state.answers(5,3),"17,345");
    ld12_toggle_solution();
    snap=bench_read_snapshot(LD12.autosave_paths($),"LD12");
    assert_checktrue(snap.state.practice_used); if snap.state.demoMode then error("LD12_EDGE: draft saved in demo mode"); end
    assert_checkequal(snap.state.answers(5,3),"17,345");
    for k=1:7; assert_checkequal(LD12.ui.controls(k).enable,"off"); end
    bench_ld12_primary(); if LD12.demoMode then error("LD12_EDGE: primary did not exit demo"); end
    assert_checkequal(LD12.ui.answerEdits(7).string,"17,345");
    // The helper closes itself even while the stand is the current figure.
    ld12_show_wiring_guide(); helpfig=gcf(); closebutton=findobj(helpfig,"tag","H01");
    scf(LD12.fig); bench_button(closebutton(1));
    assert_checktrue(is_handle_valid(LD12.fig)); if is_handle_valid(helpfig) then error("LD12_EDGE: help close left its window open"); end
    // Import rejection must leave the current student's state intact.
    good=bench_snapshot("LD12"); original=LD12.answers; original_student=LD12.student;
    for defect=1:8
        bad=good;
        select defect
        case 1 then bad.state.wireMode=99;
        case 2 then bad.state.wires=["T99" "L1"];
        case 3 then bad.state.done=%t;
        case 4 then bad.state.journal=[12 %nan 1 1 1];
        case 5 then bad.state.practice_used="false";
        case 6 then bad.state.ui=struct();
        case 7 then bad.state.phase=99;
        case 8 then bad.state.journal=[30 10 2 4 0;30 10 2 4 0];
        end
        rejected=%f; try bench_restore_snapshot(bad); catch rejected=%t; end
        assert_checktrue(rejected); assert_checkequal(LD12.answers,original);
        assert_checkequal(LD12.student,original_student); assert_checktrue(is_handle_valid(LD12.fig));
    end
    bench_restore_snapshot(good); assert_checkequal(LD12.ui.answerEdits(7).string,"17,345");
    // A legacy draft preserves its one real observation and requires missing phases.
    legacy=good;legacy.state.journal=good.state.journal(1,:);legacy.state.phase=0;
    legacy.state.wireMode=1;legacy.state.done(:)=%t;
    bench_restore_snapshot(legacy);assert_checkequal(LD12.phase,1);
    assert_checkfalse(LD12.done(2) | LD12.done(4) | LD12.done(5));
    legacy_report=bench_report_data("LD12");assert_checkequal(length(legacy_report.observations),1);
    bench_restore_snapshot(good);
    before_count=size(listfiles(bench_documents()+"/*.html"),"*");
    LD12.done(1)=%f;LD12_CHOICES=3;ld12_test_help();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),before_count);
    assert_checktrue(strindex(LD12.ui.statusMain.string,"6 etapus")<>[]);
    // Power and switch buttons state the next action; powered wires cannot change.
    ld12_set_step(1); LD12.powerOn=%f; LD12.switchOn=%f; LD12.wires=ld12_canonical_wires(1); ld12_render_stage();
    assert_checktrue(strindex(LD12.ui.controls(6).string,"Įjungti")<>[]);
    bench_ld12_action("ld12_toggle_power()"); assert_checktrue(strindex(LD12.ui.controls(6).string,"Išjungti")<>[]);
    bench_ld12_action("ld12_toggle_switch()"); assert_checktrue(strindex(LD12.ui.controls(7).string,"Atverti")<>[]);
    before_wires=LD12.wires;bench_ld12_click("L1");bench_ld12_click("R1_A");assert_checkequal(LD12.wires,before_wires);
    // A write failure must preserve both the open window and its last good draft.
    previous=LD12.autosave_paths($);
    // Block the actual draft directory instead of changing the process environment:
    // restoring a Unicode LD_DATA_DIR through setenv did not recover on Windows.
    draft_folder=fullfile(bench_documents(),"Juodrasciai");
    draft_backup=draft_folder+"-test-backup-"+bench_id();
    [ok,msg]=movefile(draft_folder,draft_backup); if ~ok then error(msg); end
    mputl("test",draft_folder);
    ld12_close(); still_open=is_handle_valid(LD12.fig); save_error=LD12.autosave_error;
    [old_folder,old_name,old_extension]=fileparts(previous);
    backup_exists=isfile(fullfile(draft_backup,old_name+old_extension));
    mdelete(draft_folder);
    [ok,msg]=movefile(draft_backup,draft_folder); if ~ok then error(msg); end
    assert_checktrue(still_open); assert_checktrue(save_error<>"");
    assert_checktrue(backup_exists); assert_checktrue(isfile(previous));
    LD12.done(:)=%t; LD12.step=6; ld12_render_stage();
    ld12_close(); if is_handle_valid(LD12.fig) then error("LD12_EDGE: close failed: "+LD12.autosave_error); end
    saved=LD12; count=size(listfiles(bench_documents()+"/*.html"),"*");
    // Delayed buttons cannot write a new report, mutate data or open another window.
    ld12_student_primary();ld12_toggle_power();ld12_toggle_switch();ld12_set_step(1);
    ld12_terminal_click("L1");ld12_measure();ld12_measure_all();ld12_restore_stage();ld12_restart();ld12_toggle_solution();
    ld12_set_phase(2);ld12_show_actions();ld12_show_wiring_guide();ld12_show_stand_map();ld12_answers_changed();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),count);
    assert_checkequal(LD12.answers,saved.answers);assert_checkequal(LD12.wires,saved.wires);
    assert_checkequal(LD12.step,saved.step);assert_checkequal(LD12.autosave_paths,saved.autosave_paths);
endfunction
