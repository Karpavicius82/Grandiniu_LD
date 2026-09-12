// LD3 · Omo dėsnio veikimas realioje elektros grandinėje (3 laboratorinis).
mode(-1);
ld3_dir = get_absolute_file_path("LD3.sce");
exec(ld3_dir + "LD3_LOAD.sce", -1);
global LD3;
LD3 = struct();
LD3.root = ld3_dir + "../";
clear ld3_dir;
st = student_enroll("LD3");
if st == [] then exit; end
LD3.student = st;
LD3.cfg = ld3_variant_config(st.number);
ld3_init_state();
ld3_start();
