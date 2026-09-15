// LD6 peržiūros paleidimas (dėstytojui): bet kuris etapas iškart.
mode(-1);
ld6_dir = get_absolute_file_path("PERZIURA_LD6.sce") + "LD6/";
exec(ld6_dir + "LD6_LOAD.sce", -1);
global LD6;
LD6 = struct();
LD6.student = student_profile(1, "Peržiūra", "TEST", "LD6");
LD6.cfg = ld6_variant_config(1);
ld6_init_state();
ld6_start();
k = x_choose(["1 etapas – sujungimas";"2 etapas – teorija ir pirmas taškas";"3 etapas – padėčių P1 ir P3 matavimai"; ...
              "4 etapas – skaičiavimai";"5 etapas – srovė ir dalis";"6 etapas – išvados"], ...
             "LD6 · peržiūros režimas – kurį etapą atverti?");
if k > 0 then ld6_set_step(k); end
