function [ids,callbacks,labels,hints]=ld2_button_registry()
    ids=["B01";"B02";"B03";"B04";"B05";"B06";"B07";"B08";"B09";"B10";"B11";"B12";"B13";"B14";"B15";"B16";"B17";"B18";"B19";"B20";"B21";"B22";"B23";"B24";"B25";"B26";"B27";"B28";"B29";"B30";"B31";"B32";"B33";"B34";"B35";"B36";"B37";"B38";"B39";"B40";"B41";"B42";"B43";"B44";"B45"];
    callbacks=["ld2_choose_student()";"ld2_help_current()";"ld2_show_solution()";"ld2_check_step()";"ld2_save_work()";"ld2_load_work()";"ld2_report_ui()";"ld2_edit_conclusions()";"ld2_power_toggle()";"ld2_check_wiring()";"ld2_undo_wire()";"ld2_clear_phase_wires()";"ld2_remove_voltage_probes()";"ld2_measure_current()";"ld2_measure_voltage()";"ld2_apply_frequency()";"ld2_frequency_delta(-10)";"ld2_frequency_delta(-1)";"ld2_frequency_delta(1)";"ld2_frequency_delta(10)";"ld2_record_resonance_point()";"ld2_clear_resonance_points()";"ld2_record_peak_point()";"ld2_record_f1()";"ld2_record_f2()";"ld2_run_sweep()";"ld2_export_csv()";"ld2_plot_impedance()";"ld2_plot_voltage_current()";"ld2_plot_scope_current()";"ld2_plot_current()";"ld2_goto_found_resonance()";"ld2_show_journal()";"ld2_show_summary_window()";"ld2_prev()";"ld2_next()";"ld2_restart()";"ld2_show_method_fixes()";"ld2_edit_parameters()";"ld2_show_theory()";"ld2_edit_step_note()";"ld2_show_contact_map()";"ld2_show_variant_bank()";"ld2_show_resonance_theory()";"ld2_show_button_map()"];
    labels=["Studentas / variantas";"Visa metodika";"Pavyzdys / mano darbas";"Tikrinti etapą";"Išsaugoti darbą";"Atverti darbą";"Generuoti ataskaitą";"Bendros išvados";"Generatorius";"Tikrinti jungimą";"Atšaukti laidą";"Išvalyti laidus";"Nuimti V zondus";"Matuoti I";"Matuoti U";"Taikyti f";"−10 Hz";"−1 Hz";"+1 Hz";"+10 Hz";"Fiksuoti UR tašką";"Išvalyti UR taškus";"Fiksuoti ekstremumą";"Fiksuoti f1";"Fiksuoti f2";"Skenuoti 0–10 kHz";"CSV duomenys";"Varžų vektoriai";"Įtampų vektoriai";"Oscilograma";"Etapo grafikas";"Nustatyti rastą fr";"Matavimų žurnalas";"Atsakymų suvestinė";"Atgal";"Toliau";"Pradėti iš naujo";"Šaltiniai / pakeitimai";"Mano parametrai";"RC / RL teorija";"Etapo paaiškinimas";"Kontaktų žinynas";"64 variantų lentelė";"RLC teorija";"Valdiklių žinynas"];
    hints=["Įveskite eilės numerį 1–64, vardą ir grupę.";"Dabartinio etapo teorija, formulės, tiksli veiksmų seka ir klaidų taisymas.";"Perjungti pilną pavyzdį ir jūsų darbą. Pavyzdys neįskaitomas.";"Išsaugoti įvestį ir patikrinti šio etapo atlikimą.";"Įrašyti darbo būseną į .sod failą, kad galėtumėte tęsti.";"Atkurti šios versijos .sod failą. Generatorius bus išjungtas.";"Pasirinkti aplanką ir įrašyti HTML ataskaitą, CSV bei darbo .sod.";"Įrašyti savo paaiškinimus ataskaitai.";"Įjungti / išjungti virtualų generatorių.";"Patikrinti pagrindinės grandinės jungtis.";"Pašalinti paskutinį leidžiamą keisti laidą.";"Sujungimo etape pašalinti tos grandinės laidus.";"Pašalinti tik voltmetro zondus, ne pagrindinę grandinę.";"A~ prietaisu išmatuoti ir į žurnalą įrašyti srovę.";"V~ prietaisu išmatuoti ir į žurnalą įrašyti įtampą.";"Pritaikyti lauke F04 įvestą dažnį hercais.";"Sumažinti dažnį 10 Hz; po keitimo matuoti iš naujo.";"Sumažinti dažnį 1 Hz.";"Padidinti dažnį 1 Hz.";"Padidinti dažnį 10 Hz.";"Į 9 etapo paiešką įrašyti paskutinį galiojantį UR13 matavimą.";"Pašalinti 9 etapo paieškos taškus; istorija žurnale lieka.";"Į 10 etapo UL / UC / ULC paiešką įrašyti dabartinį tašką.";"Įrašyti apatinį pusės galios tašką, kai išmatuotas UR13 atitinka slenkstį.";"Įrašyti viršutinį pusės galios tašką.";"Automatiškai atlikti virtualius 1–10 kHz matavimus. 0 Hz – teorinė riba.";"Įrašyti pradinius duomenis, atsakymus ir matavimų žurnalą.";"Atverti teorinę varžų R, X, Z diagramą.";"Atverti teorinę įtampų fazorių diagramą.";"Atverti nusistovėjusios sinusinės būsenos modelio oscilogramą.";"Atverti šiam etapui skirtą diagramą arba užfiksuotų taškų grafiką.";"Pritaikyti rastą fr; jeigu jo nėra, aiškiai pažymėtą teorinį fr.";"Parodyti rodmenis su matavimo kilme ir dažniu.";"Parodyti studento atsakymus ir etapų būseną.";"Grįžti vienu etapu atgal neištrinant atsakymų.";"Pereiti pirmyn; neužbaigtą etapą galima sąmoningai praleisti.";"Po patvirtinimo išvalyti bandymus; išlaikyti pasirinktą variantą.";"Parodyti kas perimta iš aprašo ir kas išplėsta šiam stendui.";"Parodyti numeriui priskirtus parametrus; laisvai jų nekeisti.";"Atverti dabartinio etapo metodiką.";"Įrašyti savo darbo eigą ir atsakymus į etapo klausimus.";"Parodyti T01–T38 paskirtį ir elektriškai sutampančius lizdus.";"Parodyti visus 64 iš anksto nustatytus parametrų rinkinius.";"Atverti RLC rezonanso metodiką.";"Visų B, E, T, F, H ir V numerių paskirtis."];
endfunction

function [code,label,hint]=ld2_button_info(cb)
    [ids,cbs,labels,hints]=ld2_button_registry(); k=find(cbs==cb);
    if size(k,"*")<>1 then error("Valdiklis neįtrauktas į numerių registrą: "+cb); end
    code=ids(k); label=labels(k); hint=hints(k);
endfunction

function ld2_action(code)
    global LD2;
    [ids,cbs,labels,hints]=ld2_button_registry(); k=find(ids==code);
    if size(k,"*")<>1 then return; end
    ld2_save_answers();
    ld2_event(code,labels(k));
    backup=LD2.state; was_example=LD2.example_active; saved_example=LD2.example_backup;
    try
        execstr(cbs(k));
    catch
        details=lasterror();
        LD2.state=backup; LD2.example_active=was_example; LD2.example_backup=saved_example;
        LD2.ui.suppress_render=%f;
        try ld2_render_step(); catch end
        ld2_show_error(code+" veiksmas nepavyko. Darbo būsena atkurta.", ...
            [details;"[B05] išsaugokite darbą. [B02] atverkite šio etapo metodiką."; ...
             "Pateikite klaidos tekstą kartu su etapo ir varianto numeriais."]);
    end
endfunction

function stamp=ld2_timestamp()
    d=getdate();
    stamp=msprintf("%04d-%02d-%02d %02d:%02d:%02d",d(1),d(2),d(6),d(7),d(8),d(9));
endfunction
