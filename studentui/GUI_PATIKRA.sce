// Run in a separate Scilab process: opens and closes only its own test windows.
mode(-1);
root=get_absolute_file_path("GUI_PATIKRA.sce");
try
    if ~isdir(root+"tests/results") then mkdir(root+"tests/results"); end
    exec(root+"LD1/LD1_LOAD.sce",-1); exec(root+"LD2/LD2_LOAD.sce",-1);
    exec(root+"tests/workflows.sci",-1);
    for n=[1 17 64]
        bench_ld1_workflow(n,root);
        bench_ld2_workflow(n,root,%t);
    end
    verdict="GUI_PASS: LD1 9 ir LD2 12 etapų, variantai 1/17/64, mygtukų funkcijos, matavimai, duomenų išlaikymas, eksportas";
    mputl(verdict,root+"GUI_PATIKRA_LAST.txt"); disp(verdict); exit(0);
catch
    verdict="GUI_FAIL: "+strcat(lasterror()," | ");
    mputl(verdict,root+"GUI_PATIKRA_LAST.txt"); disp(verdict); exit(1);
end
