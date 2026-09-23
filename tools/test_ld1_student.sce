mode(-1); funcprot(0);
root=getenv("LD1_TEST_RUNTIME")+"/"; out=getenv("LD1_TEST_OUT")+"/";
global LD1 LD1_TEST_NUMBER;
function values=x_mdialog(varargin)
    global LD1_TEST_NUMBER; values=[string(LD1_TEST_NUMBER);"Studento UI Patikra";"TEST"];
endfunction
function selected=messagebox(varargin)
    if varargin(2)=="LD1" & varargin(1)=="Ar tikrai pradėti laboratorinį darbą iš naujo?" then selected=1; return; end
    if varargin(2)<>"Jūsų priskirtos reikšmės" then error("Netikėtas dialogas: "+strcat(string(varargin(1))," | ")); end
    selected=1;
endfunction
function ui_primary()
    global LD1;
    assert_checkequal(LD1.ui.ctrlFrame.visible,"on");
    assert_checkequal(LD1.ui.checkStep.visible,"on"); assert_checkequal(LD1.ui.checkStep.enable,"on");
    execstr(LD1.ui.checkStep.callback);
endfunction
function ui_answers(values)
    global LD1;
    for k=1:size(values,"*")
        assert_checkequal(LD1.ui.qEdit(k).visible,"on");
        LD1.ui.qEdit(k).string=strsubst(msprintf("%.12g",values(k)),".",",");
    end
endfunction
function capture_ld1(name)
    global LD1;
    if getos()=="Windows" then return; end
    LD1.fig.figure_name="LD1 UI "+name; show_window(LD1.fig); sleep(250);
    command="/usr/bin/python3 """+getenv("LD1_TEST_RUNTIME")+"/capture_window.py"" ""LD1 UI "+name+""" """+getenv("LD1_TEST_OUT")+"/"+name+".png""";
    assert_checkequal(host(command),0);
endfunction
try
    exec(getenv("LD1_TEST_SOURCE")+"/tools/ergonomics.sci",-1);
    fd=mopen(out+"geometry.tsv","wt"); sizes=[1280 720];
    for number=[1 17 64]
        LD1=struct(); LD1_TEST_NUMBER=number; exec(root+"LD1/LD1.sce",-1);
        assert_checktrue(LD1.guided); assert_checktrue(LD1.assessment);
        assert_checkequal(LD1.fig.axes_size,[1280 720]); assert_checkequal(LD1.fig.resize,"off");
        LD1.autosave_enabled=%f; cfg=LD1.cfg;
        primary_position=LD1.ui.checkStep.position; back_position=LD1.ui.prev.position;
        assert_checkequal(size(LD1.wires,1),4);
        ui_primary(); assert_checkequal(LD1.step,1); // Missing choice stays visible.
        for step=1:8
            assert_checkequal(LD1.step,step);
            if step==1 then LD1.ui.typeSeries.value=1;
            elseif step==2 then
                ui_primary(); assert_checkequal(LD1.step,2);
                ui_answers([cfg.R1+1000 cfg.E/(cfg.R1+1000)*1000]);
            elseif step==3 then
                assert_checkalmostequal(LD1.stepMeas(3),cfg.E/(cfg.R1+1000)*1000,1e-9,1e-9);
                LD1.ui.yes.value=1;
            elseif step==4 then
                assert_checkequal(LD1.VR1,500);
                ui_answers([cfg.R1+500 cfg.E/(cfg.R1+500)*1000]); LD1.ui.yes.value=1;
                before=LD1.stepMeas; raw=LD1.ui.qEdit(2).string;
                LD1.assessment=%f; ld1_toggle_solution(); assert_checktrue(LD1.demoMode);
                ui_primary(); assert_checkfalse(LD1.demoMode); LD1.assessment=%t;
                assert_checkequal(LD1.stepMeas,before); assert_checkequal(LD1.ui.qEdit(2).string,raw);
            elseif step==5 then LD1.ui.typeParallel.value=1;
            elseif step==6 then
                ui_answers(cfg.R3*(cfg.R2+1000)/(cfg.R3+cfg.R2+1000)); LD1.ui.yes.value=1;
            elseif step==7 then
                assert_checkequal(LD1.VR1,500); LD1.ui.no.value=1; LD1.ui.yes.value=0;
            elseif step==8 then
                assert_checkequal(size(LD1.wires,1),8);
                i1=cfg.E/cfg.R3*1000; i2=cfg.E/cfg.R2*1000; ui_answers([i1 i2 i1+i2]);
                LD1.ui.yes.value=1; LD1.ui.no.value=0;
            end
            if number==1 then
                for dimension=1:size(sizes,1)
                    geometry_size(LD1.fig,sizes(dimension,:)); execstr(LD1.fig.resizefcn);
                    geometry_dump(LD1.fig,msprintf("LD1-E%d-%dx%d",step,sizes(dimension,1),sizes(dimension,2)),fd);
                    if dimension==1 & or(step==[1 3 8]) then capture_ld1("E"+string(step)); end
                end
            end
            ui_primary(); assert_checkequal(LD1.step,step+1); assert_checktrue(LD1.recorded(step));
            assert_checkequal(LD1.fig.axes_size,[1280 720]);
            assert_checkequal(LD1.ui.checkStep.position,primary_position);
            assert_checkequal(LD1.ui.prev.position,back_position);
            mprintf("UI LD1 V%02d E%d PASS\n",number,step);
        end
        assert_checkfalse(or(isnan(LD1.stepMeas([3 4 6 7 8]))));
        assert_checkequal(LD1.res.Mseries1000,LD1.stepMeas(3)); assert_checkequal(LD1.res.MIt,LD1.stepMeas(8));
        assert_checkequal(size(strindex(strcat(LD1.ui.resultsTable.string," "),"NEATLIKTA"),"*"),0);
        before=LD1.stepMeas; raw=LD1.stepQ;
        if number==1 then
            for dimension=1:size(sizes,1)
                geometry_size(LD1.fig,sizes(dimension,:));
                geometry_dump(LD1.fig,msprintf("LD1-E9-%dx%d",sizes(dimension,1),sizes(dimension,2)),fd);
                capture_ld1("ataskaita");
            end
        end
        ui_primary(); assert_checktrue(size(strindex(LD1.ui.statusMain.string,"Ataskaita išsaugota"),"*")>0);
        report=bench_report_data("LD1"); assert_checktrue(report.evidence.automatic_setup);
        summary_snapshot=bench_snapshot("LD1"); bench_restore_snapshot(summary_snapshot);
        assert_checkequal(LD1.step,9); assert_checkequal(length(LD1.ui.resultCards),4);
        for h=LD1.ui.resultCards; assert_checktrue(is_handle_valid(h)); assert_checkequal(h.visible,"on"); end
        ld1_set_step(2); LD1.ui.qEdit(1).string="99999,0"; ui_primary(); assert_checkequal(LD1.step,3);
        assert_checkequal(LD1.stepQ(2,1),"99999,0"); // Wrong answers are not replaced by a solution.
        report=bench_report_data("LD1"); mputl(toJSON(report),out+msprintf("wrong-V%02d.json",number));
        LD1.ui.yes.value=1; ui_primary(); assert_checkequal(LD1.step,4);
        assert_checkequal(LD1.stepMeas,before);
        snapshot=bench_snapshot("LD1"); ld1_restart(); bench_restore_snapshot(snapshot);
        assert_checkequal(LD1.stepQ(2,1),"99999,0"); assert_checkequal(LD1.stepMeas,before);
        ld1_toggle_guided(); assert_checkfalse(LD1.guided); assert_checkequal(LD1.ui.measure.visible,"on");
        ld1_toggle_guided(); assert_checktrue(LD1.guided); assert_checkequal(LD1.stepMeas,before);
        delete(LD1.fig);
        ld1_student_answer_changed(); ld1_student_primary(); ld1_student_help();
    end
    mclose(fd);
    // Original manual workflow must still work, through its actual controls.
    exec(root+"tests/workflows.sci",-1); bench_ld1_workflow(17,root);
    mputl("PASS: 3 actual LD1 student entries; 9 stages; automatic wiring and readings; raw answers; report button; saved results; draft restore; manual mode; fixed 1280x720 window, 9 geometry cases",out+"verdict.log"); exit(0);
catch
    mputl("FAIL: "+strcat(lasterror()," | "),out+"verdict.log"); disp(lasterror()); exit(1);
end
