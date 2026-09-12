// LD3 peržiūros paleidimas (dėstytojui): bet kuris etapas iškart.
mode(-1);
ld3_dir = get_absolute_file_path("PERZIURA_LD3.sce") + "LD3/";
exec(ld3_dir + "LD3_LOAD.sce", -1);
global LD3;
LD3 = struct();
LD3.student = student_profile(1, "Peržiūra", "TEST", "LD3");
LD3.cfg = ld3_variant_config(1);
ld3_init_state();
ld3_start();
k = x_choose(["1 etapas – sujungimas";"2 etapas – teorija ir pirmas taškas";"3 etapas – matavimai"; ...
              "4 etapas – skaičiavimai";"5 etapas – charakteristika";"6 etapas – išvados"], ...
             "LD3 · peržiūros režimas – kurį etapą atverti?");
if k > 0 then ld3_set_step(k); end
