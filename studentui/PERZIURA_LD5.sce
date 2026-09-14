// LD5 peržiūros paleidimas (dėstytojui): bet kuris etapas iškart.
mode(-1);
ld5_dir = get_absolute_file_path("PERZIURA_LD5.sce") + "LD5/";
exec(ld5_dir + "LD5_LOAD.sce", -1);
global LD5;
LD5 = struct();
LD5.student = student_profile(1, "Peržiūra", "TEST", "LD5");
LD5.cfg = ld5_variant_config(1);
ld5_init_state();
ld5_start();
k = x_choose(["1 etapas – sujungimas";"2 etapas – teorija ir pirmas taškas";"3 etapas – R2 matavimai"; ...
              "4 etapas – skaičiavimai";"5 etapas – charakteristika";"6 etapas – nuoseklus jungimas";"7 etapas – išvados"], ...
             "LD5 · peržiūros režimas – kurį etapą atverti?");
if k > 0 then ld5_set_step(k); end
