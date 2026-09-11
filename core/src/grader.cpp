#include "grader.hpp"
#include <algorithm>
#include <cmath>
#include <fstream>
#include <locale>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <stdexcept>
namespace ld {
namespace {
void require(bool ok,const char* reason) {if(!ok) throw std::runtime_error(reason);}
double number(const Json& j) {
    require(j.is_number(),"expected_number");
    double x=j.get<double>(); require(std::isfinite(x),"non_finite"); return x;
}
std::string text(const Json& j,size_t limit=256) {
    require(j.is_string(),"expected_text"); auto s=j.get<std::string>();
    require(s.size()<=limit && s.find('\0')==std::string::npos,"text_limit"); return s;
}
bool parse_number(std::string s,double& x) {
    auto a=s.find_first_not_of(" \t\r\n"),b=s.find_last_not_of(" \t\r\n");
    if(a==std::string::npos || s.size()>128) return false;
    s=s.substr(a,b-a+1);
    for(char& c:s) {if(c==',') c='.'; if(c=='d'||c=='D') c='e';}
    static const std::regex grammar(R"([+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?)");
    if(!std::regex_match(s,grammar)) return false;
    std::istringstream in(s); in.imbue(std::locale::classic()); in>>x;
    return bool(in) && in.eof() && std::isfinite(x);
}
bool near(double a,double b,double rel=.015,double abs=.005) {
    return std::isfinite(a) && std::isfinite(b) && std::abs(a-b)<=abs+rel*std::abs(b);
}
using Index=std::map<std::string,Json>;
Index index(const Json& array) {
    require(array.is_array() && array.size()<=256,"array_limit"); Index result;
    for(const auto& a:array) {
        std::string id=text(a.at("id"));
        require(result.emplace(id,a).second,"duplicate_item_id");
    }
    return result;
}
struct Grader {
    Json items=Json::array(); Index answers,observations; std::set<std::string> used_answers,used_observations;
    explicit Grader(const Json& r):answers(index(r.at("answers"))),observations(index(r.at("observations"))) {}
    void add(const std::string& id,const std::string& label,bool ok,const std::string& comment,const std::string& status="") {
        items.push_back({{"id",id},{"label",label},{"points",ok?1:0},{"max_points",1},
                         {"status",status.empty()?(ok?"correct":"incorrect"):status},{"comment",ok?"Teisingai.":comment}});
    }
    void answer(const std::string& id,const std::string& label,double expected,const std::string& unit,
                const std::string& hint,double rel=.015,double abs=.005) {
        used_answers.insert(id);
        auto it=answers.find(id); std::string raw; bool missing=it==answers.end();
        if(!missing) {require(text(it->second.at("unit"))==unit,"answer_unit"); raw=text(it->second.at("raw"),2048); missing=raw.find_first_not_of(" \t\r\n")==std::string::npos;}
        double value=0; bool parsed=!missing && parse_number(raw,value),ok=parsed&&near(value,expected,rel,abs);
        std::string comment=missing?"Atsakymas neįvestas.":(!parsed?"Įrašas nėra baigtinis skaičius. Įveskite skaičių be formulės ir vieneto.":hint);
        if(parsed && !ok && expected!=0 && (near(value,expected*1000,rel,abs)||near(value,expected/1000,rel,abs)))
            comment+=" Patikrinkite vienetus: atsakymas skiriasi maždaug 1000 kartų.";
        add(id,label,ok,comment,missing?"missing":(!parsed?"invalid":""));
        auto& item=items.back(); item["raw"]=raw; item["unit"]=unit; item["expected"]=expected;
        item["tolerance"]={{"absolute",abs},{"relative",rel}};
        item["given"]=parsed?Json(value):Json(nullptr);
    }
    double observation(const std::string& id,const std::string& unit) {
        used_observations.insert(id); auto it=observations.find(id);
        if(it==observations.end()) return NAN;
        require(text(it->second.at("unit"))==unit,"observation_unit");
        if(it->second.at("value").is_null()) return NAN;
        return number(it->second.at("value"));
    }
    double measured(const std::string& id,const std::string& label,double expected,const std::string& unit,double rel=.02,double abs=.005) {
        double v=observation(id,unit);
        add(id,label,near(v,expected,rel,abs),std::isnan(v)?"Matavimas neužfiksuotas.":"Matavimas neatitinka priskirtos grandinės. Patikrinkite dažnį, zondus ir vienetus.",std::isnan(v)?"missing":"");
        items.back()["expected"]=expected; items.back()["given"]=std::isnan(v)?Json(nullptr):Json(v); items.back()["unit"]=unit;
        return v;
    }
    void finish() {
        for(auto& a:answers) require(used_answers.count(a.first)!=0,"unknown_answer_id");
        for(auto& a:observations) require(used_observations.count(a.first)!=0,"unknown_observation_id");
    }
};
using Pairs=std::vector<std::pair<std::string,std::string>>;
Pairs pairs(const Json& j) {
    require(j.is_array() && j.size()<=128,"wiring_limit"); Pairs r;
    for(const auto& p:j) {require(p.is_array() && p.size()==2,"wire_pair");r.emplace_back(text(p[0]),text(p[1]));}
    return r;
}
bool contains(const Pairs& p,const std::string& a,const std::string& b) {
    return std::any_of(p.begin(),p.end(),[&](const auto& e){return (e.first==a&&e.second==b)||(e.second==a&&e.first==b);});
}
bool ld2_wiring(const Json& j,const std::string& phase) {
    auto p=pairs(j); std::string first=phase=="RC"?"R8":phase=="RL"?"R9":"C4";
    std::string second=phase=="RC"?"C2":phase=="RL"?"L1":"L3";
    Pairs req={{"GEN_H","AM_H"},{"AM_L",first+"_1"},{first+"_2",second+"_1"},
               {phase=="RLC"?"R13_2":second+"_2","GEN_L"}};
    if(phase=="RLC") req.emplace_back("L3_2","R13_1");
    for(auto& e:req) if(!contains(p,e.first,e.second)) return false;
    // Only the two removable voltmeter probes may accompany the main circuit.
    std::set<std::pair<std::string,std::string>> unique;
    int high=0,low=0;
    for(auto e:p) {
        if(e.first>e.second) std::swap(e.first,e.second);
        if(!unique.insert(e).second || e.first==e.second) return false;
        if(contains(req,e.first,e.second)) continue;
        if(e.first=="VM_H" || e.second=="VM_H") ++high;
        else if(e.first=="VM_L" || e.second=="VM_L") ++low;
        else return false;
    }
    return high<=1 && low<=1;
}
struct Nodes {
    std::map<std::string,std::string> parent;
    std::string root(const std::string& a) {auto it=parent.emplace(a,a).first; return it->second==a?a:root(it->second);}
    void join(const std::string& a,const std::string& b) {auto x=root(a),y=root(b);parent[x]=y;}
};
bool ld1_wiring(const Json& j,bool series) {
    auto p=pairs(j.at("pairs")); if(p.size()!=(series?4u:9u) || text(j.at("meter"))!=(series?"A":"V")) return false;
    std::set<std::string> allowed={"SRC_P","SRC_N","M_P","M_N","VR1_1","VR1_2"};
    for(auto r:series?std::vector<std::string>{"R1"}:std::vector<std::string>{"R2","R3"}) {allowed.insert(r+"_1");allowed.insert(r+"_2");}
    Nodes nodes;
    if(!series) for(int i=1;i<=4;++i) for(auto c:{"A","B"}) {
        std::string id="NODE_"+std::string(c)+std::to_string(i);allowed.insert(id);nodes.join(id,"NODE_"+std::string(c)+"1");
    }
    std::set<std::pair<std::string,std::string>> seen;
    for(auto e:p) {
        if(!allowed.count(e.first)||!allowed.count(e.second)||e.first==e.second) return false;
        if(e.first>e.second) std::swap(e.first,e.second);
        if(!seen.insert(e).second) return false;
        nodes.join(e.first,e.second);
    }
    auto pair=[&](std::string a,std::string b) {return std::make_pair(nodes.root(a),nodes.root(b));};
    auto src=pair("SRC_P","SRC_N"); if(src.first==src.second) return false;
    if(series) {
        std::map<std::string,int> degree; Nodes connected;
        for(auto e:Pairs{src,pair("M_P","M_N"),pair("R1_1","R1_2"),pair("VR1_1","VR1_2")}) {
            if(e.first==e.second) return false;
            ++degree[e.first];++degree[e.second];connected.join(e.first,e.second);
        }
        if(degree.size()!=4) return false;
        for(auto& d:degree) if(d.second!=2||connected.root(d.first)!=connected.root(src.first)) return false;
        return true;
    }
    auto equal=[](auto a,auto b){return a==b || (a.first==b.second && a.second==b.first);};
    if(!equal(pair("M_P","M_N"),src)||!equal(pair("R3_1","R3_2"),src)) return false;
    auto a=pair("R2_1","R2_2"),b=pair("VR1_1","VR1_2");
    for(int i=0;i<2;++i) {std::swap(a.first,a.second);for(int k=0;k<2;++k) {
        std::swap(b.first,b.second);
        if(a.first!=a.second && b.first!=b.second && a.second==b.first && equal(std::make_pair(a.first,b.second),src)) return true;
    }} return false;
}
void parameters(const Json& r,const Json& expected) {
    const auto& p=r.at("parameters"); require(p.is_object()&&p.size()==expected.size(),"parameters_shape");
    for(auto it=expected.begin();it!=expected.end();++it)
        require(near(number(p.at(it.key())),number(it.value()),1e-12,1e-15),"variant_parameters_mismatch");
}
void grade_dc(Grader& g,const Json& r,const Bank& b) {
    parameters(r,{{"E",10},{"R1",b.r1},{"R2",b.r2},{"R3",b.r3}});
    double i=10000/(b.r1+1000),j=10000/(b.r1+500),i1=10000/b.r3,i2=10000/b.r2;
    g.answer("s2.q1","2 etapas: bendra varža",b.r1+1000,"Ohm","Rb = R1 + 1000 Ω.",.01,1e-9);
    g.answer("s2.q2","2 etapas: srovė",i,"mA","I = 10 / Rb × 1000 mA.",.01,1e-9);
    g.answer("s4.q1","4 etapas: bendra varža",b.r1+500,"Ohm","Rb = R1 + 500 Ω.",.01,1e-9);
    g.answer("s4.q2","4 etapas: srovė",j,"mA","I = 10 / Rb × 1000 mA.",.01,1e-9);
    g.answer("s6.q1","6 etapas: lygiagreti varža",b.r3*(b.r2+1000)/(b.r3+b.r2+1000),"Ohm","Rb = R3 × (R2+1000) / (R3+R2+1000).",.01,1e-9);
    for(auto q:std::vector<std::pair<std::string,double>>{{"s8.q1",i1},{"s8.q2",i2},{"s8.q3",i1+i2}})
        g.answer(q.first,"8 etapas: Kirchhofo srovės",q.second,"mA","I1=10/R3×1000; I2=10/R2×1000; I=I1+I2.",.01,1e-9);
    g.answer("s1.type","1 etapas: grandinės tipas",1,"choice","1 – nuosekli; 2 – lygiagreti; 3 – mišri.",0,0);
    g.answer("s5.type","5 etapas: grandinės tipas",2,"choice","R3 ir R2+VR1 sudaro lygiagrečias šakas.",0,0);
    double base=g.measured("s6.measure","6 etapas: UAB",10,"V",.05);
    for(auto p:std::vector<std::pair<int,double>>{{3,i},{4,j},{6,10},{7,10},{8,i1+i2}}) {
        int step=p.first; auto id="s"+std::to_string(step);
        double v=step==6?base:g.measured(id+".measure",std::to_string(step)+" etapas: matavimas",p.second,step==7?"V":"mA",.05);
        double ref=p.second;
        // Comparison is against the student's calculation where the bench asks
        // for it; a wrong calculation loses its own point, not this reasoning point.
        if(step==3 || step==4) {
            auto it=g.answers.find(step==3?"s2.q2":"s4.q2");double own=0;
            if(it!=g.answers.end() && parse_number(text(it->second.at("raw"),2048),own)&&own>0) ref=own;
        }
        if(step==7 && std::isfinite(base)) ref=base;
        bool match=near(v,ref,.05,0);
        double expected=step==7?(match?2:1):(match?1:2);
        g.answer(id+".compare",std::to_string(step)+" etapas: palyginimas",expected,"choice","Palyginkite užfiksuotas reikšmes: 5 % riba; 1 – Taip, 2 – Ne.",0,0);
        if(!std::isfinite(v)) {g.items.back()["points"]=0;g.items.back()["status"]="missing_evidence";g.items.back()["comment"]="Palyginimui trūksta matavimo.";}
    }
    for(int s:{1,5}) g.add("s"+std::to_string(s)+".wiring",std::to_string(s)+" etapas: sujungimas",
        ld1_wiring(r.at("evidence").at("wiring").at("s"+std::to_string(s)),s==1),
        "Patikrinkite šaltinio, rezistorių ir matuoklio sujungimą. Vertinama išsaugota topologija.");
}
struct Point {double f,u;};
std::vector<Point> points(const Json& rows,const Bank& b,const std::string& target,bool& valid) {
    require(rows.is_array()&&rows.size()<=2048,"points_limit"); std::vector<Point> p; std::set<double> seen;
    for(auto& row:rows) {
        if(row.contains("target") && text(row.at("target"))!=target) continue;
        double f=number(row.at("f")),u=number(row.at("u"));
        if(f<0 || f>10000 || !seen.insert(f).second) {valid=false;continue;}
        auto v=ac(3,5,f,b.r13,b.l3,b.c4); int idx=target=="UR"?4:target=="UL"?5:target=="UC"?6:7;
        if(!near(u,v[idx],.002,.005)) valid=false;
        p.push_back({f,u});
    } return p;
}
bool bracket(const std::vector<Point>& p,Point best) {
    bool lo=false,hi=false; for(auto v:p) {lo|=v.f<best.f;hi|=v.f>best.f;} return p.size()>=3 && lo&&hi;
}
Point best_point(const std::vector<Point>& p,bool minimum=false) {
    Point best{NAN,NAN};for(auto v:p) if(std::isnan(best.u)||(minimum?v.u<best.u:v.u>best.u)) best=v; return best;
}
void dependent(Grader& g,const std::string& id,const std::string& label,double ref,const std::string& unit,bool valid,double rel=.015) {
    g.answer(id,label,std::isfinite(ref)?ref:0,unit,"Atsakymą apskaičiuokite iš savo užfiksuotų matavimo taškų.",rel);
    if(!valid || !std::isfinite(ref)) {
        g.items.back()["points"]=0;g.items.back()["status"]="missing_evidence";g.items.back()["expected"]=nullptr;
        g.items.back()["comment"]="Trūksta tinkamų matavimo taškų. Pirmiausia atlikite ir užfiksuokite bandymą.";
    }
}
void grade_ac(Grader& g,const Json& r,const Bank& b) {
    parameters(r,{{"E_RC",9},{"F_RC",b.frc},{"R8",b.r8},{"C2",4.7e-6},{"E_RL",9},{"F_RL",b.frl},{"R9",b.r9},{"L1",.5},{"E_RLC",5},{"R13",b.r13},{"L3",b.l3},{"C4",b.c4}});
    for(int kind:{1,2}) {
        bool rc=kind==1;int s=rc?3:6;auto v=ac(kind,9,rc?b.frc:b.frl,rc?b.r8:b.r9,.5,4.7e-6);
        double refs[]={v[rc?1:0],v[2],v[3]*1000,v[4],v[rc?6:5],v[8]*1000,-v[9]};
        const char* units[]={"Ohm","Ohm","mA","V","V","mW","deg"};
        const char* labels[]={"reaktyvioji varža","impedanso modulis","srovė","rezistoriaus įtampa","reaktyviojo elemento įtampa","aktyvioji galia","srovės fazė"};
        for(int q=0;q<7;++q) g.answer("s"+std::to_string(s)+".q"+std::to_string(q+1),std::to_string(s)+" etapas: "+labels[q],refs[q],units[q],"Naudokite kompleksinį impedansą ir RMS dydžius. P=I²R; srovės fazė priešinga impedanso fazei.");
        std::string prefix=rc?"rc_":"rl_";
        double mi=g.measured(prefix+"I",prefix+"I",v[3],"A",.002,5e-6);
        double ur=g.measured(prefix+"UR",prefix+"UR",v[4],"V"),ux=g.measured(prefix+(rc?"UC":"UL"),prefix+"UX",v[rc?6:5],"V");
        double ue=g.measured(prefix+"UE",prefix+"UE",9,"V");
        bool valid=std::isfinite(mi)&&std::isfinite(ur)&&std::isfinite(ux)&&std::isfinite(ue);
        dependent(g,"s"+std::to_string(s+1)+".q1","Įtampų vektorinė suma",std::hypot(ur,ux),"V",valid);
        dependent(g,"s"+std::to_string(s+1)+".q2","Srovė pagal UR/R",ur/(rc?b.r8:b.r9)*1000,"mA",valid);
    }
    const auto& e=r.at("evidence");
    for(auto p:std::vector<std::pair<std::string,int>>{{"RC",2},{"RL",5},{"RLC",8}})
        g.add("s"+std::to_string(p.second)+".wiring",p.first+" sujungimas",ld2_wiring(e.at("wiring").at(p.first),p.first),"Trūksta pagrindinės grandinės jungčių arba yra papildomų netinkamų laidų.");
    double f0=1/(2*std::acos(-1.0)*std::sqrt(b.l3*b.c4));
    bool valid=true;auto rp=points(e.at("resonance"),b,"UR",valid);auto best=best_point(rp);
    bool resonance=valid&&bracket(rp,best)&&best.u>=.97*5;
    g.add("s9.experiment","Rezonanso paieškos taškai",resonance,"Užfiksuokite bent 3 dažnius abipus UR maksimumo; maksimumas turi siekti bent 97 % E.");
    g.answer("s9.q1","Teorinis rezonanso dažnis",f0,"Hz","f0=1/(2π√(LC)).",.005);
    dependent(g,"s9.q2","Išmatuotas rezonanso dažnis",best.f,"Hz",resonance,.0002);
    dependent(g,"s9.q3","Išmatuotas periodas",1000/best.f,"ms",resonance,.01);
    dependent(g,"s9.q4","UR maksimumas",best.u,"V",resonance);
    int q=1;
    for(auto target:{"UL","UC","ULC"}) {
        valid=true;auto pp=points(e.at("peaks"),b,target,valid);auto bp=best_point(pp,std::string(target)=="ULC");
        bool ok=valid&&bracket(pp,bp)&&(std::string(target)!="ULC"||bp.u<=.5);
        g.add("s10.experiment."+std::string(target),std::string(target)+" ekstremumo paieška",ok,"Reikia trijų skirtingų dažnių abipus ekstremumo ir modelį atitinkančių rodmenų.");
        dependent(g,"s10.q"+std::to_string(q),std::string(target)+" ekstremumas",bp.u,"V",ok);
        dependent(g,"s10.q"+std::to_string(q+3),std::string(target)+" ekstremumo dažnis",bp.f,"Hz",ok,.0002);++q;
    }
    double f1=g.observation("f1_meas","Hz"),f2=g.observation("f2_meas","Hz"),u1=g.observation("f1_u","V"),u2=g.observation("f2_u","V");
    double threshold=(std::isfinite(best.u)?best.u:5)/std::sqrt(2.0);
    bool half=std::isfinite(f1)&&std::isfinite(f2)&&f1>0&&f1<f0&&f2>f0&&f2<=10000 &&
        near(u1,threshold,.0301,0)&&near(u2,threshold,.0301,0);
    if(half) half=near(u1,ac(3,5,f1,b.r13,b.l3,b.c4)[4],.002,.005)&&near(u2,ac(3,5,f2,b.r13,b.l3,b.c4)[4],.002,.005);
    g.add("s11.experiment","Pusės galios dažnių matavimai",half,"Išmatuokite f1 ir f2 skirtingose rezonanso pusėse, ties URmax/√2 slenksčiu (3 % paklaida).");
    double refs[]={threshold,f1,f2,f2-f1,(std::isfinite(best.f)?best.f:f0)/(f2-f1)};
    const char* units[]={"V","Hz","Hz","Hz","1"};double rel[]={.015,.0002,.0002,.02,.02};
    for(int k=0;k<5;++k) dependent(g,"s11.q"+std::to_string(k+1),"Pusės galios tyrimas: "+std::to_string(k+1),refs[k],units[k],half,rel[k]);
    valid=true;auto sweep=points(e.at("sweep"),b,"UR",valid);bool sweep_ok=valid&&sweep.size()==11;
    for(int k=0;k<=10;++k) if(std::none_of(sweep.begin(),sweep.end(),[&](auto p){return p.f==k*1000;})) sweep_ok=false;
    g.add("s12.sweep","0–10 kHz dažninė lentelė",sweep_ok,"Reikia 11 modelį atitinkančių matavimų: 0, 1000, …, 10000 Hz.");
}
} // namespace

Json read_report(const std::filesystem::path& path) {
    require(!std::filesystem::is_symlink(path)&&std::filesystem::is_regular_file(path),"file_type");
    require(std::filesystem::file_size(path)<=2*1024*1024,"file_size_limit");
    std::ifstream in(path,std::ios::binary);require(bool(in),"cannot_read");
    // Bound the read as well as the initial stat: a concurrently growing file
    // must not bypass the importer memory limit.
    std::string body(2*1024*1024+1,'\0');in.read(body.data(),static_cast<std::streamsize>(body.size()));
    auto count=in.gcount();require(!in.bad(),"cannot_read");require(count<=2*1024*1024,"file_size_limit");
    body.resize(static_cast<size_t>(count));
    const std::string start="<script type=\"application/json\" id=\"ld-data\">",end="</script>";
    auto a=body.find(start);require(a!=std::string::npos&&body.find(start,a+start.size())==std::string::npos,"data_block");
    a+=start.size();auto b=body.find(end,a);require(b!=std::string::npos,"data_block");
    std::vector<std::set<std::string>> keys;
    auto callback=[&](int depth,Json::parse_event_t event,Json& value){
        require(depth<=32,"depth_limit");
        if(event==Json::parse_event_t::object_start) keys.emplace_back();
        if(event==Json::parse_event_t::key) require(keys.back().insert(value.get<std::string>()).second,"duplicate_key");
        if(event==Json::parse_event_t::object_end) keys.pop_back();
        return true;
    };
    return Json::parse(body.begin()+static_cast<std::ptrdiff_t>(a),body.begin()+static_cast<std::ptrdiff_t>(b),callback);
}
Json grade(const Json& r) {
    require(r.at("schema_version").is_number_integer()&&r.at("schema_version")==1,"unsupported_schema");
    auto lab=text(r.at("lab_id"));require(lab=="LD1"||lab=="LD2","unsupported_lab");
    require(r.at("lab_revision")=="1"&&r.at("rubric_version")==lab+"-1"&&r.at("bank_id")==lab+"-64-A-2026","unsupported_version");
    require(r.at("variant").is_number_integer(),"variant_type");
    require(r.at("variant")>=1 && r.at("variant")<=64,"variant_range");
    int variant=r.at("variant").get<int>();auto b=bank(variant);
    const auto& s=r.at("student");
    require(s.at("number").is_number_integer()&&s.at("number")==variant,"student_number");
    for(auto k:{"name","group"}) require(text(s.at(k)).find_first_not_of(" \t\r\n")!=std::string::npos,"student_identity");
    auto id=text(r.at("submission_id"),128);require(!id.empty(),"submission_identity");
    require(r.at("mode")=="learning"||r.at("mode")=="assessment","mode");
    text(r.at("note"),32000);
    Grader g(r);if(lab=="LD1") grade_dc(g,r,b);else grade_ac(g,r,b);g.finish();
    int points=0;for(auto& item:g.items) points+=item.at("points").get<int>();
    return {{"status","graded"},{"submission_id",id},{"student",s},{"lab_id",lab},{"variant",variant},
            {"mode",r.at("mode")},{"bank_id",r.at("bank_id")},{"lab_revision","1"},{"rubric_version",lab+"-1"},
            {"core_version","0.2.0"},{"points",points},{"max_points",g.items.size()},
            {"grade_10",std::round(100.0*points/g.items.size())/10.0},{"items",g.items},
            {"note",r.at("note")},{"note_policy","Laisvas tekstas išsaugomas; už jo turinį ši skaitinė rubrika balų neskiria."}};
}
std::string html_escape(const std::string& s) {
    std::string o;for(char c:s) switch(c) {case '&':o+="&amp;";break;case '<':o+="&lt;";break;case '>':o+="&gt;";break;case '"':o+="&quot;";break;case '\'':o+="&#39;";break;default:o+=c;}return o;
}
} // namespace ld
