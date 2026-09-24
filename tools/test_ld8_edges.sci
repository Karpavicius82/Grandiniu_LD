// Extra student-side regressions, called on a live stand by test_ld8.sce.
function ld8_edge_checks()
    global LD8;
    ld8_restart(); assert_checkequal(LD8.ui.studentBack.enable,"off");
    ld8_set_step(5); assert_checkequal(LD8.ui.studentBack.enable,"on");
    LD8.ui.answerEdits(8).string="17,345"; ld8_restore_stage();
    assert_checkequal(LD8.ui.answerEdits(8).string,"17,345");
    snap=bench_read_snapshot(LD8.autosave_paths($),"LD8");
    assert_checkequal(snap.state.answers(5,2),"17,345");
    ld8_toggle_solution();
    snap=bench_read_snapshot(LD8.autosave_paths($),"LD8");
    assert_checktrue(snap.state.practice_used); assert_checkfalse(snap.state.demoMode);
    assert_checkequal(snap.state.answers(5,2),"17,345");
    for k=1:6; assert_checkequal(LD8.ui.controls(k).enable,"off"); end
    bench_ld8_primary(); assert_checkfalse(LD8.demoMode);
    assert_checkequal(LD8.ui.answerEdits(8).string,"17,345");
    // The helper closes itself even while the stand is the current figure.
    ld8_show_wiring_guide(); helpfig=gcf(); closebutton=findobj(helpfig,"tag","H01");
    scf(LD8.fig); bench_button(closebutton(1));
    assert_checktrue(is_handle_valid(LD8.fig)); assert_checkfalse(is_handle_valid(helpfig));
    // Import rejection must leave the current student's state intact.
    good=bench_snapshot("LD8"); original=LD8.answers; original_student=LD8.student;
    for defect=1:6
        bad=good;
        select defect
        case 1 then bad.state.wireMode=99;
        case 2 then bad.state.wires=["T99" "E_P"];
        case 3 then bad.state.done=%t;
        case 4 then bad.state.journal=[12 %nan 1 1 1];
        case 5 then bad.state.practice_used="false";
        case 6 then bad.state.ui=struct();
        end
        rejected=%f; try bench_restore_snapshot(bad); catch rejected=%t; end
        assert_checktrue(rejected); assert_checkequal(LD8.answers,original);
        assert_checkequal(LD8.student,original_student); assert_checktrue(is_handle_valid(LD8.fig));
    end
    bench_restore_snapshot(good); assert_checkequal(LD8.ui.answerEdits(8).string,"17,345");
    // Power and switch buttons state the next action; powered wires cannot change.
    ld8_set_step(1); LD8.wires=ld8_canonical_wires(1); ld8_render_stage();
    assert_checktrue(strindex(LD8.ui.controls(4).string,"Įjungti")<>[]);
    bench_ld8_action("ld8_toggle_power()"); assert_checktrue(strindex(LD8.ui.controls(4).string,"Išjungti")<>[]);
    bench_ld8_action("ld8_toggle_switch()"); assert_checktrue(strindex(LD8.ui.controls(5).string,"Atverti")<>[]);
    before_wires=LD8.wires;bench_ld8_click("E_P");bench_ld8_click("K1");assert_checkequal(LD8.wires,before_wires);
    // A write failure must preserve both the open window and its last good draft.
    previous=LD8.autosave_paths($); folder=getenv("LD_DATA_DIR");
    blocked=fullfile(getenv("LD8_TEST_OUT"),"not-a-directory"); mputl("test",blocked); setenv("LD_DATA_DIR",blocked);
    ld8_close(); assert_checktrue(is_handle_valid(LD8.fig));
    assert_checktrue(LD8.autosave_error<>"");assert_checktrue(isfile(previous));
    setenv("LD_DATA_DIR",folder); LD8.done(:)=%t; LD8.step=6; ld8_render_stage();
    ld8_close(); assert_checkfalse(is_handle_valid(LD8.fig));
    saved=LD8; count=size(listfiles(bench_documents()+"/*.html"),"*");
    // Delayed buttons cannot write a new report, mutate data or open another window.
    ld8_student_primary();ld8_toggle_power();ld8_toggle_switch();ld8_set_step(1);
    ld8_terminal_click("E_P");ld8_measure();ld8_restore_stage();ld8_restart();ld8_toggle_solution();
    ld8_show_actions();ld8_show_wiring_guide();ld8_show_stand_map();ld8_answers_changed();
    assert_checkequal(size(listfiles(bench_documents()+"/*.html"),"*"),count);
    assert_checkequal(LD8.answers,saved.answers);assert_checkequal(LD8.wires,saved.wires);
    assert_checkequal(LD8.step,saved.step);assert_checkequal(LD8.autosave_paths,saved.autosave_paths);
endfunction
