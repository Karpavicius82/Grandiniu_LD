// Full native suite: 64 configurations, 64 complete workflows, report/session tests.
LD2_ROOT=get_absolute_file_path("LD2_SELFTEST.sce");
exec(fullfile(LD2_ROOT,"LD2_LOAD.sce"),-1);
global LD2;
[ld2_ok,ld2_log]=ld2_run_selftest(%t);
mputl(ld2_log,fullfile(LD2_ROOT,"LD2_SELFTEST_FULL.txt"));
disp(ld2_log);
if ~ld2_ok then error("LD2 full selftest: FAIL. See LD2_SELFTEST_FULL.txt."); end
