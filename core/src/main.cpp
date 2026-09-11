#include "ldcore.hpp"
#include <iostream>
namespace fs=std::filesystem;
static int run(const fs::path& in,const fs::path& out) {
    try {return ld::run_batch(in,out);}catch(const std::exception& e) {std::cerr<<e.what()<<'\n';return 1;}
}
#ifdef _WIN32
int wmain(int argc,wchar_t** argv) {
    if(argc!=3) {std::cerr<<"ldcheck INPUT_FOLDER NEW_OUTPUT_FOLDER\n";return 2;}
    return run(fs::path(argv[1]),fs::path(argv[2]));
}
#else
int main(int argc,char** argv) {
    if(argc!=3) {std::cerr<<"ldcheck INPUT_FOLDER NEW_OUTPUT_FOLDER\n";return 2;}
    return run(fs::u8path(argv[1]),fs::u8path(argv[2]));
}
#endif
