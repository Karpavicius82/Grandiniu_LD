// LD7 · Įtampos, srovės ir galios suderinamumo tyrimas.
mode(-1);
ld7_dir = get_absolute_file_path("LD7.sce");
exec(ld7_dir + "LD7_LOAD.sce", -1);
ld7_student_main(ld7_dir + "../");
clear ld7_dir;
