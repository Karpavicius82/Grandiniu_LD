// Internal launch regression: only the registration dialogs are simulated.
// Each actual STENDAS -> LDn.sce -> student_enroll -> GUI path is exercised.
mode(-1); funcprot(0);
root=getenv("LD_ENTRY_RUNTIME")+"/";
global ENTRY_CHOICE ENTRY_CANCEL LD1 LD2 LD3;
function n=x_choose(varargin)
    global ENTRY_CHOICE; n=ENTRY_CHOICE;
endfunction
function values=x_mdialog(varargin)
    global ENTRY_CANCEL;
    if ENTRY_CANCEL then values=[];
    else values=["17";"Ergonomikos Patikra";"TEST"]; end
endfunction
function n=messagebox(varargin)
    if varargin(2)<>"Jūsų priskirtos reikšmės" then error("Netikėtas dialogas: "+strcat(string(varargin(1))," ")); end
    n=1;
endfunction
try
    for lab=1:3
        ENTRY_CHOICE=lab; ENTRY_CANCEL=%t; LD1=struct(); LD2=struct(); LD3=struct();
        exec(root+"STENDAS.sce",-1);
        if lab==1 then assert_checkfalse(isfield(LD1,"fig"));
        elseif lab==2 then assert_checkfalse(isfield(LD2,"ui"));
        else assert_checkfalse(isfield(LD3,"fig")); end
        ENTRY_CANCEL=%f; exec(root+"STENDAS.sce",-1);
        if lab==1 then f=LD1.fig; st=LD1.student;
        elseif lab==2 then f=LD2.ui.figure; st=LD2.state.student;
        else f=LD3.fig; st=LD3.student; end
        assert_checkequal(st.number,17); assert_checkequal(st.name,"Ergonomikos Patikra");
        assert_checkequal(st.group,"TEST"); assert_checkequal(f.visible,"on");
        if lab==3 then
            f.figure_name="ERGONOMIKA LD3-start"; show_window(f); sleep(350);
            cmd="/usr/bin/python3 """+root+"capture_window.py"" ""ERGONOMIKA LD3-start"" """+getenv("LD_ERGO_OUT")+"/LD3-start.png""";
            assert_checkequal(host(cmd),0);
        end
        mprintf("PASS LD%d: registracijos atšaukimas, variantas 17, vardas, grupė, tikras meniu ir langas\n",lab);
        delete(f);
    end
    disp("ENTRYPOINTS_PASS"); exit(0);
catch
    disp("ENTRYPOINTS_FAIL: "+strcat(lasterror()," | ")); exit(1);
end
