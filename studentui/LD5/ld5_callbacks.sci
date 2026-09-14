// ============================================================================
// LD5 veiksmų logika: laidai, matavimai (R1/R2/serija), 7 etapų tikrinimas.
// ============================================================================

function ld5_terminal_click(id)
    global LD5;
    if LD5.demoMode then return; end
    if ~or(LD5.step==[1 6]) then return; end
    if ~or(ld5_terminal_ids()==id) then return; end
    if LD5.pending=="" then
        LD5.pending=id;
        ld5_set_status("Pasirinktas ["+ld5_terminal_code(id)+"] "+ld5_terminal_name(id),"info","Spauskite kitą gnybtą. Esamas laidas tarp tų pačių gnybtų bus pašalintas.");
    else
        first=LD5.pending; LD5.pending="";
        if first<>id then
            found=0;
            for k=1:size(LD5.wires,1)
                if and(LD5.wires(k,:)==[first id]) | and(LD5.wires(k,:)==[id first]) then found=k; break; end
            end
            if found>0 then
                LD5.wires(found,:)=[];
                ld5_set_status("Laidas pašalintas.","ok","");
            else
                uses1=sum(LD5.wires==first); uses2=sum(LD5.wires==id);
                if uses1>=2 | uses2>=2 then
                    ld5_set_status("Gnybte jau yra du laidai.","error","Pirma pašalinkite netinkamą laidą, paspausdami abu jo galus.");
                    ld5_render_wires(); return;
                end
                LD5.wires($+1,:)=[first id];
                ld5_set_status("Laidas pridėtas.","ok","Laidą pašalinsite dar kartą paspaudę abu jo galus.");
            end
            LD5.done(LD5.step)=%f; LD5.report_wires(LD5.step)=emptystr(0,2);
            LD5.lastMeasurement=%nan;
        end
    end
    ld5_render_wires(); ld5_student_sync();
endfunction

function ld5_toggle_power()
    global LD5;
    LD5.powerOn = ~LD5.powerOn;
    if LD5.powerOn then ld5_set_status("[B01] Maitinimas ĮJUNGTAS.","ok","Dabar uždarykite jungiklį [B02].");
    else ld5_set_status("[B01] Maitinimas IŠJUNGTAS.","info","Įtampa neveikia."); end
    ld5_render_wires();
endfunction

function ld5_toggle_switch()
    global LD5;
    if ~LD5.powerOn then ld5_set_status("Negalima jungti be maitinimo.","error","Pirmiausia [B01] MAITINIMAS."); return; end
    LD5.switchOn = ~LD5.switchOn;
    if LD5.switchOn then ld5_set_status("[B02] Jungiklis UŽDARYTAS.","ok","Nustatykite įtampą [B10]–[B12] ir matuokite [B03]."); end
    ld5_render_wires();
endfunction

function ld5_set_position(k)
    // [B10]–[B12]: potenciometro padėtis (1, 2 arba 3).
    global LD5;
    LD5.position = k;
    p = LD5.cfg("P" + string(k));
    ld5_set_status(msprintf("Potenciometras: padėtis %d (%d %%).", k, p), "ok", "Dabar matuokite [B03].");
endfunction

function ld5_set_voltage(v)
    // LD5: įtampa fiksuota E (daliklis), slankiklio nėra — tuščias suderinamumui.
endfunction

function ld5_measure()
    global LD5;
    [u, i, ok, msg] = ld5_measure_values();
    if ~ok then ld5_set_status(msg, "error", ""); return; end
    if LD5.step ~= 2 & LD5.step ~= 3 then
        ld5_set_status("Matavimai atliekami 2 ir 3 etapuose.","info","Etapus keičia [E01]–[E06].");
        return;
    end
    tag = LD5.position;
    if size(ld5_journal_rows(tag), 1) >= 1 then
        ld5_set_status("Ši padėtis jau užfikstuota.","error","Perjunkite [B10]/[B11]/[B12].");
        return;
    end
    LD5.journal($+1, :) = [u, i, tag];
    LD5.lastMeasurement = i;
    ld5_set_status(msprintf("Užfiksuota (padėtis %d): U = %.2f V, I = %.2f mA.", tag, u, i), "ok","Rodmuo [V02] ir matavimų sąrašas.");
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_journal(); end
    end
endfunction

function ok = ld5_close_enough(userValue, expectedValue, rel, absolute)
    if argn(2)<3 then rel=0.02; end
    if argn(2)<4 then absolute=0.005; end
    ok=%f;
    if isnan(userValue) | isnan(expectedValue) | isinf(userValue) | isinf(expectedValue) then return; end
    ok=abs(userValue-expectedValue)<=absolute+rel*abs(expectedValue);
endfunction

function ld5_check_step()
    global LD5;
    n = LD5.step;
    if LD5.done(n) then ld5_set_status("Etapas jau atliktas.","ok","Spauskite TOLIAU."); return; end
    exp = ld5_expected_answers();
    select n
    case 1 then
        [wok, wwhy] = ld5_wiring_valid(LD5.wires);
        if ~wok then ld5_set_status(wwhy, "error", "Seką rodo [B04] KAIP SUJUNGTI."); return; end
        LD5.done(1) = %t;
        ld5_set_status("1 etapas baigtas: daliklis sujungtas.","ok","[E02] — teorinė prognozė.");
    case 2 then
        v = ld5_parse_number(LD5.answers(2,1));
        e = ld5_parse_number(exp(2,1));
        if isnan(v) then ld5_set_status("Įrašykite teorinę U2 [A02.01], V.","error","U2 = E·RVd/(R1+RVd)."); return; end
        if ~ld5_close_enough(v, e) then ld5_set_status("Teorinė U2 [A02.01] netiksli.","error",msprintf("Tikimasi ≈ %.2f V.", e)); return; end
        if size(ld5_journal_rows(2), 1) < 1 then
            ld5_set_status("Trūksta 2-os padėties matavimo.","error","[B11] PADĖTIS 2 → [B03] MATUOTI."); return; end
        LD5.done(2) = %t;
        ld5_set_status("2 etapas baigtas.","ok","[E03] — kitos dvi padėtys.");
    case 3 then
        if size(ld5_journal_rows(1), 1) < 1 then
            ld5_set_status("Trūksta 1-os padėties matavimo.","error","[B10] PADĖTIS 1 → [B03]."); return; end
        if size(ld5_journal_rows(3), 1) < 1 then
            ld5_set_status("Trūksta 3-ios padėties matavimo.","error","[B12] PADĖTIS 3 → [B03]."); return; end
        LD5.done(3) = %t;
        ld5_set_status("3 etapas baigtas: visos padėtys užfiksuotos.","ok","[E04] — skaičiavimai.");
    case 4 then
        etik = ["A04.01 U1t, V";"A04.02 U3t, V";"A04.03 ΔU, V";"A04.04 diapazonas, %"];
        for k = 1:4
            v = ld5_parse_number(LD5.answers(4,k));
            e = ld5_parse_number(exp(4,k));
            if isnan(v) then ld5_set_status("Įrašykite [" + etik(k) + "].","error","U = E·RVd/(R1+RVd)."); return; end
            if ~ld5_close_enough(v, e) then
                ld5_set_status("[" + etik(k) + "] netikslus.","error",msprintf("Tikimasi ≈ %s.", exp(4,k))); return; end
        end
        LD5.done(4) = %t;
        ld5_set_status("4 etapas baigtas.","ok","[E05] — srovė ir dalis.");
    case 5 then
        etik = ["A05.01 I2, mA";"A05.02 dalis, %"];
        for k = 1:2
            v = ld5_parse_number(LD5.answers(5,k));
            e = ld5_parse_number(exp(5,k));
            if isnan(v) then ld5_set_status("Įrašykite [" + etik(k) + "].","error","I = E/(R1+RVd); dalis = RVd/(R1+RVd)·100 %."); return; end
            if ~ld5_close_enough(v, e) then
                ld5_set_status("[" + etik(k) + "] netikslus.","error",msprintf("Tikimasi ≈ %s.", exp(5,k))); return; end
        end
        LD5.done(5) = %t;
        ld5_set_status("5 etapas baigtas.","ok","[E06] — išvados.");
    case 6 then
        if LD5.answers(6,1) ~= "1" then ld5_set_status("[A06.01]: atsakykite 1 arba 2.","error","1 – Taip, 2 – Ne."); return; end
        if LD5.answers(6,2) ~= "1" then ld5_set_status("[A06.02]: atsakykite 1 arba 2.","error","1 – Taip, 2 – Ne."); return; end
        LD5.done(6) = %t;
        ld5_set_status("6 etapas baigtas: darbas atliktas!","ok","[B08] ATASKAITA DĖSTYTOJUI sukuria HTML ataskaitą.");
    end
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_stage(); end
    end
endfunction

function ld5_next_step()
    global LD5;
    if LD5.step >= 7 then return; end
    if ~LD5.done(LD5.step) then
        LD5.skipped(LD5.step) = %t;
        ld5_set_status("Etapas praleistas (pažymėtas geltonai).","info","Grįžti galima [E] mygtukais.");
    end
    ld5_set_step(LD5.step + 1);
endfunction

function ld5_set_step(n)
    global LD5;
    if n < 1 | n > 7 then return; end
    ld5_save_answers();
    LD5.step = n;
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then
            ld5_render_stage();
        end
    end
endfunction

function s = ld5_step_instruction(n)
    global LD5;
    cfg = LD5.cfg;
    select n
    case 1 then s = "Sujunkite daliklį: [T01]→[T03], [T04]→[T05], [T06]→[T07], [T08]→[T09], [T10]→[T02]; zondai [T11]→[T09], [T12]→[T10]. Maitinimas [B01] išjungtas.";
    case 2 then s = msprintf("Apskaičiuokite teorinę U2 = E·RVd/(R1+RVd) (E=%g V, R1=%g Ω, RV=%g Ω, padėtis 2 = %d %%) → [A02.01]. Tada [B01], [B02], [B11] PADĖTIS 2, [B03] MATUOTI.", cfg.E, cfg.R1, cfg.RV, cfg.P2);
    case 3 then s = msprintf("[B10] PADĖTIS 1 (%d %%) → [B03]; tada [B12] PADĖTIS 3 (%d %%) → [B03].", cfg.P1, cfg.P3);
    case 4 then s = "Apskaičiuokite: [A04.01] U1t ir [A04.02] U3t (teorinės), [A04.03] ΔU = U3t−U1t, [A04.04] diapazoną % nuo E.";
    case 5 then s = msprintf("[A05.01] I2 = E/(R1+RVd), mA; [A05.02] dalis = RVd/(R1+RVd)·100 %% (padėtis 2 = %d %%).", cfg.P2);
    case 6 then s = "[A06.01] Ar U reguliuojama sklandžiai? [A06.02] Ar dalikio dėsnis galioja? (1 – Taip, 2 – Ne). Tada [B08] ataskaita.";
    else s = "";
    end
endfunction

function ld5_save_answers()
    global LD5;
    if ~isfield(LD5, "ui") then return; end
    if isfield(LD5.ui, "headless") then if LD5.ui.headless then return; end end
    if isfield(LD5.ui, "answerEdits") then
        for k = 1:size(LD5.ui.answerEdits, "*")
            h = LD5.ui.answerEdits(k);
            if is_handle_valid(h) then
                [st, sl] = ld5_answer_slot(k);
                if st<>LD5.step | h.visible<>"on" then continue; end
                if LD5.answers(st,sl)<>h.string then LD5.done(st)=%f; end
                LD5.answers(st, sl) = h.string;
            end
        end
    end
endfunction

function [st, sl] = ld5_answer_slot(k)
    mapa = [2 1; 4 1; 4 2; 4 3; 4 4; 5 1; 5 2; 6 1; 6 2];
    st = mapa(k, 1); sl = mapa(k, 2);
endfunction

function ld5_test_answers(step, values)
    global LD5;
    for k = 1:size(values, "*")
        LD5.answers(step, k) = msprintf("%.10g", values(k));
    end
endfunction

function ld5_show_wiring_guide()
    global LD5;
    txt = ["LD5 · KAIP SUJUNGTI · " + ld5_stage_code(LD5.step) + " etapas"; "";
           ld5_step_instruction(LD5.step); "";
           "R1 grandinė (1 etapas): [T01]→[T03] → [T04]→[T05] → [T06]→[T07] → [T08]→[T02]; zondai [T11]→[T07], [T12]→[T08].";
           "R2 (3 etapas): tas pats per [B13] automatiškai ([T09]/[T10] vietoje [T07]/[T08]).";
           "Nuoseklus (6 etapas): [T08]→[T09] jungia R1 su R2 eilėje; [T10]→[T02] grąžina."];
    ld5_text_window("KAIP SUJUNGTI", txt);
endfunction

function ld5_show_stand_map()
    global LD5;
    [bids, cbs, blabels, bhints] = ld5_button_registry();
    txt = ["LD5 · STENDO ŽEMĖLAPIS (bankas " + LD5.student.bank + ")"; "";
           "GNYBTAI (T01–T12): šaltinis, jungiklis, ampermetras, R1 (a/b), R2 (a/b), voltmetras."; "";
           "MYGTUKAI:"];
    for k = 1:size(bids, "*")
        txt($+1) = "  [" + bids(k) + "] " + blabels(k);
    end
    txt($+1) = ""; txt($+1) = "ETAPAI: [E01]–[E07]; LAUKELIAI: [A02.01], [A04.01]–[A04.04], [A05.01]–[A05.03], [A06.01], [A07.01]–[A07.02]; [V02] rodmuo.";
    ld5_text_window("STENDO ŽEMĖLAPIS", txt);
endfunction

function ld5_text_window(title, lines)
    global LD5;
    if isfield(LD5, "ui") then
        if isfield(LD5.ui, "headless") then if LD5.ui.headless then return; end end
    end
    f = figure("figure_name", "LD5 · " + title, "axes_size", [520 420], ...
               "menubar_visible", "off", "toolbar_visible", "off", "infobar_visible", "off");
    uicontrol(f, "style", "listbox", "units", "normalized", "position", [0.02 0.10 0.96 0.84], ...
              "string", lines, "fontname", "DejaVu Sans", "fontunits", "pixels", "fontsize", 12);
    uicontrol(f, "style", "pushbutton", "units", "normalized", "position", [0.35 0.02 0.3 0.06], ...
              "string", "[H01] Uždaryti", "tag", "H01", "callback", "close()");
endfunction

function ld5_toggle_solution()
    global LD5;
    if LD5.demoMode then
        LD5.demoMode = %f;
        if isfield(LD5, "backup") then
            LD5.wires = LD5.backup.wires; LD5.answers = LD5.backup.answers;
            LD5.position = LD5.backup.position; LD5.journal = LD5.backup.journal;
            LD5.powerOn = LD5.backup.powerOn; LD5.switchOn = LD5.backup.switchOn;
            LD5.lastMeasurement=LD5.backup.lastMeasurement;
        end
        if isfield(LD5, "ui") then
            if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_stage(); end
        end
        ld5_set_status("Grįžta į savo darbą.","info","Laidai ir atsakymai atkurti.");
        return;
    end
    ld5_save_answers();
    LD5.backup = struct();
    LD5.backup.wires = LD5.wires; LD5.backup.answers = LD5.answers;
    LD5.backup.position = LD5.position; LD5.backup.journal = LD5.journal;
    LD5.backup.powerOn = LD5.powerOn; LD5.backup.switchOn = LD5.switchOn;
    LD5.backup.lastMeasurement=LD5.lastMeasurement;
    LD5.practice_used=%t;
    LD5.demoMode = %t;
    LD5.wires = ld5_canonical_wires();
    LD5.powerOn = %t; LD5.switchOn = %t; LD5.position = 2;
    cfg = LD5.cfg;
    for pos = 1:3
        rvd = cfg.RV * cfg("P" + string(pos)) / 100;
        LD5.journal($+1, :) = [cfg.E * rvd / (cfg.R1 + rvd), cfg.E / (cfg.R1 + rvd) * 1000, pos];
    end
    ld5_set_status("PAVYZDYS rodomas (neišsaugojama).","info","Grįžkite [B07].");
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_stage(); end
    end
endfunction

function ld5_restore_stage()
    global LD5;
    if LD5.demoMode then ld5_toggle_solution(); return; end
    LD5.pending = "";
    if LD5.step == 1 then LD5.wires = []; end
    ld5_set_status("Etapo stendas atkurtas.","info","");
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_wires(); end
    end
endfunction

function ld5_restart()
    global LD5;
    cfg = LD5.cfg; st = LD5.student;
    ld5_init_state();
    LD5.cfg = cfg; LD5.student = st;
    if isfield(LD5, "ui") then
        if ~isfield(LD5.ui, "headless") | ~LD5.ui.headless then ld5_render_stage(); end
    end
    ld5_set_status("Darbas pradėtas iš naujo.","info","Variantas ir studentas išliko.");
endfunction

function ld5_answers_changed()
    // Atsakymo laukelio redagavimas: nedelsiant saugoma į store.
    global LD5;
    ld5_save_answers(); ld5_student_sync();
endfunction
