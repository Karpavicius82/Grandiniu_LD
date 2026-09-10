function ld2_write_exports(folder)
    global LD2;
    if LD2.example_active then error("Pavyzdžio duomenys neeksportuojami."); end
    st=LD2.state.student;
    meta=[ld2_csv_row(["Sarasas_Nr" "Vardas" "Grupe" "Bankas" "Pradzia"]); ...
        ld2_csv_row([string(st.number) st.name st.group st.bank LD2.state.started_at])];
    mputl(meta,fullfile(folder,"LD2_studentas_variantas.csv"));
    lines=ld2_csv_row(["ID" "Etapas" "Grandine" "Dydis" "f_Hz" "Reiksme" "Vienetas" "Kilme" "Grandines_revizija" "Laikas"]);
    for k=1:length(LD2.state.measurements)
        m=LD2.state.measurements(k);
        lines($+1,1)=ld2_csv_row([string(m.id) string(m.step) m.phase m.target msprintf("%.12g",m.f) msprintf("%.12g",m.value) m.unit m.origin string(m.revision) m.time]);
    end
    mputl(lines,fullfile(folder,"LD2_matavimu_zurnalas.csv"));
    lines=ld2_csv_row(["Etapas" "Pavadinimas" "Laukas" "Studento_tekstas" "Etapo_busena"]);
    for step=1:12
        status="NEATLIKTA"; if LD2.state.completed(step)==1 then status="PATIKRINTA"; end
        if LD2.state.skipped(step)==1 & LD2.state.completed(step)==0 then status="PRALEISTA"; end
        [labels,n]=ld2_answer_spec(step);
        if n==0 then lines($+1,1)=ld2_csv_row([string(step) ld2_step_title(step) "" "" status]); end
        for j=1:n
            lines($+1,1)=ld2_csv_row([string(step) ld2_step_title(step) labels(j) LD2.state.answers_text(step,j) status]);
        end
    end
    mputl(lines,fullfile(folder,"LD2_studento_atsakymai.csv"));
    lines=ld2_csv_row(["f_Hz" "UR13_V" "Kilme"]);
    for k=1:size(LD2.state.sweep_f,"*") lines($+1,1)=ld2_csv_row([string(LD2.state.sweep_f(k)) msprintf("%.12g",LD2.state.sweep_ur(k)) LD2.state.sweep_source(k)]); end
    mputl(lines,fullfile(folder,"LD2_daznine_lentele.csv"));
    lines=ld2_csv_row(["Parametras" "Reiksme_SI"]); names=fieldnames(LD2.cfg);
    for k=1:size(names,"*"); lines($+1,1)=ld2_csv_row([names(k) msprintf("%.12g",ld2_config_value(LD2.cfg,names(k)))]); end
    mputl(lines,fullfile(folder,"LD2_parametrai.csv"));
    note=LD2.state.free_note; if note=="" then note="Studento išvados dar neįrašytos."; end
    mputl(note,fullfile(folder,"LD2_isvados.txt"));
    lines=ld2_csv_row(["Eil_nr" "Dydis" "f_Hz" "U_V"]);
    for k=1:size(LD2.state.peak_f,"*") lines($+1,1)=ld2_csv_row([string(k) LD2.state.peak_target(k) msprintf("%.12g",LD2.state.peak_f(k)) msprintf("%.12g",LD2.state.peak_u(k))]); end
    mputl(lines,fullfile(folder,"LD2_maksimumu_minimumo_tyrimas.csv"));
    lines=ld2_csv_row(["Etapas" "Paaiskinimas"]); for k=1:12; lines($+1,1)=ld2_csv_row([string(k) LD2.state.step_notes(k)]); end
    mputl(lines,fullfile(folder,"LD2_etapu_paaiskinimai.csv"));
    lines=ld2_csv_row(["Matavimo_ID" "Laidas" "Nuo_T" "Iki_T"]);
    for k=1:length(LD2.state.measurements)
        m=LD2.state.measurements(k);
        for j=1:size(m.connections,1) lines($+1,1)=ld2_csv_row([string(m.id) string(j) ld2_terminal_code(m.connections(j,1)) ld2_terminal_code(m.connections(j,2))]); end
    end
    mputl(lines,fullfile(folder,"LD2_matavimu_jungtys.csv"));
endfunction

function ld2_edit_conclusions()
    global LD2;
    if LD2.example_active then
        ld2_show_info("Pavyzdys – išvadų orientyrai", ["Savo išvadose palyginkite RC ir RL srovės bei įtampos fazes.";"Aptarkite, ar įtampų moduliai sudedami aritmetiškai, ar vektoriškai.";"Nurodykite savo rastą rezonansą, UL/UC maksimumų dažnius ir -3 dB ribas.";"Grįžkite mygtuku MANO DARBAS ir įrašykite savo išvadas."]); return;
    end
    note=x_dialog(["LD2 – jūsų išvados";"Palyginkite RC/RL fazes, įtampų vektorius ir RLC rezonanso matavimus."],LD2.state.free_note);
    if size(note,"*")==0 then return; end
    LD2.state.free_note=strcat(matrix(note,-1,1),ascii(10));
    ld2_event("B08","Atnaujintos studento išvados.");
    ld2_set_status("Išvados įrašytos. [B05] išsaugo sesiją; [B07] generuoja ataskaitą.","ok");
    ld2_maybe_report();
endfunction
