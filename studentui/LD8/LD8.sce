// LD8 · Nuosekliojo, lygiagretaus ir mišriojo jungimo tyrimas.
mode(-1);
ld8_dir = get_absolute_file_path("LD8.sce");
exec(ld8_dir + "LD8_LOAD.sce", -1);
ld8_student_main(ld8_dir + "../");
clear ld8_dir;
