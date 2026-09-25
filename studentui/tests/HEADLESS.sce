mode(-1);
root=get_absolute_file_path("HEADLESS.sce")+"../";
try
    if ~isdir(root+"tests/results") then mkdir(root+"tests/results"); end
    exec(root+"LD1/LD1_LOAD.sce",-1); exec(root+"LD2/LD2_LOAD.sce",-1); exec(root+"LD3/LD3_LOAD.sce",-1); exec(root+"LD4/LD4_LOAD.sce",-1); exec(root+"LD5/LD5_LOAD.sce",-1); exec(root+"LD6/LD6_LOAD.sce",-1); exec(root+"LD7/LD7_LOAD.sce",-1); exec(root+"LD8/LD8_LOAD.sce",-1); exec(root+"LD9/LD9_LOAD.sce",-1); exec(root+"LD10/LD10_LOAD.sce",-1); exec(root+"LD11/LD11_LOAD.sce",-1);
    exec(root+"tests/workflows.sci",-1);
    global LD1 LD2 LD3 LD4 LD5 LD6 LD7 LD8 LD9 LD10 LD11;
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
    table4="Variantas;R1nom;R1;R2nom;R2;U1;U2;U3";
    for n=1:64
        c=ld4_variant_config(n);
        [v4,w4]=ld4_validate_config(c); assert_checktrue(v4);
        assert_checktrue(abs(c.R1/c.R1nom-1)<=0.0501 & abs(c.R2/c.R2nom-1)<=0.0501);
        table4($+1)=msprintf("LD4-V%02d;%g;%g;%g;%g;%g;%g;%g",n,c.R1nom,c.R1,c.R2nom,c.R2,c.U1,c.U2,c.U3);
    end
    mputl(table4,root+"LD4/VARIANTAI.csv");
    // LD5 modelio patikra: daliklio formulė visiems variantams.
    table5="Variantas;R1nom;R1;RVnom;RV;E;P1;P2;P3";
    for n=1:64
        c=ld5_variant_config(n);
        [v5,w5]=ld5_validate_config(c); assert_checktrue(v5);
        for k=1:3
            rvd=c.RV*c("P"+string(k))/100;
            assert_checktrue(c.E*rvd/(c.R1+rvd) > 0 & c.E*rvd/(c.R1+rvd) <= c.E);
        end
        table5($+1)=msprintf("LD5-V%02d;%g;%g;%g;%g;%g;%g;%g;%g",n,c.R1nom,c.R1,c.RVnom,c.RV,c.E,c.P1,c.P2,c.P3);
    end
    mputl(table5,root+"LD5/VARIANTAI.csv");
    table6="Variantas;E1;E2;R;Rnom;r1;r2";
    for n=1:64
        c=ld6_variant_config(n); [v6,w6]=ld6_validate_config(c);
        assert_checktrue(v6);
        table6($+1)=msprintf("LD6-V%02d;%g;%g;%g;%g;%g;%g",n,c.E1,c.E2,c.R,c.Rnom,c.r1,c.r2);
    end
    mputl(table6,root+"LD6/VARIANTAI.csv");
    table7="Variantas;E;r;R1;R2;R3;R4;R5";
    for n=1:64
        c=ld7_variant_config(n); [v7,w7]=ld7_validate_config(c);
        assert_checktrue(v7);
        // Suderinamumo tinklelis: didžiausia galia padėtyje P3 (R3=r), r apiplauktas iš abiejų pusių.
        loads=[c.R1 c.R2 c.R3 c.R4 c.R5];
        pp=c.E^2*loads./(loads+c.r).^2;
        assert_checkequal(max(pp),pp(3));
        assert_checktrue(c.R1<c.r & c.R5>c.r & c.R3==c.r);
        table7($+1)=msprintf("LD7-V%02d;%g;%g;%g;%g;%g;%g;%g",n,c.E,c.r,c.R1,c.R2,c.R3,c.R4,c.R5);
    end
    mputl(table7,root+"LD7/VARIANTAI.csv");
    table8="Variantas;E;R1;R2;R3;R1nom;R2nom;R3nom";
    for n=1:64
        c=ld8_variant_config(n); [v8,w8]=ld8_validate_config(c);
        assert_checktrue(v8);
        // Varžų jungimo dėsniai: serija didžiausia, lygiagretė mažiausia, mišri tarp jų.
        ser=c.R1+c.R2+c.R3;
        par=1/(1/c.R1+1/c.R2+1/c.R3);
        mis=c.R1+c.R2*c.R3/(c.R2+c.R3);
        assert_checktrue(ser>max([c.R1 c.R2 c.R3]));
        assert_checktrue(par<min([c.R1 c.R2 c.R3]));
        assert_checktrue(par<mis & mis<ser);
        table8($+1)=msprintf("LD8-V%02d;%g;%g;%g;%g;%g;%g;%g",n,c.E,c.R1,c.R2,c.R3,c.R1nom,c.R2nom,c.R3nom);
    end
    mputl(table8,root+"LD8/VARIANTAI.csv");
    table9="Variantas;E;R;L_mH;C_nF;f0_Hz";
    for n=1:64
        c=ld9_variant_config(n); [v9,w9]=ld9_validate_config(c);
        assert_checktrue(v9);
        // Rezonansas matomoje juostoje; kokybė Q > 1,5 visuose variantuose.
        f0=1/(2*%pi*sqrt(c.L*c.C));
        q=sqrt(c.L/c.C)/c.R;
        assert_checktrue(f0>500 & f0<25000);
        assert_checktrue(q>=1.5 & q<=5.5);
        table9($+1)=msprintf("LD9-V%02d;%g;%.2f;%g;%g;%.1f",n,c.E,c.R,c.LmH,c.CnF,f0);
    end
    mputl(table9,root+"LD9/VARIANTAI.csv");
    table10="Variantas;E;R;L_mH;C_nF;f0_Hz";
    for n=1:64
        c=ld10_variant_config(n); [v10,w10]=ld10_validate_config(c);
        assert_checktrue(v10);
        // Srovių rezonansas: Q = IL/I > 1,5; ties f0 I minimalus ir lygus U/R.
        f0=1/(2*%pi*sqrt(c.L*c.C));
        q=c.R*sqrt(c.C/c.L);
        assert_checktrue(f0>500 & f0<25000);
        assert_checktrue(q>=1.5 & q<=5.5);
        assert_checkalmostequal(c.E/c.R*1000, (c.E/c.R)*1000, 0, 0);
        table10($+1)=msprintf("LD10-V%02d;%g;%.2f;%g;%g;%.1f",n,c.E,c.R,c.LmH,c.CnF,f0);
    end
    mputl(table10,root+"LD10/VARIANTAI.csv");
    table11="Variantas;E;R;L_mH;Ck_uF;cos_fi0";
    for n=1:64
        c=ld11_variant_config(n); [v11,w11]=ld11_validate_config(c);
        assert_checktrue(v11);
        // Kompensacija įmanoma: cos φ0 tikrai < 1, Ck realiame diapazone.
        w=2*%pi*50; xl=w*c.L; z=sqrt(c.R^2+xl^2);
        cf=c.R/z;
        assert_checktrue(cf>0.02 & cf<0.98);
        assert_checktrue(c.Ck*1e6>0.5 & c.Ck*1e6<500);
        // Po kompensacijos: I krinta, P tas pats, cos φ → 1.
        g=c.R/(z*z); b2=w*c.Ck-xl/(z*z);
        i1=c.E*sqrt(g^2+(xl/(z*z))^2); i2=c.E*sqrt(g^2+b2^2);
        assert_checktrue(i2<i1);
        table11($+1)=msprintf("LD11-V%02d;%g;%g;%g;%.2f;%.3f",n,c.E,c.R,c.LmH,c.Ck*1e6,cf);
    end
    mputl(table11,root+"LD11/VARIANTAI.csv");
    // Instrukcijų <-> registrų konsistencija (analogas: tools/check_instruction_registry.py).
    codes1=ld1_all_codes(); codes2=ld2_all_codes(); codes3=ld3_all_codes(); codes4=ld4_all_codes(); codes5=ld5_all_codes(); codes6=ld6_all_codes(); codes7=ld7_all_codes(); codes8=ld8_all_codes(); codes9=ld9_all_codes(); codes10=ld10_all_codes(); codes11=ld11_all_codes();
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
    n4=size(codes4,1);
    if n4<35 then error("LD4 registras per mažas: "+string(n4)); end
    if size(unique(codes4),1)<>n4 then error("LD4 registre pasikartoja kodai."); end
    if size(find(codes4=="T01"),"*")==0 | size(find(codes4=="B01"),"*")==0 then error("LD4 registre trūksta kodų T01 arba B01."); end
    n5=size(codes5,1);
    if n5<35 then error("LD5 registras per mažas: "+string(n5)); end
    if size(unique(codes5),1)<>n5 then error("LD5 registre pasikartoja kodai."); end
    if size(find(codes5=="T01"),"*")==0 | size(find(codes5=="B01"),"*")==0 then error("LD5 registre trūksta T01/B01."); end
    n6=size(codes6,1);
    if n6<35 then error("LD6 registras per mažas: "+string(n6)); end
    if size(unique(codes6),1)<>n6 then error("LD6 registre pasikartoja kodai."); end
    if size(find(codes6=="T01"),"*")==0 | size(find(codes6=="B01"),"*")==0 then error("LD6 registre trūksta T01/B01."); end
    n7=size(codes7,1);
    if n7<35 then error("LD7 registras per mažas: "+string(n7)); end
    if size(unique(codes7),1)<>n7 then error("LD7 registre pasikartoja kodai."); end
    if size(find(codes7=="T01"),"*")==0 | size(find(codes7=="B01"),"*")==0 then error("LD7 registre trūksta T01/B01."); end
    n8=size(codes8,1);
    if n8<35 then error("LD8 registras per mažas: "+string(n8)); end
    if size(unique(codes8),1)<>n8 then error("LD8 registre pasikartoja kodai."); end
    if size(find(codes8=="T01"),"*")==0 | size(find(codes8=="B01"),"*")==0 then error("LD8 registre trūksta T01/B01."); end
    n9=size(codes9,1);
    if n9<35 then error("LD9 registras per mažas: "+string(n9)); end
    if size(unique(codes9),1)<>n9 then error("LD9 registre pasikartoja kodai."); end
    if size(find(codes9=="T01"),"*")==0 | size(find(codes9=="B01"),"*")==0 then error("LD9 registre trūksta T01/B01."); end
    n10=size(codes10,1);
    if n10<35 then error("LD10 registras per mažas: "+string(n10)); end
    if size(unique(codes10),1)<>n10 then error("LD10 registre pasikartoja kodai."); end
    if size(find(codes10=="T01"),"*")==0 | size(find(codes10=="B01"),"*")==0 then error("LD10 registre trūksta T01/B01."); end
    n11=size(codes11,1);
    if n11<35 then error("LD11 registras per mažas: "+string(n11)); end
    if size(unique(codes11),1)<>n11 then error("LD11 registre pasikartoja kodai."); end
    if size(find(codes11=="T01"),"*")==0 | size(find(codes11=="B01"),"*")==0 then error("LD11 registre trūksta T01/B01."); end
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
    [decl4,pb4]=ldx_declared(root+"LD4/ld4_ids.sci");
    [decl5,pb5]=ldx_declared(root+"LD5/ld5_ids.sci");
    [decl6,pb6]=ldx_declared(root+"LD6/ld6_ids.sci");
    [decl7,pb7]=ldx_declared(root+"LD7/ld7_ids.sci");
    [decl8,pb8]=ldx_declared(root+"LD8/ld8_ids.sci");
    [decl9,pb9]=ldx_declared(root+"LD9/ld9_ids.sci");
    [decl10,pb10]=ldx_declared(root+"LD10/ld10_ids.sci");
    [decl11,pb11]=ldx_declared(root+"LD11/ld11_ids.sci");
    if pb1<>[] then error("LD1 deklaracijos klaida: "+strcat(pb1,"; ")); end
    if pb2<>[] then error("LD2 deklaracijos klaida: "+strcat(pb2,"; ")); end
    if pb3<>[] then error("LD3 deklaracijos klaida: "+strcat(pb3,"; ")); end
    if pb4<>[] then error("LD4 deklaracijos klaida: "+strcat(pb4,"; ")); end
    if pb5<>[] then error("LD5 deklaracijos klaida: "+strcat(pb5,"; ")); end
    if pb6<>[] then error("LD6 deklaracijos klaida: "+strcat(pb6,"; ")); end
    if pb7<>[] then error("LD7 deklaracijos klaida: "+strcat(pb7,"; ")); end
    if pb8<>[] then error("LD8 deklaracijos klaida: "+strcat(pb8,"; ")); end
    if pb9<>[] then error("LD9 deklaracijos klaida: "+strcat(pb9,"; ")); end
    if pb10<>[] then error("LD10 deklaracijos klaida: "+strcat(pb10,"; ")); end
    if pb11<>[] then error("LD11 deklaracijos klaida: "+strcat(pb11,"; ")); end
    for c=1:n1
        if size(find(decl1==codes1(c)),"*")==0 then error("LD1 generuotas kodas "+codes1(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:n2
        if size(find(decl2==codes2(c)),"*")==0 then error("LD2 generuotas kodas "+codes2(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:n3
        if size(find(decl3==codes3(c)),"*")==0 then error("LD3 generuotas kodas "+codes3(c)+" nėra REGISTRY-CODES deklaracijoje."); end
    end
    for c=1:n4
        if size(find(decl4==codes4(c)),"*")==0 then error("LD4 generuotas kodas "+codes4(c)+" nėra REGISTRY-CODES deklaracijoje."); end
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
    for c=1:size(decl4,"*")
        if size(find(codes4==decl4(c)),"*")==0 then error("LD4 deklaruotas kodas "+decl4(c)+" negeneruojamas ld4_all_codes()."); end
    end
    for c=1:n5
        if size(find(decl5==codes5(c)),"*")==0 then error("LD5 generuotas kodas "+codes5(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl5,"*")
        if size(find(codes5==decl5(c)),"*")==0 then error("LD5 deklaruotas kodas "+decl5(c)+" negeneruojamas."); end
    end
    for c=1:n7
        if size(find(decl7==codes7(c)),"*")==0 then error("LD7 generuotas kodas "+codes7(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl7,"*")
        if size(find(codes7==decl7(c)),"*")==0 then error("LD7 deklaruotas kodas "+decl7(c)+" negeneruojamas."); end
    end
    for c=1:n8
        if size(find(decl8==codes8(c)),"*")==0 then error("LD8 generuotas kodas "+codes8(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl8,"*")
        if size(find(codes8==decl8(c)),"*")==0 then error("LD8 deklaruotas kodas "+decl8(c)+" negeneruojamas."); end
    end
    for c=1:n9
        if size(find(decl9==codes9(c)),"*")==0 then error("LD9 generuotas kodas "+codes9(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl9,"*")
        if size(find(codes9==decl9(c)),"*")==0 then error("LD9 deklaruotas kodas "+decl9(c)+" negeneruojamas."); end
    end
    for c=1:n10
        if size(find(decl10==codes10(c)),"*")==0 then error("LD10 generuotas kodas "+codes10(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl10,"*")
        if size(find(codes10==decl10(c)),"*")==0 then error("LD10 deklaruotas kodas "+decl10(c)+" negeneruojamas."); end
    end
    for c=1:n11
        if size(find(decl11==codes11(c)),"*")==0 then error("LD11 generuotas kodas "+codes11(c)+" nėra deklaracijoje."); end
    end
    for c=1:size(decl11,"*")
        if size(find(codes11==decl11(c)),"*")==0 then error("LD11 deklaruotas kodas "+decl11(c)+" negeneruojamas."); end
    end
    mprintf("REGISTRY_OK: LD1 %d, LD2 %d, LD3 %d, LD4 %d, LD5 %d, LD6 %d, LD7 %d, LD8 %d, LD9 %d, LD10 %d, LD11 %d kodų — unikalūs, pavyzdiniai T01/B01 rasti\n",n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11);
    mprintf("HEADLESS_PASS: 64 LD1 + 64 LD2 + 64 LD3 + 64 LD4 + 64 LD5 + 64 LD6 + 64 LD7 + 64 LD8 + 64 LD9 + 64 LD10 + 64 LD11 variantai, įvesties atmetimas, 768 LD2 etapų, Ohmo modelis, sesijos atkūrimas\n");
    exit(0);
catch
    mprintf("HEADLESS_FAIL: %s\n",strcat(lasterror()," | ")); exit(1);
end
