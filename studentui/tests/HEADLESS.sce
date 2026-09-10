mode(-1);
root=get_absolute_file_path("HEADLESS.sce")+"../";
try
    if ~isdir(root+"tests/results") then mkdir(root+"tests/results"); end
    exec(root+"LD1/LD1_LOAD.sce",-1); exec(root+"LD2/LD2_LOAD.sce",-1);
    exec(root+"tests/workflows.sci",-1);
    global LD1 LD2;
    [ok,log]=ld2_selftest(); mputl(log,root+"LD2/LD2_SELFTEST_LAST.txt");
    if ~ok then disp(log); error("LD2 bazinė savikontrolė nepraėjo."); end
    for invalid=["0" "65" "1.5" "1+2" "1e1" "%nan" "" "abc"]
        rejected=%f;
        try student_profile(invalid,"Testas","TEST","LD1"); catch rejected=%t; end
        assert_checktrue(rejected);
    end
    for blank=1:2
        rejected=%f;
        try
            if blank==1 then student_profile(1," ","TEST","LD2");
            else student_profile(1,"Testas"," ","LD2"); end
        catch rejected=%t; end
        assert_checktrue(rejected);
    end
    table1="Variantas;R1_Ohm;R2_Ohm;R3_Ohm;E_V";
    table2="Variantas;R8_Ohm;F_RC_Hz;R9_Ohm;F_RL_Hz;R13_Ohm;L3_mH;C4_nF";
    values1=[]; values2=[];
    for n=1:64
        cfg=ld1_variant_config(n);
        values1(n,:)=[cfg.R1 cfg.R2 cfg.R3];
        table1($+1)=msprintf("LD1-V%02d;%g;%g;%g;%g",n,cfg.R1,cfg.R2,cfg.R3,cfg.E);
        LD1=struct("cfg",cfg); ld1_init_state(); ld1_init_terminals(); LD1.powerOn=%t;
        LD1.wires=ld1_series_canonical_wires();
        for vr=[1000 500]
            LD1.VR1=vr; ld1_update_actual_values();
            [value,unit,ok,msg]=ld1_meter_read(); assert_checktrue(ok);
            expected=cfg.E/(cfg.R1+vr)*1000;
            assert_checktrue(abs(value-expected)<1d-3*expected);
        end
        LD1.panel="parallel"; LD1.wires=ld1_parallel_voltage_canonical_wires(); LD1.meterMode="V";
        [value,unit,ok,msg]=ld1_meter_read(); assert_checktrue(ok); assert_checktrue(abs(value-cfg.E)<1d-6);
        LD1.VR1=0; LD1.meterMode="A"; LD1.wires=ld1_parallel_kcl_canonical_wires(); ld1_update_actual_values();
        [value,unit,ok,msg]=ld1_meter_read(); assert_checktrue(ok);
        expected=cfg.E*(1/cfg.R2+1/cfg.R3)*1000;
        assert_checktrue(abs(value-expected)<1d-3*expected);
        cfg=ld2_variant_config(n); [ok,msg]=ld2_validate_config(cfg); assert_checktrue(ok);
        values2(n,:)=[cfg.R8 cfg.F_RC cfg.R9 cfg.F_RL cfg.R13 cfg.L3 cfg.C4];
        table2($+1)=msprintf("LD2-V%02d;%g;%g;%g;%g;%g;%g;%g",n,cfg.R8,cfg.F_RC,cfg.R9,cfg.F_RL,cfg.R13,cfg.L3*1e3,cfg.C4*1e9);
        bench_ld2_workflow(n,root,%f);
        mprintf("PASS V%02d: LD1 matavimai ir visi 12 LD2 etapų\n",n);
    end
    assert_checkequal(size(unique(values1,"r"),1),64);
    assert_checkequal(size(unique(values2,"r"),1),64);
    ld2_write_session(root+"tests/results/LD2-validation.sod");
    session=ld2_read_session(root+"tests/results/LD2-validation.sod");
    assert_checkequal(session.state.student.number,64);
    assert_checktrue(and(session.state.completed==1));
    ld2_restore_session(session);
    assert_checkfalse(LD2.state.power);
    assert_checktrue(and(LD2.state.completed==1));
    // A session labelled as a variant may not silently carry different values.
    session.cfg.R8=session.cfg.R8+1;
    save(root+"tests/results/LD2-invalid.sod","session");
    rejected=%f;
    try ld2_read_session(root+"tests/results/LD2-invalid.sod"); catch rejected=%t; end
    assert_checktrue(rejected);
    mputl(table1,root+"LD1/VARIANTAI.csv"); mputl(table2,root+"LD2/VARIANTAI.csv");
    mprintf("HEADLESS_PASS: 64 LD1 + 64 LD2 variantai, įvesties atmetimas, 768 LD2 etapų, sesijos atkūrimas\n");
    exit(0);
catch
    mprintf("HEADLESS_FAIL: %s\n",strcat(lasterror()," | ")); exit(1);
end
