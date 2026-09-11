// Bounded numerical architecture probe. Not a released or approved LD engine.
#include <Eigen/Dense>
#include <cmath>
#include <complex>
#include <vector>
#ifdef _WIN32
#define LD_EXPORT extern "C" __declspec(dllexport)
#else
#define LD_EXPORT extern "C" __attribute__((visibility("default")))
#endif

// Part table (column-major): kind, node a, node b, value real, value imaginary.
// Kinds: 1 R, 2 L, 3 C, 4 voltage source, 5 current source; node 0 is ground.
// Caller allocates voltage[(nodes+1)*2] and current[parts*2]. Status 0=success,
// 1=input, 2=singular/ill-conditioned, 3=numerical failure, 4=internal exception.
LD_EXPORT void ld_mna_probe(const double* table, const int* parts,
                           const int* nodes, const double* frequency,
                           double* voltage, double* current, int* status) noexcept {
    if (!status) return;
    *status=1;
    if (!table || !parts || !nodes || !frequency || !voltage || !current) return;
    const int m=*parts, n=*nodes;
    if (m<1 || m>256 || n<1 || n>64 || !std::isfinite(*frequency) || *frequency<0) return;
    try {
        using C=std::complex<double>;
        struct Part {int kind,a,b,source; C value,y;};
        std::vector<Part> p;
        int ns=0;
        const double w=2*std::acos(-1.0)*(*frequency);
        for (int k=0;k<m;++k) {
            for (int c=0;c<5;++c) if (!std::isfinite(table[c*m+k])) return;
            for (int c=0;c<3;++c) if (table[c*m+k]!=std::floor(table[c*m+k])) return;
            if (table[k]<1 || table[k]>5 || table[m+k]<0 || table[m+k]>n ||
                table[2*m+k]<0 || table[2*m+k]>n) return;
            Part q{static_cast<int>(table[k]),static_cast<int>(table[m+k]),
                   static_cast<int>(table[2*m+k]),-1,{table[3*m+k],table[4*m+k]},0};
            if (q.kind<=3 && (q.value.imag()!=0 || q.value.real()<=0)) return;
            if (*frequency==0 && q.value.imag()!=0) return;
            if (q.kind==4 || (q.kind==2 && *frequency==0)) q.source=ns++;
            if (q.kind==1) q.y=1.0/q.value;
            if (q.kind==2 && *frequency>0) q.y=1.0/(C(0,w)*q.value);
            if (q.kind==3 && *frequency>0) q.y=C(0,w)*q.value;
            p.push_back(q);
        }
        Eigen::MatrixXcd A=Eigen::MatrixXcd::Zero(n+ns,n+ns);
        Eigen::VectorXcd b=Eigen::VectorXcd::Zero(n+ns);
        for (const auto& q:p) {
            const int a=q.a-1, z=q.b-1;
            if (q.source>=0) {
                int j=n+q.source;
                if (a>=0) {A(a,j)+=1; A(j,a)+=1;}
                if (z>=0) {A(z,j)-=1; A(j,z)-=1;}
                b(j)=q.kind==4?q.value:C(0);
            } else if (q.kind==5) {
                if (a>=0) b(a)-=q.value;
                if (z>=0) b(z)+=q.value;
            } else {
                if (a>=0) A(a,a)+=q.y;
                if (z>=0) A(z,z)+=q.y;
                if (a>=0 && z>=0) {A(a,z)-=q.y; A(z,a)-=q.y;}
            }
        }
        if (!A.allFinite() || !b.allFinite()) {*status=3; return;}
        Eigen::FullPivLU<Eigen::MatrixXcd> lu(A);
        // Probe threshold only. Production acceptance must bound component ranges
        // and document scaling/conditioning rather than silently repairing circuits.
        if (!lu.isInvertible() || lu.rcond()<1e-14) {*status=2; return;}
        Eigen::VectorXcd x=lu.solve(b);
        const double residual=(A*x-b).norm()/(1+A.norm()*x.norm()+b.norm());
        if (!x.allFinite() || !std::isfinite(residual) || residual>1e-11) {*status=3; return;}
        voltage[0]=0; voltage[n+1]=0;
        for (int k=0;k<n;++k) {voltage[k+1]=x(k).real(); voltage[n+k+2]=x(k).imag();}
        for (int k=0;k<m;++k) {
            const auto& q=p[k]; C i;
            if (q.source>=0) i=x(n+q.source);
            else if (q.kind==5) i=q.value;
            else i=((q.a?x(q.a-1):C(0))-(q.b?x(q.b-1):C(0)))*q.y;
            if (!std::isfinite(i.real()) || !std::isfinite(i.imag())) {*status=3; return;}
            current[k]=i.real(); current[m+k]=i.imag();
        }
        *status=0;
    } catch (...) {*status=4;}
}
