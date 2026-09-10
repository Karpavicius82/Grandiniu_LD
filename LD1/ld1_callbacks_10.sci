function yes = ld1_yes_selected()
    global LD1;
    yes=(LD1.ui.yes.value<>0);
endfunction

function selected = ld1_any_yesno_selected()
    global LD1;
    selected=(LD1.ui.yes.value<>0 | LD1.ui.no.value<>0);
endfunction

function ld1_mark_done(msg)
    global LD1;
    LD1.done(LD1.step)=%t;
    LD1.skipped(LD1.step)=%f;
    ld1_save_step_inputs();
    ld1_update_step_navigation();
    ld1_set_status(msg,"ok","Etapas išsaugotas. Galite spausti TOLIAU arba vėliau grįžti – įvesti duomenys liks.");
endfunction
