// LD7 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD7.sce");
exec(perziura_root + "LD7/LD7_LOAD.sce", -1);
global LD7;
LD7 = struct();
LD7.student = student_profile(1, "Peržiūra", "TEST", "LD7");
LD7.cfg = ld7_variant_config(1);
ld7_init_state();
ld7_start();
etapai = ["1 etapas: sujungimas";"2 etapas: matavimai P1–P5";"3 etapas: vidinė varža"; ...
    "4 etapas: galia ir suderinamumas";"5 etapas: TE ir TJ";"6 etapas: išvados"];
k = x_choose(etapai, "LD7 peržiūra · pasirinkite etapą");
if k > 0 then ld7_set_step(k); end
clear perziura_root etapai k;
