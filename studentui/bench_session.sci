// Local resume files are separate from submitted reports. Keep the last two
// complete snapshots; a failed save must leave the previous snapshot intact.
function session=bench_snapshot(lab)
    global LD1 LD2;
    session=struct("format","Grandiniu-LD-session-1","lab",lab,"state",struct());
    if lab=="LD1" then
        session.cfg=LD1.cfg; session.student=LD1.student;
        for field=fieldnames(LD1)'
            if or(field==["ui" "fig" "term" "base" "cfg" "student" "demoSnapshot" "autosave_paths" "autosave_error"]) then continue; end
            session.state(field)=LD1(field);
        end
    else
        session.cfg=LD2.cfg;session.student=LD2.state.student;session.state=LD2.state;
    end
endfunction

function path=bench_save_snapshot(lab)
    session=bench_snapshot(lab);
    folder=fullfile(bench_documents(),"Juodrasciai"); if ~isdir(folder) then mkdir(folder); end
    path=fullfile(folder,lab+"-V"+msprintf("%02d",session.student.number)+"-"+bench_id()+".sod");
    temp=fullfile(TMPDIR,"ld-session-"+bench_id()+".sod");
    save(temp,"session");
    info=fileinfo(temp); n=info(1);
    if n>16*1024*1024 then error("Darbo juodraštis viršija 16 MB ribą."); end
    fd=mopen(temp,"rb"); b=mget(n,"uc",fd);mclose(fd);mdelete(temp);
    bench_core_require();p=ascii(path);
    status=call("ld_write_new",p,1,"i",size(p,"*"),2,"i",b,3,"i",size(b,"*"),4,"i","out",[1 1],5,"i");
    if status<>0 then error("Juodraštis neišsaugotas. Ankstesnis įrašas liko nepakeistas."); end
endfunction

function bench_autosave(lab)
    global LD1 LD2 BENCH_AUTOSAVE_SUSPENDED;
    if BENCH_AUTOSAVE_SUSPENDED==%t then return; end
    if lab=="LD1" then
        if ~isfield(LD1,"autosave_enabled") then return; end
        if ~LD1.autosave_enabled | LD1.demoMode then return; end
    else
        if ~isfield(LD2,"autosave_enabled") then return; end
        if ~LD2.autosave_enabled | LD2.example_active then return; end
    end
    try
        path=bench_save_snapshot(lab);
        // Retention is scoped to files created in this running session; never
        // delete another student's files or old recoverable work automatically.
        if lab=="LD1" then
            if ~isfield(LD1,"autosave_paths") then LD1.autosave_paths=emptystr(0,1); end
            LD1.autosave_paths($+1)=path;
            if size(LD1.autosave_paths,"*")>2 then mdelete(LD1.autosave_paths(1));LD1.autosave_paths(1)=[];end
            LD1.autosave_error="";
        else
            if ~isfield(LD2,"autosave_paths") then LD2.autosave_paths=emptystr(0,1); end
            LD2.autosave_paths($+1)=path;
            if size(LD2.autosave_paths,"*")>2 then mdelete(LD2.autosave_paths(1));LD2.autosave_paths(1)=[];end
            LD2.autosave_error="";
        end
    catch
        problem=strcat(lasterror()," ");
        if lab=="LD1" then LD1.autosave_error=problem;
            ld1_set_status("Nepavyko išsaugoti juodraščio.","error",problem);
        else LD2.autosave_error=problem;ld2_set_status("Nepavyko išsaugoti juodraščio: "+problem,"error");end
    end
endfunction

function session=bench_read_snapshot(path,lab)
    session=[]; info=fileinfo(path);
    if isempty(info) then error("Juodraščio failas nerastas."); end
    if info(1)>16*1024*1024 then error("Juodraščio failas per didelis.");end
    load(path,"session");
    if typeof(session)<>"st" then error("Netinkamas juodraštis.");end
    if session.format<>"Grandiniu-LD-session-1" | session.lab<>lab then error("Kito darbo arba versijos juodraštis.");end
    st=session.student; student_profile(st.number,st.name,st.group,lab);
    if lab=="LD1" then expected=ld1_variant_config(st.number); else expected=ld2_variant_config(st.number);end
    if ~isequal(session.cfg,expected) then error("Juodraščio variantas ir parametrai nesutampa.");end
    if lab=="LD1" then
        if or(size(session.state.stepQ)<>[9 3]) | session.state.step<1 | session.state.step>9 then error("Sugadinti LD1 atsakymai.");end
    else
        if or(size(session.state.answers_text)<>[12 8]) | session.state.step<1 | session.state.step>12 then error("Sugadinti LD2 atsakymai.");end
    end
endfunction

function bench_restore_snapshot(session)
    global LD1 LD2 BENCH_AUTOSAVE_SUSPENDED;
    BENCH_AUTOSAVE_SUSPENDED=%t;
    try
        if session.lab=="LD1" then
            step=session.state.step;
            LD1.cfg=session.cfg;LD1.student=session.student;
            // Rendering a stage can change transient controls; reapply saved
            // values afterwards, with power off and the original raw answers.
            LD1.step=0;
            for field=fieldnames(session.state)'
                if field=="step" then continue;end
                LD1(field)=session.state(field);
            end
            ld1_build_panel(session.state.panel);ld1_set_step(step);
            for field=fieldnames(session.state)';LD1(field)=session.state(field);end
            LD1.powerOn=%f;LD1.demoMode=%f;LD1.pendingTerminal="";
            ld1_restore_step_inputs(step);ld1_apply_meter_mode_quiet(LD1.meterMode);ld1_set_power_quiet(%f);
            LD1.ui.vrSlider.value=LD1.VR1;LD1.ui.vrText.string=string(LD1.VR1)+" Ω";
            LD1.ui.studentIdentity.string=student_caption(LD1.student);
            ld1_update_actual_values();ld1_redraw_panel();ld1_student_sync();
        else
            LD2.cfg=session.cfg;LD2.state=session.state;LD2.state.power=%f;
            LD2.example_active=%f;LD2.ui.answer_step=0;LD2.ui.answer_edits=[];
            ld2_reset_live_readings(ld2_phase_for_step(LD2.state.step));ld2_render_step();
        end
    catch
        BENCH_AUTOSAVE_SUSPENDED=%f;error(lasterror());
    end
    BENCH_AUTOSAVE_SUSPENDED=%f;
endfunction

function bench_open_snapshot(lab)
    path=uigetfile("*.sod",fullfile(bench_documents(),"Juodrasciai"),"Atverti vietinį darbo juodraštį");
    if isempty(path) then return;end
    if stripblanks(path)=="" then return;end
    try session=bench_read_snapshot(path,lab);bench_restore_snapshot(session);
    catch messagebox(lasterror(),"Juodraštis neatvertas","error");end
endfunction
