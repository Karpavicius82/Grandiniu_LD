#pragma once
#include <array>
#include <string>
#include <vector>
#include <filesystem>
#ifdef _WIN32
#define LD_API extern "C" __declspec(dllexport)
#else
#define LD_API extern "C" __attribute__((visibility("default")))
#endif
// ABI 1: scalars and caller-owned arrays only; SI, RMS, exp(+jwt).
LD_API void ld_mna(const double*,const int*,const int*,const double*,double*,double*,int*) noexcept;
// Input [E,f,R,L,C], output [XL,XC,|Z|,I,UR,UL,UC,ULC,P,phi_Z_deg].
// kind 1=RC, 2=RL, 3=series RLC; finite positive components, f >= 0.
LD_API void ld_ac(const int*,const double*,double*,int*) noexcept;
// UTF-8 paths represented as int arrays (0..255), no shell invocation.
// command 1=start, 2=process up to 25, 3=cancel, 4=finish.
// progress [processed,total,graded,review]; status 0=more, 1=done, negative=error.
LD_API void ld_batch(const int*,const int*,const int*,const int*,const int*,double*,int*) noexcept;
LD_API void ld_write_new(const int*,const int*,const int*,const int*,int*) noexcept;
namespace ld {
using Values=std::array<double,10>;
Values ac(int kind,double E,double f,double R,double L,double C);
struct Bank {double r1,r2,r3,r8,frc,r9,frl,r13,l3,c4;};
Bank bank(int variant);
void write_new(const std::filesystem::path&,const std::string&);
int run_batch(const std::filesystem::path&,const std::filesystem::path&);
}
