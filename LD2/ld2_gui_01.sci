// ============================================================================
// LD2 GUI. Sąmoningai naudojami tik uicontrol elementai pagrindiniame lange.
// Grafikai atidaromi atskiruose languose, kad Scilab 2025.1 nesumaišytų
// axes ir uicontrol koordinačių.
// ============================================================================

function ld2_main(root)
    global LD2;
    oldid=-1;
    try oldid=LD2.ui.figure.figure_id; catch end
    if or(winsid()==oldid) then
        pick=x_choose(["[D01] PALIKTI DABARTINĮ STENDĄ";"[D02] UŽDARYTI IR PALEISTI NAUJĄ"], ...
            "Pirmiau [B05] išsaugokite ankstesnį darbą.");
        if pick<>2 then return; end
        delete(LD2.ui.figure);
    end
    cfg=ld2_variant_config(1); state=ld2_initial_state(cfg);
    LD2=struct("root",root,"cfg",cfg,"state",state, ...
        "ui",struct("dummy",0,"headless",%f,"suppress_render",%f), ...
        "example_active",%f,"example_backup",struct("dummy",0));
    ld2_build_gui();
    ld2_go_step(1,%t);
    ld2_choose_student();
endfunction

function ld2_build_gui()
    global LD2;
    f=figure("default_axes","off","dockable","off","menubar","none","toolbar","none");
    f.figure_name="LD2 v2.0 | RC • RL • RLC | 64 variantai";
    wh=[1500 880];
    try
        sc=get(0,"screensize_px");
        if size(sc,"*")==4 then wh=[min([1500 sc(3)-35]) min([880 sc(4)-95])]; end
    catch end
    f.axes_size=wh; f.figure_position=[10 10];
    f.infobar_visible="off"; f.menubar_visible="off"; f.toolbar_visible="off";
    LD2.ui.figure=f; LD2.ui.dynamic=[]; LD2.ui.term_handles=struct("dummy",0);
    LD2.ui.answer_edits=[]; LD2.ui.answer_step=0;
    LD2.ui.choice_yes=[]; LD2.ui.choice_no=[];
    uicontrol(f,"style","text","units","normalized","position",[0.015 0.945 0.97 0.045], ...
        "string","LD2  |  KINTAMOSIOS SROVĖS GRANDINĖS  |  RC · RL · RLC", ...
        "fontname","Arial","fontunits","pixels","fontsize",18,"fontweight","bold", ...
        "backgroundcolor",[0.08 0.21 0.34],"foregroundcolor",[1 1 1]);
    LD2.ui.identity=uicontrol(f,"style","text","units","normalized","position",[0.015 0.900 0.97 0.034], ...
        "string","[B01] Pasirinkite studentą ir variantą.","fontname","Arial","fontunits","pixels", ...
        "fontsize",14,"fontweight","bold","horizontalalignment","left", ...
        "backgroundcolor",[0.90 0.95 0.98],"foregroundcolor",[0.06 0.20 0.32]);
    nav=uicontrol(f,"style","frame","units","normalized","position",[0.015 0.848 0.97 0.042], ...
        "backgroundcolor",[0.94 0.96 0.98]);
    LD2.ui.step_buttons=[];
    for k=1:12
        b=uicontrol(nav,"style","pushbutton","units","normalized", ...
            "position",[0.008+(k-1)*0.052 0.07 0.048 0.85], ...
            "string",msprintf("E%02d",k),"tag",msprintf("E%02d",k), ...
            "tooltipstring",ld2_step_title(k),"fontname","Arial","fontunits","pixels","fontsize",12, ...
            "callback",msprintf("ld2_nav_action(%d)",k),"margins",[0 0 0 0]);
        LD2.ui.step_buttons=[LD2.ui.step_buttons b];
    end
    LD2.ui.teacher=uicontrol(nav,"style","checkbox","units","normalized", ...
        "position",[0.648 0.10 0.34 0.80],"string","[V02] Laisva navigacija / peržiūra", ...
        "tag","V02","fontname","Arial","fontunits","pixels","fontsize",12, ...
        "callback","ld2_teacher_toggle()","backgroundcolor",[0.94 0.96 0.98]);
    LD2.ui.stand=uicontrol(f,"style","frame","units","normalized","position",[0.015 0.140 0.594 0.694], ...
        "backgroundcolor",[1 1 1]);
    LD2.ui.right=uicontrol(f,"style","frame","units","normalized","position",[0.621 0.140 0.364 0.694], ...
        "backgroundcolor",[0.96 0.97 0.98]);
    ld2_fixed_button(f,[0.015 0.068 0.172 0.058],"Studentas / variantas","ld2_choose_student()");
    ld2_fixed_button(f,[0.197 0.068 0.143 0.058],"Išsaugoti darbą","ld2_save_work()");
    ld2_fixed_button(f,[0.350 0.068 0.139 0.058],"Atverti darbą","ld2_load_work()");
    ld2_fixed_button(f,[0.499 0.068 0.220 0.058],"GENERUOTI ATASKAITĄ","ld2_report_ui()");
    ld2_fixed_button(f,[0.729 0.068 0.124 0.058],"Išvados","ld2_edit_conclusions()");
    ld2_fixed_button(f,[0.863 0.068 0.122 0.058],"Iš naujo","ld2_restart()");
    LD2.ui.status=uicontrol(f,"style","text","units","normalized","position",[0.015 0.009 0.97 0.048], ...
        "string","Paruošta.","fontname","Arial","fontunits","pixels","fontsize",12, ...
        "horizontalalignment","left","backgroundcolor",[0.90 0.95 0.98]);
endfunction

function ld2_track(h)
    global LD2;
    LD2.ui.dynamic = [LD2.ui.dynamic h];
endfunction

function ld2_clear_dynamic()
    global LD2;
    if ~isfield(LD2.ui,"dynamic") then LD2.ui.dynamic=[]; end
    n = size(LD2.ui.dynamic, "*");
    if n > 0 then
        for k = n:-1:1
            delete(LD2.ui.dynamic(k));
        end
    end
    LD2.ui.dynamic = [];
    LD2.ui.term_handles = struct("dummy",0);
    LD2.ui.answer_edits = [];
    LD2.ui.answer_step = 0;
    LD2.ui.choice_yes = [];
    LD2.ui.choice_no = [];
endfunction

function h = ld2_frame(parent, pos, bg)
    h = uicontrol(parent, "style","frame", "units","normalized", ...
        "position",pos, "backgroundcolor",bg);
    ld2_track(h);
endfunction

function h = ld2_text(parent, pos, str, fs, bold, align, bg, fg)
    h = uicontrol(parent, "style","text", "units","normalized", ...
        "position",pos, "string",str, "fontname","Arial", "fontunits","pixels", "fontsize",max([11 fs]), ...
        "horizontalalignment",align, "backgroundcolor",bg, ...
        "foregroundcolor",fg);
    if bold then h.fontweight = "bold"; end
    ld2_track(h);
endfunction

function h=ld2_button(parent,pos,str,cb,fs,bg)
    [code,label,hint]=ld2_button_info(cb);
    h=uicontrol(parent,"style","pushbutton","units","normalized","position",pos, ...
        "string","["+code+"] "+str,"tag",code,"tooltipstring",hint, ...
        "fontname","Arial","fontunits","pixels","fontsize",max([11 fs]), ...
        "margins",[1 1 1 1],"callback",msprintf("ld2_action(""%s"")",code),"backgroundcolor",bg);
    ld2_track(h);
endfunction

function h = ld2_edit(parent, pos, value)
    h = uicontrol(parent, "style","edit", "units","normalized", ...
        "position",pos, "string",value, "fontname","Arial", "fontunits","pixels", "fontsize",13, ...
        "horizontalalignment","right", "backgroundcolor",[1 1 1]);
    ld2_track(h);
endfunction

function ld2_render_step()
    global LD2;
    if isfield(LD2.ui,"suppress_render") then
        if LD2.ui.suppress_render then return; end
    end
    if isfield(LD2.ui,"headless") then
        if LD2.ui.headless then return; end
    end
    ld2_save_answers();
    ld2_clear_dynamic();
    ld2_render_instructions();
    ld2_render_controls();
    ld2_render_answers();
    ld2_render_action_row();
    ld2_render_stand();
    ld2_update_nav_colors();
    ld2_identity_banner();
endfunction

function ld2_render_instructions()
    global LD2;
    p=LD2.ui.stand; step=LD2.state.step;
    ttl=ld2_step_title(step);
    if LD2.example_active then ttl="PAVYZDYS | "+ttl; end
    ld2_text(p,[0.025 0.953 0.95 0.034],ttl,15,%t,"left",[1 1 1],[0.06 0.20 0.34]);
    rows=ld2_wrap_lines(ld2_instruction_lines(step),100);
    h=uicontrol(p,"style","listbox","units","normalized","position",[0.025 0.755 0.95 0.183], ...
        "string",rows,"fontname","Arial","fontunits","pixels","fontsize",12,"backgroundcolor",[0.97 0.985 1]);
    ld2_track(h);
endfunction
