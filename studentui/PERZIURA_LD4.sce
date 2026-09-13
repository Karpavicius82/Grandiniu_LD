// LD4 peržiūros paleidimas (dėstytojui): bet kuris etapas iškart.
mode(-1);
ld4_dir = get_absolute_file_path("PERZIURA_LD4.sce") + "LD4/";
exec(ld4_dir + "LD4_LOAD.sce", -1);
global LD4;
LD4 = struct();
LD4.student = student_profile(1, "Peržiūra", "TEST", "LD4");
LD4.cfg = ld4_variant_config(1);
ld4_init_state();
ld4_start();
k = x_choose(["1 etapas – sujungimas";"2 etapas – teorija ir pirmas taškas";"3 etapas – R2 matavimai"; ...
              "4 etapas – skaičiavimai";"5 etapas – charakteristika";"6 etapas – nuoseklus jungimas";"7 etapas – išvados"], ...
             "LD4 · peržiūros režimas – kurį etapą atverti?");
if k > 0 then ld4_set_step(k); end
