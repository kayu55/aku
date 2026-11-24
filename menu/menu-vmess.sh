#!/bin/bash

NC='\033[0;37m' 
PURPLE='\033[0;34m' 
GREEN='\033[0;32m' 
RED='\033[0;31m'
BIWhite='\033[1;97m'  
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
clear
function renewws(){
clear
mapfile -t USERS < <(awk '
/^#vmess$/ {in_v=1; next}
/^#vmessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && /^### / {print $2}
' /etc/xray/config.json | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  clear
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "\E[42;1;37m           Perbarui Vmess          \E[0m"
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m           Perbarui Vmess          \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""; echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -h "^### $u " /etc/xray/config.json | head -1 | awk '{print $3}')
  printf "%s) %s %s\n" "$((i+1))" "$u" "$e"
done
echo ""; red "tap enter to go back"; echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"
if [ -z "$user" ]; then menu; return; fi
read -p "Expired (days): " masaaktif
exp=$(grep -h "^### $user " /etc/xray/config.json | head -1 | awk '{print $3}')
now=$(date +%Y-%m-%d); d1=$(date -d "$exp" +%s); d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 )); exp3=$(($exp2 + $masaaktif)); exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
# RENEW MUNG NENG BAGIAN VMESS TOK!
cp /etc/xray/config.json /etc/xray/config.json.bak
awk -v u="$user" -v ne="$exp4" '
/^#vmess$/ {in_v=1; print; next}
/^#vmessgrpc$/ {in_v=1; print; next}
/^#/ && !/^###/ {in_v=0; print; next}
in_v && $0 ~ "^### " u " " {print "### " u " " ne; next}
{print}
' /etc/xray/config.json > /tmp/cfg.tmp && mv /tmp/cfg.tmp /etc/xray/config.json
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Akun XRAY Berhasil Diperpanjang"; echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""; echo " Client Name : $user"; echo " Expired On  : $exp4 👍"; echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo ""
read -n 1 -s -r -p "Press any key to back on menu"; menu-vmess
}

function delws() {
clear
# LIST MUNG VMESS TOK - nganggo #vmess, OJO json! Mergo json e rusak!
mapfile -t USERS < <(awk '
/^#vmess$/ {in_v=1; next}
/^#vmessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && /^### / {print $2}
' /etc/xray/config.json | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "\E[42;1;37m       Delete Vmess Account        \E[0m"
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m       Delete Vmess Account        \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired  "
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -h "^### $u " /etc/xray/config.json | head -1 | awk '{print $3}')
  printf "%s) %s %s\n" "$((i+1))" "$u" "$e"
done
echo ""; red "tap enter to go back"; echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"
if [ -z "$user" ]; then menu; return; fi
exp=$(grep -h "^### $user " /etc/xray/config.json | head -1 | awk '{print $3}')
cp /etc/xray/config.json /etc/xray/config.json.bak
# HAPUS MUNG NENG BAGIAN #vmess / #vmessgrpc TOK!
# VLESS / TROJAN sing jeneng e podo, AMAN, gak kehapus!
awk -v u="$user" '
/^#vmess$/ {in_v=1; print; next}
/^#vmessgrpc$/ {in_v=1; print; next}
/^#/ && !/^###/ {in_v=0; print; next}
in_v && $0 ~ "^### " u " " {next}
in_v && index($0, "\"email\": \"" u "\"") {next}
{print}
' /etc/xray/config.json > /tmp/cfg.tmp && mv /tmp/cfg.tmp /etc/xray/config.json
# Cek neng bagian VMESS tok, wes ilang pora?
SISA=$(awk '/^#vmess$/{in_v=1;next} /^#vmessgrpc$/{in_v=1;next} /^#/&&!/^###/{in_v=0;next} in_v && index($0,"'"$user"'")' /etc/xray/config.json | wc -l)
systemctl restart xray > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$SISA" == "0" ]]; then echo -e " XRAY Account Deleted Successfully"; else echo -e " GAGAL! File dibalekno!"; cp /etc/xray/config.json.bak /etc/xray/config.json; systemctl restart xray > /dev/null 2>&1; fi
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"; echo " Expired On  : $exp"; echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo ""
read -n 1 -s -r -p "Press any key to back on menu"; menu-vmess
}

function user-ws(){
clear
mapfile -t USERS < <(awk '
/^#vmess$/ {in_v=1; next}
/^#vmessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && /^### / {print $2}
' /etc/xray/config.json | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then echo "Gak ono user VMESS!"; read -n 1 -s -r -p "Press any key"; menu-vmess; exit 0; fi
echo "     Check Detail XRAY Vmess"; echo "---------------------------------"; echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -h "^### $u " /etc/xray/config.json | head -1 | awk '{print $3}')
  echo "$((i+1))) $u $e"
done
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"; [ -z "$user" ] && menu-vmess
domain=$(cat /etc/xray/domain)
exp=$(grep -h "^### $user " /etc/xray/config.json | head -1 | awk '{print $3}')
# UUID dijupuk teko baris email neng bagian VMESS tok, OJO json!
uuid=$(awk -v u="$user" '
/^#vmess$/ {in_v=1; next}
/^#vmessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && index($0, "\"email\": \"" u "\"") {
  if (match($0, /"id": *"[^"]*"/)) { s=substr($0, RSTART, RLENGTH); gsub(/"id": *"|"/, "", s); print s; exit }
}' /etc/xray/config.json)
asu=`cat <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "bug.com",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
ask=`cat <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "bug.com",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF`
grpc=`cat <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF`
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
clear
echo -e "=========== XRAY/VMESS ==========="
echo -e "Remarks       : ${user}"; echo -e "Expired On    : $exp"; echo -e "Domain        : ${domain}"; echo -e "id            : ${uuid}"; echo -e "Path          : /vmess"; echo -e "ServiceName   : vmess-grpc"
echo -e "=================================="; echo -e "Link TLS : ${vmesslink1}"; echo -e "=================================="; echo -e "Link none TLS : ${vmesslink2}"; echo -e "=================================="; echo -e "Link GRPC : ${vmesslink3}"; echo -e "=================================="
read -n 1 -s -r -p "Press any key to back on menu"; menu-vmess
}

clear
echo -e "${PURPLE}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│\E[42;1;37m                    VMESS MENU                   ${PURPLE}│$NC"
echo -e "${PURPLE}└─────────────────────────────────────────────────┘${NC}"
echo -e "${PURPLE}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${PURPLE}[${BIWhite}1${PURPLE}]${NC} Create Vmess Account     "
echo -e "     ${PURPLE}[${BIWhite}2${PURPLE}]${NC} Trial Vmess Account     "
echo -e "     ${PURPLE}[${BIWhite}3${PURPLE}]${NC} Delete Account Vmess     "
echo -e "     ${PURPLE}[${BIWhite}4${PURPLE}]${NC} Renew Account Vmess     "
echo -e "     ${PURPLE}[${BIWhite}5${PURPLE}]${NC} User Account Vmess     "
echo -e ""
echo -e "     ${PURPLE}[${BIWhite}0${PURPLE}]${NC} Back To Menu     "
echo -e "${PURPLE}└──────────────────────────────────────────────────┘${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; create_vmess ;;
2) clear ; trialvmess ;;
3) clear ; delws ;;
4) clear ; renewws;;
5) clear ; user-ws;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo " Klik Enter Balik Menu" ; sleep 1 ; menu ;;
esac
