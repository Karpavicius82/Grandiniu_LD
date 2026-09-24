// LD8 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD8.sce");
exec(perziura_root + "LD8/LD8_LOAD.sce", -1);
global LD8;
LD8 = struct();
LD8.student = student_profile(1, "Peržiūra", "TEST", "LD8");
LD8.cfg = ld8_variant_config(1);
ld8_init_state();
ld8_start();
etapai = ["1 etapas: nuoseklioji grandinė";"2 etapas: varžų skaičiavimai";"3 etapas: lygiagretė grandinė"; ...
    "4 etapas: mišrioji grandinė";"5 etapas: šakų srovės";"6 etapas: išvados"];
k = x_choose(etapai, "LD8 peržiūra · pasirinkite etapą");
if k > 0 then ld8_set_step(k); end
clear perziura_root etapai k;
