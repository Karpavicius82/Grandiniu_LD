function d=ld2_method_data(step)
    if step>=1 & step<=4 then d=ld2_method_data_1_4(step);
    elseif step>=5 & step<=8 then d=ld2_method_data_5_8(step);
    elseif step>=9 & step<=12 then d=ld2_method_data_9_12(step);
    else error("Etapas turi būti nuo 1 iki 12."); end
endfunction
