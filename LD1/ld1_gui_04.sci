function ld1_update_terminal_highlight()
    ld1_redraw_panel();
endfunction

function ld1_hide_all_answers()
    global LD1;
    for k=1:3
        ld1_show(LD1.ui.qLabel(k),%f);
        ld1_show(LD1.ui.qEdit(k),%f);
        LD1.ui.qEdit(k).string="";
    end
    ld1_show(LD1.ui.typeSeries,%f); ld1_show(LD1.ui.typeParallel,%f); ld1_show(LD1.ui.typeMixed,%f);
    ld1_show(LD1.ui.yesNoQuestion,%f);
    ld1_show(LD1.ui.yes,%f); ld1_show(LD1.ui.no,%f);
    LD1.ui.typeSeries.value=0; LD1.ui.typeParallel.value=0; LD1.ui.typeMixed.value=0;
    LD1.ui.yes.value=0; LD1.ui.no.value=0;
endfunction

function ld1_show_numeric_field(k,label)
    global LD1;
    LD1.ui.qLabel(k).string=label;
    ld1_show(LD1.ui.qLabel(k),%t);
    ld1_show(LD1.ui.qEdit(k),%t);
endfunction

function ld1_show_yes_no(question)
    global LD1;
    LD1.ui.yesNoQuestion.string=question;
    ld1_show(LD1.ui.yesNoQuestion,%t);
    ld1_show(LD1.ui.yes,%t);
    ld1_show(LD1.ui.no,%t);
endfunction
