// LD4 · Omo dėsnio veikimas realioje elektros grandinėje (3 laboratorinis).
mode(-1);
ld4_dir = get_absolute_file_path("LD4.sce");
exec(ld4_dir + "LD4_LOAD.sce", -1);
ld4_student_main(ld4_dir + "../");
clear ld4_dir;
