// LD11 · Nuosekliai sujungtos RLC grandinės: trikampiai ir įtampų rezonansas.
mode(-1);
ld11_dir = get_absolute_file_path("LD11.sce");
exec(ld11_dir + "LD11_LOAD.sce", -1);
ld11_student_main(ld11_dir + "../");
clear ld11_dir;
