function ld2_render_controls()
    global LD2;
    step=LD2.state.step; phase=ld2_phase_for_step(step);
    fr=ld2_frame(LD2.ui.right,[0.025 0.560 0.95 0.421],[1 1 1]);
    ld2_text(fr,[0.025 0.912 0.95 0.069],"PRIETAISAI IR VALDYMAS",13,%t,"left",[1 1 1],[0.06 0.20 0.34]);
    bg=[0.93 0.96 0.99];
    if step==1 then
        ld2_button(fr,[0.025 0.710 0.95 0.145],"Mano priskirti parametrai","ld2_edit_parameters()",12,bg);
        ld2_button(fr,[0.025 0.510 0.45 0.145],"64 variantai","ld2_show_variant_bank()",12,bg);
        ld2_button(fr,[0.525 0.510 0.45 0.145],"Kontaktai","ld2_show_contact_map()",12,bg);
        ld2_button(fr,[0.025 0.310 0.45 0.145],"Valdikliai","ld2_show_button_map()",12,bg);
        ld2_button(fr,[0.525 0.310 0.45 0.145],"Šaltiniai","ld2_show_method_fixes()",12,bg);
        ld2_text(fr,[0.025 0.065 0.95 0.17],"[B01] Numeris sąraše = jūsų varianto numeris.",12,%t,"left",[1 1 1],[0.06 0.20 0.34]);
        return;
    end
    if LD2.state.power then label="ĮJUNGTA"; pbg=[0.77 0.94 0.82]; else label="IŠJUNGTA"; pbg=[0.99 0.87 0.85]; end
    LD2.ui.power_btn=ld2_button(fr,[0.525 0.762 0.45 0.119],label,"ld2_power_toggle()",12,pbg);
    ld2_text(fr,[0.025 0.763 0.48 0.110],ld2_source_text(phase),12,%t,"left",[1 1 1],[0.08 0.16 0.24]);
    if step==2 | step==5 | step==8 then
        ld2_button(fr,[0.025 0.573 0.95 0.128],"Tikrinti jungimą","ld2_check_wiring()",12,bg);
        ld2_button(fr,[0.025 0.397 0.45 0.128],"Atšaukti laidą","ld2_undo_wire()",11,bg);
        ld2_button(fr,[0.525 0.397 0.45 0.128],"Išvalyti laidus","ld2_clear_phase_wires()",11,[1 .94 .91]);
        ld2_button(fr,[0.025 0.220 0.95 0.128],"Kontaktų numeriai ir paskirtis","ld2_show_contact_map()",12,bg);
        ld2_text(fr,[0.025 0.06 0.95 0.110],"Vienas laidas = du konkretūs T numeriai.",12,%t,"left",[1 1 1],[0.1 .2 .3]); return;
    end
    if step==3 | step==6 then
        lines=ld2_parameter_lines(LD2.cfg);
        if step==3 then text=lines(1); else text=lines(2); end
        rows=[text;" ";"[B02] Visa etapo teorija ir skaičiavimo seka."; ...
            "[B03] Pilnas atliktas pavyzdys.";"[B28] Varžų; [B29] įtampų diagrama."; ...
            "[B41] Jūsų paaiškinimas ataskaitai."];
        h=uicontrol(fr,"style","listbox","units","normalized","position",[.025 .055 .95 .635], ...
            "string",ld2_wrap_lines(rows,58),"fontname","Arial","fontunits","pixels","fontsize",12,"backgroundcolor",[1 1 1]);
        ld2_track(h); return;
    end
    if phase=="RLC" then
        ld2_text(fr,[0.025 0.626 0.27 0.10],"[F04] Dažnis, Hz",12,%t,"left",[1 1 1],[.1 .1 .1]);
        LD2.ui.freq_edit=ld2_edit(fr,[0.310 0.625 0.265 0.115],ld2_num(LD2.state.freq,3));
        LD2.ui.freq_edit.tag="F04";
        ld2_button(fr,[0.605 0.625 0.370 0.115],"Taikyti f","ld2_apply_frequency()",12,bg);
        LD2.ui.freq_slider=uicontrol(fr,"style","slider","units","normalized","position",[0.090 0.519 0.885 0.073], ...
            "tag","V01","tooltipstring","[V01] Apytikslis dažnio nustatymas. Tikslų f įveskite į F04.", ...
            "min",1,"max",LD2.cfg.F_MAX,"value",max([1 LD2.state.freq]),"callback","ld2_frequency_slider()");
        ld2_track(LD2.ui.freq_slider);
        ld2_text(fr,[0.025 0.518 0.061 0.080],"V01",11,%f,"left",[1 1 1],[.1 .1 .1]);
        ld2_button(fr,[0.025 0.393 0.222 0.098],"−10 Hz","ld2_frequency_delta(-10)",11,bg);
        ld2_button(fr,[0.267 0.393 0.222 0.098],"−1 Hz","ld2_frequency_delta(-1)",11,bg);
        ld2_button(fr,[0.510 0.393 0.222 0.098],"+1 Hz","ld2_frequency_delta(1)",11,bg);
        ld2_button(fr,[0.753 0.393 0.222 0.098],"+10 Hz","ld2_frequency_delta(10)",11,bg);
        LD2.ui.volt_display=ld2_text(fr,[0.025 0.223 0.95 0.130],ld2_volt_display_text(),17,%t,"center",[.04 .09 .13],[.6 1 .77]);
        ld2_button(fr,[0.025 0.061 0.45 0.115],"Matuoti U","ld2_measure_voltage()",12,bg);
        ld2_button(fr,[0.525 0.061 0.45 0.115],"Matuoti I","ld2_measure_current()",12,bg);
    else
        LD2.ui.amp_display=ld2_text(fr,[0.025 0.555 0.45 0.139],ld2_amp_display_text(),15,%t,"center",[.04 .09 .13],[.6 1 .77]);
        ld2_button(fr,[0.525 0.555 0.45 0.139],"Matuoti I","ld2_measure_current()",12,bg);
        LD2.ui.volt_display=ld2_text(fr,[0.025 0.360 0.45 0.139],ld2_volt_display_text(),15,%t,"center",[.04 .09 .13],[.6 1 .77]);
        ld2_button(fr,[0.525 0.360 0.45 0.139],"Matuoti U","ld2_measure_voltage()",12,bg);
        ld2_button(fr,[0.025 0.140 0.45 0.139],"Nuimti V zondus","ld2_remove_voltage_probes()",11,bg);
        ld2_button(fr,[0.525 0.140 0.45 0.139],"Oscilograma","ld2_plot_scope_current()",11,bg);
    end
endfunction

function ld2_render_answers()
    global LD2;
    step=LD2.state.step;
    fr=ld2_frame(LD2.ui.right,[0.025 0.155 0.95 0.387],[1 1 1]);
    title="ATSAKYMAI | vienetas prie kiekvieno lauko";
    if LD2.example_active then title="PAVYZDŽIO ATSAKYMAI – neįskaitomi"; end
    ld2_text(fr,[0.025 0.895 0.95 0.080],title,12,%t,"left",[1 1 1],[.06 .20 .34]);
    [labels,n]=ld2_answer_spec(step);
    LD2.ui.answer_edits=[]; LD2.ui.answer_step=step;
    if n>0 then
        for k=1:n
            y=0.778-(k-1)*0.106;
            label=msprintf("[A%02d.%02d] ",step,k)+labels(k);
            h=ld2_text(fr,[0.025 y 0.68 0.087],label,11,%f,"left",[1 1 1],[.1 .1 .1]);
            h.tooltipstring=label;
            e=ld2_edit(fr,[0.728 y 0.244 0.092],LD2.state.answers_text(step,k));
            e.tag=msprintf("A%02d.%02d",step,k); e.tooltipstring=label;
            LD2.ui.answer_edits=[LD2.ui.answer_edits e];
        end
    else
        if step==1 then lines=ld2_parameter_lines(LD2.cfg);
        else lines=ld2_summary_lines_for_step(step); end
        h=uicontrol(fr,"style","listbox","units","normalized","position",[0.025 0.22 0.95 0.60], ...
            "string",ld2_wrap_lines(lines,58),"fontname","Arial","fontunits","pixels","fontsize",12,"backgroundcolor",[1 1 1]);
        ld2_track(h);
        if step==12 then
            ld2_text(fr,[0.025 0.040 0.45 0.13],"[B08] Išvados – apačioje",11,%f,"left",[1 1 1],[.1 .2 .3]);
            ld2_button(fr,[0.525 0.040 0.45 0.13],"Suvestinė","ld2_show_summary_window()",12,[.93 .96 .99]);
        else
            ld2_text(fr,[0.025 0.040 0.95 0.13],"[B41] Paaiškinimas – po schema",11,%f,"left",[1 1 1],[.1 .2 .3]);
        end
    end
endfunction

function ld2_render_action_row()
    global LD2;
    fr=ld2_frame(LD2.ui.right,[0.025 0.015 0.95 0.120],[.96 .97 .98]);
    if LD2.example_active then sample="Mano darbas"; else sample="Pavyzdys"; end
    bg=[.93 .96 .99];
    ld2_button(fr,[0.000 0.555 0.318 0.42],sample,"ld2_show_solution()",11,bg);
    ld2_button(fr,[0.341 0.555 0.318 0.42],"Metodika","ld2_help_current()",11,bg);
    ld2_button(fr,[0.682 0.555 0.318 0.42],"Tikrinti etapą","ld2_check_step()",11,[.78 .93 .83]);
    ld2_button(fr,[0.000 0.025 0.318 0.42],"Atgal","ld2_prev()",11,bg);
    ld2_button(fr,[0.341 0.025 0.318 0.42],"Grafikas","ld2_plot_current()",11,bg);
    ld2_button(fr,[0.682 0.025 0.318 0.42],"Toliau","ld2_next()",11,bg);
endfunction

function [labels,n]=ld2_answer_spec(step)
    labels=emptystr(0,1);
    select step
    case 3 then labels=["XC, Ω";"|Z|, Ω";"I, mA";"UR8, V";"UC2, V";"P, mW";"φI, ° (srovės fazė)"];
    case 4 then labels=["E iš matuotų UR ir UC, V";"I = UR8/R8, mA"];
    case 6 then labels=["XL, Ω";"|Z|, Ω";"I, mA";"UR9, V";"UL1, V";"P, mW";"φI, ° (srovės fazė)"];
    case 7 then labels=["E iš matuotų UR ir UL, V";"I = UR9/R9, mA"];
    case 9 then labels=["fr teorinis, Hz";"fr iš taškų maksimumo, Hz";"Periodas T = 1000/fr, ms";"UR13 maksimumas, V"];
    case 10 then labels=["UL maksimumas, V";"UC maksimumas, V";"ULC minimumas, V";"f ties UL maksimumu, Hz";"f ties UC maksimumu, Hz";"f ties ULC minimumu, Hz"];
    case 11 then labels=["UR13 slenkstis, V";"Užfiksuotas f1, Hz";"Užfiksuotas f2, Hz";"BW = f2-f1, Hz";"Q = fr/BW"];
    end
    n=size(labels,"*");
endfunction
