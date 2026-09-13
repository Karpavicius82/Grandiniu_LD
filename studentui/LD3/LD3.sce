// LD3 · Omo dėsnio veikimas realioje elektros grandinėje (3 laboratorinis).
mode(-1);
ld3_dir = get_absolute_file_path("LD3.sce");
exec(ld3_dir + "LD3_LOAD.sce", -1);
ld3_student_main(ld3_dir + "../");
clear ld3_dir;
