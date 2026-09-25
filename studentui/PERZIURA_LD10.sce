// LD10 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD10.sce");
exec(perziura_root + "LD10/LD10_LOAD.sce", -1);
global LD10;
LD10 = struct();
LD10.student = student_profile(1, "Peržiūra", "TEST", "LD10");
LD10.cfg = ld10_variant_config(1);
ld10_init_state();
ld10_start();
etapai = ["1 etapas: lygiagretus sujungimas ir f0";"2 etapas: 0,5·f0 srovės";"3 etapas: f0 srovės (rezonansas)"; ...
    "4 etapas: 2·f0 srovės";"5 etapas: srovių trikampiai";"6 etapas: išvados"];
k = x_choose(etapai, "LD10 peržiūra · pasirinkite etapą");
if k > 0 then ld10_set_step(k); end
clear perziura_root etapai k;
