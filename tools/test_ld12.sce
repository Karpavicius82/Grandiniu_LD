mode(-1); funcprot(0);
root=getenv("LD12_TEST_RUNTIME")+"/"; out=getenv("LD12_TEST_OUT")+"/"; source=getenv("LD12_TEST_SOURCE")+"/";
global LD12 LD12_CANCEL LD12_CHOICES LD12_DRAFT;
LD12_CHOICES=[]; LD12_DRAFT="";
function values=x_mdialog(varargin)
    global LD12_CANCEL;
    if LD12_CANCEL then values=[]; else values=["17";"Patikra Žąsė";"TEST"]; end
endfunction
function selected=messagebox(varargin)
    if varargin(2)<>"Jūsų priskirtos reikšmės" then error("Netikėtas dialogas"); end
    selected=1;
endfunction
function selected=x_choose(varargin)
    global LD12_CHOICES;
    assert_checktrue(size(LD12_CHOICES,"*")>0);
    selected=LD12_CHOICES(1); LD12_CHOICES(1)=[];
endfunction
function path=uigetfile(varargin)
    global LD12_DRAFT; path=LD12_DRAFT;
endfunction
function ld12_test_help()
    global LD12;
    handles=findobj(LD12.fig,"callback","ld12_show_actions()");
    assert_checkequal(size(handles,"*"),1); bench_button(handles(1));
endfunction
function capture_ld12(name)
    global LD12;
    if getos()<>"Linux" then return; end
    LD12.fig.figure_name="LD12 PATIKRA "+name; show_window(LD12.fig); sleep(500);
    command="/usr/bin/python3 """+getenv("LD12_TEST_RUNTIME")+"/capture_window.py"" ""LD12 PATIKRA "+name+""" """+getenv("LD12_TEST_OUT")+"/"+name+".png""";
    assert_checkequal(host(command),0);
endfunction
try
    LD12=struct(); LD12_CANCEL=%t; exec(root+"LD12/LD12.sce",-1); assert_checkfalse(isfield(LD12,"fig"));
    LD12_CANCEL=%f; exec(root+"LD12/LD12.sce",-1); assert_checkequal(LD12.student.number,17);
    assert_checkequal(LD12.student.bank,"LD12-64-A-2026"); assert_checktrue(LD12.assessment & LD12.autosave_enabled); delete(LD12.fig);
    exec(root+"tests/workflows.sci",-1); exec(source+"tools/ergonomics.sci",-1);
    for number=[1 17 64]; bench_ld12_workflow(number,root,%t); end
    LD12=struct("cfg",ld12_variant_config(1),"student",student_profile(1,"Patikra Žąsė","TEST","LD12"),"ui",struct("headless",%f));
    ld12_start(); report=bench_report_data("LD12");
    for key=["s1" "s3"]; assert_checkequal(length(report.evidence.wiring(key).pairs),0); end
    assert_checkequal(length(report.observations),0);
    ld12_set_step(7); ld12_jump_step(%nan); assert_checkequal(LD12.step,1);
    ld12_set_mode(0); ld12_set_mode(%nan); ld12_set_mode(1.5); assert_checkequal(LD12.wireMode,1);
    ld12_toggle_solution(); rejected=%f;
    try report=bench_report_data("LD12"); catch rejected=%t; end
    assert_checktrue(rejected); ld12_measure(); ld12_check_step(); assert_checkfalse(or(LD12.done));
    ld12_toggle_solution(); assert_checkequal(size(LD12.journal,1),0); assert_checkequal(size(LD12.wires,1),0);
    sleep(200); // Let the window manager finish attaching decorations.
    descriptor=mopen(out+"geometry.tsv","wt"); sizes=[1280 720];
    screen=get(0,"screensize_px"); viewport=min(sizes,max([320 240],screen(3:4)-[40 120]));
    for dimension=1
        assert_checkequal(matrix(LD12.fig.axes_size,1,-1),viewport);
        assert_checkequal(student_size(LD12.ui.circuitFrame.parent),sizes);
        for step=1:6
            LD12.step=step; LD12.wireMode=ld12_stage_mode(step); LD12.wires=ld12_canonical_wires(LD12.wireMode);
            LD12.powerOn=%t; LD12.switchOn=%t; ld12_render_stage();
            label=msprintf("LD12-E%d-%dx%d",step,sizes(dimension,1),sizes(dimension,2));
            geometry_dump(LD12.fig,label,descriptor);
            LD12.wires=LD12.wires(:,[2 1]); ld12_render_wires(); geometry_dump(LD12.fig,label+"-reverse",descriptor);
            LD12.wires=LD12.wires($:-1:1,:); ld12_render_wires(); geometry_dump(LD12.fig,label+"-shuffled",descriptor);
            if step>=2 then capture_ld12("E"+string(step)); end
        end
    end
    LD12.ui.answerEdits(8).string="1,0";
    for dimension=1
        assert_checkequal(matrix(LD12.fig.axes_size,1,-1),viewport);
        assert_checkequal(student_size(LD12.ui.circuitFrame.parent),sizes);
        assert_checktrue(LD12.fig.resizefcn<>""); execstr(LD12.fig.resizefcn);
        assert_checkequal(LD12.ui.answerEdits(8).string,"1,0");
        geometry_dump(LD12.fig,"LD12-resize-"+string(dimension),descriptor);
    end

    report=bench_report_data("LD12");
    for key=["s1" "s3"]; assert_checkequal(length(report.evidence.wiring(key).pairs),0); end
    LD12.cfg=ld12_variant_config(64); LD12.student=student_profile(64,"Patikra Žąsė","TEST","LD12");
    // All seven channels must be visible and independently recorded.
    for circuit_mode=1:2
        LD12.step=2*circuit_mode;LD12.wireMode=circuit_mode;
        LD12.wires=ld12_canonical_wires(circuit_mode);LD12.powerOn=%t;LD12.switchOn=%t;
        count=3;if circuit_mode==2 then count=4;end
        for channel=1:count
            LD12.phase=channel;ld12_render_stage();[u,i,ok,msg]=ld12_measure_values();assert_checktrue(ok);
            handle=findobj(LD12.fig,"tag","reading:A");assert_checkequal(handle.string,msprintf("%.3f mA",i));
            handle=findobj(LD12.fig,"tag","reading:V");assert_checkequal(handle.string,msprintf("%.4f V",u));
            geometry_dump(LD12.fig,msprintf("LD12-mode%d-channel%d",circuit_mode,channel),descriptor);
            bench_ld12_action("ld12_measure()");
            report=bench_report_data("LD12");assert_checkequal(length(report.observations),size(LD12.journal,1));
            if circuit_mode==2 & channel==3 then
                if_phase=i;assert_checkequal(length(report.observations),6);
                ids=emptystr(0,1);for n=1:length(report.observations);ids($+1)=report.observations(n).id;end
                assert_checkfalse(or(ids=="ild"));
            end
            if circuit_mode==2 & channel==4 then assert_checkalmostequal(i,if_phase*sqrt(3),1e-9,1e-9);end
        end
        if circuit_mode==2 then capture_ld12("trikampis-V64");else capture_ld12("zvaigzde-V64");end
    end
    mclose(descriptor);
    assert_checkequal(size(LD12.journal,1),7);
    journal=LD12.journal; bench_ld12_action("ld12_measure()"); assert_checkequal(LD12.journal,journal);
    ld12_set_step(5); LD12.ui.answerEdits(6).string="10,321";
    snapshot_path=bench_save_snapshot("LD12"); snapshot=bench_read_snapshot(snapshot_path,"LD12");
    ld12_restart(); bench_restore_snapshot(snapshot);
    assert_checkequal(LD12.ui.answerEdits(6).string,"10,321"); assert_checkequal(LD12.journal,journal);
    assert_checkfalse(LD12.powerOn); assert_checkfalse(LD12.switchOn);
    ld12_toggle_solution(); assert_checkequal(size(LD12.journal,1),1); ld12_toggle_solution(); assert_checkequal(LD12.journal,journal);
    LD12.assessment=%f; LD12.done(5)=%t; LD12.ui.answerEdits(6).string="1+2"; bench_ld12_primary();
    assert_checkfalse(LD12.done(5)); assert_checkequal(LD12.step,5); assert_checkequal(LD12.ui.answerEdits(6).string,"1+2");
    expected=ld12_expected_answers(); bench_ld12_answers(5,expected(5,1:3));
    LD12.ui.answerEdits(6).string=strsubst(LD12.ui.answerEdits(6).string,".",","); bench_ld12_primary();
    assert_checkequal(LD12.step,6); assert_checktrue(LD12.done(5));
    ld12_set_step(1); ld12_restore_stage(); assert_checkequal(size(LD12.wires,1),0);
    assert_checkequal(size(ld12_journal_rows(1),1),0); assert_checkfalse(LD12.done(1));
    report=bench_report_data("LD12"); assert_checkequal(length(report.evidence.wiring.s1.pairs),0);
    ld12_show_wiring_guide(); window=gcf(); assert_checktrue(window<>LD12.fig); delete(window);
    ld12_show_stand_map(); window=gcf(); assert_checktrue(window<>LD12.fig); delete(window);
    LD12.assessment=%t; ld12_set_step(5); expected=ld12_expected_answers();
    bench_ld12_answers(5,expected(5,1:3)); LD12.ui.answerEdits(7).string="";
    bench_ld12_primary(); assert_checkequal(LD12.step,5); assert_checkfalse(LD12.done(5));
    LD12.ui.answerEdits(7).string="1+2"; bench_ld12_primary();
    assert_checkequal(LD12.step,6); assert_checkequal(LD12.answers(5,3),"1+2");
    LD12.ui.answerEdits(8).string="2,0"; closing=LD12.fig; execstr(closing.closerequestfcn);
    if is_handle_valid(closing) then error("LD12_CLOSE_FAILED: "+LD12.autosave_error); end
    ld12_show_actions(); ld12_render_stage(); ld12_render_journal();
    LD12_DRAFT=LD12.autosave_paths($); saved=bench_read_snapshot(LD12_DRAFT,"LD12");
    assert_checkequal(saved.state.answers(6,1),"2,0"); assert_checkequal(saved.state.answers(5,3),"1+2");
    LD12=struct(); exec(root+"LD12/LD12.sce",-1); LD12_CHOICES=1; ld12_test_help();
    assert_checkequal(LD12.step,6); assert_checkequal(LD12.student.number,64); assert_checkequal(LD12.ui.answerEdits(8).string,"2,0");
    assert_checktrue(LD12.assessment & LD12.autosave_enabled);
    LD12_CHOICES=[4 2]; ld12_test_help(); assert_checkfalse(LD12.assessment); assert_checktrue(LD12.practice_used);
    LD12_CHOICES=[4 1]; ld12_test_help(); assert_checktrue(LD12.assessment & LD12.practice_used);
    LD12_CHOICES=6; ld12_test_help(); window=gcf(); assert_checktrue(window<>LD12.fig); delete(window);
    exec(source+"tools/test_ld12_edges.sci",-1); ld12_edge_checks();
    cases=list();
    // [etapas, laukelis, santykinė paklaida; 0 = absoliuti 0,005 V (trikampio Uf)].
    specs=[1 1 .01;2 1 .02;3 1 0;4 1 .02;5 1 .02;5 2 .02;5 3 .02];
    for number=[1 17 64]
        bench_ld12_workflow(number,root,%f); expected=ld12_expected_answers(); original=LD12.answers;
        if number==1 then
            LD12.autosave_enabled=%t; bench_autosave("LD12"); bench_autosave("LD12"); bench_autosave("LD12");
            assert_checkequal(size(LD12.autosave_paths,"*"),2); assert_checkequal(LD12.autosave_error,"");
            // Užbaigtos ataskaitos: vertinimas ir suvestinės teisė nepriklauso.
            LD12.answers(2,1)="wrong";
            cases($+1)=struct("report",bench_report_data("LD12"),"accepted",%f);
            LD12.answers=original; LD12.practice_used=%t;
            cases($+1)=struct("report",bench_report_data("LD12"),"accepted",%t);
            LD12.practice_used=%f;
        end
        for index=1:size(specs,1)
            step=specs(index,1); slot=specs(index,2); value=expected(step,slot);
            if specs(index,3)==0 then tolerance=.005; else tolerance=1e-9+specs(index,3)*abs(value); end
            for delta=[-1.0001 -.9999 .9999 1.0001]
                LD12.answers=original; LD12.step=step; LD12.done(step)=%f;
                if or(step==[1 3]) then
                    LD12.wireMode=ld12_stage_mode(step); LD12.wires=ld12_canonical_wires(LD12.wireMode);
                end
                LD12.answers(step,slot)=msprintf("%.17g",value+delta*tolerance); ld12_check_step();
                accepted=LD12.done(step); assert_checkequal(accepted,abs(delta)<1);
                cases($+1)=struct("report",bench_report_data("LD12"),"accepted",accepted);
            end
        end
        for slot=1:3
            for raw=[string(expected(6,slot))+",0" string(3-expected(6,slot)) "" "1+1"]
                LD12.answers=original; LD12.step=6; LD12.done(6)=%f; LD12.answers(6,slot)=raw; ld12_check_step();
                accepted=LD12.done(6); assert_checkequal(accepted,raw==string(expected(6,slot))+",0");
                cases($+1)=struct("report",bench_report_data("LD12"),"accepted",accepted);
            end
        end
    end
    mputl(toJSON(cases),out+"tolerance-cases.json");
    mputl("LD12_PASS: 3 actual assessment workflows; 26 fixed-canvas geometry cases; 122 grading comparisons; seven independently recorded channels; no fabricated measurements; close/help recovery; eight malformed drafts; save failure; demo isolation; stale callbacks ignored",out+"verdict.log");exit(0);
catch
    [msg,num,line,fn]=lasterror();
    mputl("LD12_FAIL: "+strcat(msg," | ")+" at "+fn+":"+string(line),out+"verdict.log");disp(msg);exit(1);
end
