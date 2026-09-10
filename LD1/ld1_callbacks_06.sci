function ld1_restore_solution_state()
    global LD1;
    S=LD1.demoSnapshot;
    LD1.demoMode=%f;
    if LD1.panel<>S.panel then
        ld1_build_panel(S.panel);
    end
    LD1.savedSeriesWires=S.savedSeriesWires;
    LD1.savedParallelWires=S.savedParallelWires;
    LD1.savedParallelVoltageWires=S.savedParallelVoltageWires;
    LD1.savedParallelVoltageVR=S.savedParallelVoltageVR;
    LD1.kclPrepared=S.kclPrepared;
    LD1.kclTargetA=S.kclTargetA;
    LD1.wires=S.wires;
    LD1.VR1=S.VR1;
    LD1.ui.vrSlider.value=S.VR1;
    LD1.ui.vrText.string=string(S.VR1)+" Ω";
    ld1_apply_meter_mode_quiet(S.meterMode);
    ld1_set_power_quiet(S.powerOn);
    LD1.pendingTerminal=S.pendingTerminal;
    LD1.lastMeasurement=S.lastMeasurement;
    LD1.lastMeasurementUnit=S.lastMeasurementUnit;
    LD1.lastMeasurementStep=S.lastMeasurementStep;
    for k=1:3
        LD1.ui.qEdit(k).string=S.q(k);
    end
    LD1.ui.typeSeries.value=S.typeSeries;
    LD1.ui.typeParallel.value=S.typeParallel;
    LD1.ui.typeMixed.value=S.typeMixed;
    LD1.ui.yes.value=S.yes;
    LD1.ui.no.value=S.no;
    LD1.ui.instructionTitle.string=S.instructionTitle;
    for k=1:5
        LD1.ui.instructionLine(k).string=S.instructionLines(k);
        if S.instructionLines(k)=="" then
            ld1_show(LD1.ui.instructionLine(k),%f);
        else
            ld1_show(LD1.ui.instructionLine(k),%t);
        end
    end
    LD1.ui.resultsTable.string=S.resultsString;
    LD1.ui.checkStep.string=S.checkStepString;
    LD1.ui.solution.string="PAVYZDYS / SPRENDIMAS";
    ld1_update_actual_values();
    if ~isnan(LD1.lastMeasurement) then
        LD1.ui.meterDisplay.string=ld1_num(LD1.lastMeasurement,3)+" "+LD1.lastMeasurementUnit;
    else
        ld1_refresh_meter_idle_display();
    end
    ld1_set_solution_lock(%f);
    if LD1.step<9 then ld1_redraw_panel(); end
    ld1_set_status("Grąžintas jūsų darbas – pavyzdys nieko nepakeitė.","ok","Dabar galite atkartoti matytą jungimą ir skaičiavimus savo stende.");
endfunction
