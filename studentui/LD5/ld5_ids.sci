// ============================================================================
// LD5 elementų numerių registras. Bankas LD5-64-A-2026.
// REGISTRY-CODES: T01:T12 B01:B12 E01:E06 A02.01 A04.01:A04.04 A05.01 A05.02 A06.01 A06.02 V02 H01
// ============================================================================

function ids = ld5_terminal_ids()
    ids = ["E_P";"E_N";"K1";"K2";"A_P";"A_N";"R1A";"R1B";"RVA";"RVB";"V_P";"V_N"];
endfunction

function code = ld5_terminal_code(id)
    tids = ld5_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then code = ""; else code = msprintf("T%02d", k(1)); end
endfunction

function name = ld5_terminal_name(id)
    names = ["Maitinimo šaltinio + gnybtas";"Maitinimo šaltinio − gnybtas"; ...
             "Jungiklio įėjimas";"Jungiklio išėjimas";"Ampermetro + gnybtas"; ...
             "Ampermetro − gnybtas";"Rezistoriaus R1 gnybtas a";"Rezistoriaus R1 gnybtas b"; ...
             "Potenciometro RV viršutinis gnybtas";"Potenciometro RV apatinis gnybtas"; ...
             "Voltmetro + zondas";"Voltmetro − zondas"];
    tids = ld5_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then name = id; else name = names(k(1)); end
endfunction

function [ids, callbacks, labels, hints] = ld5_button_registry()
    ids = ["B01";"B02";"B03";"B04";"B05";"B06";"B07";"B08";"B09";"B10";"B11";"B12"];
    callbacks = ["ld5_toggle_power()";"ld5_toggle_switch()";"ld5_measure()"; ...
                 "ld5_show_wiring_guide()";"ld5_show_stand_map()";"ld5_restore_stage()"; ...
                 "ld5_toggle_solution()";"bench_export_current(""LD5"")";"ld5_restart()"; ...
                 "ld5_set_position(1)";"ld5_set_position(2)";"ld5_set_position(3)"];
    labels = ["MAITINIMAS";"JUNGIKLIS";"MATUOTI";"KAIP SUJUNGTI";"STENDO ŽEMĖLAPIS"; ...
              "ATKURTI ETAPO STENDĄ";"PAVYZDYS";"ATASKAITA DĖSTYTOJUI";"PRADĖTI IŠ NAUJO"; ...
              "PADĖTIS 1";"PADĖTIS 2";"PADĖTIS 3"];
    hints = ["Įjungti/išjungti maitinimo šaltinį.";"Atidaryti/uždaryti jungiklį."; ...
             "Užfiksuoti voltmetro ir ampermetro rodmenis į žurnalą."; ...
             "Parodyti šio etapo sujungimo seką."; ...
             "Visų B, E, T numerių paskirtis."; ...
             "Grąžinti stendą į saugią būseną."; ...
             "Parodyti teisingą sujungimą."; ...
             "Sukurti HTML ataskaitą."; ...
             "Pradėti darbą iš naujo."; ...
             "Nustatyti potenciometrą į pirmąją padėtį."; ...
             "Nustatyti potenciometrą į antrąją padėtį."; ...
             "Nustatyti potenciometrą į trečiąją padėtį."];
endfunction

function [code, label, hint] = ld5_button_info(cb)
    [ids, callbacks, labels, hints] = ld5_button_registry();
    k = find(callbacks == cb);
    if size(k, "*") ~= 1 then error("Valdiklis neįtrauktas į LD5 registrą: " + cb); end
    code = ids(k(1)); label = labels(k(1)); hint = hints(k(1));
endfunction

function code = ld5_stage_code(n)
    code = msprintf("E%02d", n);
endfunction

function code = ld5_answer_code(n, k)
    code = msprintf("A%02d.%02d", n, k);
endfunction

function codes = ld5_all_codes()
    tids = ld5_terminal_ids();
    codes = emptystr(size(tids, "*"), 1);
    for k = 1:size(tids, "*"); codes(k) = msprintf("T%02d", k); end
    [bids, callbacks, labels, hints] = ld5_button_registry();
    codes = [codes; bids];
    for n = 1:6; codes($+1, 1) = msprintf("E%02d", n); end
    codes = [codes; "A02.01";"A04.01";"A04.02";"A04.03";"A04.04"; ...
             "A05.01";"A05.02";"A06.01";"A06.02"];
    codes = [codes; "V02";"H01"];
endfunction
