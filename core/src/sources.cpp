#include "ldcore.hpp"
#include <algorithm>
#include <cmath>
#include <limits>

LD_API void ld_sources(const int* mode,const double* parameters,double* result,int* status) noexcept {
    if(!status) return;
    *status=1;
    if(!mode||!parameters||!result) return;
    std::fill(result,result+4,std::numeric_limits<double>::quiet_NaN());
    if(*mode<1||*mode>4) return;
    for(int index=0;index<5;++index)
        if(!std::isfinite(parameters[index])||parameters[index]<=0||parameters[index]>1e6) return;
    try {
        const double first=parameters[0],second=parameters[1],load=parameters[2];
        const double internal_first=parameters[3],internal_second=parameters[4];
        std::vector<std::array<double,5>> rows;
        int nodes=2;
        if(*mode==1) {
            rows={{{4,2,0,first,0}},{{1,2,1,internal_first,0}},{{1,1,0,load,0}}};
        } else if(*mode==4) {
            nodes=3;
            rows={{{4,2,0,first,0}},{{1,2,1,internal_first,0}},{{1,1,0,load,0}},
                  {{4,3,0,second,0}},{{1,3,1,internal_second,0}}};
        } else {
            nodes=4;
            rows={{{4,2,4,first,0}},{{1,2,1,internal_first,0}},{{1,1,0,load,0}},
                  {{4,3,0,*mode==2?second:-second,0}},{{1,4,3,internal_second,0}}};
        }
        const int parts=static_cast<int>(rows.size());
        const double frequency=0;
        std::vector<double> table(parts*5),voltage((nodes+1)*2),current(parts*2);
        for(int row=0;row<parts;++row)
            for(int column=0;column<5;++column) table[column*parts+row]=rows[row][column];
        ld_mna(table.data(),&parts,&nodes,&frequency,voltage.data(),current.data(),status);
        if(*status!=0) return;
        result[0]=voltage[1]; result[1]=current[2]*1000;
        result[2]=current[1]*1000;
        result[3]=*mode==1?0:(*mode==4?current[4]*1000:(*mode==2?1:-1)*current[2]*1000);
    } catch(...) {*status=4;}
}
