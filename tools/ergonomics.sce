mode(-1);
root=getenv("LD_ERGO_RUNTIME")+"/"; out=getenv("LD_ERGO_OUT")+"/"; source=getenv("LD_ERGO_SOURCE")+"/";
exec(source+"tools/ergonomics.sci",-1);
function ergo_capture(f,name)
    root=getenv("LD_ERGO_RUNTIME")+"/"; out=getenv("LD_ERGO_OUT")+"/";
    f.figure_name="ERGONOMIKA "+name; show_window(f); sleep(350);
    cmd="/usr/bin/python3 """+root+"capture_window.py"" ""ERGONOMIKA "+name+""" """+out+name+".png""";
    status=host(cmd); assert_checkequal(status,0);
endfunction
try
    exec(root+"LD1/LD1_LOAD.sce",-1); exec(root+"LD2/LD2_LOAD.sce",-1); exec(root+"LD3/LD3_LOAD.sce",-1);
    global LD1 LD2 LD3;
    fd=mopen(out+"geometry.tsv","wt");
    sizes=[1280 800;1280 720;1600 900];
    for dim=1:size(sizes,1)
        suffix=msprintf("-%dx%d",sizes(dim,1),sizes(dim,2));
        LD1=struct("base",root+"tests/results/","cfg",ld1_variant_config(64), ...
            "student",student_profile(64,"Ergonomikos Patikra","TEST","LD1")); ld1_start(); geometry_size(LD1.fig,sizes(dim,:));
        for st=1:9
            ld1_set_step(st); label="LD1-E"+string(st)+suffix;
            geometry_dump(LD1.fig,label+"-before",fd);
            if st<9 then
                if st<5 then LD1.wires=ld1_series_canonical_wires();
                elseif st<8 then LD1.wires=ld1_parallel_voltage_canonical_wires();
                else LD1.wires=ld1_parallel_kcl_canonical_wires(); end
                ld1_redraw_panel(); geometry_dump(LD1.fig,label+"-wired",fd);
            end
            if dim==1 & or(st==[1 5 8]) then ergo_capture(LD1.fig,"LD1-E"+string(st)); end
        end
        delete(LD1.fig);
        cfg=ld2_variant_config(64);
        LD2=struct("root",root,"cfg",cfg,"state",ld2_initial_state(cfg),"ui", ...
            struct("headless",%f,"suppress_render",%f,"dynamic",[],"answer_edits",[],"answer_step",0,"test_no_dialogs",%t), ...
            "example_active",%f,"example_backup",struct());
        LD2.state.student=student_profile(64,"Ergonomikos Patikra","TEST","LD2"); ld2_build_gui(); geometry_size(LD2.ui.figure,sizes(dim,:));
        for st=1:12
            LD2.state.step=st; phase=ld2_phase_for_step(st); label="LD2-E"+string(st)+suffix;
            if phase<>"OVERVIEW" then ld2_set_phase_connections(phase,emptystr(0,2)); end
            ld2_render_step(); geometry_dump(LD2.ui.figure,label+"-before",fd);
            if phase<>"OVERVIEW" then
                ld2_set_phase_connections(phase,ld2_solution_connections(st)); ld2_render_step();
                if st==9 then
                    // Inspect real, populated readouts at resonance, not only
                    // the short idle dash. Voltage/current still use the model.
                    LD2.state.freq=1/(2*%pi*sqrt(cfg.L3*cfg.C4)); LD2.state.power=%t;
                    ld2_measure_current(); ld2_measure_voltage();
                end
                geometry_dump(LD2.ui.figure,label+"-wired",fd);
                allowed=ld2_allowed_pairs(st);
                for pair=1:size(allowed,1)-1
                    if allowed(pair,1)<>"VM_H" then continue; end
                    conn=[ld2_required_main(phase);allowed(pair,:);allowed(pair+1,:)];
                    ld2_set_phase_connections(phase,conn); ld2_render_step();
                    geometry_dump(LD2.ui.figure,label+"-probe"+string(pair),fd);
                end
            end
            if dim==1 & or(st==[4 8 9 10]) then ergo_capture(LD2.ui.figure,"LD2-E"+string(st)); end
        end
        delete(LD2.ui.figure);
        LD3=struct("cfg",ld3_variant_config(64),"student",student_profile(64,"Ergonomikos Patikra","TEST","LD3"),"ui",struct("headless",%f));
        ld3_start(); geometry_size(LD3.fig,sizes(dim,:));
        for st=1:6
            LD3.step=st; LD3.wires=ld3_canonical_wires(); ld3_render_stage(); label="LD3-E"+string(st)+suffix;
            geometry_dump(LD3.fig,label,fd);
            // Repeated redraw must retain an exact, bounded number of controls.
            count=size(LD3.ui.circuitFrame.children,"*"); dyn=size(LD3.ui.dynamic,"*");
            for redraw=1:10; ld3_render_wires(); end
            assert_checkequal(size(LD3.ui.circuitFrame.children,"*"),count);
            assert_checkequal(size(LD3.ui.dynamic,"*"),dyn);
            LD3.wires=LD3.wires(:,[2 1]); ld3_render_wires();
            assert_checkequal(size(LD3.ui.circuitFrame.children,"*"),count);
            geometry_dump(LD3.fig,label+"-reversed",fd);
            if dim==1 & or(st==[1 4]) then ergo_capture(LD3.fig,"LD3-E"+string(st)); end
        end
        delete(LD3.fig);
    end
    mclose(fd);
    disp("ERGONOMICS_PASS: all 27 stages, three client sizes, probe permutations, stable LD3 redraw"); exit(0);
catch
    disp("ERGONOMICS_FAIL: "+strcat(lasterror()," | ")); exit(1);
end
