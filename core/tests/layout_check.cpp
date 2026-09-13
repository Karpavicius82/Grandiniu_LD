// Internal audit of coordinates exported from real Scilab controls.
// No Python dependency in either the student runtime or this checker.
#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
struct Rect { double x,y,w,h; };
struct Item {std::string scenario,path,style,tag; Rect r,parent; double font;};
bool overlap(Rect a,Rect b,double eps=.75) {
 return std::min(a.x+a.w,b.x+b.w)-std::max(a.x,b.x)>eps &&
        std::min(a.y+a.h,b.y+b.h)-std::max(a.y,b.y)>eps;
}
bool inside(Rect a,Rect b,double eps=1.) {
 return a.x>=b.x-eps && a.y>=b.y-eps && a.x+a.w<=b.x+b.w+eps && a.y+a.h<=b.y+b.h+eps;
}
bool action(const Item& a) {
 return a.style=="pushbutton" || a.style=="edit" || a.style=="radiobutton" || a.style=="checkbox" || a.style=="slider";
}
bool prefix(const std::string& s,const std::string& p) {return s.rfind(p,0)==0;}
bool terminal(const Item& a) {return a.tag.size()==3 && a.tag[0]=='T' && a.tag[1]>='0' && a.tag[1]<='9';}
bool wire_hits(Rect w,Rect b) {
 // Check the centerline against the component interior, excluding edge leads.
 if(w.w>w.h) return w.y+w.h/2>b.y+1 && w.y+w.h/2<b.y+b.h-1 &&
  std::min(w.x+w.w,b.x+b.w-1)>std::max(w.x,b.x+1)+.75;
 return w.x+w.w/2>b.x+1 && w.x+w.w/2<b.x+b.w-1 &&
  std::min(w.y+w.h,b.y+b.h-1)>std::max(w.y,b.y+1)+.75;
}
bool crossing(Rect a,Rect b) {
 // A sub-stroke cap is a point, not a vertical wire. In particular, a
 // 1.96 x 3 px horizontal bus cap must not become a false crossing.
 if(std::max(a.w,a.h)<=3.01 || std::max(b.w,b.h)<=3.01)return false;
 if(a.w<a.h)std::swap(a,b);
 if(a.w<=a.h || b.h<=b.w)return false;
 double x=b.x+b.w/2,y=a.y+a.h/2;
 return x>a.x+.75 && x<a.x+a.w-.75 && y>b.y+.75 && y<b.y+b.h-.75;
}
int main(int argc,char**argv) {try {
 if(argc==2 && std::string(argv[1])=="--self-test") {
  if(!overlap({284.16,118.4,79.36,24},{307.2,118.4,121.6,24})) throw std::runtime_error("LD3 overlap missed");
  if(overlap({0,0,36,40},{44,0,36,40})) throw std::runtime_error("gap misclassified");
  if(!wire_hits({0,49,200,3},{50,30,50,50})) throw std::runtime_error("wire obstruction missed");
  if(wire_hits({0,9,200,3},{50,30,50,50})) throw std::runtime_error("wire clearance misclassified");
  if(!crossing({0,49,100,3},{49,0,3,100}) || crossing({0,49,100,3},{49,0,3,44})) throw std::runtime_error("crossing/gap misclassified");
  if(crossing({18,10,1.96,3},{0,10,20,3}))throw std::runtime_error("collinear cap misclassified");
  if(inside({95,0,10,10},{0,0,100,100})) throw std::runtime_error("clipping missed");
  std::cout<<"PASS: known overlap, gap, clipping and wire regressions\n"; return 0;
 }
 if(argc!=2) throw std::runtime_error("usage: layoutcheck geometry.tsv | --self-test");
 std::ifstream f(argv[1]); if(!f) throw std::runtime_error("cannot open geometry dump");
 std::map<std::string,std::vector<Item>> cases; std::string line;
 while(std::getline(f,line)) {
  if(line.empty()||line[0]=='#')continue;
  std::vector<std::string> v; std::istringstream stream(line); std::string col;
  while(std::getline(stream,col,'\t'))v.push_back(col);
  if(v.size()!=13)throw std::runtime_error("invalid geometry row: "+line);
  auto d=[&](int i){double n=std::stod(v.at(i)); if(!std::isfinite(n))throw std::runtime_error("nonfinite coordinate");return n;};
  Item i{v[0],v[1],v[2],v[3],{d(4),d(5),d(6),d(7)},{d(8),d(9),d(10),d(11)},d(12)};
  cases[i.scenario].push_back(i);
 }
 if(cases.empty())throw std::runtime_error("empty audit");
 int errors=0, controls=0, wires=0, ports=0; double minGap=1e9;
 auto fail=[&](const Item&a,const std::string& why){++errors;std::cout<<a.scenario<<" "<<a.path<<" ["<<a.tag<<"] "<<why<<"\n";};
 for(const auto& entry:cases) {
  const auto& items=entry.second;
  for(size_t j=0;j<items.size();++j) {
   const auto& a=items[j];
   if(action(a)) {
    ++controls;
    if(!inside(a.r,a.parent))fail(a,"outside parent");
    if(a.r.h<24-.75)fail(a,"target height below 24 px: "+std::to_string(a.r.h));
    if(terminal(a)) {++ports;
     if(a.r.w<35.25 || a.r.h<39.25)fail(a,"contact below 36 x 40 px");
     if(a.font<12)fail(a,"contact font below 12 px");
    }
    for(size_t k=j+1;k<items.size();++k)if(action(items[k])) {
     const auto& b=items[k];
     if(overlap(a.r,b.r))fail(a,"overlaps "+b.path+" ["+b.tag+"]");
     if(terminal(a)&&terminal(b)) {
      double dx=std::max({0.,a.r.x-b.r.x-b.r.w,b.r.x-a.r.x-a.r.w});
      double dy=std::max({0.,a.r.y-b.r.y-b.r.h,b.r.y-a.r.y-a.r.h});
      minGap=std::min(minGap,std::hypot(dx,dy));
      if(std::hypot(dx,dy)<7.99)fail(a,"contact gap below 8 px to "+b.tag);
     }
    }
    for(const auto& b:items)if(prefix(b.tag,"component:")&&!prefix(a.path,b.path+"/"))
     if(overlap(a.r,b.r))fail(a,"covers component "+b.tag);
   }
   if(prefix(a.tag,"wire")) {
    ++wires;
    if(std::abs(std::min(a.r.w,a.r.h)-3)>1.01 && std::max(a.r.w,a.r.h)>3)fail(a,"wire thickness differs from 3 px");
    for(const auto& b:items)if(prefix(b.tag,"component:")&&wire_hits(a.r,b.r))fail(a,"wire enters "+b.tag);
    for(size_t k=j+1;k<items.size();++k)if(prefix(items[k].tag,"wire") && crossing(a.r,items[k].r))fail(a,"unmarked wire crossing at "+items[k].path);
   }
  }
 }
 std::cout<<"scenarios="<<cases.size()<<" controls="<<controls<<" contacts="<<ports<<" wire_segments="<<wires
          <<" min_contact_gap_px="<<minGap<<" errors="<<errors<<"\n";
 return errors?1:0;
 }catch(const std::exception&e){std::cerr<<e.what()<<'\n';return 2;}}
