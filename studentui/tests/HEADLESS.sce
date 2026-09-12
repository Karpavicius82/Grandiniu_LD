mode(-1);
root=get_absolute_file_path("HEADLESS.sce")+"../";
try
    if ~isdir(root+"tests/results") then mkdir(root+"tests/results"); end
    exec(root+"LD1/LD1_LOAD.sce",-1); exec(root+"LD2/LD2_LOAD.sce",-1); exec(root+"LD3/LD3_LOAD.sce",-1);
    exec(root+"tests/workflows.sci",-1);
    global LD1 LD2 LD3;
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
    table3="Variantas;R_Ohm;U1_V;U2_V;U3_V";
    values1=[]; values2=[]; values3=[];
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
        cfg3=ld3_variant_config(n); [ok3,why3]=ld3_validate_config(cfg3); assert_checktrue(ok3);
        values3(n,:)=[cfg3.R cfg3.U1 cfg3.U2 cfg3.U3];
        table3($+1)=msprintf("LD3-V%02d;%g;%g;%g;%g",n,cfg3.R,cfg3.U1,cfg3.U2,cfg3.U3);
        // Ohmo dėsnio modelis: kiekviename taške I = U/R turi būti teigiama reali srovė.
        for u=[cfg3.U1 cfg3.U2 cfg3.U3]
            i_mA=u/cfg3.R*1000;
            assert_checktrue((~isnan(i_mA)) & (~isinf(i_mA)) & (i_mA>0));
        end
        bench_ld2_workflow(n,root,%f);
        mprintf("PASS V%02d: LD1 matavimai, visi 12 LD2 etapų, LD3 variantas ir Ohmo modelis\n",n);
    end
    assert_checkequal(size(unique(values1,"r"),1),64);
    assert_checkequal(size(unique(values2,"r"),1),64);
    assert_checkequal(size(unique(values3,"r"),1),64);
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
    mputl(table1,root+"LD1/VARIANTAI.csv"); mputl(table2,root+"LD2/VARIANTAI.csv"); mputl(table3,root+"LD3/VARIANTAI.csv");
    // Instrukcijų <-> registrų konsistencija (analogas: tools/check_instruction_registry.py).
    codes1=ld1_all_codes(); codes2=ld2_all_codes(); codes3=ld3_all_codes();
    n1=size(codes1,1); n2=size(codes2,1); n3=size(codes3,1);
    if n1<40 then error("LD1 registras per mažas: "+string(n1)+" kodų (tikėtasi ne mažiau 40)."); end
    if n2<50 then error("LD2 registras per mažas: "+string(n2)+" kodų (tikėtasi ne mažiau 50)."); end
    if n3<30 then error("LD3 registras per mažas: "+string(n3)+" kodų (tikėtasi ne mažiau 30)."); end
    if size(unique(codes1),1)<>n1 then error("LD1 registre pasikartoja kodai."); end
    if size(unique(codes2),1)<>n2 then error("LD2 registre pasikartoja kodai."); end
    if size(unique(codes3),1)<>n3 then error("LD3 registre pasikartoja kodai."); end
    if size(find(codes1=="T01"),"*")==0 | size(find(codes1=="B01"),"*")==0 then error("LD1 registre trūksta kodų T01 arba B01."); end
    if size(find(codes2=="T01"),"*")==0 | size(find(codes2=="B01"),"*")==0 then error("LD2 registre trūksta kodų T01 arba B01."); end
    if size(find(codes3=="T01"),"*")==0 | size(find(codes3=="B01"),"*")==0 then error("LD3 registre trūksta kodų T01 arba B01."); end
    // Deklaracijos (REGISTRY-CODES) ir generatoriaus (ld*_all_codes) tapatumas abi kryptimis.
    function r=ldx_digit(ch)
        r=%f;
        for d=["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]
            if ch==d then r=%t; end
        end
    endfunction
    function [decl,problems]=ldx_declared(path)
        problems=[]; decl=[];
        lines=mgetl(path);
        for i=1:size(lines,"*")
            k=strindex(lines(i),"REGISTRY-CODES:");
            if k<>[] then
                tail=part(lines(i),k(1)+length("REGISTRY-CODES:"):length(lines(i)));
                toks=tokens(tail);
                for t=1:size(toks,"*")
                    tt=toks(t);
                    dd=strindex(tt,":");
                    if dd<>[] then
                        a=part(tt,1:dd(1)-1); b=part(tt,dd(1)+1:length(tt));
                        ja=length(a); while ja>0 & ldx_digit(part(a,ja)) then ja=ja-1; end
                        jb=length(b); while jb>0 & ldx_digit(part(b,jb)) then jb=jb-1; end
                        pa=part(a,1:ja); pb=part(b,1:jb);
                        na=evstr(part(a,ja+1:length(a))); nb=evstr(part(b,jb+1:length(b)));
                        if pa<>pb | na>nb then
                            problems($+1)=tt;
                        else
                            fmt=pa+"%0"+string(length(a)-ja)+"d";
                            for v=na:nb; decl($+1)=msprintf(fmt,v); end
                        end
                    else
                        decl($+1)=tt;
                    end
                end
                break;
            end
        end
        if decl==[] then problems($+1)="REGISTRY-CODES eilutė nerasta: "+path; end
    endfunction
    [decl1,pb1]=ldx_declared(root+"LD1/ld1_ids.sci");
    [decl2,pb2]=ldx_declared(root+"LD2/ld2_ids.sci");
    [decl3,pb3]=ldx_declared(root+"LD3/ld3_ids.sci");
    if pb1<>[] then error("LD1 deklaracijos klaida: "+strcat(pb1,"; ")); end
    if pb2<>[] then error("LD2 deklaracijos klaida: "+strcat(pb2,"; ")); end
    if pb3<>[] then error("LD3 deklaracijos klaida: "+strcat(pb3,"; ")); end
    for c=1:n1
        if size(find(decl1==codes1(c)),"*")==0 then error("LD1 generuotas kodas "+codes1(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:n2
        if size(find(decl2==codes2(c)),"*")==0 then error("LD2 generuotas kodas "+codes2(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:n3
        if size(find(decl3==codes3(c)),"*")==0 then error("LD3 generuotas kodas "+codes3(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:size(decl1,"*")
        if size(find(codes1==decl1(c)),"*")==0 then error("LD1 deklaruotas kodas "+decl1(c)+" negeneruojamas ld1_all_codes()."); end
    end
    for c=1:size(decl2,"*")
        if size(find(codes2==decl2(c)),"*")==0 then error("LD2 deklaruotas kodas "+decl2(c)+" negeneruojamas ld2_all_codes()."); end
    end
    for c=1:size(decl3,"*")
        if size(find(codes3==decl3(c)),"*")==0 then error("LD3 deklaruotas kodas "+decl3(c)+" negeneruojamas ld3_all_codes()."); end
    end
    mprintf("REGISTRY_OK: LD1 %d, LD2 %d, LD3 %d kodų — unikalūs, pavyzdiniai T01/B01 rasti\n",n1,n2,n3);
    mprintf("HEADLESS_PASS: 64 LD1 + 64 LD2 + 64 LD3 variantai, įvesties atmetimas, 768 LD2 etapų, Ohmo modelis, sesijos atkūrimas\n");
    exit(0);
catch
    mprintf("HEADLESS_FAIL: %s\n",strcat(lasterror()," | ")); exit(1);
end
