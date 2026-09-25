// LD11 peržiūra be registracijos dialogo.
mode(-1);
perziura_root = get_absolute_file_path("PERZIURA_LD11.sce");
exec(perziura_root + "LD11/LD11_LOAD.sce", -1);
global LD11;
LD11 = struct();
LD11.student = student_profile(1, "Peržiūra", "TEST", "LD11");
LD11.cfg = ld11_variant_config(1);
ld11_init_state();
ld11_start();
etapai = ["1 etapas: rišlės sujungimas ir cos φ0";"2 etapas: matavimai be Ck (U, I, P)";"3 etapas: teorinis Ck"; ...
    "4 etapas: sujungti Ck ir matuoti";"5 etapas: S2, Q2, cos φ2, ΔS";"6 etapas: išvados"];
k = x_choose(etapai, "LD11 peržiūra · pasirinkite etapą");
if k > 0 then ld11_set_step(k); end
clear perziura_root etapai k;
