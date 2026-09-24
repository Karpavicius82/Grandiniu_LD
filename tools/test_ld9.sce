mode(-1); funcprot(0);
root=getenv("LD9_TEST_RUNTIME")+"/"; out=getenv("LD9_TEST_OUT")+"/"; source=getenv("LD9_TEST_SOURCE")+"/";
global LD9 LD9_CANCEL LD9_CHOICES LD9_DRAFT;
LD9_CHOICES=[]; LD9_DRAFT="";
function values=x_mdialog(varargin)
    global LD9_CANCEL;
    if LD9_CANCEL then values=[]; else values=["17";"Patikra Žąsė";"TEST"]; end
endfunction
function selected=messagebox(varargin)
    if varargin(2)<>"Jūsų priskirtos reikšmės" then error("Netikėtas dialogas"); end
    selected=1;
endfunction
function selected=x_choose(varargin)
    global LD9_CHOICES;
    assert_checktrue(size(LD9_CHOICES,"*")>0);
    selected=LD9_CHOICES(1); LD9_CHOICES(1)=[];
endfunction
function path=uigetfile(varargin)
    global LD9_DRAFT; path=LD9_DRAFT;
endfunction
function ld9_test_help()
    global LD9;
    handles=findobj(LD9.fig,"callback","ld9_show_actions()");
    assert_checkequal(size(handles,"*"),1); bench_button(handles(1));
endfunction
function capture_ld9(name)
    global LD9;
    if getos()<>"Linux" then return; end
    LD9.fig.figure_name="LD9 PATIKRA "+name; show_window(LD9.fig); sleep(500);
    command="/usr/bin/python3 """+getenv("LD9_TEST_RUNTIME")+"/capture_window.py"" ""LD9 PATIKRA "+name+""" """+getenv("LD9_TEST_OUT")+"/"+name+".png""";
    assert_checkequal(host(command),0);
endfunction
try
    LD9=struct(); LD9_CANCEL=%t; exec(root+"LD9/LD9.sce",-1); assert_checkfalse(isfield(LD9,"fig"));
    LD9_CANCEL=%f; exec(root+"LD9/LD9.sce",-1); assert_checkequal(LD9.student.number,17);
    assert_checkequal(LD9.student.bank,"LD9-64-A-2026");
    assert_checktrue(LD9.assessment & LD9.autosave_enabled); delete(LD9.fig);
    exec(root+"tests/workflows.sci",-1); exec(source+"tools/ergonomics.sci",-1);
    for number=[1 17 64]; bench_ld9_workflow(number,root,%t); end
    LD9=struct("cfg",ld9_variant_config(1),"student",student_profile(1,"Patikra Žąsė","TEST","LD9"),"ui",struct("headless",%f));
    ld9_start(); report=bench_report_data("LD9");
    assert_checkequal(length(report.evidence.wiring.s1.pairs),0);
    assert_checkequal(length(report.observations),0);
    ld9_set_step(7); ld9_jump_step(%nan); assert_checkequal(LD9.step,1);
    assert_checkfalse(ld9_valid_index([1 2],4));
    ld9_toggle_solution(); rejected=%f;
    try report=bench_report_data("LD9"); catch rejected=%t; end
    assert_checktrue(rejected); ld9_measure(); ld9_check_step(); assert_checkfalse(or(LD9.done));
    ld9_toggle_solution(); assert_checkequal(size(LD9.journal,1),0); assert_checkequal(size(LD9.wires,1),0);
    descriptor=mopen(out+"geometry.tsv","wt"); sizes=[1280 720];
    screen=get(0,"screensize_px"); viewport=min(sizes,max([320 240],screen(3:4)-[40 120]));
    for dimension=1
        assert_checkequal(matrix(LD9.fig.axes_size,1,-1),viewport);
        assert_checkequal(student_size(LD9.ui.circuitFrame.parent),sizes);
        for step=1:6
            LD9.step=step; LD9.wires=ld9_canonical_wires();
            if or(step==[2 3 4]) then LD9.freqPoint=step-1; LD9.target=1; end
            if step==5 then LD9.freqPoint=1; LD9.target=4; end
            LD9.powerOn=%t; LD9.switchOn=%t; ld9_render_stage();
            label=msprintf("LD9-E%d-%dx%d",step,sizes(dimension,1),sizes(dimension,2));
            geometry_dump(LD9.fig,label,descriptor);
            LD9.wires=LD9.wires(:,[2 1]); ld9_render_wires(); geometry_dump(LD9.fig,label+"-reverse",descriptor);
            LD9.wires=LD9.wires($:-1:1,:); ld9_render_wires(); geometry_dump(LD9.fig,label+"-shuffled",descriptor);
            if step>=2 then capture_ld9("E"+string(step)); end
        end
    end
    // Invoke the registered native resize callback without re-rendering a stage.
    // This checks the callback contract; it does not emulate an OS drag event.
    LD9.ui.answerEdits(10).string="1,0";
    for dimension=1
        assert_checkequal(matrix(LD9.fig.axes_size,1,-1),viewport);
        assert_checktrue(LD9.fig.resizefcn<>""); execstr(LD9.fig.resizefcn);
        assert_checkequal(LD9.ui.answerEdits(10).string,"1,0");
        geometry_dump(LD9.fig,"LD9-resize-"+string(dimension),descriptor);
    end

    report=bench_report_data("LD9"); assert_checkequal(length(report.evidence.wiring.s1.pairs),0);
    LD9.cfg=ld9_variant_config(64); LD9.student=student_profile(64,"Patikra Žąsė","TEST","LD9");
    // Rodmenys visuose trijuose taškuose ir visuose taikiniuose.
    for step=[2 3 4]
        LD9.step=step; LD9.wires=ld9_canonical_wires(); LD9.powerOn=%t; LD9.switchOn=%t;
        LD9.freqPoint=step-1;
        ld9_render_stage();
        kk=[0.5 1 2]; f=kk(step-1)/sqrt(LD9.cfg.L*LD9.cfg.C)/(2*%pi);
        for target=1:4
            LD9.target=target; ld9_render_wires();
            geometry_dump(LD9.fig,msprintf("LD9-measure-%d-%d",step,target),descriptor);
            v=bench_cpp_ac(3,LD9.cfg.E,f,LD9.cfg.R,LD9.cfg.L,LD9.cfg.C);
            u=LD9.cfg.E; if target==1 then u=v(5); elseif target==2 then u=v(6); elseif target==3 then u=v(7); end
            handle=findobj("tag","reading:V"); assert_checkequal(handle.string,msprintf("%.4f V",u));
        end
        handle=findobj("tag","reading:A"); assert_checkequal(handle.string,msprintf("%.3f mA",v(4)*1000));
        if step==3 then
            // Ties f0: UL = UC ir jos abi viršija U (kokybė Q > 1).
            assert_checkalmostequal(v(6),v(7),1e-9,1e-6);
            assert_checktrue(v(6)>LD9.cfg.E & v(7)>LD9.cfg.E);
        end
        // Atstatome išjungtą maitinimą, nes measure_point pats perjungia.
        LD9.powerOn=%f; LD9.switchOn=%f; LD9.target=4;
        bench_ld9_measure_point(step);
        execstr(LD9.fig.resizefcn); capture_ld9("taskas-f"+string(step-1));
    end
    mclose(descriptor);
    assert_checkequal(size(LD9.journal,1),12);
    journal=LD9.journal; bench_ld9_action("ld9_measure()"); assert_checkequal(LD9.journal,journal);
    ld9_set_step(5); LD9.ui.answerEdits(4).string="10,321";
    snapshot_path=bench_save_snapshot("LD9"); snapshot=bench_read_snapshot(snapshot_path,"LD9");
    ld9_restart(); bench_restore_snapshot(snapshot);
    assert_checkequal(LD9.ui.answerEdits(4).string,"10,321"); assert_checkequal(LD9.journal,journal);
    assert_checkfalse(LD9.powerOn); assert_checkfalse(LD9.switchOn);
    ld9_set_step(3); ld9_toggle_solution(); assert_checkequal(size(LD9.journal,1),4); ld9_toggle_solution(); assert_checkequal(LD9.journal,journal);
    LD9.assessment=%f; ld9_set_step(5); LD9.done(5)=%t; LD9.ui.answerEdits(4).string="1+2"; bench_ld9_primary();
    assert_checkfalse(LD9.done(5)); assert_checkequal(LD9.step,5); assert_checkequal(LD9.ui.answerEdits(4).string,"1+2");
    expected=ld9_expected_answers(); bench_ld9_answers(5,expected(5,1:6));
    LD9.ui.answerEdits(4).string=strsubst(LD9.ui.answerEdits(4).string,".",","); bench_ld9_primary();
    assert_checkequal(LD9.step,6); assert_checktrue(LD9.done(5));
    ld9_set_step(1); ld9_restore_stage(); assert_checkequal(size(LD9.wires,1),0);
    assert_checkequal(size(LD9.journal,1),0); assert_checkfalse(LD9.done(1));
    report=bench_report_data("LD9"); assert_checkequal(length(report.evidence.wiring.s1.pairs),0);
    ld9_show_wiring_guide(); window=gcf(); assert_checktrue(window<>LD9.fig); delete(window);
    ld9_show_stand_map(); window=gcf(); assert_checktrue(window<>LD9.fig); delete(window);
    // Assessment accepts raw wrong answers, but requires a nonempty field.
    LD9.assessment=%t; ld9_set_step(5); expected=ld9_expected_answers();
    bench_ld9_answers(5,expected(5,1:6)); LD9.ui.answerEdits(8).string="";
    bench_ld9_primary(); assert_checkequal(LD9.step,5); assert_checkfalse(LD9.done(5));
    LD9.ui.answerEdits(8).string="1+2"; bench_ld9_primary();
    assert_checkequal(LD9.step,6); assert_checkequal(LD9.answers(5,5),"1+2");
    // Close flushes an edit without Enter; actual Help restores the saved work.
    LD9.ui.answerEdits(10).string="2,0";
    closing=LD9.fig; execstr(closing.closerequestfcn);
    if is_handle_valid(closing) then error("LD9_CLOSE_FAILED: "+LD9.autosave_error); end
    ld9_show_actions(); ld9_render_stage(); ld9_render_journal(); // queued events after close
    LD9_DRAFT=LD9.autosave_paths($);
    saved=bench_read_snapshot(LD9_DRAFT,"LD9"); assert_checkequal(saved.state.answers(6,1),"2,0");
    assert_checkequal(saved.state.answers(5,5),"1+2");
    LD9=struct(); exec(root+"LD9/LD9.sce",-1);
    LD9_CHOICES=1; ld9_test_help();
    assert_checkequal(LD9.step,6); assert_checkequal(LD9.student.number,64);
    assert_checkequal(LD9.ui.answerEdits(10).string,"2,0");
    assert_checktrue(LD9.assessment); assert_checktrue(LD9.autosave_enabled);
    LD9_CHOICES=[4 2]; ld9_test_help(); assert_checkfalse(LD9.assessment); assert_checktrue(LD9.practice_used);
    LD9_CHOICES=[4 1]; ld9_test_help(); assert_checktrue(LD9.assessment); assert_checktrue(LD9.practice_used);
    LD9_CHOICES=6; ld9_test_help(); window=gcf(); assert_checktrue(window<>LD9.fig); delete(window);
    mprintf("LD9_EDGE_BEGIN\n"); exec(source+"tools/test_ld9_edges.sci",-1); ld9_edge_checks(); mprintf("LD9_EDGE_END\n");
    cases=list(); specs=[1 1 .01;3 1 .03;3 2 0;5 1 .02;5 2 .02;5 3 .02;5 4 .02;5 5 .02;5 6 .02];
    for number=[1 17 64]
        bench_ld9_workflow(number,root,%f); expected=ld9_expected_answers(); original=LD9.answers;
        if number==1 then
            LD9.autosave_enabled=%t; bench_autosave("LD9"); bench_autosave("LD9"); bench_autosave("LD9");
            assert_checkequal(size(LD9.autosave_paths,"*"),2); assert_checkequal(LD9.autosave_error,"");
        end
        // Užbaigtos ataskaitos: vertinimas ir suvestinės teisė nepriklauso.
        if number==1 then
            LD9.answers(5,1)="wrong";
            cases($+1)=struct("report",bench_report_data("LD9"),"accepted",%f);
            LD9.answers=original; LD9.practice_used=%t;
            cases($+1)=struct("report",bench_report_data("LD9"),"accepted",%t);
            LD9.practice_used=%f;
        end
        for index=1:size(specs,1)
            step=specs(index,1); slot=specs(index,2); value=expected(step,slot);
            if specs(index,3)==0 then tolerance=.02; else tolerance=1e-9+specs(index,3)*abs(value); end
            for delta=[-1.0001 -.9999 .9999 1.0001]
                LD9.answers=original; LD9.step=step; LD9.done(step)=%f;
                if step==1 then LD9.wires=ld9_canonical_wires(); end
                LD9.answers(step,slot)=msprintf("%.17g",value+delta*tolerance); ld9_check_step();
                accepted=LD9.done(step); assert_checkequal(accepted,abs(delta)<1);
                cases($+1)=struct("report",bench_report_data("LD9"),"accepted",accepted);
            end
        end
        for slot=1:3
            for raw=[string(expected(6,slot))+",0" string(3-expected(6,slot)) "" "1+1"]
                LD9.answers=original; LD9.step=6; LD9.done(6)=%f; LD9.answers(6,slot)=raw; ld9_check_step();
                accepted=LD9.done(6); assert_checkequal(accepted,raw==string(expected(6,slot))+",0");
                cases($+1)=struct("report",bench_report_data("LD9"),"accepted",accepted);
            end
        end
    end
    mputl(toJSON(cases),out+"tolerance-cases.json");
    mputl("LD9_PASS: 3 GUI variants; single series RLC wiring; three frequency points; four voltmeter targets; UL=UC at resonance; triangles from own measurements; actual report button; comma input without Enter; demo isolation; draft restore; 31 fixed-canvas geometry cases; 146 grading comparisons; actual assessment and draft recovery; six malformed drafts rejected; failed-write recovery; late callbacks ignored; batch measurements",out+"verdict.log"); exit(0);
catch
    mputl("LD9_FAIL: "+strcat(lasterror()," | "),out+"verdict.log"); disp(lasterror()); exit(1);
end
