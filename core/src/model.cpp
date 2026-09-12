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
    return {dc[a],dc[b],dc[(a+b)%8],rc[a],35+5.0*(b+1),rl[b],35+5.0*(a+1),
            std::round(std::sqrt(l/c)/(2.8+.35*(a+1)+.20*(b+1))),l,c,
            uu[b][0],uu[b][1],uu[b][2],rld[a]};
}
Values ac(int kind,double E,double f,double R,double L,double C) {
    for(double v:{E,f,R,L,C}) if(!std::isfinite(v)) throw std::runtime_error("non_finite");
    if(kind<1 || kind>3 || E<0 || E>1e6 || f<0 || f>1e9 || R<=0 ||
       (kind!=1 && L<=0) || (kind!=2 && C<=0)) throw std::runtime_error("model_input");
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
