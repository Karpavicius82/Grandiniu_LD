// LD4 · Tiesinių rezistorių tyrimas.
mode(-1);
ld4_dir = get_absolute_file_path("LD4.sce");
exec(ld4_dir + "LD4_LOAD.sce", -1);
ld4_student_main(ld4_dir + "../");
clear ld4_dir;
