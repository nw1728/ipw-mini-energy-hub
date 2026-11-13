#!/usr/bin/env bash
# Extracts computeEms() straight out of the sketch, compiles it on the host and
# prints the scenario table from the assignment. Run this after changing any
# EMS constant: the printed numbers must match section 5 of assignment.pdf.
set -euo pipefail
cd "$(dirname "$0")"
SK=../src/main.cpp
OUT=$(mktemp -d)
{
  echo '#include <cstdio>'
  echo '#include <cstdint>'
  echo 'template<class T> T constrain(T v,T a,T b){return v<a?a:(v>b?b:v);}'
  sed -n '/^const int GRID_LIMIT/,/^const int HOUSE2_W/p' "$SK"
  sed -n '/^enum Status/,/^  return r;$/p' "$SK"
  echo '}'
  cat <<'EOF'
int main(){
  struct C{const char*n;int g,b;} cs[]={
    {"Evening, both houses, no sun/wind",0,55},
    {"Cloudy, one house",40,30},
    {"Sunny noon, one house",130,30},
    {"Extremely sunny, one house",200,30}};
  const char* sn[]={"OK","IMPORT","EXPORT"};
  for(auto&c:cs){
    Ems d=computeEms(c.g,c.b,false), s=computeEms(c.g,c.b,true);
    printf("%-34s gen=%3d base=%2d | DUMB ev=%2d grid=%+5d %-7s"
           " | SMART ev=%2d grid=%+5d %s\n",
           c.n,c.g,c.b,d.ev,d.grid,sn[d.status],s.ev,s.grid,sn[s.status]);}
  return 0;}
EOF
} > "$OUT/check.cpp"
g++ -O1 -Wall -o "$OUT/check" "$OUT/check.cpp"
"$OUT/check"
rm -rf "$OUT"
