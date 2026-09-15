// ============================================================================
// LD6 pagalbinės funkcijos: statusas, skaičių skaitymas, headless apsaugos.
// ============================================================================

function ld6_set_status(msg, kind, hint)
    global LD6;
    if argn(2) < 3 then hint = ""; end
    if argn(2) < 2 then kind = "info"; end
    if isfield(LD6, "ui") then
        if isfield(LD6.ui, "headless") then
            if LD6.ui.headless then return; end
        end
        if isfield(LD6.ui, "statusMain") & is_handle_valid(LD6.ui.statusMain) then
            LD6.ui.statusMain.string = msg;
        end
        if isfield(LD6.ui, "statusFix") & is_handle_valid(LD6.ui.statusFix) then
            LD6.ui.statusFix.string = hint;
        end
    end
endfunction

function v = ld6_parse_number(s)
    v = %nan;
    if exists("bench_safe_number") == 1 then
        v = bench_safe_number(s);
    end
endfunction

function s = ld6_trim(s)
    s = stripblanks(s);
end

function ok = ld6_valid_index(n, max)
    ok = (n >= 1 & n <= max);
endfunction
