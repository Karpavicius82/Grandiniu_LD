// LD12 · Nuosekliai sujungtos RLC grandinės: trikampiai ir įtampų rezonansas.
mode(-1);
ld12_dir = get_absolute_file_path("LD12.sce");
exec(ld12_dir + "LD12_LOAD.sce", -1);
ld12_student_main(ld12_dir + "../");
clear ld12_dir;
