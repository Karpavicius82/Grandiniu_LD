// ============================================================================
// LD3 elementų numerių registras („rėmai"). Bankas LD3-64-A-2026.
// REGISTRY-CODES: T01:T10 B01:B09 E01:E06 A02.01 A04.01:A04.04 A05.01 A06.01 A06.02 V01 V02 H01
// Instrukcijose kodai tik laužtiniuose skliaustuose [T07]; čia — pliki literalai.
// ============================================================================

function ids = ld3_terminal_ids()
    // Tvarka STABILI: T01..T10.
    ids = ["E_P";"E_N";"K1";"K2";"A_P";"A_N";"R1A";"R1B";"V_P";"V_N"];
endfunction

function code = ld3_terminal_code(id)
    tids = ld3_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then code = ""; else code = msprintf("T%02d", k(1)); end
endfunction

function name = ld3_terminal_name(id)
    names = ["Maitinimo šaltinio + gnybtas";"Maitinimo šaltinio − gnybtas"; ...
             "Jungiklio įėjimas";"Jungiklio išėjimas";"Ampermetro + gnybtas"; ...
             "Ampermetro − gnybtas";"Rezistoriaus R1 gnybtas a";"Rezistoriaus R1 gnybtas b"; ...
             "Voltmetro + zondas";"Voltmetro − zondas"];
    tids = ld3_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then name = id; else name = names(k(1)); end
endfunction

function [ids, callbacks, labels, hints] = ld3_button_registry()
    // Tvarka STABILI: B01..B09. Callbackai NEKEIČIAMI – pagal juos testai randa mygtukus.
    ids = ["B01";"B02";"B03";"B04";"B05";"B06";"B07";"B08";"B09"];
    callbacks = ["ld3_toggle_power()";"ld3_toggle_switch()";"ld3_measure()"; ...
                 "ld3_show_wiring_guide()";"ld3_show_stand_map()";"ld3_restore_stage()"; ...
                 "ld3_toggle_solution()";"bench_export_current(""LD3"")";"ld3_restart()"];
    labels = ["MAITINIMAS";"JUNGLIS";"MATUOTI";"KAIP SUJUNGTI";"STENDO ŽEMĖLAPIS"; ...
              "ATKURTI ETAPO STENDĄ";"PAVYZDYS";"ATASKAITA DĖSTYTOJUI";"PRADĖTI IŠ NAUJO"];
    hints = ["Įjungti/išjungti maitinimo šaltinį.";"Atidaryti/uždaryti jungiklį grandinėje."; ...
             "Užfiksuoti voltmetro ir ampermetro rodmenis į matavimų žurnalą."; ...
             "Parodyti šio etapo sujungimo seką su elementų numeriais."; ...
             "Visų B, E, T ir V numerių paskirtis viename lange."; ...
             "Grąžinti šio etapo stendą į saugią pradinę būseną."; ...
             "Parodyti teisingą sujungimą/atlygius neįrašant jų kaip savo."; ...
             "Sukurti HTML ataskaitą ir ją išsaugoti diske."; ...
             "Pradėti darbą iš naujo (atsakymai ištrinami)."];
endfunction

function [code, label, hint] = ld3_button_info(cb)
    [ids, callbacks, labels, hints] = ld3_button_registry();
    k = find(callbacks == cb);
    if size(k, "*") ~= 1 then error("Valdiklis neįtrauktas į LD3 registrą: " + cb); end
    code = ids(k(1)); label = labels(k(1)); hint = hints(k(1));
endfunction

function code = ld3_stage_code(n)
    code = msprintf("E%02d", n);
endfunction

function code = ld3_answer_code(n, k)
    code = msprintf("A%02d.%02d", n, k);
endfunction

function codes = ld3_all_codes()
    // VISI galiojantys LD3 kodai (mašininei patikrai).
    tids = ld3_terminal_ids();
    codes = emptystr(size(tids, "*"), 1);
    for k = 1:size(tids, "*")
        codes(k) = msprintf("T%02d", k);
    end
    [bids, callbacks, labels, hints] = ld3_button_registry();
    codes = [codes; bids];
    for n = 1:6
        codes($+1, 1) = msprintf("E%02d", n);
    end
    codes = [codes; "A02.01";"A04.01";"A04.02";"A04.03";"A04.04";"A05.01";"A06.01";"A06.02"];
    codes = [codes; "V01";"V02";"H01"];
endfunction
