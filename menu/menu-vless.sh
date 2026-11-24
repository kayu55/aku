#!/bin/bash
NC='\033[0;37m'
PURPLE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BIWhite='\033[1;97m'
COLOR1='\033[1;34m'
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
clear

# === HELPER - MUNG VLESS TOK! Iki kuncine! ===
# Moco mung neng antarane #vless / #vlessgrpc, VMESS/TROJAN gak diwoco!
vless_users() {
awk '
/^#vless$/ {in_v=1; next}
/^#vlessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && /^### / {print $2}
' /etc/xray/config.json | sort -u
}
vless_exp() { grep -h "^### $1 " /etc/xray/config.json | head -1 | awk '{print $3}'; }
vless_uuid() {
awk -v u="$1" '
/^#vless$/ {in_v=1; next}
/^#vlessgrpc$/ {in_v=1; next}
/^#/ && !/^###/ {in_v=0; next}
in_v && index($0, "\"email\": \"" u "\"") {
  if (match($0, /"id": *"[^"]*"/)) { s=substr($0, RSTART, RLENGTH); gsub(/"id": *"|"/, "", s); print s; exit }
}' /etc/xray/config.json
}

function renewws(){
clear
mapfile -t USERS < <(vless_users)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  clear; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "\E[42;1;37m          Perpanjang Vless         \E[0m"
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m          Perpanjang Vless         \E[0m"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""; echo "     No  User   Expired"
for i in "${!USERS[@]}"; do u="${USERS[$i]}"; e=$(vless_exp "$u"); printf "%s) %s %s\n" "$((i+1))" "$u" "$e"; done
echo ""; red "tap enter to go back"; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then user="${USERS[$((input-1))]}"; else user="$input"; fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then echo ""; echo "User $user dudu VLESS!"; sleep 2; menu; return; fi
read -p "Expired (days): " masaaktif
exp=$(vless_exp "$user")
now=$(date +%Y-%m-%d); d1=$(date -d "$exp" +%s); d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 )); exp3=$(($exp2 + $masaaktif)); exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
# RENEW MUNG NENG BAGIAN VLESS TOK, VMESS/TROJAN OJO DIUBAH!
cp /etc/xray/config.json /etc/xray/config.json.bak
awk -v u="$user" -v ne="$exp4" '
/^#vless$/ {in_v=1; print; next}
/^#vlessgrpc$/ {in_v=1; print; next}
/^#/ && !/^###/ {in_v=0; print; next}
in_v && $0 ~ "^### " u " " {print "### " u " " ne; next}
{print}
' /etc/xray/config.json > /tmp/cfg.tmp && mv /tmp/cfg.tmp /etc/xray/config.json
clear; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Akun Vless Berhasil Diperpanjang"; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""; echo " Client Name : $user"; echo " Expired On  : $exp4"; echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo ""
read -n 1 -s -r -p "Press any key to back on menu"; menu
}

function delws() {
clear
mapfile -t USERS < <(vless_users)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e " \E[42;1;37m       Delete XRAY  Account         \E[0m"
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m       Delete XRAY Account         \E[0m"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired  "
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
for i in "${!USERS[@]}"; do u="${USERS[$i]}"; e=$(vless_exp "$u"); printf "%s) %s %s\n" "$((i+1))" "$u" "$e"; done
echo ""; red "tap enter to go back"; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then user="${USERS[$((input-1))]}"; else user="$input"; fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then echo ""; echo "User $user gak ketemu!"; sleep 2; menu; return; fi
exp=$(vless_exp "$user")
cp /etc/xray/config.json /etc/xray/config.json.bak
# HAPUS MUNG NENG BAGIAN VLESS TOK! VMESS/TROJAN SING JENENG E PODO, AMAN!
awk -v u="$user" '
/^#vless$/ {in_v=1; print; next}
/^#vlessgrpc$/ {in_v=1; print; next}
/^#/ && !/^###/ {in_v=0; print; next}
in_v && $0 ~ "^### " u " " {next}
in_v && index($0, "\"email\": \"" u "\"") {next}
{print}
' /etc/xray/config.json > /tmp/cfg.tmp && mv /tmp/cfg.tmp /etc/xray/config.json
SISA=$(awk '/^#vless$/{in_v=1;next} /^#vlessgrpc$/{in_v=1;next} /^#/&&!/^###/{in_v=0;next} in_v && index($0,"'"$user"'")' /etc/xray/config.json | wc -l)
systemctl restart xray > /dev/null 2>&1
clear; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$SISA" == "0" ]]; then echo -e " XRAY Account Deleted Successfully"; else echo -e " GAGAL! File dibalekno!"; cp /etc/xray/config.json.bak /etc/xray/config.json; systemctl restart xray > /dev/null 2>&1; fi
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"; echo " Expired On  : $exp"; echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo ""
read -n 1 -s -r -p "Press any key to back on menu"; menu
}

function user-vless(){
clear
mapfile -t USERS < <(vless_users)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then echo "Gak ono user VLESS!"; read -n 1 -s -r -p "Press any key"; menu; return; fi
echo "     Check Detail XRAY VLESS"; echo "---------------------------------"; echo "     No  User   Expired"
for i in "${!USERS[@]}"; do u="${USERS[$i]}"; e=$(vless_exp "$u"); echo "$((i+1))) $u $e"; done
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"; [ -z "$user" ] && menu
domain=$(cat /etc/xray/domain); exp=$(vless_exp "$user"); uuid=$(vless_uuid "$user")
IP_AKTIF=$(ss -tn state established '( sport = :443 )' | awk '{print $5}' | cut -d: -f1 | sort -u)
echo "$IP_AKTIF" | while read IP; do [ -z "$IP" ] && continue; grep "$IP" /var/log/nginx/access.log 2>/dev/null | tail -n 5 | grep -q "$user" && echo "[REAL] $IP"; done | sort -u > /tmp/ip_aktif.txt
DEVICE=$(wc -l < /tmp/ip_aktif.txt)
vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"
clear; echo -e "=========== XRAY/VLESS ==========="; echo -e "Remarks       : ${user}"; echo -e "Expired On    : $exp"; echo -e "Domain        : ${domain}"; echo -e "id            : ${uuid}"; echo -e "Device : $DEVICE DEVICE"; cat /tmp/ip_aktif.txt
echo -e "=================================="; echo -e "Link TLS : ${vlesslink1}"; echo -e "=================================="; echo -e "Link none TLS : ${vlesslink2}"; echo -e "=================================="; echo -e "Link GRPC : ${vlesslink3}"; echo -e "=================================="
read -n 1 -s -r -p "Press any key to back on menu"; menu
}
clear
echo -e "${PURPLE}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│\E[42;1;37m                    VLESS MENU                   ${PURPLE}│$NC"
echo -e "${PURPLE}└─────────────────────────────────────────────────┘${NC}"
echo -e "${PURPLE}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${PURPLE}[${BIWhite}1${PURPLE}]${NC} Create Vless Account     "
echo -e "     ${PURPLE}[${BIWhite}2${PURPLE}]${NC} Trial Vless Account     "
echo -e "     ${PURPLE}[${BIWhite}3${PURPLE}]${NC} Delete Account Vless     "
echo -e "     ${PURPLE}[${BIWhite}4${PURPLE}]${NC} Renew Account Vless     "
echo -e "     ${PURPLE}[${BIWhite}5${PURPLE}]${NC} Cek Account Vless     "
echo -e ""
echo -e "     ${PURPLE}[${BIWhite}0${PURPLE}]${NC} Back To Menu     "
echo -e "${PURPLE}└─────────────────────────────────────────────────┘${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; create_vless ;;
2) clear ; trialvless ;;
3) clear ; delws;;
4) clear ; renewws ;;
5) clear ; user-vless ;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back on menu" ; sleep 1 ; menu ;;
esac