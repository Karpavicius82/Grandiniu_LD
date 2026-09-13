// ============================================================================
// LD4 elementų numerių registras. Bankas LD4-64-A-2026.
// REGISTRY-CODES: T01:T12 B01:B13 E01:E07 A02.01 A04.01:A04.04 A05.01:A05.03 A06.01 A07.01 A07.02 V02 H01
// ============================================================================

function ids = ld4_terminal_ids()
    ids = ["E_P";"E_N";"K1";"K2";"A_P";"A_N";"R1A";"R1B";"R2A";"R2B";"V_P";"V_N"];
endfunction

function code = ld4_terminal_code(id)
    tids = ld4_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then code = ""; else code = msprintf("T%02d", k(1)); end
endfunction

function name = ld4_terminal_name(id)
    names = ["Maitinimo šaltinio + gnybtas";"Maitinimo šaltinio − gnybtas"; ...
             "Jungiklio įėjimas";"Jungiklio išėjimas";"Ampermetro + gnybtas"; ...
             "Ampermetro − gnybtas";"Rezistoriaus R1 gnybtas a";"Rezistoriaus R1 gnybtas b"; ...
             "Rezistoriaus R2 gnybtas a";"Rezistoriaus R2 gnybtas b"; ...
             "Voltmetro + zondas";"Voltmetro − zondas"];
    tids = ld4_terminal_ids();
    k = find(tids == id);
    if size(k, "*") ~= 1 then name = id; else name = names(k(1)); end
endfunction

function [ids, callbacks, labels, hints] = ld4_button_registry()
    ids = ["B01";"B02";"B03";"B04";"B05";"B06";"B07";"B08";"B09";"B10";"B11";"B12";"B13"];
    callbacks = ["ld4_toggle_power()";"ld4_toggle_switch()";"ld4_measure()"; ...
                 "ld4_show_wiring_guide()";"ld4_show_stand_map()";"ld4_restore_stage()"; ...
                 "ld4_toggle_solution()";"bench_export_current(""LD4"")";"ld4_restart()"; ...
                 "ld4_set_voltage(LD4.cfg.U1)";"ld4_set_voltage(LD4.cfg.U2)";"ld4_set_voltage(LD4.cfg.U3)"; ...
                 "ld4_set_resistor(2)"];
    labels = ["MAITINIMAS";"JUNGLIS";"MATUOTI";"KAIP SUJUNGTI";"STENDO ŽEMĖLAPIS"; ...
              "ATKURTI ETAPO STENDĄ";"PAVYZDYS";"ATASKAITA DĖSTYTOJUI";"PRADĖTI IŠ NAUJO"; ...
              "NUSTATYTI U1";"NUSTATYTI U2";"NUSTATYTI U3";"Į R2 REZISTORIŲ"];
    hints = ["Įjungti/išjungti maitinimo šaltinį.";"Atidaryti/uždaryti jungiklį grandinėje."; ...
             "Užfiksuoti voltmetro ir ampermetro rodmenis į žurnalą."; ...
             "Parodyti šio etapo sujungimo seką su elementų numeriais."; ...
             "Visų B, E, T numerių paskirtis viename lange."; ...
             "Grąžinti šio etapo stendą į saugią pradinę būseną."; ...
             "Parodyti teisingą sujungimą neįrašant jo kaip savo."; ...
             "Sukurti HTML ataskaitą ir ją išsaugoti diske."; ...
             "Pradėti darbą iš naujo (atsakymai ištrinami)."; ...
             "Nustatyti įtampą į pirmąją instrukcijos reikšmę U1."; ...
             "Nustatyti įtampą į antrąją instrukcijos reikšmę U2."; ...
             "Nustatyti įtampą į trečiąją instrukcijos reikšmę U3."; ...
             "Perjungti matavimo grandinę į antrąjį rezistorių R2."];
endfunction

function [code, label, hint] = ld4_button_info(cb)
    [ids, callbacks, labels, hints] = ld4_button_registry();
    k = find(callbacks == cb);
    if size(k, "*") ~= 1 then error("Valdiklis neįtrauktas į LD4 registrą: " + cb); end
    code = ids(k(1)); label = labels(k(1)); hint = hints(k(1));
endfunction

function code = ld4_stage_code(n)
    code = msprintf("E%02d", n);
endfunction

function code = ld4_answer_code(n, k)
    code = msprintf("A%02d.%02d", n, k);
endfunction

function codes = ld4_all_codes()
    tids = ld4_terminal_ids();
    codes = emptystr(size(tids, "*"), 1);
    for k = 1:size(tids, "*")
        codes(k) = msprintf("T%02d", k);
    end
    [bids, callbacks, labels, hints] = ld4_button_registry();
    codes = [codes; bids];
    for n = 1:7
        codes($+1, 1) = msprintf("E%02d", n);
    end
    codes = [codes; "A02.01";"A04.01";"A04.02";"A04.03";"A04.04"; ...
             "A05.01";"A05.02";"A05.03";"A06.01";"A07.01";"A07.02"];
    codes = [codes; "V02";"H01"];
endfunction
