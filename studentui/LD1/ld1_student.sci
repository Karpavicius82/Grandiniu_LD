// Student interface. The v1.7 circuit solver and experiment checks remain in use.
function ld1_student_main(root)
    global LD1;
    if typeof(LD1)=="st" then
        if isfield(LD1,"fig") then
            if is_handle_valid(LD1.fig) then show_window(LD1.fig); return; end
        end
    end
    bench_core_require();
    [ok,st,cfg]=student_enroll("LD1");
    if ~ok then return; end
    LD1=struct("base",root,"cfg",cfg,"student",st,"assessment",%t);
    student_remember(st);
    ld1_start();
    LD1.autosave_enabled=%t;
endfunction

function ld1_student_details()
    global LD1;
    if ~isfield(LD1,"student") then LD1.student=student_empty("LD1"); end
    pick=messagebox([student_caption(LD1.student);student_parameter_lines("LD1",LD1.cfg)], ...
        "Studentas ir priskirtos reikšmės","info",["Grįžti" "Keisti duomenis"],"modal");
    if pick<>2 then return; end
    [ok,st,cfg]=student_enroll("LD1",LD1.student);
    if ~ok then return; end
    if st.number<>LD1.student.number then
        pick=messagebox("Kitas variantas pradės naują darbą. Dabartinius rezultatus galite išsaugoti CSV.", ...
            "Keisti variantą?","question",["Atšaukti" "Pradėti naują"],"modal");
        if pick<>2 then return; end
    end
    ld1_apply_profile(st,cfg);
endfunction

function ld1_apply_profile(st,cfg)
    global LD1;
    ld1_save_step_inputs();
    changed=st.number<>LD1.student.number;
    LD1.student=st;
    if changed then
        LD1.cfg=cfg; ld1_init_state(); ld1_init_terminals();
        ld1_build_panel("series"); ld1_set_step(1);
    end
    LD1.ui.studentIdentity.string=student_caption(st);
    student_remember(st);
endfunction

function ld1_create_gui()
    global LD1;
    ld1_create_gui_classic();
    LD1.fig.axes_size=[1280 800];
    LD1.fig.figure_name="LD1 · Nuolatinės srovės stendas";
    LD1.fig.background=color(246,248,249);
    LD1.ui.header.position=[0.03 0.925 0.68 0.05];
    LD1.ui.header.string="LD1  /  Nuolatinės srovės grandinės";
    LD1.ui.header.horizontalalignment="left";
    LD1.ui.header.backgroundcolor=[0.965 0.973 0.977];
    LD1.ui.header.foregroundcolor=[0.13 0.19 0.23];
    LD1.ui.header.fontunits="pixels"; LD1.ui.header.fontsize=22;
    LD1.ui.navFrame.visible="off";
    LD1.ui.circuitFrame.position=[0.025 0.12 0.655 0.77];
    LD1.ui.circuitFrame.relief="flat";
    LD1.ui.ctrlFrame.position=[0.70 0.12 0.275 0.77];
    LD1.ui.ctrlFrame.backgroundcolor=[1 1 1]; LD1.ui.ctrlFrame.relief="flat";
    LD1.ui.standFrame.visible="off";
    LD1.ui.instructionFrame.position=[0.07 0.67 0.86 0.30];
    LD1.ui.instructionFrame.relief="flat";
    LD1.ui.instructionTitle.position=[0 0.68 1 0.28];
    LD1.ui.instructionTitle.fontunits="pixels"; LD1.ui.instructionTitle.fontsize=20;
    for k=1:5; LD1.ui.instructionLine(k).visible="off"; end
    LD1.ui.instructionLine(1).position=[0 0.01 1 0.64];
    LD1.ui.instructionLine(1).fontunits="pixels"; LD1.ui.instructionLine(1).fontsize=14;
    LD1.ui.instructionLine(1).verticalalignment="top";
    LD1.ui.answerFrame.position=[0.07 0.19 0.86 0.45];
    LD1.ui.answerFrame.relief="flat"; LD1.ui.answerFrame.backgroundcolor=[1 1 1];
    for h=LD1.ui.answerFrame.children'
        h.fontunits="pixels"; h.fontsize=14; h.backgroundcolor=[1 1 1];
    end
    for k=1:3
        yy=0.69-(k-1)*0.17;
        LD1.ui.qLabel(k).position=[0 yy 0.58 0.13];
        LD1.ui.qEdit(k).position=[0.61 yy 0.39 0.13];
        LD1.ui.qEdit(k).callback="ld1_student_answer_changed()";
        LD1.ui.qEdit(k).backgroundcolor=[0.94 0.96 0.96]; LD1.ui.qEdit(k).relief="solid";
    end
    choices=[LD1.ui.typeSeries LD1.ui.typeParallel LD1.ui.typeMixed];
    for k=1:3
        choices(k).position=[0 0.65-(k-1)*0.18 1 0.15];
        choices(k).callback="ld1_student_answer_changed()";
    end
    LD1.ui.yesNoQuestion.position=[0 0.16 1 0.16];
    LD1.ui.yesNoQuestion.fontsize=12;
    LD1.ui.yes.position=[0 0.015 0.46 0.12]; LD1.ui.no.position=[0.5 0.015 0.46 0.12];
    LD1.ui.yes.callback="ld1_student_answer_changed()";
    LD1.ui.no.callback="ld1_student_answer_changed()";
    LD1.ui.checkStep.position=[0.07 0.085 0.86 0.075];
    LD1.ui.checkStep.callback="ld1_student_primary()";
    LD1.ui.checkStep.fontunits="pixels"; LD1.ui.checkStep.fontsize=15;
    LD1.ui.checkStep.backgroundcolor=[0.08 0.39 0.37]; LD1.ui.checkStep.foregroundcolor=[1 1 1];
    LD1.ui.prev.position=[0.07 0.015 0.37 0.045]; LD1.ui.prev.string="← Atgal";
    LD1.ui.prev.fontunits="pixels"; LD1.ui.prev.fontsize=13;
    // STENDO ŽEMĖLAPIS [B13] – tas pats registras, kaip klasikiniame stende.
    LD1.ui.standMap=student_button(LD1.ui.prev.parent,[0.47 0.015 0.46 0.045],"STENDO ŽEMĖLAPIS","ld1_show_stand_map()");
    ld1_register_button(LD1.ui.standMap,"ld1_show_stand_map()");
    LD1.ui.standMap.fontunits="pixels"; LD1.ui.standMap.fontsize=11;
    LD1.ui.next.visible="off"; LD1.ui.solution.visible="off"; LD1.ui.help.visible="off";
    LD1.ui.restart.visible="off";
    LD1.ui.studentHelp=student_button(LD1.fig,[0.87 0.93 0.105 0.044],"Pagalba", "ld1_student_help()");
    LD1.ui.studentProgress=student_text(LD1.fig,[0.705 0.93 0.15 0.044],"",14,%f,[0.965 0.973 0.977]);
    LD1.ui.statusFrame.position=[0.025 0.02 0.95 0.075];
    LD1.ui.statusMain.fontunits="pixels"; LD1.ui.statusMain.fontsize=13;
    LD1.ui.statusFix.fontunits="pixels"; LD1.ui.statusFix.fontsize=12;
    LD1.ui.studentReady=%t;
    LD1.ui.studentIdentity=student_text(LD1.fig,[0.03 0.895 0.94 0.025],"",12,%f,[0.965 0.973 0.977]);
    if isfield(LD1,"student") then LD1.ui.studentIdentity.string=student_caption(LD1.student); end
    LD1.fig.visible="on";
endfunction

function ld1_set_instruction(title,lines)
    global LD1;
    LD1.studentDetail=lines;
    titles=["Sujunkite grandinę";"Apskaičiuokite";"Išmatuokite srovę";"Pakartokite bandymą"; ...
        "Sujunkite dvi šakas";"Išmatuokite įtampą";"Pakeiskite varžą";"Bendra srovė";"Jūsų rezultatai"];
    tips=["Sujunkite kilpą: [T01]→[T03]; [T04]→[T09]; [T10]→[T11]; [T12]→[T02]. Režimas A (DC) [B07]. Pabaigoje pasirinkite NUOSEKLI."; ...
        "VR1 = 1000 Ω [B04]. Rbendr = R1 + VR1 rašykite į [A02.01], o I = E/Rbendr (mA) – į [A02.02]. Matuoti nereikia."; ...
        "Įjunkite 10 V [B01], režimas A (DC) [B07], spauskite MATUOTI [B06] ir palyginkite rodmenį su savo skaičiavimu."; ...
        "VR1 = 500 Ω [B03]. Apskaičiuokite Rbendr [A04.01] ir I (mA) [A04.02], tada MATUOTI [B06] ir palyginkite."; ...
        "Šaltinis [T01]→[T13], [T02]→[T17]; R3 [T14]-[T18]; R2+VR1 [T15]-[T19]; voltmetras [T16]-[T20]. Visa seka: KAIP SUJUNGTI [B05]."; ...
        "VR1 = 1000 Ω [B04]. Rbendr apskaičiuokite į [A06.01], įjunkite [B01], MATUOTI [B06] (režimas V [B08])."; ...
        "Pakeiskite VR1, pvz., į 500 Ω [B03] arba slankikliu [V01], tada vėl MATUOTI [B06]. Ar UAB pasikeitė?"; ...
        "Į bendrą laidą prieš A: [T01]→[T11], COM [T12]→ATARGET. I1→[A08.01], I2→[A08.02], I=I1+I2→[A08.03]."; ...
        "Čia surinkti jūsų skaičiavimai ir matavimai. Neatliktus etapus rasite per Pagalba → Etapai."];
    LD1.ui.instructionTitle.string=student_wrap(titles(LD1.step),24);
    for k=2:5; LD1.ui.instructionLine(k).visible="off"; end
    tip=tips(LD1.step);
    if LD1.step==8 & isfield(LD1,"kclTargetA") & exists("ld1_terminal_code")==1 then
        tip=strsubst(tip,"ATARGET",ld1_terminal_button_text(LD1.kclTargetA)+" ["+ld1_terminal_code(LD1.kclTargetA)+"]");
    end
    LD1.ui.instructionLine(1).string=student_wrap(tip,37);
    LD1.ui.instructionLine(1).visible="on";
    LD1.ui.instructionFrame.position=[0.07 0.67 0.86 0.30];
    LD1.ui.standFrame.visible="off";
endfunction

function ld1_student_sync()
    global LD1;
    if ~isfield(LD1,"ui") then return; end
    if ~isfield(LD1.ui,"studentReady") then return; end
    LD1.ui.studentProgress.string=string(LD1.step)+" / 9 etapas";
    LD1.ui.standFrame.visible="off";
    LD1.ui.instructionFrame.position=[0.07 0.67 0.86 0.30];
    LD1.ui.next.visible="off";
    LD1.ui.checkStep.enable="on";
    if LD1.demoMode then
        ld1_button_string(LD1.ui.checkStep,"Grįžti į savo darbą");
        LD1.ui.studentProgress.string="Pavyzdys · "+string(LD1.step)+" / 9";
    elseif LD1.step==9 then ld1_button_string(LD1.ui.checkStep,"Išsaugoti ataskaitą");
    elseif isfield(LD1,"assessment") & LD1.assessment then ld1_button_string(LD1.ui.checkStep,"Įrašyti ir toliau →");
    elseif LD1.done(LD1.step) then ld1_button_string(LD1.ui.checkStep,"Toliau →");
    else ld1_button_string(LD1.ui.checkStep,"Patikrinti");
    end
endfunction

function ld1_student_primary()
    global LD1;
    if LD1.demoMode then ld1_toggle_solution();
    elseif LD1.step==9 then bench_export_current("LD1");
    elseif isfield(LD1,"assessment") & LD1.assessment then
        ld1_save_step_inputs();bench_autosave("LD1");ld1_set_step(LD1.step+1);
    elseif LD1.done(LD1.step) then ld1_next_step();
    else ld1_check_step(); end
    ld1_student_sync();
endfunction

function ld1_student_answer_changed()
    global LD1;
    if LD1.demoMode then return; end
    LD1.done(LD1.step)=%f;
    ld1_save_step_inputs(); bench_autosave("LD1"); ld1_student_sync();
endfunction

function ld1_student_help()
    global LD1;
    if LD1.demoMode then ld1_toggle_solution(); ld1_student_sync(); return; end
    n=x_choose(["Kaip sujungti šį stendą";"Teorija";"Parodyti pavyzdį"; ...
        "Atkurti šio etapo stendą";"Etapai";"Pradėti darbą iš naujo";"Studentas ir priskirtos reikšmės";"Išsaugoti ataskaitą dėstytojui";"Atverti juodraštį";"Atsiskaitymo / mokymosi režimas"],"Pagalba");
    select n
    case 1 then ld1_show_wiring_guide();
    case 2 then ld1_show_help();
    case 3 then ld1_toggle_solution();
    case 4 then ld1_restore_current_stage_board();
    case 5 then
        options=emptystr(9,1);
        for k=1:9
            state="Neatlikta"; if LD1.done(k) then state="Atlikta"; end
            options(k)=string(k)+" etapas · "+state;
        end
        k=x_choose(options,"Etapai · atsakymai išlieka");
        if k>0 then
            if k<=LD1.step | LD1.done(k) | LD1.skipped(k) then ld1_set_step(k);
            else ld1_set_status("Šio etapo dar nepasiekėte.","info","Dabartinį etapą patikrinkite ir spauskite Toliau."); end
        end
    case 6 then ld1_restart();
    case 7 then ld1_student_details();
    case 8 then bench_export_current("LD1");
    case 9 then bench_open_snapshot("LD1");
    case 10 then bench_mode("LD1");
    end
    ld1_student_sync();
endfunction

function ld1_student_source(pos)
    global LD1;
    bg=[0.94 0.97 0.97]; fr=student_frame(LD1.ui.circuitFrame,pos,bg); ld1_track_board_handle(fr);
    student_text(fr,[0.09 0.70 0.82 0.20],"ŠALTINIS",13,%t,bg);
    LD1.ui.sourceDisplay=student_text(fr,[0.09 0.43 0.82 0.22],"10 V DC",20,%t,bg);
    caption="Įjungti"; if LD1.powerOn then caption="Išjungti"; end
    LD1.ui.power=student_button(fr,[0.09 0.10 0.82 0.25],caption,"ld1_toggle_power()");
    ld1_register_button(LD1.ui.power,"ld1_toggle_power()");
    LD1.ui.power.enable="on";
    if LD1.demoMode | LD1.step==1 | LD1.step==2 | LD1.step==5 then LD1.ui.power.enable="off"; end
endfunction

function ld1_student_resistor(pos,name,value,variable)
    global LD1;
    bg=[0.97 0.97 0.95]; fr=student_frame(LD1.ui.circuitFrame,pos,bg); ld1_track_board_handle(fr);
    student_text(fr,[0.09 0.57 0.82 0.30],name,17,%t,bg);
    h=student_text(fr,[0.09 0.16 0.82 0.30],string(value)+" Ω",16,%f,bg);
    if variable then
        LD1.ui.vrText=h;
        if LD1.step==7 & ~LD1.demoMode then
            h.position=[0.09 0.36 0.82 0.24];
            hb=student_button(fr,[0.09 0.06 0.82 0.26],"500 Ω","ld1_set_vr(500)");
            ld1_register_button(hb,"ld1_set_vr(500)");
        end
    end
endfunction

function ld1_student_meter(pos)
    global LD1;
    bg=[0.93 0.96 0.96]; fr=student_frame(LD1.ui.circuitFrame,pos,bg); ld1_track_board_handle(fr);
    name="AMPERMETRAS"; if LD1.meterMode=="V" then name="VOLTMETRAS"; end
    student_text(fr,[0.07 0.74 0.86 0.20],name,12,%t,bg);
    reading="— "+LD1.meterMode;
    if ~isnan(LD1.lastMeasurement) then reading=ld1_num(LD1.lastMeasurement,3)+" "+LD1.lastMeasurementUnit; end
    LD1.ui.meterDisplay=student_text(fr,[0.07 0.40 0.86 0.28],reading,20,%t,bg);
    LD1.ui.meterDisplay.horizontalalignment="center";
    LD1.ui.measure=student_button(fr,[0.07 0.08 0.86 0.25],"Matuoti","ld1_measure()",%t);
    ld1_register_button(LD1.ui.measure,"ld1_measure()");
    if LD1.step==1 | LD1.step==2 | LD1.step==5 | LD1.demoMode then LD1.ui.measure.visible="off"; end
endfunction

function ld1_draw_series_board()
    global LD1;
    ld1_board_text([0.04 0.89 0.9 0.055],"Nuoseklioji grandinė",17,%t);
    ld1_student_source([0.04 0.39 0.18 0.25]);
    ld1_student_resistor([0.40 0.68 0.20 0.14],"R1",LD1.cfg.R1,%f);
    ld1_student_resistor([0.72 0.43 0.23 0.22],"VR1",LD1.VR1,%t);
    ld1_student_meter([0.33 0.17 0.34 0.20]);
endfunction

function ld1_draw_parallel_board()
    global LD1;
    ld1_board_text([0.04 0.92 0.9 0.045],"Lygiagrečioji grandinė",17,%t);
    ld1_board_segment(0.30,0.83,0.92,0.83,[0.41 0.49 0.51]);
    ld1_board_segment(0.30,0.15,0.92,0.15,[0.41 0.49 0.51]);
    ld1_board_text([0.27 0.845 0.08 0.04],"A",16,%t);
    ld1_board_text([0.27 0.09 0.08 0.04],"B",16,%t);
    ld1_student_source([0.035 0.37 0.18 0.25]);
    ld1_student_resistor([0.43 0.41 0.15 0.19],"R3",LD1.cfg.R3,%f);
    ld1_student_resistor([0.65 0.57 0.17 0.12],"R2",LD1.cfg.R2,%f);
    ld1_student_resistor([0.65 0.27 0.17 0.18],"VR1",LD1.VR1,%t);
    if LD1.step==8 then ld1_student_meter([0.27 0.48 0.145 0.26]);
    else ld1_student_meter([0.84 0.36 0.145 0.26]); end
endfunction

function ld1_set_parallel_meter_layout(forCurrent)
    if forCurrent then ld1_set_xy("M_P",25,62); ld1_set_xy("M_N",42,62);
    else ld1_set_xy("M_P",91.0,67); ld1_set_xy("M_N",91.0,31); end
endfunction

function ld1_build_panel(kind)
    global LD1;
    LD1.panel=kind; LD1.pendingTerminal=""; LD1.wires=emptystr(0,2);
    LD1.term.xy=%nan*ones(size(LD1.term.ids,"*"),2);
    if kind=="series" then
        LD1.term.active=["SRC_P";"SRC_N";"R1_1";"R1_2";"VR1_1";"VR1_2";"M_P";"M_N"];
        ld1_set_xy("SRC_P",24,60); ld1_set_xy("SRC_N",24,43);
        ld1_set_xy("R1_1",38,75); ld1_set_xy("R1_2",62,75);
        ld1_set_xy("VR1_1",83.5,68); ld1_set_xy("VR1_2",83.5,40);
        ld1_set_xy("M_P",70,27); ld1_set_xy("M_N",30,27);
    else
        LD1.term.active=LD1.term.ids(find(LD1.term.ids<>"R1_1" & LD1.term.ids<>"R1_2"));
        ld1_set_xy("SRC_P",23,62); ld1_set_xy("SRC_N",23,37);
        xs=[32 50.5 73.5 91];
        for k=1:4
            ld1_set_xy("NODE_A"+string(k),xs(k),83);
            ld1_set_xy("NODE_B"+string(k),xs(k),15);
        end
        ld1_set_xy("R3_1",50.5,64); ld1_set_xy("R3_2",50.5,37);
        ld1_set_xy("R2_1",73.5,73); ld1_set_xy("R2_2",73.5,54);
        ld1_set_xy("VR1_1",73.5,49); ld1_set_xy("VR1_2",73.5,23);
        ld1_set_parallel_meter_layout(LD1.step==8);
    end
    ld1_redraw_panel();
endfunction

function ld1_redraw_panel()
    global LD1;
    ld1_redraw_panel_classic();
    if LD1.step==1 | LD1.step==5 | LD1.step==8 then
        h=student_button(LD1.ui.circuitFrame,[0.04 0.025 0.24 0.05],"Atšaukti laidą","ld1_remove_last_wire()");
        ld1_register_button(h,"ld1_remove_last_wire()");
        ld1_track_board_handle(h);
        if LD1.demoMode then h.visible="off"; end
        if LD1.pendingTerminal=="" then tip="Laidas: spauskite du gnybtus.";
        else tip="Dabar pasirinkite antrą gnybtą."; end
        ld1_board_text([0.34 0.025 0.62 0.05],tip,13,%f);
    end
    ld1_student_sync();
endfunction
