// Feasibility experiment only: no GUI, report grader or production integration.
mode(-1);
probe_repo=get_absolute_file_path("model_probe.sce")+"../../../";
function c=probe_component(kind,a,b,value)
    c=struct("kind",kind,"a",a,"b",b,"value",value);
endfunction

function [v,isource]=probe_linear(parts,f)
    if ~isreal(f) | isnan(f) | isinf(f) | f<0 then error("Invalid frequency"); end
    nn=0; sources=list(); admittances=list();
    for k=1:length(parts)
        c=parts(k); nn=max([nn c.a c.b]);
        if c.a<0 | c.b<0 | c.a<>floor(c.a) | c.b<>floor(c.b) then error("Invalid node"); end
        if isnan(c.value) | isinf(c.value) then error("Invalid value"); end
        if c.kind=="V" then sources($+1)=c; continue; end
        if ~isreal(c.value) | c.value<=0 then error("Passive value must be positive"); end
        select c.kind
        case "R" then y=1/c.value;
        case "C" then
            if f==0 then continue; end
            y=%i*2*%pi*f*c.value;
        case "L" then
            if f==0 then sources($+1)=probe_component("V",c.a,c.b,0); continue; end
            y=1/(%i*2*%pi*f*c.value);
        else error("Unknown component");
        end
        admittances($+1)=probe_component("Y",c.a,c.b,y);
    end
    ns=length(sources); A=zeros(nn+ns,nn+ns); rhs=zeros(nn+ns,1);
    for k=1:length(admittances)
        c=admittances(k); a=c.a; b=c.b; y=c.value;
        if a>0 then A(a,a)=A(a,a)+y; end
        if b>0 then A(b,b)=A(b,b)+y; end
        if a>0 & b>0 then A(a,b)=A(a,b)-y; A(b,a)=A(b,a)-y; end
    end
    for k=1:ns
        c=sources(k); j=nn+k;
        if c.a>0 then A(c.a,j)=A(c.a,j)+1; A(j,c.a)=A(j,c.a)+1; end
        if c.b>0 then A(c.b,j)=A(c.b,j)-1; A(j,c.b)=A(j,c.b)-1; end
        rhs(j)=c.value;
    end
    if rcond(A)<1d-14 then error("Undefined or inconsistent circuit"); end
    x=A\rhs;
    v=[0;x(1:nn)]; isource=x(nn+1:$);
    // Separate C++/Eigen assembly and solve, compared with this Scilab MNA solve.
    global probe_cpp_count;
    if c_link("ld_mna_probe") then
        kinds=["R" "L" "C" "V" "I"]; table=zeros(length(parts),5);
        for k=1:length(parts)
            c=parts(k); table(k,:)=[find(kinds==c.kind) c.a c.b real(c.value) imag(c.value)];
        end
        [cv,ci,status]=call("ld_mna_probe",table,1,"d",length(parts),2,"i",nn,3,"i",f,4,"d", ...
            "out",[nn+1 2],5,"d",[length(parts) 2],6,"d",[1 1],7,"i");
        assert_checkequal(status,0);
        assert_checktrue(max(abs(cv(:,1)+%i*cv(:,2)-v))<1d-9*max([1;abs(v)]));
        source_indices=[];
        for k=1:length(parts)
            c=parts(k);
            if c.kind=="V" | (c.kind=="L" & f==0) then source_indices($+1)=k; end
        end
        cpp_source_i=ci(source_indices,1)+%i*ci(source_indices,2);
        assert_checktrue(max(abs(cpp_source_i-isource))<1d-9*max([1;abs(isource)]));
        probe_cpp_count=probe_cpp_count+1;
    end
endfunction

function probe_check(label,actual,expected)
    global probe_count probe_max_error;
    rel=max(abs(actual-expected))/max([1;matrix(abs(expected),-1,1)]);
    if isnan(rel) | rel>1d-9 then error(label+": mismatch "+string(rel)); end
    probe_count=probe_count+1; probe_max_error=max(probe_max_error,rel);
endfunction

try
    exec(probe_repo+"studentui/LD1/LD1_LOAD.sce",-1);
    exec(probe_repo+"studentui/LD2/LD2_LOAD.sce",-1);
    global probe_count probe_max_error probe_cpp_count;
    probe_count=0; probe_max_error=0; probe_cpp_count=0;
    for n=1:64
        dc=ld1_variant_config(n);
        [v,iv]=probe_linear(list(probe_component("V",1,0,dc.E),probe_component("R",1,2,dc.R1),probe_component("R",2,0,500)),0);
        probe_check("DC divider",v(3),dc.E*500/(dc.R1+500));
        probe_check("DC current",-iv(1),dc.E/(dc.R1+500));
        ac=ld2_variant_config(n);
        [v,iv]=probe_linear(list(probe_component("V",1,0,ac.E_RC),probe_component("R",1,2,ac.R8),probe_component("C",2,0,ac.C2)),ac.F_RC);
        ref=ld2_rc_values(ac.E_RC,ac.F_RC,ac.R8,ac.C2);
        probe_check("RC",[abs(iv(1));abs(v(2)-v(3));abs(v(3))],[ref.I;ref.UR;ref.UX]);
        [v,iv]=probe_linear(list(probe_component("V",1,0,ac.E_RL),probe_component("R",1,2,ac.R9),probe_component("L",2,0,ac.L1)),ac.F_RL);
        ref=ld2_rl_values(ac.E_RL,ac.F_RL,ac.R9,ac.L1);
        probe_check("RL",[abs(iv(1));abs(v(2)-v(3));abs(v(3))],[ref.I;ref.UR;ref.UX]);
        f0=1/(2*%pi*sqrt(ac.L3*ac.C4));
        for f=f0*[0.5 1 2]
            [v,iv]=probe_linear(list(probe_component("V",1,0,ac.E_RLC),probe_component("R",1,2,ac.R13),probe_component("L",2,3,ac.L3),probe_component("C",3,0,ac.C4)),f);
            ref=ld2_rlc_values(ac.E_RLC,f,ac.R13,ac.L3,ac.C4);
            probe_check("series RLC",[abs(iv(1));abs(v(2)-v(3));abs(v(3)-v(4));abs(v(4))],[ref.I;ref.UR;ref.UL;ref.UC]);
            [v,iv]=probe_linear(list(probe_component("V",1,0,ac.E_RLC),probe_component("R",1,0,ac.R13),probe_component("L",1,0,ac.L3),probe_component("C",1,0,ac.C4)),f);
            omega=2*%pi*f;
            refI=ac.E_RLC*(1/ac.R13+%i*(omega*ac.C4-1/(omega*ac.L3)));
            probe_check("parallel RLC",-iv(1),refI);
            probe_check("AC power",ac.E_RLC*conj(-iv(1)),ac.E_RLC*conj(refI));
        end
    end
    // Two nonideal sources in parallel; source internal resistances are explicit.
    [v,iv]=probe_linear(list(probe_component("V",1,0,12),probe_component("V",2,0,10),probe_component("R",1,3,2),probe_component("R",2,3,3),probe_component("R",3,0,10)),0);
    refU=(12/2+10/3)/(1/2+1/3+1/10);
    probe_check("parallel sources",v(4),refU);
    // Two voltage sources in series, including a floating voltage source.
    [v,iv]=probe_linear(list(probe_component("V",1,0,10),probe_component("V",2,1,5),probe_component("R",2,0,100)),0);
    probe_check("series sources",v(3),15);
    probe_check("series sources current",-iv(1),0.15);
    // Balanced three-phase wye without neutral, and delta with the same branch R.
    E=230; R=100; ea=E; eb=E*exp(-%i*2*%pi/3); ec=E*exp(%i*2*%pi/3);
    src=list(probe_component("V",1,0,ea),probe_component("V",2,0,eb),probe_component("V",3,0,ec));
    c=src; c($+1)=probe_component("R",1,4,R); c($+1)=probe_component("R",2,4,R); c($+1)=probe_component("R",3,4,R);
    [v,iv]=probe_linear(c,50);
    probe_check("wye neutral",v(5),0);
    probe_check("wye line current",abs(iv),E/R*ones(3,1));
    probe_check("wye total power",sum([ea;eb;ec].*conj(-iv)),3*E^2/R);
    c=src; c($+1)=probe_component("R",1,2,R); c($+1)=probe_component("R",2,3,R); c($+1)=probe_component("R",3,1,R);
    [v,iv]=probe_linear(c,50);
    probe_check("delta line current",abs(iv),3*E/R*ones(3,1));
    probe_check("delta total power",sum([ea;eb;ec].*conj(-iv)),9*E^2/R);
    // Unbalanced wye without neutral: independently derived neutral voltage.
    ra=100; rb=200; rc=300; vn=(ea/ra+eb/rb+ec/rc)/(1/ra+1/rb+1/rc);
    c=src; c($+1)=probe_component("R",1,4,ra); c($+1)=probe_component("R",2,4,rb); c($+1)=probe_component("R",3,4,rc);
    [v,iv]=probe_linear(c,50);
    probe_check("unbalanced neutral",v(5),vn);
    probe_check("unbalanced line currents",-iv,[(ea-vn)/ra;(eb-vn)/rb;(ec-vn)/rc]);
    // DC limits: capacitor open circuit, inductor short circuit.
    [v,iv]=probe_linear(list(probe_component("V",1,0,10),probe_component("R",1,2,100),probe_component("C",2,0,1d-6)),0);
    probe_check("DC capacitor current",iv(1),0);
    [v,iv]=probe_linear(list(probe_component("V",1,0,10),probe_component("R",1,2,100),probe_component("L",2,0,0.1)),0);
    probe_check("DC inductor current",-iv(1),0.1);
    rejected=%f;
    try probe_linear(list(probe_component("V",1,0,10),probe_component("V",1,0,12),probe_component("R",1,0,100)),0);
    catch rejected=%t; end
    if ~rejected then error("Contradicting sources were not rejected"); end
    mprintf("MODEL_TEMPLATE_PROBE_PASS checks=%d max_scaled_error=%.3e\n",probe_count,probe_max_error);
    mprintf("CPP_MNA_COMPARISONS_PASS count=%d\n",probe_cpp_count);
    mprintf("Covered: DC divider, RC/RL, series/parallel RLC, power, multiple sources, balanced/unbalanced three-phase, DC limits.\n");
    mprintf("Scope: numerical feasibility only; no industrial acceptance or full LD coverage claimed.\n");
    // Caller writes evidence and terminates after this file returns.
catch
    mprintf("MODEL_TEMPLATE_PROBE_FAIL: %s\n",strcat(lasterror()," | "));
    error("MODEL_TEMPLATE_PROBE_FAIL");
end
