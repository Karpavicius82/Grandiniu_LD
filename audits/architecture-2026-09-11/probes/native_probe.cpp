// Integration experiment, not the production circuit solver.
// Only plain arrays and integer dimensions cross the C ABI.
#include <cmath>
#include <complex>
#include <limits>
#ifdef _WIN32
#define LD_EXPORT extern "C" __declspec(dllexport)
#else
#define LD_EXPORT extern "C" __attribute__((visibility("default")))
#endif

LD_EXPORT void ld_rlc_batch(const double* data, const int* count,
                           const int* columns, double* output, int* status) noexcept {
    if (!data || !count || !columns || !output || !status) return;
    const int n = *count;
    if (n < 1 || n > 4096) { status[0] = 1; return; }
    for (int i = 0; i < n; ++i) {
        status[i] = 1;
        for (int k = 0; k < 4; ++k) output[k*n+i] = 0;
    }
    if (*columns != 6) return;
    const double pi = std::acos(-1.0);
    for (int i = 0; i < n; ++i) {
        bool finite = true;
        for (int k = 0; k < 6; ++k) finite = finite && std::isfinite(data[k*n+i]);
        if (!finite) continue;
        const double e=data[i], f=data[n+i], r=data[2*n+i];
        const double l=data[3*n+i], c=data[4*n+i], mode=data[5*n+i];
        if (e <= 0 || f <= 0 || r <= 0 || l <= 0 || c <= 0 ||
            (mode != 0 && mode != 1)) continue;
        const double w=2*pi*f;
        std::complex<double> current;
        if (mode == 0) current=e/std::complex<double>(r,w*l-1/(w*c));
        else current=e*std::complex<double>(1/r,w*c-1/(w*l));
        const std::complex<double> power=e*std::conj(current);
        const double values[4]={current.real(),current.imag(),power.real(),power.imag()};
        finite=true;
        for (double value : values) finite=finite && std::isfinite(value);
        if (!finite) continue;
        for (int k=0; k<4; ++k) output[k*n+i]=values[k];
        status[i]=0;
    }
}

#ifdef LD_NATIVE_PROBE_MAIN
#include <cassert>
#include <iostream>
extern "C" void ld_mna_probe(const double*,const int*,const int*,const double*,double*,double*,int*) noexcept;
int main() {
    int n=1, cols=6, status=9;
    const double pi=std::acos(-1.0);
    double data[6]={10,1/(2*pi*std::sqrt(0.1*1e-6)),100,0.1,1e-6,0};
    double result[4]={};
    ld_rlc_batch(data,&n,&cols,result,&status);
    assert(status==0 && std::abs(result[0]-0.1)<1e-12 && std::abs(result[2]-1)<1e-12);
    for (int k=0;k<6;++k) {
        const double saved=data[k]; data[k]=std::numeric_limits<double>::infinity();
        ld_rlc_batch(data,&n,&cols,result,&status); assert(status!=0); data[k]=saved;
    }
    data[2]=-100; ld_rlc_batch(data,&n,&cols,result,&status); assert(status!=0);
    data[2]=100; cols=5; ld_rlc_batch(data,&n,&cols,result,&status); assert(status!=0);
    n=0; ld_rlc_batch(data,&n,&cols,result,&status); assert(status!=0);
    int m=2,nodes=1; double frequency=0, voltage[4]={},current[4]={};
    double circuit[10]={4,1, 1,1, 0,0, 10,100, 0,0};
    ld_mna_probe(circuit,&m,&nodes,&frequency,voltage,current,&status);
    assert(status==0 && std::abs(voltage[1]-10)<1e-12 && std::abs(current[0]+0.1)<1e-12);
    double cs[10]={5,1, 0,1, 1,0, 0.1,100, 0,0};
    ld_mna_probe(cs,&m,&nodes,&frequency,voltage,current,&status);
    assert(status==0 && std::abs(voltage[1]-10)<1e-12);
    nodes=65; ld_mna_probe(cs,&m,&nodes,&frequency,voltage,current,&status); assert(status==1);
    nodes=1; cs[1]=9; ld_mna_probe(cs,&m,&nodes,&frequency,voltage,current,&status); assert(status==1);
    std::cout << "NATIVE_SANITIZER_PROBE_PASS\n";
}
#endif
