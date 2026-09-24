// LD9 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD9.sce");
exec(perziura_root + "LD9/LD9_LOAD.sce", -1);
global LD9;
LD9 = struct();
LD9.student = student_profile(1, "Peržiūra", "TEST", "LD9");
LD9.cfg = ld9_variant_config(1);
ld9_init_state();
ld9_start();
etapai = ["1 etapas: sujungimas ir f0";"2 etapas: 0,5·f0 matavimai";"3 etapas: f0 matavimai"; ...
    "4 etapas: 2·f0 matavimai";"5 etapas: trikampiai";"6 etapas: išvados"];
k = x_choose(etapai, "LD9 peržiūra · pasirinkite etapą");
if k > 0 then ld9_set_step(k); end
clear perziura_root etapai k;
