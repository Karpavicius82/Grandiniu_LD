// LD10 · Nuosekliai sujungtos RLC grandinės: trikampiai ir įtampų rezonansas.
mode(-1);
ld10_dir = get_absolute_file_path("LD10.sce");
exec(ld10_dir + "LD10_LOAD.sce", -1);
ld10_student_main(ld10_dir + "../");
clear ld10_dir;
