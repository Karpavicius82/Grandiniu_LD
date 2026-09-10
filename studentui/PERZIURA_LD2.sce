mode(-1);
exec(get_absolute_file_path("PERZIURA_LD2.sce")+"LD2/LD2_LOAD.sce",-1);
ld2_main(LD2_ROOT);
ld2_go_step(2,%t);
mprintf("LD2_STUDENT_GUI_READY\n");
