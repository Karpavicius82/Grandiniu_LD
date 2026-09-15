function cfg=ld6_variant_config(number)
    if ~ld6_valid_index(number,64) then error("Eilės numeris turi būti nuo 1 iki 64."); end
    voltages=[3;4;5;6;7;8;10;12]; nominal=[100;120;150;180;220;270;330;390];
    row=floor((number-1)/8)+1; column=modulo(number-1,8)+1; deviation=modulo(number,11)-5;
    cfg=struct("E1",9,"E2",voltages(column),"Rnom",nominal(row), ...
        "R",round(nominal(row)*(1+deviation/100)*10)/10,"r1",10,"r2",10);
endfunction

function [valid,why]=ld6_validate_config(cfg)
    valid=%f; why="Netinkamos priskirtos reikšmės.";
    if typeof(cfg)<>"st" then return; end
    for field=["E1" "E2" "R" "Rnom" "r1" "r2"]
        if ~isfield(cfg,field) then return; end
        value=cfg(field);
        if type(value)<>1 | size(value,"*")<>1 then return; end
        if ~isreal(value) | isnan(value) | isinf(value) then return; end
        if value<=0 then return; end
    end
    if cfg.E1<>9 | cfg.r1<>10 | cfg.r2<>10 then return; end
    if ~or(cfg.E2==[3 4 5 6 7 8 10 12]) | ~or(cfg.Rnom==[100 120 150 180 220 270 330 390]) then return; end
    if abs(cfg.R/cfg.Rnom-1)>0.0501 then return; end
    valid=%t; why="";
endfunction
