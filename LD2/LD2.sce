// Entry point for Scilab 2025.1. Run only this file to open the laboratory.
LD2_ROOT=get_absolute_file_path("LD2.sce");
exec(fullfile(LD2_ROOT,"LD2_LOAD.sce"),-1);
global LD2;
[ld2_ok,ld2_log]=ld2_run_selftest(%f);
try mputl(ld2_log,fullfile(LD2_ROOT,"LD2_SELFTEST_LAST.txt")); catch end
if ~ld2_ok then
    disp(ld2_log);
    error("LD2 savitikra nepraėjo. Žr. LD2_SELFTEST_LAST.txt. Failų nemaišykite su v1.x.");
end
ld2_main(LD2_ROOT);
