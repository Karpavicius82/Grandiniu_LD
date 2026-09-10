function s = ld1_result_value(v,d,unit)
    if isnan(v) then
        s="NEATLIKTA";
    else
        s=ld1_num(v,d);
        if unit<>"" then s=s+" "+unit; end
    end
endfunction

function ld1_update_results_table(showExample)
    global LD1;
    if argn(2)<1 then showExample=%f; end
    r=LD1.res;

    if showExample then
        [Rs1,Is1]=ld1_series_theory(1000);
        [Rs5,Is5]=ld1_series_theory(500);
        Rp=ld1_parallel_theory(1000);
        [I1,I2,It]=ld1_parallel_currents(0);
        t=["Bandymas" "Formulė / kilmė" "Skaičiuota" "Multimetro rodmuo" "Vertinimas"; ..
           "Nuosekli, VR1=1 kΩ" "I=E/(R1+1000)" ld1_num(Is1,3)+" mA" ld1_num(Is1,3)+" mA" "idealus pavyzdys"; ..
           "Nuosekli, VR1=500 Ω" "I=E/(R1+500)" ld1_num(Is5,3)+" mA" ld1_num(Is5,3)+" mA" "idealus pavyzdys"; ..
           "Lygiagreti, VR1=1 kΩ" "Rb=R3||(R2+1000)" ld1_num(Rp,2)+" Ω" ld1_num(LD1.cfg.E,3)+" V" "UAB=E"; ..
           "Kirchhofo dėsnis" "I1=E/R3; I2=E/R2" ld1_num(I1,3)+"+"+ld1_num(I2,3)+"="+ld1_num(It,3)+" mA" ld1_num(It,3)+" mA" "I=I1+I2"];
    else
        sIs1=ld1_result_value(r.Iseries1000,3,"mA");
        sMs1=ld1_result_value(r.Mseries1000,3,"mA");
        sEr1=ld1_result_value(r.Errseries1000,2,"%");
        sIs5=ld1_result_value(r.Iseries500,3,"mA");
        sMs5=ld1_result_value(r.Mseries500,3,"mA");
        sEr5=ld1_result_value(r.Errseries500,2,"%");
        sRp=ld1_result_value(r.Rparallel1000,2,"Ω");
        sUp=ld1_result_value(r.Uparallel1000,3,"V");
        sIt=ld1_result_value(r.It,3,"mA");
        sMIt=ld1_result_value(r.MIt,3,"mA");
        sKe=ld1_result_value(r.KclErr,2,"%");
        if isnan(r.I1) | isnan(r.I2) | isnan(r.It) then
            sKcalc="NEATLIKTA";
        else
            sKcalc=ld1_num(r.I1,3)+" + "+ld1_num(r.I2,3)+" = "+ld1_num(r.It,3)+" mA";
        end
        t=["Bandymas" "Formulė / kilmė" "Skaičiuota" "Multimetro rodmuo" "Vertinimas"; ..
           "Nuosekli, VR1=1 kΩ" "2–3 et.: I=E/(R1+1000)" sIs1 sMs1 sEr1; ..
           "Nuosekli, VR1=500 Ω" "4 et.: I=E/(R1+500)" sIs5 sMs5 sEr5; ..
           "Lygiagreti, VR1=1 kΩ" "6 et.: Rb=R3||(R2+1000)" sRp sUp "UAB matavimas"; ..
           "Kirchhofo dėsnis" "8 et.: I1=E/R3; I2=E/R2" sKcalc sMIt sKe];
    end
    LD1.ui.resultsTable.string=t;
endfunction

function ld1_export_results()
    global LD1;
    r=LD1.res;
    lines=["LD Nr.1;Nuolatinės srovės grandinės tyrimas";
           "E_V;"+string(LD1.cfg.E);
           "R1_Ohm;"+string(LD1.cfg.R1);
           "R2_Ohm;"+string(LD1.cfg.R2);
           "R3_Ohm;"+string(LD1.cfg.R3);
           "Bandymas;Formule_ar_kilme;Skaiciuota;Ismatuota;Skirtumas_proc";
           "Nuosekli_VR1_1000;I=E/(R1+1000);"+ld1_result_value(r.Iseries1000,6,"mA")+";"+ld1_result_value(r.Mseries1000,6,"mA")+";"+ld1_result_value(r.Errseries1000,4,"");
           "Nuosekli_VR1_500;I=E/(R1+500);"+ld1_result_value(r.Iseries500,6,"mA")+";"+ld1_result_value(r.Mseries500,6,"mA")+";"+ld1_result_value(r.Errseries500,4,"");
           "Lygiagreti_UAB;Rb=R3||(R2+1000);"+ld1_result_value(r.Rparallel1000,6,"Ohm")+";"+ld1_result_value(r.Uparallel1000,6,"V")+";";
           "Kirchhofas_It;I1=E/R3, I2=E/R2;"+ld1_result_value(r.It,6,"mA")+";"+ld1_result_value(r.MIt,6,"mA")+";"+ld1_result_value(r.KclErr,4,"")];
    out=LD1.base+"LD1_rezultatai.csv";
    mputl(lines,out);
    ld1_set_status("Rezultatai eksportuoti: "+out,"ok","NEATLIKTA CSV faile reiškia, kad atitinkamas etapas buvo praleistas arba neužfiksuotas.");
endfunction
