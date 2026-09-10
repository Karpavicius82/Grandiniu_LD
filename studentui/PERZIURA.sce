// Preview parameters are examples only, not a replacement for the real LD1 kit values.
mode(-1);
root=get_absolute_file_path("PERZIURA.sce");
funcprot(0);
exec(root+"student_style.sci",-1);
exec(root+"student_profile.sci",-1);
for name=["ld1_config.sci" "ld1_utils.sci" "ld1_circuit.sci" "ld1_gui.sci" "ld1_callbacks.sci" "ld1_student.sci"]
    exec(root+"LD1/"+name,-1);
end
global LD1;
LD1=struct(); LD1.base=root+"LD1/"; LD1.cfg=ld1_config();
LD1.cfg.R1=1000; LD1.cfg.R2=1000; LD1.cfg.R3=1000;
ld1_init_state(); ld1_init_terminals(); ld1_create_gui(); ld1_build_panel("series"); ld1_set_step(1);
LD1.fig.figure_name="LD1 peržiūra · pavyzdinės R1, R2, R3 = 1000 Ω";
mprintf("LD1_STUDENT_GUI_READY\n");
