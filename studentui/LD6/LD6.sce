// LD6 · Tiesinių rezistorių tyrimas.
mode(-1);
ld6_dir = get_absolute_file_path("LD6.sce");
exec(ld6_dir + "LD6_LOAD.sce", -1);
ld6_student_main(ld6_dir + "../");
clear ld6_dir;
