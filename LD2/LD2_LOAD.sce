// Load definitions only. No experiment data or figures are created here.
LD2_ROOT=get_absolute_file_path("LD2_LOAD.sce");
ld2_previous_funcprot=funcprot(); funcprot(0);
try
    exec(fullfile(LD2_ROOT,"ld2_config.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_model.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_ids.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_variants.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_utils.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_wiring.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_observations.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_storage.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_plots.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_method.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_gui.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_callbacks.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_review.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_report.sci"),-1);
    exec(fullfile(LD2_ROOT,"ld2_selftest.sci"),-1);
catch
    funcprot(ld2_previous_funcprot);
    error(lasterror());
end
funcprot(ld2_previous_funcprot);
