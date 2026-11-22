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
# ANTI-BUG: moco by protocol=="trojan", OJO by index [3,6]!
mapfile -t USERS < <(python3 -c "
import json
txt=open('/etc/xray/config.json').read().splitlines()
clean='\n'.join([l for l in txt if not l.strip().startswith('#')])
j=json.loads(clean)
seen=set()
for ib in j['inbounds']:
    if ib.get('protocol')!='trojan': continue
    for c in ib.get('settings',{}).get('clients',[]):
        e=c.get('email')
        if e and e not in seen:
            seen.add(e); print(e)
" | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  clear
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[42;1;37m          Perbarui Trojan          \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo ""; read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[42;1;37m          Perbarui Trojan          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}' | tr -d '\r')
  printf "%-4s %-20s %s\n" "$((i+1))) " "$u" "$e"
done
echo ""
red "tap enter to go back"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then
  user="${USERS[$((input-1))]}"
else
  user="$input"
fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then
  echo ""; echo "User $user dudu TROJAN!"; sleep 2; menu; return
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
systemctl restart xray > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \033[0;33mAkun Trojan Berhasil Diperbarui"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-trojan
  #fi
}

function delws() {
clear
mapfile -t USERS < <(python3 -c "
import json
txt=open('/etc/xray/config.json').read().splitlines()
clean='\n'.join([l for l in txt if not l.strip().startswith('#')])
j=json.loads(clean)
seen=set()
for ib in j['inbounds']:
    if ib.get('protocol')!='trojan': continue
    for c in ib.get('settings',{}).get('clients',[]):
        e=c.get('email')
        if e and e not in seen:
            seen.add(e); print(e)
" | sort -u)
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[42;1;37m      Delete Trojan  Account      \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo ""; echo "You have no existing clients!"; echo ""
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  read -n 1 -s -r -p "Press any key to back on menu"; menu; return
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[42;1;37m       Delete Trojan  Account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "     No  User   Expired  "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}' | tr -d '\r')
  printf "%-4s %-20s %s\n" "$((i+1))) " "$u" "$e"
done
echo ""
red "tap enter to go back"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "Input Username / Nomor : " input
if [ -z "$input" ]; then menu; return; fi
if [[ "$input" =~ ^[0-9]+$ ]]; then
  user="${USERS[$((input-1))]}"
else
  user="$input"
fi
if [ -z "$user" ]; then menu; return; fi
if ! printf '%s\n' "${USERS[@]}" | grep -qx "$user"; then
  echo ""; echo "User $user dudu TROJAN!"; sleep 2; menu; return
fi
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq | head -1)
# Hapus AMAN: cek protocol trojan, ojo index!
python3 - "$user" << 'PYEOF'
import sys, json
user=sys.argv[1]
lines=open('/etc/xray/config.json').read().splitlines()
out=[]; cur_proto=""; skip=False
for line in lines:
    if '"protocol"' in line:
        # ambil nama protocol e: "trojan" / "vmess" / "vless"
        cur_proto=line.split('"')[3] if line.count('"')>=4 else ""
    s=line.strip()
    if s.startswith('### ') and len(s.split())>1 and s.split()[1]==user:
        if cur_proto=='trojan':
            skip=True; continue
    if skip:
        if '}' in line:
            skip=False
        continue
    out.append(line)
open('/etc/xray/config.json','w').write('\n'.join(out)+'\n')
PYEOF
systemctl restart xray > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[0;33mTrojan  Account Deleted Successfully"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Client Name : $user"
echo " Expired On  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-trojan
    #fi
}

function user-trojan() {
clear
# MOCO BY MARKER #trojanws / #trojangrpc - podo koyo CREATE mu!
# Ojo gawe inbounds[3,6] maneh, soale create mu gak gawe iku!
mapfile -t USERS < <(awk '
  /#trojanws$/ || /#trojangrpc$/ { in_trojan=1; next }
  /^#.*(vless|vmess|shadowsocks|vlessgrpc|vmessgrpc|trojanws|trojangrpc)/ {
    if ($0 !~ /trojan/) in_trojan=0
    next
  }
  /^#.*$/ && $0 !~ /trojan/ {
    # Nek ketemu marker liyo, metu teko trojan
    if ($0 ~ /#vless|#vmess|#ss|#socks/) in_trojan=0
  }
  in_trojan && /^### / { print $2 }
' /etc/xray/config.json | sort -u)
# Fallback: nek awk nduwur gagal, gawe cara simple - moco kabeh ### neng blok trojan
if [[ ${#USERS[@]} == '0' ]]; then
  mapfile -t USERS < <(python3 -c "
import re
lines=open('/etc/xray/config.json').read().splitlines()
in_trojan=False
users=[]
for l in lines:
    s=l.strip()
    if '#trojanws' in s or '#trojangrpc' in s:
        in_trojan=True; continue
    if s.startswith('#') and ('vless' in s.lower() or 'vmess' in s.lower()):
        in_trojan=False; continue
    if in_trojan and s.startswith('### '):
        parts=s.split()
        if len(parts)>=2 and parts[1] not in users:
            users.append(parts[1])
for u in sorted(set(users)):
    print(u)
")
fi
NUMBER=${#USERS[@]}
if [[ $NUMBER == '0' ]]; then echo "Gak ono user TROJAN!"; echo "Cek: grep -n trojanws /etc/xray/config.json"; read -n 1 -s -r -p "Press any key"; menu-trojan; return; fi
echo "     Check Detail XRAY TROJAN"
echo "---------------------------------"
echo "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}' | tr -d '\r')
  printf "%-4s %-20s %s\n" "$((i+1))) " "$u" "$e"
done
read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"
[ -z "$user" ] && menu-trojan; return
domain=$(cat /etc/xray/domain)
exp=$(grep -w "^### $user" /etc/xray/config.json | head -1 | awk '{print $3}')
# PASSWORD: neng baris ngisor ### user mu! Podo koyo CREATE mu!
# Format create mu: ### user exp  -> baris ngisor e: },{"password": "UUID","email": "user"}
uuid=$(grep -A1 -w "^### $user" /etc/xray/config.json | grep -o '"password": *"[^"]*"' | head -1 | cut -d'"' -f4)
# Fallback: nek cara nduwur gagal, golek by email
if [ -z "$uuid" ]; then
  uuid=$(grep -B1 -A1 "\"email\": *\"$user\"" /etc/xray/config.json | grep -o '"password": *"[^"]*"' | head -1 | cut -d'"' -f4)
fi
IP_AKTIF=$(ss -tn state established '( sport = :443 )' | awk '{print $5}' | cut -d: -f1 | sort -u)
echo "$IP_AKTIF" | while read IP; do
  [ -z "$IP" ] && continue
  grep "$IP" /var/log/nginx/access.log 2>/dev/null | tail -n 5 | grep -q "$user" && echo "[REAL] $IP"
done | sort -u > /tmp/ip_aktif.txt
DEVICE=$(wc -l < /tmp/ip_aktif.txt)
trojanlink="trojan://${uuid}@bug.com:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
clear
echo -e "=========== XRAY/TROJAN ==========="
echo -e "Remarks       : ${user}"
echo -e "Expired On    : $exp"
echo -e "Domain        : ${domain}"
echo -e "password      : ${uuid}"
echo -e "Device : $DEVICE DEVICE"
cat /tmp/ip_aktif.txt
echo -e "=================================="
echo -e "Link WS : ${trojanlink}"
echo -e "=================================="
echo -e "Link GRPC : ${trojanlink1}"
echo -e "=================================="
read -n 1 -s -r -p "Press any key to back on menu"
menu-trojan
}

clear
echo -e "$PURPLE┌─────────────────────────────────────────────────┐${NC}"
echo -e "$PURPLE│\E[42;1;37m                    TROJAN MENU                  $PURPLE│$NC"
echo -e "$PURPLE└─────────────────────────────────────────────────┘${NC}"
echo -e " $PURPLE┌───────────────────────────────────────────────┐${NC}"
echo -e "     ${GREEN}[${BIWhite}1${GREEN}] ${NC}Create Trojan Account      "
echo -e "     ${GREEN}[${BIWhite}2${GREEN}] ${NC}Trial Account Trojan     "
echo -e "     ${GREEN}[${BIWhite}3${GREEN}] ${NC}Delete Account Trojan      "
echo -e "     ${GREEN}[${BIWhite}4${GREEN}] ${NC}Renew Account Trojan      "
echo -e "     ${GREEN}[${BIWhite}5${GREEN}] ${NC}Cek Account Trojan      "
echo -e " "
echo -e "     ${GREEN}[${BIWhite}0${GREEN}] Back To Menu     "
echo -e " ${PURPLE}└──────────────────────────────────────────────┘${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; create_trojan ;;
2) clear ; trialtrojan ;;
3) clear ; delws ;;
4) clear ; renewws;;
5) clear ; user-trojan ;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back on menu" ; sleep 1 ; menu ;;
esac
