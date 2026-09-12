mode(-1);
bench_root=get_absolute_file_path("STENDAS.sce");
bench_choice=x_choose(["LD1 · Nuolatinės srovės grandinės";"LD2 · RC, RL ir RLC grandinės";"LD3 · Omo dėsnio veikimas realioje grandinėje";"Dėstytojui · automatinis ataskaitų vertinimas"],"Pasirinkite laboratorinį darbą");
if bench_choice==1 then exec(bench_root+"LD1/LD1.sce",-1); end
if bench_choice==2 then exec(bench_root+"LD2/LD2.sce",-1); end
if bench_choice==3 then exec(bench_root+"LD3/LD3.sce",-1); end

if bench_choice==4 then exec(bench_root+"DESTYTOJUI.sce",-1); end
