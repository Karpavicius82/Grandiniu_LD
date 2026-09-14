// LD5 · Tiesinių rezistorių tyrimas.
mode(-1);
ld5_dir = get_absolute_file_path("LD5.sce");
exec(ld5_dir + "LD5_LOAD.sce", -1);
ld5_student_main(ld5_dir + "../");
clear ld5_dir;
