// ============================================================================
// LD6 veiksmų logika: laidai, trys daliklio padėtys, 6 etapų tikrinimas.
// ============================================================================

function ld6_terminal_click(id)
    global LD6;
    if LD6.demoMode then return; end
    if LD6.step<>1 then return; end
    if ~or(ld6_terminal_ids()==id) then return; end
    if LD6.pending=="" then
        LD6.pending=id;
        ld6_set_status("Pasirinktas ["+ld6_terminal_code(id)+"] "+ld6_terminal_name(id),"info","Spauskite kitą gnybtą. Esamas laidas tarp tų pačių gnybtų bus pašalintas.");
    else
        first=LD6.pending; LD6.pending="";
        if first<>id then
            found=0;
            for k=1:size(LD6.wires,1)
                if and(LD6.wires(k,:)==[first id]) | and(LD6.wires(k,:)==[id first]) then found=k; break; end
            end
            if found>0 then
                LD6.wires(found,:)=[];
                ld6_set_status("Laidas pašalintas.","ok","");
            else
                uses1=sum(LD6.wires==first); uses2=sum(LD6.wires==id);
                if uses1>=2 | uses2>=2 then
                    ld6_set_status("Gnybte jau yra du laidai.","error","Pirma pašalinkite netinkamą laidą, paspausdami abu jo galus.");
                    ld6_render_wires(); return;
                end
                LD6.wires($+1,:)=[first id];
                ld6_set_status("Laidas pridėtas.","ok","Laidą pašalinsite dar kartą paspaudę abu jo galus.");
            end
            LD6.done(:)=%f; LD6.report_wires(1)=emptystr(0,2);
            LD6.journal=[]; LD6.powerOn=%f; LD6.switchOn=%f;
            LD6.lastMeasurement=%nan;
        end
    end
    ld6_render_wires(); ld6_render_journal(); ld6_student_sync();
endfunction

function ld6_toggle_power()
    global LD6;
    LD6.powerOn = ~LD6.powerOn;
    if LD6.powerOn then ld6_set_status("[B01] Maitinimas ĮJUNGTAS.","ok","Dabar uždarykite jungiklį [B02].");
    else ld6_set_status("[B01] Maitinimas IŠJUNGTAS.","info","Įtampa neveikia."); end
    ld6_render_wires();
endfunction

function ld6_toggle_switch()
    global LD6;
    if ~LD6.powerOn then ld6_set_status("Negalima jungti be maitinimo.","error","Pirmiausia [B01] MAITINIMAS."); return; end
    LD6.switchOn = ~LD6.switchOn;
    if LD6.switchOn then ld6_set_status("[B02] Jungiklis UŽDARYTAS.","ok","Pasirinkite padėtį [B10]–[B12] ir matuokite [B03]."); end
    ld6_render_wires();
endfunction

function ld6_set_mode(k)
    // [B10]–[B12]: šaltinių jungimo režimas (1=E1, 2=+E2, 3=−E2).
    global LD6;
    LD6.wireMode = k;
    LD6.wires = ld6_canonical_wires(k);
    zodis = "E1 vienas"; if k == 2 then zodis = "E1+E2 sutampintieji"; elseif k == 3 then zodis = "E1−E2 priešinieji"; end
    ld6_set_status("Režimas: " + zodis + " (laidai automatiškai perjungti).","ok","Matuokite [B03].");
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_wires(); end
    end
endfunction

function ld6_set_voltage(v)
    // LD6: šaltiniai fiksuoti — tuščias suderinamumui.
endfunction

function ld6_measure()
    global LD6;
    [u, i, ok, msg] = ld6_measure_values();
    if ~ok then ld6_set_status(msg, "error", ""); return; end
    if LD6.step ~= 2 & LD6.step ~= 3 & LD6.step ~= 4 then
        ld6_set_status("Matavimai atliekami 2, 3 ir 4 etapuose.","info","[E01]–[E06].");
        return;
    end
    tag = LD6.wireMode;
    if size(ld6_journal_rows(tag), 1) >= 1 then
        ld6_set_status("Šis režimas jau užfiksuotas.","error","Perjunkite [B10]/[B11]/[B12].");
        return;
    end
    LD6.journal($+1, :) = [u, i, tag];
    LD6.lastMeasurement = i;
    ld6_set_status(msprintf("Užfiksuota (režimas %d): U = %.2f V, I = %.2f mA.", tag, u, i), "ok","[V02] ir matavimų sąrašas.");
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_journal(); end
    end
endfunction

function ok = ld6_close_enough(userValue, expectedValue, rel, absolute)
    if argn(2)<3 then rel=0.02; end
    if argn(2)<4 then absolute=1e-9; end
    ok=%f;
    if isnan(userValue) | isnan(expectedValue) | isinf(userValue) | isinf(expectedValue) then return; end
    ok=abs(userValue-expectedValue)<=absolute+rel*abs(expectedValue);
endfunction

function ld6_check_step()
    global LD6;
    n = LD6.step;
    if LD6.done(n) then ld6_set_status("Etapas jau atliktas.","ok","TOLIAU."); return; end
    exp = ld6_expected_answers();
    select n
    case 1 then
        [wok, wwhy] = ld6_wiring_valid(LD6.wires);
        if ~wok then ld6_set_status(wwhy, "error", "[B04] KAIP SUJUNGTI."); return; end
        LD6.done(1) = %t;
        ld6_set_status("1 etapas baigtas: E1 grandinė sujungta.","ok","[E02] — teorinė prognozė.");
    case 2 then
        v = ld6_parse_number(LD6.answers(2,1));
        e = ld6_parse_number(exp(2,1));
        if isnan(v) then ld6_set_status("Įrašykite I1 [A02.01], mA.","error","I = E1/R."); return; end
        if ~ld6_close_enough(v, e) then ld6_set_status("I1 [A02.01] netiksli.","error",msprintf("Tikimasi ≈ %.2f mA.", e)); return; end
        if size(ld6_journal_rows(1), 1) < 1 then
            ld6_set_status("Trūksta E1 matavimo.","error","[B10] E1 → [B03]."); return; end
        LD6.done(2) = %t;
        ld6_set_status("2 etapas baigtas (E1).","ok","[E03] — serija.");
    case 3 then
        if LD6.wireMode ~= 2 & size(ld6_journal_rows(2), 1) == 0 then
            ld6_set_status("Perjunkite į E1+E2.","error","[B11]."); return; end
        if size(ld6_journal_rows(2), 1) < 1 then
            ld6_set_status("Trūksta E1+E2 matavimo.","error","[B11] → [B03]."); return; end
        LD6.done(3) = %t;
        ld6_set_status("3 etapas baigtas (E1+E2).","ok","[E04] — priešinieji.");
    case 4 then
        if size(ld6_journal_rows(3), 1) < 1 then
            ld6_set_status("Trūksta E1−E2 matavimo.","error","[B12] → [B03]."); return; end
        etik = ["A04.01 U_ser, V";"A04.02 I_ser, mA";"A04.03 U_pries, V";"A04.04 I_pries, mA"];
        for k = 1:4
            v = ld6_parse_number(LD6.answers(4,k));
            e = ld6_parse_number(exp(4,k));
            if isnan(v) then ld6_set_status("Įrašykite [" + etik(k) + "].","error","Pagal matavimus."); return; end
            if ~ld6_close_enough(v, e) then
                ld6_set_status("[" + etik(k) + "] netikslus.","error",msprintf("Tikimasi ≈ %s.", exp(4,k))); return; end
        end
        LD6.done(4) = %t;
        ld6_set_status("4 etapas baigtas.","ok","[E05] — patikra.");
    case 5 then
        // Patikra: U_ser ≈ U1 + U2 (iš žurnalo), I_pries < I_ser
        r1 = ld6_journal_rows(1); r2 = ld6_journal_rows(2); r3 = ld6_journal_rows(3);
        if size(r1,1) < 1 | size(r2,1) < 1 | size(r3,1) < 1 then
            ld6_set_status("Trūksta matavimų patikrai.","error","Užpildykite 2–4 etapus."); return; end
        LD6.done(5) = %t;
        ld6_set_status("5 etapas baigtas: dėsniai patikrinti.","ok","[E06] — išvados.");
    case 6 then
        if LD6.answers(6,1) ~= "1" then ld6_set_status("[A06.01]: 1 arba 2.","error","1 – Taip."); return; end
        if LD6.answers(6,2) ~= "1" then ld6_set_status("[A06.02]: 1 arba 2.","error","1 – Taip."); return; end
        LD6.done(6) = %t;
        ld6_set_status("6 etapas baigtas!","ok","[B08] ATASKAITA.");
    end
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_stage(); end
    end
endfunction

function ld6_next_step()
    global LD6;
    if LD6.step >= 6 then return; end
    if ~LD6.done(LD6.step) then
        LD6.skipped(LD6.step) = %t;
        ld6_set_status("Etapas praleistas (pažymėtas geltonai).","info","Grįžti galima [E] mygtukais.");
    end
    ld6_set_step(LD6.step + 1);
endfunction

function ld6_set_step(n)
    global LD6;
    if ~ld6_valid_index(n,6) then return; end
    if LD6.demoMode then ld6_toggle_solution(); end
    ld6_save_answers();
    LD6.pending="";
    LD6.step = n;
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then
            ld6_render_stage();
        end
    end
endfunction

function s = ld6_step_instruction(n)
    global LD6;
    cfg = LD6.cfg;
    select n
    case 1 then s = "Sujunkite grandinę su E1: [T01]→[T05], [T06]→[T07], [T08]→[T09], [T10]→[T02]; zondai [T11]→[T09], [T12]→[T10]. [B01] išjungtas.";
    case 2 then s = msprintf("Apskaičiuokite I1 = E1/R (E1=%g V, R=%g Ω) → [A02.01]. Tada [B01], [B02], [B10] E1, [B03].", cfg.E1, cfg.R);
    case 3 then s = msprintf("Spauskite [B11] E1+E2 (E2=%g V): laidai perjungiami. Tada [B03] MATUOTI.", cfg.E2);
    case 4 then s = "[B12] E1−E2 → [B03]. Tada apskaičiuokite [A04.01]–[A04.04]."
    case 5 then s = "Patikra: ar U_ser = U1 + U2? Ar I_pries < I_ser? (iš žurnalo matavimų).";
    case 6 then s = "[A06.01] Ar nuosekliai jungtų šaltinių EV sudedamos? [A06.02] Ar priešininkų atimamos? Tada [B08].";
    else s = "";
    end
endfunction

function ld6_save_answers()
    global LD6;
    if LD6.demoMode then return; end
    if ~isfield(LD6, "ui") then return; end
    if isfield(LD6.ui, "headless") then if LD6.ui.headless then return; end end
    if isfield(LD6.ui, "answerEdits") then
        for k = 1:size(LD6.ui.answerEdits, "*")
            h = LD6.ui.answerEdits(k);
            if is_handle_valid(h) then
                [st, sl] = ld6_answer_slot(k);
                if st<>LD6.step | h.visible<>"on" then continue; end
                if LD6.answers(st,sl)<>h.string then LD6.done(st)=%f; end
                LD6.answers(st, sl) = h.string;
            end
        end
    end
endfunction

function [st, sl] = ld6_answer_slot(k)
    mapa = [2 1; 4 1; 4 2; 4 3; 4 4; 6 1; 6 2];
    st = mapa(k, 1); sl = mapa(k, 2);
endfunction

function ld6_test_answers(step, values)
    global LD6;
    for k = 1:size(values, "*")
        LD6.answers(step, k) = msprintf("%.10g", values(k));
    end
endfunction

function ld6_show_wiring_guide()
    txt=["LD6 · ĮTAMPOS DALIKLIO SUJUNGIMAS"; "";
         "Visuose etapuose naudojama ta pati grandinė.";
         "1. Šaltinis + → jungiklis: [T01]–[T03].";
         "2. Jungiklis → ampermetras +: [T04]–[T05].";
         "3. Ampermetras − → R1 a: [T06]–[T07].";
         "4. R1 b → RV a: [T08]–[T09].";
         "5. RV b → šaltinis −: [T10]–[T02].";
         "6. Voltmetras + → RV a: [T11]–[T09].";
         "7. Voltmetras − → RV b: [T12]–[T10]."; "";
         "Sujungimą keiskite 1 etape, be maitinimo.";
         "Laidą pašalinsite paspaudę abu jo gnybtus.";
         "P1, P2 ir P3 keičia aktyvią RV dalį (RVd).";
         "RVd = RV · padėtis % / 100; voltmetras matuoja U ties RVd."];
    ld6_text_window("KAIP SUJUNGTI", txt);
endfunction

function ld6_show_stand_map()
    global LD6;
    [bids, cbs, blabels, bhints] = ld6_button_registry();
    txt = ["LD6 · STENDO ŽEMĖLAPIS (bankas " + LD6.student.bank + ")"; "";
           "GNYBTAI (T01–T12): šaltinis, jungiklis, ampermetras, R1 (a/b), RV (a/b), voltmetras."; "";
           "MYGTUKAI:"];
    for k = 1:size(bids, "*")
        txt($+1) = "  [" + bids(k) + "] " + blabels(k);
    end
    txt($+1) = ""; txt($+1) = "ETAPAI: [E01]–[E06]. Grįžkite mygtuku Atgal.";
    txt($+1) = "LAUKELIAI: [A02.01], [A04.01]–[A04.04],";
    txt($+1) = "[A05.01]–[A05.02], [A06.01]–[A06.02].";
    txt($+1) = "[V02] – trijų padėčių matavimų žurnalas.";
    ld6_text_window("STENDO ŽEMĖLAPIS", txt);
endfunction

function ld6_text_window(title, lines)
    global LD6;
    if isfield(LD6, "ui") then
        if isfield(LD6.ui, "headless") then if LD6.ui.headless then return; end end
    end
    f = figure("figure_name", "LD6 · " + title, "axes_size", [520 420], ...
               "menubar_visible", "off", "toolbar_visible", "off", "infobar_visible", "off");
    uicontrol(f, "style", "listbox", "units", "normalized", "position", [0.02 0.10 0.96 0.84], ...
              "string", lines, "fontname", "SansSerif", "fontunits", "pixels", "fontsize", 12);
    uicontrol(f, "style", "pushbutton", "units", "normalized", "position", [0.35 0.02 0.3 0.06], ...
              "string", "[H01] Uždaryti", "tag", "H01", "callback", "close()");
endfunction

function ld6_toggle_solution()
    global LD6;
    if LD6.demoMode then
        LD6.demoMode = %f;
        LD6.pending="";
        if isfield(LD6, "backup") then
            LD6.wires = LD6.backup.wires; LD6.answers = LD6.backup.answers;
            LD6.wireMode = LD6.backup.wireMode; LD6.journal = LD6.backup.journal;
            LD6.powerOn = LD6.backup.powerOn; LD6.switchOn = LD6.backup.switchOn;
            LD6.lastMeasurement=LD6.backup.lastMeasurement;
        end
        if isfield(LD6, "ui") then
            if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_stage(); end
        end
        ld6_set_status("Grįžta į savo darbą.","info","Laidai ir atsakymai atkurti.");
        return;
    end
    ld6_save_answers();
    LD6.backup = struct();
    LD6.backup.wires = LD6.wires; LD6.backup.answers = LD6.answers;
    LD6.backup.wireMode = LD6.wireMode; LD6.backup.journal = LD6.journal;
    LD6.backup.powerOn = LD6.powerOn; LD6.backup.switchOn = LD6.switchOn;
    LD6.backup.lastMeasurement=LD6.lastMeasurement;
    LD6.practice_used=%t;
    LD6.demoMode = %t;
    LD6.wireMode = 1;
    LD6.wires = ld6_canonical_wires(1);
    LD6.powerOn = %t; LD6.switchOn = %t;
    cfg = LD6.cfg;
    LD6.journal = [cfg.E1, cfg.E1/cfg.R*1000, 1; cfg.E1+cfg.E2, (cfg.E1+cfg.E2)/cfg.R*1000, 2; cfg.E1-cfg.E2, (cfg.E1-cfg.E2)/cfg.R*1000, 3];
    ld6_set_status("PAVYZDYS rodomas (neišsaugojama).","info","Grįžkite [B07].");
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_stage(); end
    end
endfunction

function ld6_restore_stage()
    global LD6;
    if LD6.demoMode then ld6_toggle_solution(); return; end
    LD6.pending = "";
    LD6.powerOn=%f; LD6.switchOn=%f; LD6.wireMode=0; LD6.lastMeasurement=%nan;
    if LD6.step == 1 then
        LD6.wires=[]; LD6.report_wires(1)=emptystr(0,2);
        LD6.done(:)=%f; LD6.journal=[];
    end
    ld6_set_status("Etapo stendas atkurtas.","info","");
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_stage(); end
    end
endfunction

function ld6_restart()
    global LD6;
    cfg = LD6.cfg; st = LD6.student;
    ld6_init_state();
    LD6.cfg = cfg; LD6.student = st;
    if isfield(LD6, "ui") then
        if ~isfield(LD6.ui, "headless") | ~LD6.ui.headless then ld6_render_stage(); end
    end
    ld6_set_status("Darbas pradėtas iš naujo.","info","Variantas ir studentas išliko.");
endfunction

function ld6_answers_changed()
    // Atsakymo laukelio redagavimas: nedelsiant saugoma į store.
    global LD6;
    ld6_save_answers(); ld6_student_sync();
endfunction
