function ld1_check_step()
    global LD1;
    n=LD1.step;
    if n==9 then ld1_export_results(); return; end

    select n
    case 1 then
        [ok,msg,fix]=ld1_validate_series_topology();
        if ~ok then ld1_set_status(msg,"error",fix); return; end
        if LD1.ui.typeSeries.value==0 then
            ld1_set_status("Grandinės tipas pasirinktas neteisingai.","error","Pažymėkite NUOSEKLI: R1, VR1, ampermetru ir šaltiniu yra tik vienas srovės kelias."); return;
        end
        ld1_mark_done("Teisingai: grandinė nuosekli, ampermetras įjungtas nuosekliai.");

    case 2 then
        if abs(LD1.VR1-1000)>1 then ld1_set_status("VR1 nėra 1000 Ω.","error","Paspauskite mygtuką 1 kΩ arba slankikliu nustatykite 1000 Ω."); return; end
        [R,I]=ld1_series_theory(1000);
        uR=ld1_parse_number(LD1.ui.qEdit(1).string); uI=ld1_parse_number(LD1.ui.qEdit(2).string);
        if isnan(uR) then ld1_set_status("Rbendr laukas tuščias arba įrašas nėra skaičius.","error","Įrašykite tik skaičių omais. Formulė: Rbendr = R1 + 1000 Ω."); return; end
        if ~ld1_close_enough(uR,R) then ld1_set_status("Rbendr reikšmė neteisinga.","error","Naudokite Rbendr = R1 + VR1. Abi varžos turi būti omais; VR1 = 1000 Ω."); return; end
        if isnan(uI) then ld1_set_status("Srovės laukas tuščias arba įrašas nėra skaičius.","error","Skaičiuokite I = 10 V / Rbendr. Gautus amperus padauginkite iš 1000 ir įrašykite mA."); return; end
        if ~ld1_close_enough(uI,I) then ld1_set_status("Apskaičiuota srovė neteisinga.","error","Naudokite I = E/Rbendr, E=10 V. Nepamirškite A → mA: ×1000."); return; end
        LD1.res.Rseries1000=R; LD1.res.Iseries1000=I;
        ld1_mark_done("Teoriniai skaičiavimai ties VR1 = 1 kΩ teisingi.");

    case 3 then
        [ok,msg,fix]=ld1_validate_series_topology(); if ~ok then ld1_set_status(msg,"error",fix); return; end
        if ~LD1.powerOn then ld1_set_status("Maitinimo šaltinis išjungtas.","error","Paspauskite IŠJUNGTA/ĮJUNGTA mygtuką, kad būtų 10 V DC, tada MATUOTI."); return; end
        if LD1.lastMeasurementStep<>3 | isnan(LD1.lastMeasurement) then ld1_set_status("Šiame etape dar nėra srovės matavimo.","error","Paspauskite MATUOTI. Jei gaunate KLAIDA – pirmiausia PATIKRINTI SUJUNGIMĄ."); return; end
        if ~ld1_any_yesno_selected() then ld1_set_status("Nepasirinktas atsakymas Taip/Ne.","error","Pažymėkite Taip, jei išmatuota ir apskaičiuota srovė skiriasi ne daugiau kaip 5 %; kitu atveju Ne."); return; end
        theo=LD1.res.Iseries1000; meas=LD1.lastMeasurement;
        if isnan(theo) then [rr,theo]=ld1_series_theory(1000); end
        err=abs(meas-theo)/max(theo,1e-9); expectedYes=(err<=0.05);
        if ld1_yes_selected()<>expectedYes then ld1_set_status("Taip/Ne pasirinkimas neatitinka skaitinio palyginimo.","error","Apskaičiuokite santykinį skirtumą. ≤5 % → Taip; >5 % → Ne."); return; end
        LD1.res.Mseries1000=meas; LD1.res.Errseries1000=err*100;
        ld1_mark_done("Matavimas užfiksuotas. Skirtumas = "+ld1_num(err*100,2)+" %.");

    case 4 then
        [ok,msg,fix]=ld1_validate_series_topology(); if ~ok then ld1_set_status(msg,"error",fix); return; end
        if abs(LD1.VR1-500)>1 then ld1_set_status("VR1 nėra 500 Ω.","error","Paspauskite 500 Ω mygtuką."); return; end
        [R,I]=ld1_series_theory(500);
        uR=ld1_parse_number(LD1.ui.qEdit(1).string); uI=ld1_parse_number(LD1.ui.qEdit(2).string);
        if isnan(uR) | ~ld1_close_enough(uR,R) then ld1_set_status("Rbendr ties VR1=500 Ω neteisinga.","error","Naudokite Rbendr = R1 + 500 Ω."); return; end
        if isnan(uI) | ~ld1_close_enough(uI,I) then ld1_set_status("I ties VR1=500 Ω neteisinga.","error","Naudokite I = 10 V / Rbendr ir rezultatą įrašykite mA."); return; end
        if ~LD1.powerOn then ld1_set_status("Maitinimo šaltinis išjungtas.","error","Įjunkite 10 V DC ir paspauskite MATUOTI."); return; end
        if LD1.lastMeasurementStep<>4 | isnan(LD1.lastMeasurement) then ld1_set_status("Trūksta srovės matavimo.","error","Paspauskite MATUOTI, tada palyginkite su apskaičiuota I."); return; end
        if ~ld1_any_yesno_selected() then ld1_set_status("Nepasirinktas Taip/Ne.","error","Pažymėkite, ar išmatuota ir apskaičiuota srovė sutampa 5 % ribose."); return; end
        meas=LD1.lastMeasurement; err=abs(meas-I)/max(I,1e-9); expectedYes=(err<=0.05);
        if ld1_yes_selected()<>expectedYes then ld1_set_status("Taip/Ne pasirinkimas neatitinka rezultato.","error","≤5 % skirtumas → Taip; >5 % → Ne."); return; end
        LD1.res.Rseries500=R; LD1.res.Iseries500=I; LD1.res.Mseries500=meas; LD1.res.Errseries500=err*100;
        ld1_mark_done("VR1 = 500 Ω bandymas baigtas. Sumažinus Rbendr, srovė padidėjo.");

    case 5 then
        [ok,msg,fix]=ld1_validate_parallel_voltage_topology();
        if ~ok then ld1_set_status(msg,"error",fix); return; end
        if LD1.ui.typeParallel.value==0 then ld1_set_status("Grandinės tipas pasirinktas neteisingai.","error","Pažymėkite LYGIAGRETI: R3 ir R2+VR1 yra dvi šakos tarp tų pačių A ir B mazgų."); return; end
        ld1_mark_done("Teisingai: dvi šakos yra lygiagrečios, voltmetras prijungtas tarp A ir B.");

    case 6 then
        [ok,msg,fix]=ld1_validate_parallel_voltage_topology(); if ~ok then ld1_set_status(msg,"error",fix); return; end
        if abs(LD1.VR1-1000)>1 then ld1_set_status("VR1 nėra 1000 Ω.","error","Paspauskite 1 kΩ mygtuką."); return; end
        R=ld1_parallel_theory(1000); uR=ld1_parse_number(LD1.ui.qEdit(1).string);
        if isnan(uR) | ~ld1_close_enough(uR,R) then ld1_set_status("Bendra lygiagrečios grandinės varža neteisinga.","error","Pirma Rš2=R2+VR1. Tada Rbendr=(R3·Rš2)/(R3+Rš2). VR1=1000 Ω."); return; end
        if ~LD1.powerOn then ld1_set_status("Maitinimo šaltinis išjungtas.","error","Įjunkite 10 V DC ir spauskite MATUOTI."); return; end
        if LD1.lastMeasurementStep<>6 | isnan(LD1.lastMeasurement) then ld1_set_status("Trūksta UAB matavimo.","error","Multimetras V (DC), +/V→A4, COM→B4; tada MATUOTI."); return; end
        if ~ld1_any_yesno_selected() then ld1_set_status("Nepasirinktas Taip/Ne.","error","Palyginkite UAB su 10 V ir pažymėkite atsakymą."); return; end
        expectedYes=(abs(LD1.lastMeasurement-LD1.cfg.E)/LD1.cfg.E<=0.05);
        if ld1_yes_selected()<>expectedYes then ld1_set_status("Taip/Ne pasirinkimas neatitinka UAB palyginimo.","error","Jei UAB nuo 10 V skiriasi ≤5 %, rinkitės Taip; kitu atveju Ne."); return; end
        LD1.res.Rparallel1000=R; LD1.res.Uparallel1000=LD1.lastMeasurement; LD1.parallelBaseVoltage=LD1.lastMeasurement;
        ld1_mark_done("UAB matavimas užfiksuotas: "+ld1_num(LD1.lastMeasurement,3)+" V.");

    case 7 then
        [ok,msg,fix]=ld1_validate_parallel_voltage_topology(); if ~ok then ld1_set_status(msg,"error",fix); return; end
        if LD1.VR1==1000 then ld1_set_status("VR1 dar nepakeistas.","error","Paspauskite, pvz., 500 Ω. Kitų laidų nekeiskite."); return; end
        if LD1.lastMeasurementStep<>7 | isnan(LD1.lastMeasurement) then ld1_set_status("Po VR1 pakeitimo neatliktas naujas UAB matavimas.","error","Paspauskite MATUOTI dar kartą."); return; end
        if ~ld1_any_yesno_selected() then ld1_set_status("Nepasirinktas Taip/Ne.","error","Pažymėkite, ar UAB pasikeitė daugiau kaip 5 %."); return; end
        base=LD1.parallelBaseVoltage;
        if isnan(base) & ~isnan(LD1.res.Uparallel1000) then base=LD1.res.Uparallel1000; end
        if isnan(base) then base=LD1.cfg.E; end
        delta=abs(LD1.lastMeasurement-base);
        changed=(delta/max(LD1.cfg.E,1e-9)>0.05);
        if ld1_yes_selected()<>changed then ld1_set_status("Taip/Ne pasirinkimas neatitinka grandinės elgsenos.","error","Idealiame 10 V šaltinyje A-B įtampa iš esmės nekinta keičiant vienos šakos varžą, todėl tikėtinas atsakymas – Ne."); return; end
        LD1.res.UparallelChanged=LD1.lastMeasurement;
        ld1_mark_done("Teisingai: keičiant vienos lygiagrečios šakos varžą, UAB idealiame modelyje iš esmės nekinta.");

    case 8 then
        [ok,msg,fix]=ld1_validate_parallel_total_current_topology(); if ~ok then ld1_set_status(msg,"error",fix); return; end
        if abs(LD1.VR1)>1 then ld1_set_status("VR1 nėra 0 Ω.","error","Paspauskite 0 Ω. Kitų 8 etapo laidų nekeiskite."); return; end
        [I1,I2,It]=ld1_parallel_currents(0);
        u1=ld1_parse_number(LD1.ui.qEdit(1).string); u2=ld1_parse_number(LD1.ui.qEdit(2).string); ut=ld1_parse_number(LD1.ui.qEdit(3).string);
        if isnan(u1) | ~ld1_close_enough(u1,I1) then ld1_set_status("I1 reikšmė neteisinga.","error","I1 yra R3 šakos srovė: I1 = E/R3. E=10 V; rezultatą įrašykite mA."); return; end
        if isnan(u2) | ~ld1_close_enough(u2,I2) then ld1_set_status("I2 reikšmė neteisinga.","error","Kai VR1=0 Ω, antroji šaka turi R2. Skaičiuokite I2 = E/R2 ir įrašykite mA."); return; end
        if isnan(ut) | ~ld1_close_enough(ut,It) then ld1_set_status("Bendra I reikšmė neteisinga.","error","Taikykite Kirchhofo srovės dėsnį: I = I1 + I2."); return; end
        if ~LD1.powerOn then ld1_set_status("Maitinimo šaltinis išjungtas.","error","Pirmiausia PATIKRINTI SUJUNGIMĄ. Jei jis teisingas, įjunkite 10 V ir MATUOTI."); return; end
        if LD1.lastMeasurementStep<>8 | isnan(LD1.lastMeasurement) then ld1_set_status("Trūksta bendros srovės matavimo.","error","Kai sujungimas patikrintas ir maitinimas įjungtas, paspauskite MATUOTI."); return; end
        if ~ld1_any_yesno_selected() then ld1_set_status("Nepasirinktas Taip/Ne.","error","Palyginkite išmatuotą bendrą srovę su I1+I2 ir pažymėkite atsakymą."); return; end
        meas=LD1.lastMeasurement; err=abs(meas-It)/max(It,1e-9); expectedYes=(err<=0.05);
        if ld1_yes_selected()<>expectedYes then ld1_set_status("Taip/Ne pasirinkimas neatitinka skaitinio palyginimo.","error","Jei |Imat−(I1+I2)|/(I1+I2) ≤5 %, rinkitės Taip; kitu atveju Ne."); return; end
        LD1.res.I1=I1; LD1.res.I2=I2; LD1.res.It=It; LD1.res.MIt=meas; LD1.res.KclErr=err*100;
        ld1_mark_done("Kirchhofo srovės dėsnis patikrintas: I ≈ I1 + I2. Skirtumas = "+ld1_num(err*100,2)+" %.");
    end
endfunction
