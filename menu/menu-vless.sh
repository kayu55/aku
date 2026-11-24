#!/bin/bash

NC='\033[0;37m' 
PURPLE='\033[0;34m' 
GREEN='\033[0;32m' 
RED='\033[0;31m'
BIWhite='\033[1;97m'  
COLOR1='\033[1;34m'
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
clear
clear

function renewws(){
clear
# MUNG VLESS TOK - [1,4] - ojo diganti dadi [2,5]!
mapfile -t USERS < <(python3 -c "
import json
txt=open('/etc/xray/config.json').read().splitlines()
clean='\n'.join([l for l in txt if not l.strip().startswith('#')])
j=json.loads(clean)
seen=set()
for idx in [1,4]:
    try:
        for c in j['inbounds'][idx].get('settings',{}).get('clients',[]):
            e=c.get('email')
            if e and e not in seen:
                seen.add(e); print(e)
    except: pass
" | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  clear
  echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
echo ""
echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}')
  printf "%s) %s %s\n" "$((i+1))" "$u" "$e"
done
echo ""
red "tap enter to go back"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then
  user="${USERS[$((input-1))]}"
else
  user="$input"
fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then
  echo ""; echo "User $user dudu VLESS!"; sleep 2; menu; return
fi
read -p "Expired (days): " masaaktif
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq | head -1)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "/^### $user /c\### $user $exp4" /etc/xray/config.json
#systemctl restart xray > /dev/null 2>&1
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Akun Vless Berhasil Diperpanjang"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
  #fi
}
function delws() {
clear
# LIST NGANGGO grep ### TOK, OJO NGANGGO JSON! Mergo JSON e rusak gara-gara create!
mapfile -t USERS < <(grep -h "^### " /etc/xray/config.json | awk '{print $2}' | sort -u)
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
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -h "^### $u " /etc/xray/config.json | head -1 | awk '{print $3}')
  printf "%s) %s %s\n" "$((i+1))" "$u" "$e"
done
echo ""
red "tap enter to go back"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then
  user="${USERS[$((input-1))]}"
else
  user="$input"
fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then
  echo ""; echo "User $user gak ketemu!"; sleep 2; menu; return
fi
exp=$(grep -h "^### $user " /etc/xray/config.json | head -1 | awk '{print $3}')
# === HAPUS 2 BARIS SING DIGAWE CREATE MU, TOK! ===
cp /etc/xray/config.json /etc/xray/config.json.bak
# 1. Hapus baris ### user
sed -i "/^### $user /d" /etc/xray/config.json
# 2. Hapus baris client sing ono email user e (..., "email": "TrialVL168")
# Iki sing penting! Ojo ngenteni }, mergo create mu gak gawe }!
sed -i "/\"email\": \"$user\"/d" /etc/xray/config.json
# Cek tenan wes ilang pora
SISA=$(grep -c "$user" /etc/xray/config.json || true)
systemctl restart xray > /dev/null 2>&1
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$SISA" == "0" ]]; then
  echo -e " XRAY Account Deleted Successfully"
else
  echo -e " GAGAL! Sek ono $SISA baris! File dibalekno!"
  cp /etc/xray/config.json.bak /etc/xray/config.json
  systemctl restart xray > /dev/null 2>&1
fi
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Expired On  : $exp"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
}

}
function user-vless(){
clear
mapfile -t USERS < <(python3 -c "
import json
txt=open('/etc/xray/config.json').read().splitlines()
clean='\n'.join([l for l in txt if not l.strip().startswith('#')])
j=json.loads(clean)
seen=set()
for idx in [1,4]:
    for c in j['inbounds'][idx].get('settings',{}).get('clients',[]):
        e=c.get('email')
        if e and e not in seen:
            seen.add(e); print(e)
" | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then echo "Gak ono user VLESS!"; read -n 1 -s -r -p "Press any key"; menu-vless; exit 0; fi
echo "     Check Detail XRAY VLESS"
echo "---------------------------------"
echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}')
  echo "$((i+1))) $u $e"
done
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"
[ -z "$user" ] && menu-vless
domain=$(cat /etc/xray/domain)
exp=$(grep -w "^### $user" /etc/xray/config.json | head -1 | awk '{print $3}')
uuid=$(python3 -c "
import json
txt=open('/etc/xray/config.json').read().splitlines()
clean='\n'.join([l for l in txt if not l.strip().startswith('#')])
j=json.loads(clean)
for idx in [1,4]:
    for c in j['inbounds'][idx].get('settings',{}).get('clients',[]):
        if c.get('email')=='$user': print(c.get('id','')); exit(0)
")
# === CEK IP AKTIF - CARA BARU, UDU LOG LAWAS! ===
IP_AKTIF=$(ss -tn state established '( sport = :443 )' | awk '{print $5}' | cut -d: -f1 | sort -u)
echo "$IP_AKTIF" | while read IP; do
  [ -z "$IP" ] && continue
  grep "$IP" /var/log/nginx/access.log 2>/dev/null | tail -n 5 | grep -q "$user" && echo "[REAL] $IP"
done | sort -u > /tmp/ip_aktif.txt
DEVICE=$(wc -l < /tmp/ip_aktif.txt)
vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"
clear
echo -e "=========== XRAY/VLESS ==========="
echo -e "Remarks       : ${user}"
echo -e "Expired On    : $exp"
echo -e "Domain        : ${domain}"
echo -e "id            : ${uuid}"
echo -e "Device : $DEVICE DEVICE"
cat /tmp/ip_aktif.txt
echo -e "=================================="
echo -e "Link TLS : ${vlesslink1}"
echo -e "=================================="
echo -e "Link none TLS : ${vlesslink2}"
echo -e "=================================="
echo -e "Link GRPC : ${vlesslink3}"
echo -e "=================================="
read -n 1 -s -r -p "Press any key to back on menu"
menu-vless
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
