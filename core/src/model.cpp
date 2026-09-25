#include "ldcore.hpp"
#include <cmath>
#include <complex>
#include <limits>
#include <stdexcept>
namespace ld {
Bank bank(int variant) {
    if(variant<1 || variant>64) throw std::runtime_error("variant_range");
    int a=(variant-1)/8,b=(variant-1)%8;
    const double dc[]={330,470,680,820,1000,1200,1500,2200};
    const double rc[]={330,470,680,820,1000,1200,1500,1800};
    const double rl[]={100,150,180,220,270,330,390,470};
    const double ls[]={10,12,15,18,22,27,33,39};
    const double cs[]={47,56,68,82,100,120,150,180};
    // LD3 (Ohm's law): resistor R by row a, three source voltages by column b.
    const double rld[]={33,47,56,68,82,100,120,150};
    const double uu[][3]={{3,6,9},{4,8,12},{2,5,8},{5,10,12},{3,7,11},{6,9,12},{2,6,10},{4,7,10}};
    double l=ls[a]*1e-3,c=cs[b]*1e-9;
    // LD4-64-A-2026: E24 nominalai + deterministinis ±5 % (d1=variant%11-5, d2=3*variant%11-5).
    const double n1[]={100,120,150,180,220,270,330,390};
    const double n2[]={470,560,680,820,1000,1200,1500,1800};
    const double d1=(variant%11)-5,d2=((3*variant)%11)-5;
    const double a1=std::round(n1[a]*(1+d1/100.0)*10)/10.0;
    const double a2=std::round(n2[b]*(1+d2/100.0)*10)/10.0;
    // LD5-64-A-2026: potenciometro padėtys % pagal stulpelį b.
    const double pp[][3]={{25,50,75},{20,45,70},{30,55,80},{15,40,65},{35,60,85},{25,60,90},{10,50,80},{30,50,70}};
    // LD6-64-A-2026: E2 pagal b, R (krovinys) E24 su ±5 % pagal a.
    const double e2v[]={3,4,5,6,7,8,10,12};
    const double r6n[]={100,120,150,180,220,270,330,390};
    const double d6=((variant*5)%11)-5;
    const double r6=std::round(r6n[a]*(1+d6/100.0)*10)/10.0;
    // LD7-64-A-2026: suderinamumo tyrimas — E pagal stulpelį b, vidinė varža r pagal
    // eilutę a (E12 serija); reostato padėtys R_k = round(m_k*r*10)/10 apiplaukia r.
    const double ev7[]={3,4,5,6,7,8,10,12};
    const double rv7[]={22,27,33,39,47,56,68,82};
    const double m7[]={0.33,0.56,1.0,1.8,3.0};
    double w7[5];
    for(int k=0;k<5;++k) w7[k]=std::round(m7[k]*rv7[a]*10)/10.0;
    // LD8-64-A-2026: varžų jungimo tyrimas — trys rezistoriai E24 nominalais
    // (R1 pagal eilutę, R2 pagal stulpelį, R3 pagal (a+b)%8) su ±5 % nuokrypiais.
    const double n8a[]={100,120,150,180,220,270,330,390};
    const double n8b[]={470,560,680,820,1000,1200,1500,1800};
    const double n8c[]={220,270,330,390,470,560,680,820};
    const double d8a=(variant%11)-5,d8b=((3*variant)%11)-5,d8c=((5*variant)%11)-5;
    const double e8a=std::round(n8a[a]*(1+d8a/100.0)*10)/10.0;
    const double e8b=std::round(n8b[b]*(1+d8b/100.0)*10)/10.0;
    const double e8c=std::round(n8c[(a+b)%8]*(1+d8c/100.0)*10)/10.0;
    // LD9-64-A-2026: nuoseklus RLC ir įtampų rezonansas — L pagal eilutę,
    // C pagal stulpelį; R = sqrt(L/C)/Qt, Qt = 2..3,5 pagal (a+b)%4 (Q>1 visada).
    const double l9=ls[a]*1e-3, c9=cs[b]*1e-9;
    const double qt9=2.0+0.5*((a+b)%4);
    const double e9r=std::round(100.0*std::sqrt(l9/c9)/qt9)/100.0;
    // LD10-64-A-2026: lygiagretus RLC ir srovių rezonansas — L pagal stulpelį,
    // C pagal eilutę (sukelta-retas tinklelis); R = Qt·sqrt(L/C), Qt = 2..3,5
    // pagal (a+b)%4 — srovių kokybė Q = IL/I > 1,5 visuose variantuose.
    const double l10=ls[b]*1e-3, c10=cs[a]*1e-9;
    const double qt10=2.0+0.5*((a+b)%4);
    const double e10r=std::round(100.0*qt10*std::sqrt(l10/c10))/100.0;
    // LD11-64-A-2026: galios tyrimas ir cos φ gerinimas — E pagal stulpelį,
    // R ir L pagal eilutę (L iš (a+b)%8); Ck = XL/(ω(R²+XL²)), ω = 2π·50.
    const double e11v[]={5,6,7,8,9,10,11,12};
    const double e11r0[]={10,15,22,33,47,68,82,100};
    const double e11l0[]={100,150,220,330,470,680,1000,1500};
    const double e11e=e11v[b];
    const double e11r=e11r0[a];
    const double e11l=e11l0[(a+b)%8]*1e-3;
    const double w11=100.0*std::acos(-1.0);
    const double xl11=w11*e11l;
    const double e11c=std::round(xl11/(w11*(e11r*e11r+xl11*xl11))*1e8)/1e8;
    // LD12-64-A-2026: trifazės grandinės — linijinė įtampa pagal stulpelį
    // (30–220 V), imtuvų varža pagal eilutę (10–100 Ω, simetriška žvaigždė/trikampis).
    const double e12v[]={30,40,50,60,100,110,127,220};
    const double e12r0[]={10,15,22,33,47,68,82,100};
    const double e12u=e12v[b];
    const double e12r=e12r0[a];
    return {dc[a],dc[b],dc[(a+b)%8],rc[a],35+5.0*(b+1),rl[b],35+5.0*(a+1),
            std::round(std::sqrt(l/c)/(2.8+.35*(a+1)+.20*(b+1))),l,c,
            uu[b][0],uu[b][1],uu[b][2],rld[a],
            n1[a],n2[b],a1,a2,
            pp[b][0],pp[b][1],pp[b][2],
            (double)e2v[b],r6,(double)r6n[a],ev7[b],(double)rv7[a],w7[0],w7[1],w7[2],w7[3],w7[4],e8a,e8b,e8c,l9,c9,e9r,l10,c10,e10r,e11e,e11r,e11l,e11c,e12u,e12r};
}
Values ac(int kind,double E,double f,double R,double L,double C) {
    for(double v:{E,f,R,L,C}) if(!std::isfinite(v)) throw std::runtime_error("non_finite");
    if(kind<1 || kind>6 || E<0 || E>1e6 || f<0 || f>1e9 || R<=0 ||
       (kind!=1 && kind!=6 && L<=0) || (kind!=2 && kind!=5 && kind!=6 && C<=0) || (kind==5 && C<0))
        throw std::runtime_error("model_input");
    if(kind==6) {
        // Balanced three-phase loads. Actual MNA results for BOTH topologies.
        // [Uf_Y V, If_Y mA, Uf_D V, If_D mA, Il_D mA, P_Y W, P_D W, Ul V, 0, 0].
        if(f==0) throw std::runtime_error("model_input");
        const double phase=E/std::sqrt(3.0), angle=2*std::acos(-1.0)/3;
        auto solve=[&](bool delta) {
            const auto e2=std::polar(phase,-angle), e3=std::polar(phase,angle);
            std::vector<std::array<double,5>> rows={{{4,1,0,phase,0}},
                {{4,2,0,e2.real(),e2.imag()}},{{4,3,0,e3.real(),e3.imag()}},
                {{1,1,delta?2.0:0.0,R,0}},{{1,2,delta?3.0:0.0,R,0}},{{1,3,delta?1.0:0.0,R,0}}};
            int m=6,n=3,status=1;
            std::vector<double> table(m*5),voltage((n+1)*2),current(m*2);
            for(int k=0;k<m;++k) for(int col=0;col<5;++col) table[col*m+k]=rows[k][col];
            ld_mna(table.data(),&m,&n,&f,voltage.data(),current.data(),&status);
            if(status) throw std::runtime_error("reference_model_"+std::to_string(status));
            auto v=[&](int node){return std::complex<double>(voltage[node],voltage[n+1+node]);};
            auto i=[&](int branch){return std::complex<double>(current[branch],current[m+branch]);};
            double power=0;for(int k=3;k<6;++k) power+=std::norm(i(k))*R;
            return std::array<double,5>{std::abs(v(1)-v(delta?2:0)),std::abs(i(3))*1000,
                std::abs(i(0))*1000,power,std::abs(v(1)-v(2))};
        };
        const auto y=solve(false),d=solve(true);
        return {y[0],y[1],d[0],d[1],d[2],y[3],d[3],d[4],0.0,0.0};
    }
    if(kind==5) {
        // RL ∥ C: [XL, Z_RL, cosφ0, I_bendra, I_RL, P, Q, S, φ°, IC].
        // Analitinis tikslus sprendimas: G = R/Z², B = ωC − XL/Z².
        if(f==0) throw std::runtime_error("model_input");
        const double w=2*std::acos(-1.0)*f, xl=w*L, zrl=std::hypot(R,xl);
        const double g=R/(zrl*zrl), b=w*C-xl/(zrl*zrl);
        const double it=E*std::hypot(g,b);
        const double p=E*E*g, q=-E*E*b; // passive load: inductive Q > 0
        return {xl,zrl,R/zrl,it,E/zrl,p,q,E*it,
                std::atan2(-b,g)*180/std::acos(-1.0),C>0?E*w*C:0.0};
    }
    if(kind==4) {
        // Lygiagretus RLC: [XL, XC, |Z|, I_bendra, IR, IL, IC, |IL−IC|, P, phi].
        const double w=2*std::acos(-1.0)*f;
        if(f==0) throw std::runtime_error("model_input");
        std::vector<std::array<double,5>> rows={{{4,1,0,E,0}},{{1,1,0,R,0}},{{2,1,0,L,0}},{{3,1,0,C,0}}};
        int m=4,n=1,st=1;
        std::vector<double> table(m*5),v((n+1)*2),i(m*2);
        for(int k=0;k<m;++k) for(int col=0;col<5;++col) table[col*m+k]=rows[k][col];
        ld_mna(table.data(),&m,&n,&f,v.data(),i.data(),&st);
        if(st!=0) throw std::runtime_error("reference_model_"+std::to_string(st));
        const double xl=w*L, xc=1/(w*C);
        std::complex<double> y(1.0/R, w*C-1.0/(w*L));
        std::complex<double> z=1.0/y;
        const double it=std::abs(std::complex<double>(i[0],i[m]));
        return {xl,xc,std::abs(z),it,E/R,E/xl,E/xc,std::abs(E/xl-E/xc),E*E/R,
                std::atan2(z.imag(),z.real())*180/std::acos(-1.0)};
    }
    int m=kind==3?4:3,n=kind==3?3:2,st=1;
    std::vector<std::array<double,5>> rows={{{4,1,0,E,0}},{{1,1,2,R,0}}};
    if(kind==1) rows.push_back({3,2,0,C,0});
    if(kind==2) rows.push_back({2,2,0,L,0});
    if(kind==3) {rows.push_back({2,2,3,L,0}); rows.push_back({3,3,0,C,0});}
    std::vector<double> table(m*5),v((n+1)*2),i(m*2);
    for(int k=0;k<m;++k) for(int col=0;col<5;++col) table[col*m+k]=rows[k][col];
    ld_mna(table.data(),&m,&n,&f,v.data(),i.data(),&st);
    if(st!=0) throw std::runtime_error("reference_model_"+std::to_string(st));
    double w=2*std::acos(-1.0)*f, xl=kind==1?0:w*L;
    double xc=kind==2?0:(f==0?std::numeric_limits<double>::infinity():1/(w*C));
    std::complex<double> current(i[1],i[m+1]);
    double im=std::abs(current), uc=kind==2?0:(f==0?E:im*xc),ul=im*xl;
    return {xl,xc,std::hypot(R,xl-xc),im,im*R,ul,uc,std::abs(ul-uc),im*im*R,
            f==0 && kind!=2?-90:std::atan2(xl-xc,R)*180/std::acos(-1.0)};
}
}
LD_API void ld_ac(const int* kind,const double* p,double* out,int* status) noexcept {
    if(!status) return;
    *status=1;
    if(!kind || !p || !out) return;
    try {auto r=ld::ac(*kind,p[0],p[1],p[2],p[3],p[4]); std::copy(r.begin(),r.end(),out); *status=0;}
    catch(...) {*status=1;}
}
