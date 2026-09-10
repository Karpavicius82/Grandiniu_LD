function ld1_create_gui()
    global LD1;
    f=createWindow();
    f.axes_size=[1420 800];
    f.figure_name=LD1.cfg.title+"  •  Scilab 2025.1";
    f.resize="on";
    LD1.fig=f;

    LD1.ui.header=uicontrol(f,"style","text","units","normalized", ..
        "position",[0.018 0.938 0.964 0.049],"string",LD1.cfg.title, ..
        "fontsize",19,"fontweight","bold","horizontalalignment","center", ..
        "backgroundcolor",[0.15 0.27 0.42],"foregroundcolor",[1 1 1]);

    nav=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.891 0.964 0.039],"backgroundcolor",[0.87 0.91 0.96],"relief","flat");
    LD1.ui.navFrame=nav;
    LD1.ui.progress=uicontrol(nav,"style","text","units","normalized", ..
        "position",[0.01 0.10 0.14 0.80],"string","", ..
        "fontsize",10,"fontweight","bold","horizontalalignment","left", ..
        "backgroundcolor",[0.87 0.91 0.96],"foregroundcolor",[0.12 0.22 0.34]);
    LD1.ui.stepButtons=list();
    for k=1:9
        xx=0.155+(k-1)*0.050;
        LD1.ui.stepButtons(k)=uicontrol(nav,"style","pushbutton","units","normalized", ..
            "position",[xx 0.12 0.043 0.76],"string",string(k),"fontsize",9,"fontweight","bold", ..
            "callback","ld1_jump_step("+string(k)+")");
    end
    LD1.ui.review=uicontrol(nav,"style","checkbox","units","normalized", ..
        "position",[0.625 0.08 0.36 0.84],"string","DĖSTYTOJO / PERŽIŪROS REŽIMAS – laisva navigacija", ..
        "fontsize",9,"value",0,"backgroundcolor",[0.87 0.91 0.96],"callback","ld1_review_toggle()");

    LD1.ui.circuitFrame=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.105 0.600 0.770],"backgroundcolor",[1 1 1],"relief","groove");
    LD1.ui.boardHandles=list();
    LD1.ui.resultsTable=uicontrol(LD1.ui.circuitFrame,"style","table","units","normalized", ..
        "position",[0.04 0.10 0.92 0.78], ..
        "string",["Bandymas" "Formulė / kilmė" "Skaičiuota" "Multimetro rodmuo" "Vertinimas"]);
    LD1.ui.resultsTable.visible="off";

    ctrl=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.632 0.105 0.350 0.770],"backgroundcolor",[0.97 0.97 0.97],"relief","groove");
    LD1.ui.ctrlFrame=ctrl;

    inf=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.735 0.93 0.245],"backgroundcolor",[1 1 1],"relief","groove");
    LD1.ui.instructionFrame=inf;
    LD1.ui.instructionTitle=uicontrol(inf,"style","text","units","normalized", ..
        "position",[0.03 0.81 0.94 0.15],"string","", ..
        "fontsize",13,"fontweight","bold","horizontalalignment","left", ..
        "verticalalignment","middle","backgroundcolor",[1 1 1],"foregroundcolor",[0.07 0.12 0.18]);
    LD1.ui.instructionLine=list();
    iy=[0.65 0.51 0.37 0.23 0.09];
    for k=1:5
        LD1.ui.instructionLine(k)=uicontrol(inf,"style","text","units","normalized", ..
            "position",[0.03 iy(k) 0.94 0.125],"string","", ..
            "fontsize",10,"horizontalalignment","left","verticalalignment","middle", ..
            "backgroundcolor",[1 1 1],"foregroundcolor",[0.10 0.12 0.15]);
    end

    sf=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.330 0.93 0.385],"backgroundcolor",[0.97 0.97 0.97],"relief","groove");
    LD1.ui.standFrame=sf;
    ld1_label(sf,[0.03 0.91 0.94 0.07],"STENDO VALDYMAS",13,%t);
    ld1_label(sf,[0.03 0.81 0.25 0.065],"Maitinimas:",10,%t);
    LD1.ui.sourceDisplay=ld1_label(sf,[0.30 0.81 0.28 0.065],"0 V DC",10,%f);
    LD1.ui.power=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.65 0.795 0.32 0.085],"string","IŠJUNGTA", ..
        "fontsize",10,"fontweight","bold","backgroundcolor",[0.94 0.82 0.82], ..
        "callback","ld1_toggle_power()");

    ld1_label(sf,[0.03 0.70 0.14 0.06],"VR1:",10,%t);
    LD1.ui.vrText=ld1_label(sf,[0.18 0.70 0.28 0.06],"1000 Ω",11,%t);
    LD1.ui.vrSlider=uicontrol(sf,"style","slider","units","normalized", ..
        "position",[0.03 0.625 0.94 0.055],"min",LD1.cfg.VR1_min, ..
        "max",LD1.cfg.VR1_max,"value",1000,"sliderstep",[LD1.cfg.VR1_step 100], ..
        "snaptoticks","on","callback","ld1_vr_changed()");
    LD1.ui.vr0=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.545 0.27 0.065],"string","0 Ω","fontsize",9,"callback","ld1_set_vr(0)");
    LD1.ui.vr500=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.365 0.545 0.27 0.065],"string","500 Ω","fontsize",9,"callback","ld1_set_vr(500)");
    LD1.ui.vr1000=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.70 0.545 0.27 0.065],"string","1 kΩ","fontsize",9,"callback","ld1_set_vr(1000)");

    ld1_label(sf,[0.03 0.455 0.25 0.06],"Multimetras:",10,%t);
    LD1.ui.modeA=uicontrol(sf,"style","radiobutton","units","normalized", ..
        "position",[0.28 0.452 0.24 0.065],"string","A (DC)","fontsize",10, ..
        "groupname","meter","value",1,"callback","ld1_meter_mode(""A"")");
    LD1.ui.modeV=uicontrol(sf,"style","radiobutton","units","normalized", ..
        "position",[0.56 0.452 0.24 0.065],"string","V (DC)","fontsize",10, ..
        "groupname","meter","value",0,"callback","ld1_meter_mode(""V"")");
    LD1.ui.meterDisplay=uicontrol(sf,"style","text","units","normalized", ..
        "position",[0.03 0.355 0.94 0.085],"string","NEPRIJUNGTA", ..
        "fontsize",14,"fontweight","bold","horizontalalignment","center", ..
        "backgroundcolor",[0.06 0.09 0.07],"foregroundcolor",[0.55 1.00 0.58]);

    LD1.ui.measure=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.265 0.45 0.070],"string","MATUOTI", ..
        "fontsize",10,"fontweight","bold","callback","ld1_measure()");
    LD1.ui.checkWiring=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.265 0.45 0.070],"string","PATIKRINTI SUJUNGIMĄ", ..
        "fontsize",9,"callback","ld1_check_wiring()");
    LD1.ui.undoWire=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.180 0.45 0.065],"string","ATŠAUKTI LAIDĄ", ..
        "fontsize",9,"callback","ld1_remove_last_wire()");
    LD1.ui.clearWires=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.180 0.45 0.065],"string","IŠVALYTI LAIDUS", ..
        "fontsize",9,"callback","ld1_clear_wires()");
    LD1.ui.wiringGuide=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.03 0.095 0.45 0.065],"string","KAIP SUJUNGTI", ..
        "fontsize",9,"fontweight","bold","callback","ld1_show_wiring_guide()");
    LD1.ui.restoreStage=uicontrol(sf,"style","pushbutton","units","normalized", ..
        "position",[0.52 0.095 0.45 0.065],"string","ATKURTI ETAPO STENDĄ", ..
        "fontsize",8,"fontweight","bold","callback","ld1_restore_current_stage_board()");

    af=uicontrol(ctrl,"style","frame","units","normalized", ..
        "position",[0.035 0.105 0.93 0.205],"backgroundcolor",[0.98 0.98 0.98],"relief","groove");
    LD1.ui.answerFrame=af;
    ld1_label(af,[0.03 0.84 0.94 0.13],"JŪSŲ ATSAKYMAS",12,%t);
    LD1.ui.qLabel=list(); LD1.ui.qEdit=list();
    qy=[0.63 0.41 0.19];
    for k=1:3
        LD1.ui.qLabel(k)=uicontrol(af,"style","text","units","normalized", ..
            "position",[0.03 qy(k) 0.46 0.14],"string","", ..
            "fontsize",9,"horizontalalignment","left","verticalalignment","middle", ..
            "backgroundcolor",[0.98 0.98 0.98]);
        LD1.ui.qEdit(k)=uicontrol(af,"style","edit","units","normalized", ..
            "position",[0.52 qy(k) 0.30 0.15],"string","","fontsize",9);
    end
    LD1.ui.typeSeries=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.03 0.04 0.29 0.14],"string","Nuosekli","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.typeParallel=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.34 0.04 0.32 0.14],"string","Lygiagreti","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.typeMixed=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.69 0.04 0.25 0.14],"string","Mišri","fontsize",9,"groupname","ctype","value",0);
    LD1.ui.yesNoQuestion=uicontrol(af,"style","text","units","normalized", ..
        "position",[0.03 0.025 0.56 0.15],"string","", ..
        "fontsize",8,"fontweight","bold","horizontalalignment","left", ..
        "verticalalignment","middle","backgroundcolor",[0.98 0.98 0.98]);
    LD1.ui.yes=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.62 0.035 0.16 0.14],"string","Taip","fontsize",9,"groupname","yesno","value",0);
    LD1.ui.no=uicontrol(af,"style","radiobutton","units","normalized", ..
        "position",[0.80 0.035 0.16 0.14],"string","Ne","fontsize",9,"groupname","yesno","value",0);

    LD1.ui.checkStep=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.035 0.060 0.93 0.035],"string","PATIKRINTI IR UŽFIKSUOTI ETAPĄ", ..
        "fontsize",9,"fontweight","bold","callback","ld1_check_step()");
    LD1.ui.prev=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.035 0.010 0.18 0.035],"string","← ATGAL","fontsize",8,"callback","ld1_prev_step()");
    LD1.ui.solution=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.225 0.010 0.25 0.035],"string","PAVYZDYS / SPRENDIMAS","fontsize",8,"fontweight","bold","callback","ld1_toggle_solution()");
    LD1.ui.help=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.485 0.010 0.22 0.035],"string","TEORIJA","fontsize",8,"callback","ld1_show_help()");
    LD1.ui.next=uicontrol(ctrl,"style","pushbutton","units","normalized", ..
        "position",[0.715 0.010 0.25 0.035],"string","TOLIAU →","fontsize",8,"callback","ld1_next_step()");

    LD1.ui.statusFrame=uicontrol(f,"style","frame","units","normalized", ..
        "position",[0.018 0.012 0.785 0.077],"backgroundcolor",[0.90 0.93 0.97],"relief","flat");
    LD1.ui.statusMain=uicontrol(LD1.ui.statusFrame,"style","text","units","normalized", ..
        "position",[0.01 0.52 0.98 0.42],"string","", ..
        "fontsize",10,"fontweight","bold","horizontalalignment","left","verticalalignment","middle", ..
        "backgroundcolor",[0.90 0.93 0.97],"foregroundcolor",[0.10 0.18 0.28]);
    LD1.ui.statusFix=uicontrol(LD1.ui.statusFrame,"style","text","units","normalized", ..
        "position",[0.01 0.07 0.98 0.40],"string","", ..
        "fontsize",9,"horizontalalignment","left","verticalalignment","middle", ..
        "backgroundcolor",[0.90 0.93 0.97],"foregroundcolor",[0.10 0.18 0.28]);
    LD1.ui.restart=uicontrol(f,"style","pushbutton","units","normalized", ..
        "position",[0.818 0.020 0.164 0.055],"string","PRADĖTI IŠ NAUJO", ..
        "fontsize",10,"callback","ld1_restart()");
endfunction
