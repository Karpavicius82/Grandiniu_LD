// LD9 · Nuosekliai sujungtos RLC grandinės: trikampiai ir įtampų rezonansas.
mode(-1);
ld9_dir = get_absolute_file_path("LD9.sce");
exec(ld9_dir + "LD9_LOAD.sce", -1);
ld9_student_main(ld9_dir + "../");
clear ld9_dir;
