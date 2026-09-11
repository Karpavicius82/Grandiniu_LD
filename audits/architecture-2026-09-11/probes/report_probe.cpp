// One-question, synthetic-report transport/grading probe; not the 13-LD grader.
#include "json.hpp"
#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
using json=nlohmann::json;
namespace fs=std::filesystem;
extern "C" void ld_mna_probe(const double*,const int*,const int*,const double*,double*,double*,int*) noexcept;

json read_report(const fs::path& path) {
    if (fs::is_symlink(path) || !fs::is_regular_file(path) || fs::file_size(path)>2*1024*1024)
        throw std::runtime_error("file_limit_or_type");
    std::ifstream in(path,std::ios::binary);
    if (!in) throw std::runtime_error("cannot_read");
    std::string text((std::istreambuf_iterator<char>(in)),{});
    const std::string start="<script type=\"application/json\" id=\"ld-data\">", end="</script>";
    auto a=text.find(start);
    if (a==std::string::npos || text.find(start,a+start.size())!=std::string::npos)
        throw std::runtime_error("data_block");
    a+=start.size(); auto b=text.find(end,a);
    if (b==std::string::npos) throw std::runtime_error("data_block");
    std::vector<std::set<std::string>> objects;
    auto callback=[&](int depth,json::parse_event_t event,json& parsed) {
        if (depth>32) throw std::runtime_error("depth_limit");
        if (event==json::parse_event_t::object_start) objects.emplace_back();
        if (event==json::parse_event_t::key && !objects.back().insert(parsed.get<std::string>()).second)
            throw std::runtime_error("duplicate_key");
        if (event==json::parse_event_t::object_end) objects.pop_back();
        return true;
    };
    return json::parse(text.begin()+static_cast<std::ptrdiff_t>(a),text.begin()+static_cast<std::ptrdiff_t>(b),callback);
}

json evaluate(const json& r) {
    if (!r.at("schema_version").is_number_integer() || r.at("schema_version")!=1 ||
        r.at("lab_id")!="PROBE-RC" || r.at("lab_revision")!="audit-1" ||
        r.at("bank_id")!="LD2-64-A-2026") throw std::runtime_error("unsupported_version");
    if (!r.at("variant").is_number_integer()) throw std::runtime_error("variant_type");
    int variant=r.at("variant").get<int>();
    if (variant<1 || variant>64) throw std::runtime_error("variant_range");
    for (const auto& key:{"id","name","group"}) {
        const auto& s=r.at("student").at(key);
        if (!s.is_string() || s.get_ref<const std::string&>().empty() || s.get_ref<const std::string&>().size()>256)
            throw std::runtime_error("student_identity");
    }
    const auto& id=r.at("submission_id");
    if (!id.is_string() || id.get_ref<const std::string&>().empty() || id.get_ref<const std::string&>().size()>128)
        throw std::runtime_error("submission_identity");
    const auto& a=r.at("answer");
    if (a.at("unit")!="A") throw std::runtime_error("unit");
    json result={{"id",id},{"points",0},{"rule","probe-current-v1"}};
    if (a.at("status")=="missing") {
        if (!a.at("value_SI").is_null()) throw std::runtime_error("missing_value_contract");
        result["status"]="missing"; return result;
    }
    if (a.at("status")!="entered" || !a.at("value_SI").is_number()) throw std::runtime_error("answer_type");
    double given=a.at("value_SI").get<double>();
    if (!std::isfinite(given)) throw std::runtime_error("non_finite");
    // Trusted bank values, independently reconstructed from the original bank.
    const double levels[8]={330,470,680,820,1000,1200,1500,1800};
    double resistance=levels[(variant-1)/8], f=35+5*((variant-1)%8+1);
    // V(1,0)=9; R(1,2); C(2,0). Column-major input to the shared C++ core.
    double parts[15]={4,1,3, 1,1,2, 0,2,0, 9,resistance,4.7e-6, 0,0,0};
    int m=3,n=2,status=1; double voltage[6]={},current[6]={};
    ld_mna_probe(parts,&m,&n,&f,voltage,current,&status);
    if (status!=0) throw std::runtime_error("reference_model");
    double expected=std::hypot(current[0],current[3]);
    bool correct=std::abs(given-expected)<=1e-9+0.015*std::abs(expected);
    result["status"]=correct?"correct":"incorrect";
    result["points"]=correct?1:0; result["reference_A"]=expected;
    return result;
}

int main(int argc,char** argv) {
    if (argc!=3) {std::cerr<<"usage: report_probe INPUT_FOLDER OUTPUT_JSON\n"; return 2;}
    try {
        std::vector<fs::path> paths;
        for (const auto& e:fs::directory_iterator(fs::u8path(argv[1])))
            if (e.path().extension()==".html") paths.push_back(e.path());
        std::sort(paths.begin(),paths.end());
        json results=json::array(); std::set<std::string> seen;
        for (const auto& path:paths) {
            json result;
            try {
                result=evaluate(read_report(path));
                if (!seen.insert(result.at("id").get<std::string>()).second) {
                    result["status"]="duplicate"; result.erase("points");
                }
            } catch (const std::exception&) {result={{"status","review"}};}
            result["file"]=path.filename().u8string(); results.push_back(result);
        }
        std::ofstream out(fs::u8path(argv[2]),std::ios::binary);
        out.exceptions(std::ios::badbit|std::ios::failbit);
        out<<results.dump(2); out.close();
        std::cout<<"CPP_REPORT_PROBE_COMPLETE files="<<results.size()<<"\n";
        return 0;
    } catch (const std::exception& e) {std::cerr<<e.what()<<"\n"; return 1;}
}
