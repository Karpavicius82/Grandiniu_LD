function ld1_show_help()
    global LD1;
    txt=["LD1 – TEORIJA IR STENDO ATMINTINĖ";
         "";
         "STENDO VALDYMAS";
         "• Laidui prijungti: spauskite vieną rodomą lizdą, tada kitą.";
         "• 1 ir 5 etapuose jungiate visą schemą; 2–4 ir 6–7 etapuose patikrinti laidai užrakinami.";
         "• 8 etape aktyvūs tik 4 lizdai: šaltinio +, +/mA, COM ir nurodytas A lizdas.";
         "• PATIKRINTI SUJUNGIMĄ parodo: kas blogai + kaip tiksliai pataisyti.";
         "• KAIP SUJUNGTI parodo visą dabartinio etapo jungimo sąrašą.";
         "• PAVYZDYS / SPRENDIMAS laikinai parodo pilnai teisingą, veikiantį dabartinio etapo variantą.";
         "• Grįžus iš PAVYZDŽIO jūsų laidai, atsakymai ir matavimai lieka tokie, kokie buvo.";
         "• ATKURTI ETAPO STENDĄ atkuria tik šio etapo saugią pradinę būseną.";
         "• TOLIAU leidžia ir PRaleisti nebaigtą etapą; toks etapas pažymimas geltonai ir jį galima užbaigti vėliau.";
         "• DĖSTYTOJO / PERŽIŪROS REŽIMAS leidžia atidaryti bet kurį 1–9 etapą be ankstesnių atlikimo.";
         "";
         "MATAVIMO TAISYKLĖS";
         "• Ampermetras jungiamas NUOSEKLIAI su matuojama srove.";
         "• Voltmetras jungiamas LYGIAGREČIAI tarp A ir B.";
         "• Skaitinis rodmuo atsiranda tik paspaudus MATUOTI.";
         "";
         "REIKALINGOS FORMULĖS";
         "• Omo dėsnis: I = U/R.";
         "• Nuosekliai: Rbendr = R1 + R2 + ...; visur teka ta pati I.";
         "• Lygiagrečiai: U1 = U2 = UAB.";
         "• 2-oji šaka: Rš2 = R2 + VR1.";
         "• Rbendr = (R3·Rš2)/(R3+Rš2).";
         "• Kirchhoffas mazge: Ibendr = I1 + I2.";
         "• 8 etape VR1=0 Ω: I1=E/R3, I2=E/R2.";
         "";
         "PASTABOS APIE VIRTUALIĄ LABORATORORIJĄ";
         "• Atsakymų skaitinė tolerancija yra programos mokomoji taisyklė, ne originalaus aprašo tekstas.";
         "• 8 etape voltmetras vizualiai nuimamas, kad stendas būtų aiškesnis; 13–14 punktams jo rodmens nereikia.";
         "• Varžos įvedamos omais: 1 kΩ = 1000 Ω."];
    messagebox(txt,"LD1 – teorija ir valdymas","info");
endfunction

function ld1_restart()
    global LD1;
    answ=messagebox("Ar tikrai pradėti laboratorinį darbą iš naujo?","LD1","question",["Taip" "Ne"],"modal");
    if answ==1 then
        try
            delete(LD1.fig);
        catch
        end
        ld1_init_state();
        ld1_init_terminals();
        ld1_create_gui();
        ld1_build_panel("series");
        ld1_set_step(1);
    end
endfunction

function ld1_prev_step()
    global LD1;
    if LD1.step<=1 then return; end
    if LD1.reviewMode then
        ld1_jump_step(LD1.step-1);
    else
        ld1_set_step(LD1.step-1);
    end
endfunction

function ld1_next_step()
    global LD1;
    if LD1.step>=9 then return; end
    if LD1.reviewMode then
        ld1_jump_step(LD1.step+1);
        return;
    end
    if LD1.done(LD1.step) then
        ld1_set_step(LD1.step+1);
        return;
    end

    answ=messagebox([
        "Dabartinis etapas dar neužbaigtas.";
        "Galite pereiti toliau ir grįžti vėliau.";
        "Praleistas etapas bus pažymėtas GELTONAI, o 9 etape jo rezultatai bus NEATLIKTA.";
        "Kitas stendas bus paruoštas saugiai, todėl nereikės visko pradėti nuo pradžių."], ..
        "LD1 – pereiti nebaigus?","question",["LIKTI IR BAIGTI" "PEREITI NEBAIGUS"],"modal");
    if answ<>2 then return; end

    old=LD1.step;
    ld1_save_step_inputs();
    LD1.skipped(old)=%t;
    nxt=old+1;
    ld1_set_step(nxt);
    if nxt<9 then ld1_prepare_review_stage(nxt); end
    ld1_update_step_navigation();
    ld1_set_status("Etapas "+string(old)+" praleistas – galite grįžti vėliau.","warn","Geltonas etapo numeris reiškia NEBAIGTA. Kitas stendas paruoštas teisingai, kad galėtumėte tęsti testavimą.");
endfunction

function ld1_set_wiring_edit_mode(mode)
    global LD1;
    select mode
    case "full" then
        ld1_enable(LD1.ui.undoWire,%t);
        ld1_enable(LD1.ui.clearWires,%t);
    case "meter" then
        ld1_enable(LD1.ui.undoWire,%t);
        ld1_enable(LD1.ui.clearWires,%f);
    else
        ld1_enable(LD1.ui.undoWire,%f);
        ld1_enable(LD1.ui.clearWires,%f);
    end
endfunction

function ld1_prepare_step_common()
    global LD1;
    ld1_hide_all_answers();
    LD1.ui.resultsTable.visible="off";
    LD1.ui.resultsTable.position=[0.04 0.10 0.92 0.78];
    LD1.ui.checkStep.string="PATIKRINTI IR UŽFIKSUOTI ETAPĄ";
    LD1.ui.solution.string="PAVYZDYS / SPRENDIMAS";
    LD1.ui.instructionFrame.visible="on";
    LD1.ui.instructionFrame.position=[0.035 0.735 0.93 0.245];
    LD1.ui.standFrame.visible="on";
    LD1.ui.answerFrame.visible="on";
    if LD1.step<9 then ld1_redraw_panel(); end
    ld1_enable(LD1.ui.prev, LD1.step>1);
    LD1.ui.progress.string="Etapas "+string(LD1.step)+" / 9";
    ld1_update_step_navigation();
endfunction

function ld1_update_step_navigation()
    global LD1;
    if ~isfield(LD1.ui,"stepButtons") then return; end
    for k=1:9
        h=LD1.ui.stepButtons(k);
        if k==LD1.step then
            h.backgroundcolor=[0.20 0.48 0.78];
            ld1_enable(h,%t);
        elseif LD1.done(k) then
            h.backgroundcolor=[0.72 0.92 0.74];
            ld1_enable(h,%t);
        elseif LD1.skipped(k) then
            h.backgroundcolor=[1.00 0.86 0.56];
            ld1_enable(h,%t);
        elseif LD1.reviewMode then
            h.backgroundcolor=[0.93 0.93 0.93];
            ld1_enable(h,%t);
        else
            h.backgroundcolor=[0.93 0.93 0.93];
            ld1_enable(h,%f);
        end
    end
    if LD1.step<9 then
        ld1_enable(LD1.ui.next,%t);
    else
        ld1_enable(LD1.ui.next,%f);
    end
endfunction

function ld1_review_toggle()
    global LD1;
    LD1.reviewMode=(LD1.ui.review.value<>0);
    ld1_update_step_navigation();
    if LD1.reviewMode then
        ld1_set_status("PERŽIŪROS REŽIMAS įjungtas.","warn","Galite spausti bet kurį etapo numerį 1–9 arba TOLIAU. Neatlikti etapai nebus pažymėti kaip užbaigti; stendas bus paruoštas to etapo pradžiai.");
    else
        ld1_set_status("Grįžta įprastas studento režimas.","info","TOLIAU bus leidžiama tik užfiksavus dabartinį etapą.");
    end
endfunction

function ld1_jump_step(n)
    global LD1;
    if n<1 | n>9 | n==LD1.step then return; end
    if ~LD1.reviewMode then
        if LD1.done(n) then
            ld1_set_step(n);
        elseif LD1.skipped(n) then
            ld1_set_step(n);
            if n<9 then ld1_prepare_review_stage(n); end
            ld1_set_status("Grįžote į anksčiau praleistą "+string(n)+" etapą.","warn","Etapo atsakymai išsaugoti; stendas paruoštas saugioje pradinėje būsenoje.");
        else
            ld1_set_status("Šis etapas dar neatliktas.","warn","Galite naudoti TOLIAU → PEREITI NEBAIGUS arba viršuje įjungti PERŽIŪROS REŽIMĄ.");
        end
        return;
    end
    ld1_set_step(n);
    if n<9 then ld1_prepare_review_stage(n); end
    ld1_update_step_navigation();
    ld1_set_status("Atidarytas "+string(n)+" etapas peržiūros režimu.","info","Stendas paruoštas taip, kad šį etapą galėtumėte tikrinti nepradėję laboratorinio nuo 1 etapo.");
endfunction
