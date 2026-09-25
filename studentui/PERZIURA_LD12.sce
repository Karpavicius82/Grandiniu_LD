// LD12 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD12.sce");
exec(perziura_root + "LD12/LD12_LOAD.sce", -1);
global LD12;
LD12 = struct();
LD12.student = student_profile(1, "Peržiūra", "TEST", "LD12");
LD12.cfg = ld12_variant_config(1);
ld12_init_state();
ld12_start();
etapai = ["1 etapas: žvaigždės sujungimas ir Uf";"2 etapas: žvaigždės matavimai";"3 etapas: trikampio sujungimas ir Uf"; ...
    "4 etapas: trikampio matavimai";"5 etapas: Il, PΔ, PY";"6 etapas: išvados"];
k = x_choose(etapai, "LD12 peržiūra · pasirinkite etapą");
if k > 0 then ld12_set_step(k); end
clear perziura_root etapai k;
