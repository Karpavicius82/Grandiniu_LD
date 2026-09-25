mode(-1); funcprot(0);
root=getenv("LD11_TEST_RUNTIME")+"/"; out=getenv("LD11_TEST_OUT")+"/"; source=getenv("LD11_TEST_SOURCE")+"/";
global LD11 LD11_CANCEL LD11_CHOICES LD11_DRAFT;
LD11_CHOICES=[]; LD11_DRAFT="";
function values=x_mdialog(varargin)
    global LD11_CANCEL;
    if LD11_CANCEL then values=[]; else values=["17";"Patikra Žąsė";"TEST"]; end
endfunction
function selected=messagebox(varargin)
    if varargin(2)<>"Jūsų priskirtos reikšmės" then error("Netikėtas dialogas"); end
    selected=1;
endfunction
function selected=x_choose(varargin)
    global LD11_CHOICES;
    assert_checktrue(size(LD11_CHOICES,"*")>0);
    selected=LD11_CHOICES(1); LD11_CHOICES(1)=[];
endfunction
function path=uigetfile(varargin)
    global LD11_DRAFT; path=LD11_DRAFT;
endfunction
function ld11_test_help()
    global LD11;
    handles=findobj(LD11.fig,"callback","ld11_show_actions()");
    assert_checkequal(size(handles,"*"),1); bench_button(handles(1));
endfunction
function capture_ld11(name)
    global LD11;
    if getos()<>"Linux" then return; end
    LD11.fig.figure_name="LD11 PATIKRA "+name; show_window(LD11.fig); sleep(500);
    command="/usr/bin/python3 """+getenv("LD11_TEST_RUNTIME")+"/capture_window.py"" ""LD11 PATIKRA "+name+""" """+getenv("LD11_TEST_OUT")+"/"+name+".png""";
    assert_checkequal(host(command),0);
endfunction
try
    LD11=struct(); LD11_CANCEL=%t; exec(root+"LD11/LD11.sce",-1); assert_checkfalse(isfield(LD11,"fig"));
    LD11_CANCEL=%f; exec(root+"LD11/LD11.sce",-1); assert_checkequal(LD11.student.number,17);
    assert_checkequal(LD11.student.bank,"LD11-64-A-2026"); assert_checktrue(LD11.assessment & LD11.autosave_enabled); delete(LD11.fig);
    exec(root+"tests/workflows.sci",-1); exec(source+"tools/ergonomics.sci",-1);
    for number=[1 17 64]; bench_ld11_workflow(number,root,%t); end
    LD11=struct("cfg",ld11_variant_config(1),"student",student_profile(1,"Patikra Žąsė","TEST","LD11"),"ui",struct("headless",%f));
    ld11_start(); report=bench_report_data("LD11");
    for key=["s1" "s4"]; assert_checkequal(length(report.evidence.wiring(key).pairs),0); end
    assert_checkequal(length(report.observations),0);
    ld11_set_step(7); ld11_jump_step(%nan); assert_checkequal(LD11.step,1);
    ld11_set_mode(0); ld11_set_mode(%nan); ld11_set_mode(1.5); assert_checkequal(LD11.wireMode,1);
    ld11_toggle_solution(); rejected=%f;
    try report=bench_report_data("LD11"); catch rejected=%t; end
    assert_checktrue(rejected); ld11_measure(); ld11_check_step(); assert_checkfalse(or(LD11.done));
    ld11_toggle_solution(); assert_checkequal(size(LD11.journal,1),0); assert_checkequal(size(LD11.wires,1),0);
    descriptor=mopen(out+"geometry.tsv","wt"); sizes=[1280 720];
    screen=get(0,"screensize_px"); viewport=min(sizes,max([320 240],screen(3:4)-[40 120]));
    for dimension=1
        assert_checkequal(matrix(LD11.fig.axes_size,1,-1),viewport);
        assert_checkequal(student_size(LD11.ui.circuitFrame.parent),sizes);
        for step=1:6
            LD11.step=step; LD11.wireMode=ld11_stage_mode(step); LD11.wires=ld11_canonical_wires(LD11.wireMode);
            LD11.powerOn=%t; LD11.switchOn=%t; ld11_render_stage();
            label=msprintf("LD11-E%d-%dx%d",step,sizes(dimension,1),sizes(dimension,2));
            geometry_dump(LD11.fig,label,descriptor);
            LD11.wires=LD11.wires(:,[2 1]); ld11_render_wires(); geometry_dump(LD11.fig,label+"-reverse",descriptor);
            LD11.wires=LD11.wires($:-1:1,:); ld11_render_wires(); geometry_dump(LD11.fig,label+"-shuffled",descriptor);
            if step>=2 then capture_ld11("E"+string(step)); end
        end
    end
    LD11.ui.answerEdits(10).string="1,0";
    for dimension=1
        assert_checkequal(matrix(LD11.fig.axes_size,1,-1),viewport);
        assert_checkequal(student_size(LD11.ui.circuitFrame.parent),sizes);
        assert_checktrue(LD11.fig.resizefcn<>""); execstr(LD11.fig.resizefcn);
        assert_checkequal(LD11.ui.answerEdits(10).string,"1,0");
        geometry_dump(LD11.fig,"LD11-resize-"+string(dimension),descriptor);
    end

    report=bench_report_data("LD11");
    for key=["s1" "s4"]; assert_checkequal(length(report.evidence.wiring(key).pairs),0); end
    LD11.cfg=ld11_variant_config(64); LD11.student=student_profile(64,"Patikra Žąsė","TEST","LD11");
    // Rodmenys abiejuose režimuose; kompensacijos poveikis matomas kortelėse.
    for circuit_mode=1:2
        LD11.step=2*circuit_mode;
        LD11.wireMode=circuit_mode; LD11.wires=ld11_canonical_wires(circuit_mode);
        LD11.powerOn=%t; LD11.switchOn=%t; ld11_render_stage();
        [u,i,ok,msg,p]=ld11_measure_values();
        assert_checktrue(ok);
        handle=findobj("tag","reading:A"); assert_checkequal(handle.string,msprintf("%.6f mA",i));
        handle=findobj("tag","reading:W"); assert_checkequal(handle.string,msprintf("%.6f mW",p));
        handle=findobj("tag","reading:V"); assert_checkequal(handle.string,msprintf("%.4f V",u));
        geometry_dump(LD11.fig,"LD11-circuit_mode-"+string(circuit_mode),descriptor);
        bench_ld11_action("ld11_measure()");
        if circuit_mode==1 then
            assert_checktrue(and([i p] > 0));
        else
            // Po kompensacijos: I mažesnis, P toks pat, cos φ → 1.
            assert_checktrue(i<i1_saved);
            assert_checkalmostequal(p,p1_saved,1e-9,1e-9);
            execstr(LD11.fig.resizefcn); capture_ld11("su-Ck-V64");
        end
        if circuit_mode==1 then i1_saved=i; p1_saved=p; end
    end
    // The old equivalent return connection remains readable and gradeable.
    LD11.wires($,:)=["C_B" "GEN_N"]; ld11_render_wires();
    [ok,why]=ld11_wiring_valid(LD11.wires); assert_checktrue(ok);
    geometry_dump(LD11.fig,"LD11-legacy-return",descriptor);
    LD11.wires=LD11.wires(:,[2 1]); ld11_render_wires();
    geometry_dump(LD11.fig,"LD11-legacy-reverse",descriptor);
    mclose(descriptor);
    assert_checkequal(size(LD11.journal,1),2);
    journal=LD11.journal; bench_ld11_action("ld11_measure()"); assert_checkequal(LD11.journal,journal);
    ld11_set_step(5); LD11.ui.answerEdits(6).string="10,321";
    snapshot_path=bench_save_snapshot("LD11"); snapshot=bench_read_snapshot(snapshot_path,"LD11");
    ld11_restart(); bench_restore_snapshot(snapshot);
    assert_checkequal(LD11.ui.answerEdits(6).string,"10,321"); assert_checkequal(LD11.journal,journal);
    assert_checkfalse(LD11.powerOn); assert_checkfalse(LD11.switchOn);
    ld11_toggle_solution(); assert_checkequal(size(LD11.journal,1),1); ld11_toggle_solution(); assert_checkequal(LD11.journal,journal);
    LD11.assessment=%f; LD11.done(5)=%t; LD11.ui.answerEdits(6).string="1+2"; bench_ld11_primary();
    assert_checkfalse(LD11.done(5)); assert_checkequal(LD11.step,5); assert_checkequal(LD11.ui.answerEdits(6).string,"1+2");
    expected=ld11_expected_answers(); bench_ld11_answers(5,expected(5,1:4));
    LD11.ui.answerEdits(6).string=strsubst(LD11.ui.answerEdits(6).string,".",","); bench_ld11_primary();
    assert_checkequal(LD11.step,6); assert_checktrue(LD11.done(5));
    ld11_set_step(1); ld11_restore_stage(); assert_checkequal(size(LD11.wires,1),0);
    assert_checkequal(size(ld11_journal_rows(1),1),0); assert_checkfalse(LD11.done(1));
    report=bench_report_data("LD11"); assert_checkequal(length(report.evidence.wiring.s1.pairs),0);
    ld11_show_wiring_guide(); window=gcf(); assert_checktrue(window<>LD11.fig); delete(window);
    ld11_show_stand_map(); window=gcf(); assert_checktrue(window<>LD11.fig); delete(window);
    LD11.assessment=%t; ld11_set_step(5); expected=ld11_expected_answers();
    bench_ld11_answers(5,expected(5,1:4)); LD11.ui.answerEdits(7).string="";
    bench_ld11_primary(); assert_checkequal(LD11.step,5); assert_checkfalse(LD11.done(5));
    LD11.ui.answerEdits(7).string="1+2"; bench_ld11_primary();
    assert_checkequal(LD11.step,6); assert_checkequal(LD11.answers(5,2),"1+2");
    LD11.ui.answerEdits(10).string="2,0"; closing=LD11.fig; execstr(closing.closerequestfcn);
    if is_handle_valid(closing) then error("LD11_CLOSE_FAILED: "+LD11.autosave_error); end
    ld11_show_actions(); ld11_render_stage(); ld11_render_journal();
    LD11_DRAFT=LD11.autosave_paths($); saved=bench_read_snapshot(LD11_DRAFT,"LD11");
    assert_checkequal(saved.state.answers(6,1),"2,0"); assert_checkequal(saved.state.answers(5,2),"1+2");
    LD11=struct(); exec(root+"LD11/LD11.sce",-1); LD11_CHOICES=1; ld11_test_help();
    assert_checkequal(LD11.step,6); assert_checkequal(LD11.student.number,64); assert_checkequal(LD11.ui.answerEdits(10).string,"2,0");
    assert_checktrue(LD11.assessment & LD11.autosave_enabled);
    LD11_CHOICES=[4 2]; ld11_test_help(); assert_checkfalse(LD11.assessment); assert_checktrue(LD11.practice_used);
    LD11_CHOICES=[4 1]; ld11_test_help(); assert_checktrue(LD11.assessment & LD11.practice_used);
    LD11_CHOICES=6; ld11_test_help(); window=gcf(); assert_checktrue(window<>LD11.fig); delete(window);
    exec(source+"tools/test_ld11_edges.sci",-1); ld11_edge_checks();
    cases=list(); specs=[1 1 .01;2 1 .02;2 2 .02;2 3 .02;3 1 .03;5 1 .02;5 2 .02;5 3 .02;5 4 .02];
    for number=[1 17 64]
        bench_ld11_workflow(number,root,%f); expected=ld11_expected_answers(); original=LD11.answers;
        if number==1 then
            LD11.autosave_enabled=%t; bench_autosave("LD11"); bench_autosave("LD11"); bench_autosave("LD11");
            assert_checkequal(size(LD11.autosave_paths,"*"),2); assert_checkequal(LD11.autosave_error,"");
            // Užbaigtos ataskaitos: vertinimas ir suvestinės teisė nepriklauso.
            LD11.answers(2,1)="wrong";
            cases($+1)=struct("report",bench_report_data("LD11"),"accepted",%f);
            LD11.answers=original; LD11.practice_used=%t;
            cases($+1)=struct("report",bench_report_data("LD11"),"accepted",%t);
            LD11.practice_used=%f;
        end
        for index=1:size(specs,1)
            step=specs(index,1); slot=specs(index,2); value=expected(step,slot); tolerance=1e-9+specs(index,3)*abs(value);
            if step==5 & slot==2 then tolerance=.001+.02*abs(value); end
            for delta=[-1.0001 -.9999 .9999 1.0001]
                LD11.answers=original; LD11.step=step; LD11.done(step)=%f;
                if or(step==[1 4]) then
                    LD11.wireMode=ld11_stage_mode(step); LD11.wires=ld11_canonical_wires(LD11.wireMode);

                end
                LD11.answers(step,slot)=msprintf("%.17g",value+delta*tolerance); ld11_check_step();
                accepted=LD11.done(step); assert_checkequal(accepted,abs(delta)<1);
                cases($+1)=struct("report",bench_report_data("LD11"),"accepted",accepted);
            end
        end
        for slot=1:3
            for raw=[string(expected(6,slot))+",0" string(3-expected(6,slot)) "" "1+1"]
                LD11.answers=original; LD11.step=6; LD11.done(6)=%f; LD11.answers(6,slot)=raw; ld11_check_step();
                accepted=LD11.done(6); assert_checkequal(accepted,raw==string(expected(6,slot))+",0");
                cases($+1)=struct("report",bench_report_data("LD11"),"accepted",accepted);
            end
        end
    end
    mputl(toJSON(cases),out+"tolerance-cases.json");
    mputl("LD11_PASS: 3 GUI variants; coil wiring with and without Ck; wattmeter readings; compensation keeps P, cuts S and I, cos phi toward 1; actual report button; comma input without Enter; demo isolation; draft restore; 23 fixed-canvas geometry cases; 146 grading comparisons; actual assessment and close recovery; six malformed drafts; save failure recovery; retained base wiring; late callbacks ignored",out+"verdict.log"); exit(0);
catch
    [msg,num,line,fn]=lasterror();
    mputl("LD11_FAIL: "+strcat(msg," | ")+" at "+fn+":"+string(line),out+"verdict.log"); disp(msg); exit(1);
end
