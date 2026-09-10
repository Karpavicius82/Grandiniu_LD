// LD2 v2.0. Vienas pastovių viešųjų numerių registras.
function ids=ld2_terminal_ids()
    ids=["GEN_H";"GEN_L";"GEN_MH";"GEN_ML";"AM_H";"AM_L";"VM_H";"VM_L";"R8_1";"R8_2";"R8_M1";"R8_M2";"C2_1";"C2_2";"C2_M1";"C2_M2";"R9_1";"R9_2";"R9_M1";"R9_M2";"L1_1";"L1_2";"L1_M1";"L1_M2";"C4_1";"C4_2";"C4_M1";"C4_M2";"L3_1";"L3_2";"L3_M1";"L3_M2";"R13_1";"R13_2";"R13_M1";"R13_M2";"LC_M1";"LC_M2"];
endfunction

function code=ld2_terminal_code(id)
    ids=ld2_terminal_ids(); k=find(ids==id);
    if size(k,"*")<>1 then error("Nežinomas kontaktas: "+id); end
    code=msprintf("T%02d",k);
endfunction

function name=ld2_terminal_name(id)
    ids=ld2_terminal_ids(); k=find(ids==id);
    if size(k,"*")<>1 then error("Nežinomas kontaktas: "+id); end
    names=["generatoriaus ~ išėjimas";"generatoriaus 0 V grįžimas";"generatoriaus ~ matavimo lizdas";"generatoriaus 0 V matavimo lizdas";"ampermetro A~ įėjimas";"ampermetro COM išėjimas";"voltmetro V~ įėjimas";"voltmetro COM";"R8 kairysis pagrindinis lizdas";"R8 dešinysis pagrindinis lizdas";"R8 kairysis matavimo lizdas";"R8 dešinysis matavimo lizdas";"C2 kairysis pagrindinis lizdas";"C2 dešinysis pagrindinis lizdas";"C2 kairysis matavimo lizdas";"C2 dešinysis matavimo lizdas";"R9 kairysis pagrindinis lizdas";"R9 dešinysis pagrindinis lizdas";"R9 kairysis matavimo lizdas";"R9 dešinysis matavimo lizdas";"L1 kairysis pagrindinis lizdas";"L1 dešinysis pagrindinis lizdas";"L1 kairysis matavimo lizdas";"L1 dešinysis matavimo lizdas";"C4 kairysis pagrindinis lizdas";"C4 dešinysis pagrindinis lizdas";"C4 kairysis matavimo lizdas";"C4 dešinysis matavimo lizdas";"L3 kairysis pagrindinis lizdas";"L3 dešinysis pagrindinis lizdas";"L3 kairysis matavimo lizdas";"L3 dešinysis matavimo lizdas";"R13 kairysis pagrindinis lizdas";"R13 dešinysis pagrindinis lizdas";"R13 kairysis matavimo lizdas";"R13 dešinysis matavimo lizdas";"L3–C4 poros kairysis matavimo lizdas";"L3–C4 poros dešinysis matavimo lizdas"];
    name=ld2_terminal_code(id)+" – "+names(k);
endfunction
