// Exercise normal student actions. Never mark a stage completed directly.
function bench_button(h)
    assert_checkequal(h.enable,"on");
    assert_checkequal(h.visible,"on");
    execstr(h.callback);
endfunction

function bench_ld1_click(id)
    global LD1;
    k=find(LD1.term.handleIds==id);
    assert_checktrue(size(k,"*")>0);
    bench_button(LD1.term.handles(k(1)));
endfunction

function bench_ld1_answers(values)
    global LD1;
    for k=1:size(values,"*")
        LD1.ui.qEdit(k).string=msprintf("%.12g",values(k));
        execstr(LD1.ui.qEdit(k).callback);
    end
endfunction

function bench_ld1_workflow(n,root)
    global LD1;
    cfg=ld1_variant_config(n);
    LD1=struct("base",root+"tests/results/","cfg",cfg,"student",student_profile(n,"Automatinė Patikra","TEST","LD1"));
    ld1_start();
    LD1.fig.figure_name="PATIKRA · LD1 · variantas "+string(n);
    for step=1:8
        assert_checkequal(LD1.step,step);
        if step==1 | step==5 then
            if step==1 then W=ld1_series_canonical_wires(); else W=ld1_parallel_voltage_canonical_wires(); end
            for k=1:size(W,1); bench_ld1_click(W(k,1)); bench_ld1_click(W(k,2)); end
            if step==1 then LD1.ui.typeSeries.value=1; execstr(LD1.ui.typeSeries.callback);
            else LD1.ui.typeParallel.value=1; execstr(LD1.ui.typeParallel.callback); end
        elseif step==2 then
            bench_ld1_answers([cfg.R1+1000 cfg.E/(cfg.R1+1000)*1000]);
        elseif step==3 then
            bench_button(LD1.ui.power); bench_button(LD1.ui.measure);
            LD1.ui.yes.value=1; execstr(LD1.ui.yes.callback);
        elseif step==4 then
            bench_ld1_answers([cfg.R1+500 cfg.E/(cfg.R1+500)*1000]);
            bench_button(LD1.ui.measure); LD1.ui.yes.value=1; execstr(LD1.ui.yes.callback);
        elseif step==6 then
            bench_ld1_answers(cfg.R3*(cfg.R2+1000)/(cfg.R3+cfg.R2+1000));
            bench_button(LD1.ui.power); bench_button(LD1.ui.measure);
            LD1.ui.yes.value=1; execstr(LD1.ui.yes.callback);
        elseif step==7 then
            ld1_set_vr(500); bench_button(LD1.ui.measure);
            LD1.ui.no.value=1; LD1.ui.yes.value=0; execstr(LD1.ui.no.callback);
        elseif step==8 then
            bench_ld1_click("SRC_P"); bench_ld1_click("M_P");
            bench_ld1_click("M_N"); bench_ld1_click(LD1.kclTargetA);
            i1=cfg.E/cfg.R3*1000; i2=cfg.E/cfg.R2*1000;
            bench_ld1_answers([i1 i2 i1+i2]);
            bench_button(LD1.ui.power); bench_button(LD1.ui.measure);
            LD1.ui.yes.value=1; LD1.ui.no.value=0; execstr(LD1.ui.yes.callback);
        end
        bench_button(LD1.ui.checkStep);
        if ~LD1.done(step) then error("LD1 V"+string(n)+" etapas "+string(step)+": "+LD1.ui.statusMain.string); end
        if step==2 then
            saved=LD1.ui.qEdit(2).string; LD1.ui.qEdit(2).string="0";
            execstr(LD1.ui.qEdit(2).callback); assert_checkfalse(LD1.done(2));
            bench_button(LD1.ui.checkStep); assert_checkfalse(LD1.done(2));
            LD1.ui.qEdit(2).string=saved; execstr(LD1.ui.qEdit(2).callback);
            bench_button(LD1.ui.checkStep); assert_checktrue(LD1.done(2));
        end
        if step==4 then
            saved=LD1.wires; savedText=LD1.ui.qEdit(2).string;
            ld1_toggle_solution(); assert_checktrue(LD1.demoMode);
            bench_button(LD1.ui.checkStep); assert_checkfalse(LD1.demoMode);
            assert_checkequal(LD1.wires,saved); assert_checkequal(LD1.ui.qEdit(2).string,savedText);
        end
        bench_button(LD1.ui.checkStep);
        mprintf("PASS LD1 V%02d: etapas %d\n",n,step);
    end
    assert_checkequal(LD1.step,9); assert_checktrue(and(LD1.done));
    bench_button(LD1.ui.checkStep);
    exported=mgetl(LD1.base+LD1.student.variant_id+"_rezultatai.csv");
    assert_checktrue(or(exported=="Variantas;"+ascii(34)+LD1.student.variant_id+ascii(34)));
    // Same variant identity edits retain work; changing variant resets it.
    st=student_profile(n,"Pataisytas Vardas","TEST-2","LD1"); ld1_apply_profile(st,cfg);
    assert_checktrue(and(LD1.done));
    st=student_profile(modulo(n,64)+1,"Kitas Studentas","TEST","LD1");
    ld1_apply_profile(st,ld1_variant_config(st.number)); assert_checkfalse(or(LD1.done));
    assert_checkequal(LD1.step,1); assert_checkequal(size(LD1.wires,1),0);
    delete(LD1.fig);
endfunction

function bench_ld2_action(callback)
    global LD2;
    if LD2.ui.headless then execstr(callback); return; end
    for k=1:size(LD2.ui.dynamic,"*")
        h=LD2.ui.dynamic(k);
        if h.callback==callback then bench_button(h); return; end
    end
    error("Nėra matomo mygtuko: "+callback);
endfunction

function bench_ld2_click(id)
    bench_ld2_action(msprintf("ld2_terminal_click(""%s"")",id));
endfunction

function bench_ld2_probe(phase,target)
    // The same action as the instrument's Remove probes button.
    bench_ld2_action("ld2_remove_voltage_probes()");
    pair=ld2_probe_pair(phase,target);
    bench_ld2_click("VM_H"); bench_ld2_click(pair(1));
    bench_ld2_click("VM_L"); bench_ld2_click(pair(2));
endfunction

function bench_ld2_answers(step,values)
    global LD2;
    if LD2.ui.headless then ld2_test_answers(step,values); return; end
    for k=1:size(values,"*")
        LD2.ui.answer_edits(k).string=msprintf("%.12g",values(k));
        execstr(LD2.ui.answer_edits(k).callback);
    end
endfunction

function bench_ld2_primary()
    global LD2;
    if LD2.ui.headless then ld2_student_primary();
    else bench_button(LD2.ui.studentPrimary); end
endfunction

function bench_ld2_workflow(n,root,gui)
    global LD2;
    cfg=ld2_variant_config(n);
    LD2=struct("root",root,"cfg",cfg,"state",ld2_initial_state(cfg), ...
        "ui",struct("headless",~gui,"suppress_render",%f,"dynamic",[],"answer_edits",[],"answer_step",0,"test_no_dialogs",%t), ...
        "example_active",%f,"example_backup",struct());
    LD2.state.student=student_profile(n,"Automatinė Patikra","TEST","LD2");
    if gui then ld2_build_gui(); LD2.ui.figure.figure_name="PATIKRA · LD2 · variantas "+string(n); end
    ld2_go_step(1,%f);
    rc=ld2_rc_values(cfg.E_RC,cfg.F_RC,cfg.R8,cfg.C2);
    rl=ld2_rl_values(cfg.E_RL,cfg.F_RL,cfg.R9,cfg.L1);
    rr=ld2_peak_reference(cfg);
    for step=1:12
        assert_checkequal(LD2.state.step,step);
        phase=ld2_phase_for_step(step);
        if step==2 | step==5 | step==8 then
            W=ld2_required_main(phase);
            for k=1:size(W,1); bench_ld2_click(W(k,1)); bench_ld2_click(W(k,2)); end
        elseif step==3 then
            bench_ld2_answers(step,[rc.X rc.Z rc.I*1000 rc.UR rc.UX rc.P*1000 rc.PHI_I]);
        elseif step==6 then
            bench_ld2_answers(step,[rl.X rl.Z rl.I*1000 rl.UR rl.UX rl.P*1000 rl.PHI_I]);
        elseif step==4 | step==7 then
            bench_ld2_action("ld2_power_toggle()"); bench_ld2_action("ld2_measure_current()");
            if step==4 then targets=["UR" "UC" "UE"]; r=rc; e=cfg.E_RC;
            else targets=["UR" "UL" "UE"]; r=rl; e=cfg.E_RL; end
            for target=targets; bench_ld2_probe(phase,target); bench_ld2_action("ld2_measure_voltage()"); end
            bench_ld2_answers(step,[e r.I*1000]);
        elseif step==9 then
            bench_ld2_probe("RLC","UR"); bench_ld2_action("ld2_power_toggle()");
            for f=[rr.F0-rr.BW/2 rr.F0 rr.F0+rr.BW/2]
                ld2_set_frequency(f); bench_ld2_action("ld2_measure_voltage()"); bench_ld2_action("ld2_record_resonance_point()");
            end
            bench_ld2_answers(step,[rr.F0 rr.F0 1000/rr.F0 cfg.E_RLC]);
        elseif step==10 then
            targets=["UL" "UC" "ULC"]; centers=[rr.FL rr.FC rr.F0];
            for j=1:3
                bench_ld2_probe("RLC",targets(j));
                for f=[centers(j)-rr.BW/2 centers(j) centers(j)+rr.BW/2]
                    ld2_set_frequency(f); bench_ld2_action("ld2_measure_voltage()"); bench_ld2_action("ld2_record_peak_point()");
                end
            end
            [fl,ul,yes]=ld2_peak_best("UL"); [fc,uc,yes]=ld2_peak_best("UC"); [fz,uz,yes]=ld2_peak_best("ULC");
            bench_ld2_answers(step,[ul uc uz fl fc fz]);
        elseif step==11 then
            bench_ld2_probe("RLC","UR");
            ld2_set_frequency(rr.F1); bench_ld2_action("ld2_measure_voltage()"); bench_ld2_action("ld2_record_f1()");
            ld2_set_frequency(rr.F2); bench_ld2_action("ld2_measure_voltage()"); bench_ld2_action("ld2_record_f2()");
            bench_ld2_answers(step,[cfg.E_RLC/sqrt(2) rr.F1 rr.F2 rr.BW rr.Q]);
        elseif step==12 then
            bench_ld2_probe("RLC","UR"); bench_ld2_action("ld2_run_sweep()");
        end
        bench_ld2_primary();
        if LD2.state.completed(step)<>1 then error("LD2 V"+string(n)+" etapas "+string(step)+": "+LD2.state.last_error); end
        if gui & step==3 then
            saved=LD2.ui.answer_edits(1).string;
            LD2.ui.answer_edits(1).string="0"; execstr(LD2.ui.answer_edits(1).callback);
            bench_ld2_primary(); assert_checkequal(LD2.state.completed(3),0);
            assert_checktrue(LD2.state.last_error<>"");
            LD2.ui.answer_edits(1).string=saved; execstr(LD2.ui.answer_edits(1).callback);
            bench_ld2_primary(); assert_checkequal(LD2.state.completed(3),1);
        end
        if step>1 & step<12 then bench_ld2_primary(); end
        if gui then mprintf("PASS LD2 V%02d: etapas %d\n",n,step); end
    end
    assert_checktrue(and(LD2.state.completed==1));
    assert_checktrue(length(LD2.state.measurements)>=30);
    assert_checkequal(LD2.state.student.number,n);
    if gui then
        before=LD2.state;
        ld2_show_solution(); assert_checktrue(LD2.example_active);
        bench_ld2_primary(); assert_checkfalse(LD2.example_active);
        assert_checkequal(LD2.state.student,before.student);
        assert_checkequal(LD2.state.answers_text,before.answers_text);
        ld2_write_exports(root+"tests/results/");
        ld2_write_session(root+"tests/results/LD2-test.sod");
        session=ld2_read_session(root+"tests/results/LD2-test.sod");
        assert_checkequal(session.state.student,LD2.state.student);
        ld2_restore_session(session);
        assert_checktrue(and(LD2.state.completed==1));
        assert_checkfalse(LD2.state.power);
        st=student_profile(n,"Pataisytas Vardas","TEST-2","LD2"); ld2_apply_profile(st,cfg);
        assert_checktrue(and(LD2.state.completed==1));
        st=student_profile(modulo(n,64)+1,"Kitas Studentas","TEST","LD2");
        ld2_apply_profile(st,ld2_variant_config(st.number));
        assert_checkequal(length(LD2.state.measurements),0); assert_checkequal(LD2.state.step,1);
        delete(LD2.ui.figure);
    end
endfunction
