function ld12_invalidate_mode()
    global LD12;
    mode = LD12.wireMode; LD12.report_wires(mode) = emptystr(0, 2);
    if LD12.journal <> [] then LD12.journal(find(LD12.journal(:,3) == mode), :) = []; end
    select mode
    case 1 then LD12.done([1 2 5]) = %f;
    case 2 then LD12.done([3 4 5]) = %f;
    end
    LD12.done(6) = %f; LD12.lastMeasurement = %nan;
endfunction

function ld12_terminal_click(id)
    if ~ld12_can_act() then return; end
    global LD12;
    if ~ld12_wiring_editable() | ~or(ld12_terminal_ids() == id) then return; end
    if LD12.powerOn then ld12_set_status("Prieš keisdami laidus išjunkite [B01].", "error", ""); return; end
    if LD12.pending == "" then
        LD12.pending = id;
        ld12_set_status("Pasirinktas [" + ld12_terminal_code(id) + "] " + ld12_terminal_name(id), "info", "Spauskite kitą gnybtą. Pakartoję esamo laido galus jį pašalinsite.");
    else
        first = LD12.pending; LD12.pending = "";
        if first <> id then
            existing = 0;
            for row = 1:size(LD12.wires, 1)
                if and(LD12.wires(row,:) == [first id]) | and(LD12.wires(row,:) == [id first]) then existing = row; break; end
            end
            if existing > 0 then
                LD12.wires(existing,:) = []; ld12_set_status("Laidas pašalintas.", "ok", "");
            else
                if sum(LD12.wires == first) >= 2 | sum(LD12.wires == id) >= 2 then
                    ld12_set_status("Gnybte jau yra du laidai.", "error", "Pirma pašalinkite netinkamą laidą.");
                    ld12_render_wires(); return;
                end
                LD12.wires($+1,:) = [first id]; ld12_set_status("Laidas pridėtas.", "ok", "");
            end
            LD12.switchOn = %f; ld12_invalidate_mode();
        else
            ld12_set_status("Gnybto pasirinkimas atšauktas.","info","Pasirinkite pirmą ir antrą laido gnybtą.");
        end
    end
    LD12.wires_by_mode(LD12.wireMode)=LD12.wires;
    ld12_render_wires(); ld12_render_journal(); ld12_student_sync(); bench_autosave("LD12");
endfunction

function ld12_toggle_power()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then return; end
    LD12.powerOn = ~LD12.powerOn;
    if ~LD12.powerOn then LD12.switchOn = %f; end
    ld12_render_wires();
    if LD12.powerOn then ld12_set_status("Generatorius įjungtas.", "ok", "Uždarykite jungiklį [B02] ir matuokite [B03].");
    else ld12_set_status("Generatorius išjungtas.", "info", "Galima keisti grandinės laidus."); end
endfunction

function ld12_toggle_switch()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then return; end
    if ~LD12.powerOn then ld12_set_status("Pirma įjunkite [B01].", "error", ""); return; end
    LD12.switchOn = ~LD12.switchOn; ld12_render_wires();
    if LD12.switchOn then ld12_set_status("Jungiklis uždarytas.", "ok", "Rodmenis įrašykite [B03].");
    else ld12_set_status("Jungiklis atviras.", "info", ""); end
endfunction

function ld12_set_mode(mode)
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode | ~ld12_valid_index(mode, 2) then return; end
    if mode <> LD12.wireMode then
        LD12.wires_by_mode(LD12.wireMode) = LD12.wires;
        LD12.wireMode = mode; LD12.wires = LD12.wires_by_mode(mode);
        LD12.powerOn = %f; LD12.switchOn = %f; LD12.pending = ""; LD12.lastMeasurement = %nan;
    end
    if mode==1 & LD12.phase==4 then LD12.phase=1; end
    ld12_render_wires(); bench_autosave("LD12");
    names = ["ŽVAIGŽDĖ — imtuvai tarp linijos ir neutralio";"TRIKAMPIS — imtuvai tarp linijų"];
    ld12_set_status("Režimas: " + names(mode), "info", "Šio režimo laidai išliko. Seką rasite Pagalboje.");
endfunction

function ld12_set_phase(k)
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode | ~ld12_valid_index(k,4) then return; end
    if k==4 & LD12.wireMode<>2 then return; end
    LD12.phase=k; ld12_render_wires(); bench_autosave("LD12");
    ld12_set_status("Matuojama: "+ld12_channel_name(k),"info","Uf / If — imtuve; Ul / Il — šaltinio linijoje.");
endfunction

function ld12_measure(refresh)
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then return; end
    if argn(2)<1 then refresh=%t; end
    if ~or(LD12.step == [2 4]) | LD12.wireMode <> ld12_stage_mode(LD12.step) then
        ld12_set_status("Matuojama 2 ir 4 etapuose atitinkamu režimu.", "error", "Režimą nurodo užduotis."); return;
    end
    [u, i, ok, message] = ld12_measure_values();
    if ~ok then ld12_set_status(message, "error", ""); return; end
    if LD12.journal<>[] then
        if or(LD12.journal(:,3)==LD12.wireMode & LD12.journal(:,4)==LD12.phase) then
        ld12_set_status("Šis matavimo taškas jau įrašytas.", "info", "Rodmenys išsaugoti žurnale."); return;
    end
    end
    // One row per actually measured channel; never synthesize missing phases.
    LD12.journal($+1,:) = [u, i, LD12.wireMode, LD12.phase, 0];
    LD12.report_wires(LD12.wireMode) = LD12.wires;
    LD12.lastMeasurement = i;
    if refresh then ld12_render_journal();ld12_render_wires();bench_autosave("LD12");end
    ld12_set_status(msprintf("%s: U = %.4f V; I = %.3f mA.",ld12_channel_name(LD12.phase),u,i), "ok", ...
        "Rodmenų moduliai simetriški; fazės skiriasi 120°.");
endfunction

function ok = ld12_close_enough(value, expected, relative, absolute)
    if argn(2) < 3 then relative = .02; end
    if argn(2) < 4 then absolute = 1e-9; end
    ok = %f;
    if isnan(value) | isinf(value) | isnan(expected) | isinf(expected) then return; end
    ok = abs(value - expected) <= absolute + relative*abs(expected);
endfunction

function ld12_check_step(check_answers)
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then return; end
    if argn(2)<1 then check_answers=%t; end
    ld12_save_answers(); step = LD12.step;
    if ~ld12_valid_index(step, 6) then return; end
    if LD12.done(step) then return; end
    select step
    case 1 then
        if LD12.wireMode <> 1 then ld12_set_status("Pirma sujunkite žvaigždę [B10].", "error", ""); return; end
        [valid, message] = ld12_wiring_valid(LD12.wires);
        if ~valid then ld12_set_status(message, "error", "Pagalba → Kaip sujungti."); return; end
        LD12.report_wires(1) = LD12.wires;
    case 3 then
        if LD12.wireMode <> 2 then ld12_set_status("Sujunkite trikampį [B11].", "error", ""); return; end
        [valid, message] = ld12_wiring_valid(LD12.wires);
        if ~valid then ld12_set_status(message, "error", "Pagalba → Kaip sujungti."); return; end
        LD12.report_wires(2) = LD12.wires;
    end
    if or(step == [2 4]) then
        rows=ld12_journal_rows(ld12_stage_mode(step)); needed=3; if step==4 then needed=4; end
        if size(rows,1)<>needed then
            name = "žvaigždė"; if step == 4 then name = "trikampis"; end
            ld12_set_status("Trūksta matavimo (" + name + ").", "error", "Spauskite [B15] Įjungti ir matuoti visus."); return;
        end
    end
    expected = ld12_expected_answers();
    for index = 1:10
        [answer_step, slot] = ld12_answer_slot(index);
        if answer_step <> step then continue; end
        if ~check_answers then
            if stripblanks(LD12.answers(step,slot))=="" then
                ld12_set_status("Įrašykite ["+ld12_answer_code(step,slot)+"].","error","Atsakymą vertins dėstytojo programa."); return;
            end
            continue;
        end
        value = ld12_parse_number(LD12.answers(step, slot)); relative = .02; absolute = 1e-9;
        if step == 1 | step == 3 then relative = .01; end
        if step == 3 & slot == 1 then relative = 0; absolute = .005; end
        if step == 6 then relative = 0; absolute = 0; end
        if ~ld12_close_enough(value, expected(step, slot), relative, absolute) then
            ld12_set_status("Patikrinkite [" + ld12_answer_code(step, slot) + "].", "error", "Peržiūrėkite formulę užduotyje ir vienetus."); return;
        end
    end
    LD12.done(step) = %t; ld12_render_stage();
    ld12_set_status(string(step) + " etapas patikrintas.", "ok", "");
endfunction

function ld12_next_step()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.step >= 6 | ~LD12.done(LD12.step) then return; end
    ld12_set_step(LD12.step + 1);
endfunction

function ld12_set_step(step)
    if ~ld12_can_act() then return; end
    global LD12;
    if ~ld12_valid_index(step, 6) then return; end
    if LD12.demoMode then ld12_toggle_solution(); end
    ld12_save_answers(); LD12.pending = ""; LD12.step = step;
    ld12_set_mode(ld12_stage_mode(step));
    ld12_render_stage(); bench_autosave("LD12");
endfunction

function text = ld12_step_instruction(step)
    global LD12;
    select step
    case 1 then text=msprintf("1. Sujunkite 6 laidus pagal Pagalba → [B04]. Žvaigždėje galai b sujungiami su N. Apskaičiuokite Uf = Ul/√3; Ul = %g V (tarp linijų).",LD12.cfg.Ul);
    case 2 then text=msprintf("2. [B15] įjunkite ir išmatuokite visus 3 imtuvus. If[mA] = 1000·Uf[V]/R[Ω]; R = %g Ω. Žvaigždėje If = Il. Rodmenys yra žurnale.",LD12.cfg.R);
    case 3 then text="3. Sujunkite 6 trikampio laidus: R1 tarp L1–L2, R2 tarp L2–L3, R3 tarp L3–L1. Seką rodo [B04]. N čia nejungiamas. Įrašykite Uf = Ul, V.";
    case 4 then text="4. [B15] išmatuokite R1, R2, R3 ir liniją L1. If[mA] = 1000·Ul[V]/R[Ω]. If teka imtuve; Il teka šaltinio linijoje. Šie rodmenys skiriasi.";
    case 5 then text="5. Naudokite žurnalo rodmenis: IlΔ = √3·IfΔ; PΔ = √3·Ul·IlΔ; PY = 3·UfY·IfY. Srovės — mA, įtampos — V, todėl galios — mW. PY skaičiuokite iš ŽVAIGŽDĖS matavimų.";
    case 6 then text="6. Palyginkite abu jungimus. Kiekvienai išvadai įrašykite 1 – Taip arba 2 – Ne. Baigę spauskite ĮRAŠYTI ATASKAITĄ; HTML failą siųskite dėstytojui.";
    else text="";
    end
endfunction

function ld12_save_answers()
    global LD12;
    if LD12.demoMode | ~isfield(LD12, "ui") then return; end
    if isfield(LD12.ui, "headless") then if LD12.ui.headless then return; end; end
    if ~isfield(LD12.ui, "answerEdits") then return; end
    for index = 1:size(LD12.ui.answerEdits, "*")
        handle = LD12.ui.answerEdits(index);
        if ~is_handle_valid(handle) then continue; end
        [step, slot] = ld12_answer_slot(index);
        if step <> LD12.step | handle.visible <> "on" then continue; end
        if LD12.answers(step, slot) <> handle.string then LD12.done(step) = %f; end
        LD12.answers(step, slot) = handle.string;
    end
endfunction

function [step, slot] = ld12_answer_slot(index)
    mapping = [1 1;2 1;3 1;4 1;5 1;5 2;5 3;6 1;6 2;6 3];
    step = mapping(index, 1); slot = mapping(index, 2);
endfunction

function ld12_test_answers(step, values)
    global LD12;
    for index = 1:size(values, "*"); LD12.answers(step, index) = msprintf("%.17g", values(index)); end
endfunction

function ld12_show_wiring_guide()
    if ~ld12_can_act() then return; end
    global LD12;
    text = ["LD12 · " + ld12_mode_name(); ""; "Išjunkite trifazį šaltinį prieš jungdami laidus."];
    wires = ld12_canonical_wires(LD12.wireMode);
    for index = 1:size(wires, 1)
        text($+1) = msprintf("%d. [%s]–[%s]: %s → %s", index, ld12_terminal_code(wires(index,1)), ld12_terminal_code(wires(index,2)), ld12_terminal_name(wires(index,1)), ld12_terminal_name(wires(index,2)));
    end
    text = [text; ""; "Režimas renkamas mygtukais [B10] (žvaigždė) ir [B11] (trikampis)."; "Matuojama fazė renkama [B12]–[B14]; simetrinėje grandinėje fazės vienodos."; "Žvaigždėje imtuvai tarp linijos ir N; trikampyje — tarp linijų."];
    ld12_text_window("Kaip sujungti", text);
endfunction

function ld12_show_stand_map()
    if ~ld12_can_act() then return; end
    [ids, callbacks, labels, hints] = ld12_button_registry();
    text = ["LD12 · STENDO ŽEMĖLAPIS";"T01/T02/T03 – linijos L1/L2/L3; T04 – neutralis N.";"T05/T06 – R1; T07/T08 – R2; T09/T10 – R3."; ...
        "Fazė matuoti: [B12]–[B14]. Voltmetras ir ampermetras — pagalbinės kortelės."; ""];
    for index = 1:size(ids, "*"); text($+1) = "[" + ids(index) + "] " + labels(index); end
    text = [text; ""; "Etapai E01–E06. V02 – dviejų jungimų matavimų žurnalas."; ...
        "A01 – Uf žvaigždėje; A02 – fazinė srovė žvaigždėje."; ...
        "A03/A04 – trikampio įtampa ir srovė; A05 – Il, PΔ, PY. A06 – išvados."];
    ld12_text_window("Žemėlapis", text);
endfunction

function ld12_text_window(title, lines)
    global LD12;
    if LD12.ui.headless then return; end
    window = figure("figure_name", "LD12 · " + title, "axes_size", [560 420], ...
        "menubar_visible", "off", "toolbar_visible", "off", "infobar_visible", "off");
    uicontrol(window, "style", "listbox", "units", "normalized", "position", [.02 .10 .96 .84], ...
        "string", lines, "fontname", "SansSerif", "fontunits", "pixels", "fontsize", 12);
    uicontrol(window, "style", "pushbutton", "units", "normalized", "position", [.35 .02 .30 .06], ...
        "string", "[H01] Uždaryti", "tag", "H01", "callback", msprintf("close(%d)",window.figure_id));
endfunction

function ld12_toggle_solution()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then
        LD12.demoMode = %f;
        for field = ["wires" "answers" "wireMode" "journal" "powerOn" "switchOn" "lastMeasurement" "phase"]
            LD12(field) = LD12.backup(field);
        end
        LD12.pending = ""; ld12_render_stage(); ld12_set_status("Grįžta į savo darbą.", "info", ""); bench_autosave("LD12"); return;
    end
    ld12_save_answers(); LD12.backup = struct();
    for field = ["wires" "answers" "wireMode" "journal" "powerOn" "switchOn" "lastMeasurement" "phase"]
        LD12.backup(field) = LD12(field);
    end
    LD12.practice_used = %t; bench_autosave("LD12"); LD12.demoMode = %t; LD12.pending = "";
    LD12.wires = ld12_canonical_wires(LD12.wireMode); LD12.powerOn = %t; LD12.switchOn = %t;
    LD12.journal = []; LD12.phase=1;
    [u, i, ok, message] = ld12_measure_values();
    if ok then LD12.journal = [u, i, LD12.wireMode, LD12.phase, 0]; end
    ld12_render_stage(); ld12_set_status("PAVYZDYS: šio režimo sujungimas ir matavimas.", "info", "Grįžkite į savo darbą pagrindiniu mygtuku.");
endfunction

function ld12_restore_stage()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode then ld12_toggle_solution(); return; end
    ld12_save_answers();
    LD12.powerOn = %f; LD12.switchOn = %f; LD12.pending = ""; LD12.lastMeasurement = %nan;
    if ld12_wiring_editable() then
        LD12.wires = emptystr(0, 2); LD12.wires_by_mode(LD12.wireMode)=LD12.wires; ld12_invalidate_mode();
    end
    ld12_render_stage(); ld12_set_status("Šio etapo stendas atkurtas.", "info", ""); bench_autosave("LD12");
endfunction

function ld12_restart()
    if ~ld12_can_act() then return; end
    ld12_init_state(); ld12_render_stage(); ld12_set_status("Darbas pradėtas iš naujo.", "info", "Studentas ir variantas išliko."); bench_autosave("LD12");
endfunction

function ld12_answers_changed()
    if ~ld12_can_act() then return; end
    ld12_save_answers(); ld12_student_sync(); bench_autosave("LD12");
endfunction

function name = ld12_mode_name()
    global LD12;
    if LD12.wireMode == 1 then name = "Žvaigždė"; else name = "Trikampis"; end
endfunction


function ld12_close()
    global LD12;
    if ~isfield(LD12,"fig") then return; end
    if ~is_handle_valid(LD12.fig) then return; end
    if LD12.demoMode then ld12_toggle_solution(); end
    bench_autosave("LD12");
    if isfield(LD12,"autosave_error") then
        if LD12.autosave_error<>"" then return; end
    end
    delete(LD12.fig);
endfunction

function ld12_measure_all()
    if ~ld12_can_act() then return; end
    global LD12;
    if LD12.demoMode | ~or(LD12.step==[2 4]) then return; end
    ld12_set_mode(ld12_stage_mode(LD12.step));
    [valid,why]=ld12_wiring_valid(LD12.wires);
    if ~valid then ld12_set_status(why,"error","Pagalba → [B04] rodo kiekvieną laidą."); return; end
    LD12.powerOn=%t; LD12.switchOn=%t;
    count=3; if LD12.wireMode==2 then count=4; end
    for channel=1:count; LD12.phase=channel; ld12_measure(%f); end
    ld12_render_journal();ld12_render_wires();bench_autosave("LD12");
    ld12_set_status("Visi šio jungimo matavimai įrašyti.","ok","Žurnale atskirti imtuvai R1–R3 ir trikampio linija L1. Galite tęsti.");
endfunction

function name = ld12_channel_name(channel)
    global LD12;
    names=["R1 (L1–N)";"R2 (L2–N)";"R3 (L3–N)";"Linija L1"];
    if LD12.wireMode==2 then names=["R1 (L1–L2)";"R2 (L2–L3)";"R3 (L3–L1)";"Linija L1"];end
    name=names(channel);
endfunction
