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
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
        echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "\E[42;1;37m          Perpanjang Vless         \E[0m"
        echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
		echo ""
		echo "You have no existing clients!"
		echo ""
		echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
	fi

	clear
	echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\E[42;1;37m          Perpanjang Vless         \E[0m"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
  	grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
    echo ""
    red "tap enter to go back"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	read -rp "Input Username : " user
    if [ -z $user ]; then
    menu
    else
    read -p "Expired (days): " masaaktif
    exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
    sed -i "/### $user/c\### $user $exp4" /etc/xray/config.json
    systemctl restart xray > /dev/null 2>&1
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
  fi
}
function delws() {
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e " \E[42;1;37m       Delete XRAY  Account         \E[0m"
        echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
		echo ""
		echo "You have no existing clients!"
		echo ""
		echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
		read -n 1 -s -r -p "Press any key to back on menu"
        menu
	fi

	clear
	echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\E[42;1;37m       Delete XRAY Account         \E[0m"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "  User       Expired  " 
	echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
    echo ""
    red "tap enter to go back"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	read -rp "Input Username : " user
    if [ -z $user ]; then
    menu
    else
    exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
    systemctl restart xray > /dev/null 2>&1
    clear
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " XRAY Account Deleted Successfully"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo " Client Name : $user"
    echo " Expired On  : $exp"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to back on menu"
    
    menu
    fi
}
function user-vless(){
clear
# MUNG user VLESS tok! Gak campur vmess/trojan!
# Vless neng config mu ono 2 blok: #vless lan #vlessgrpc, user e podo
# Dadi ambil soko blok #vless tok

# Golek list user vless: baris sakwise #vless
mapfile -t USERS < <(grep -A1 '^#vless$' /etc/xray/config.json | grep '^### ' | awk '{print $2}' | sort -u)
NUMBER=${#USERS[@]}

if [[ $NUMBER == '0' ]]; then
  echo "Gak ono user VLESS!"
  read -n 1 -s -r -p "Press any key to back on menu"
  menu-vless
  exit 0
fi

echo -e "     Check Detail XRAY VLESS"
echo -e "---------------------------------"
echo -e "     No  User   Expired"
for i in "${!USERS[@]}"; do
  u="${USERS[$i]}"
  e=$(grep -w "^### $u" /etc/xray/config.json | head -1 | awk '{print $3}')
  echo "$((i+1))) $u $e"
done

read -rp "Select one client [1-$NUMBER]: " CLIENT_NUMBER
user="${USERS[$((CLIENT_NUMBER-1))]}"
[ -z "$user" ] && menu-vless

domain=$(cat /etc/xray/domain)
# UUID VLESS seng bener: sakdurunge ### user neng blok #vless
uuid=$(grep -B2 "^### ${user} " /etc/xray/config.json | grep '"id"' | head -1 | cut -d '"' -f 4)
exp=$(grep -w "^### $user" /etc/xray/config.json | head -1 | awk '{print $3}')

vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

clear
echo -e "=========== XRAY/VLESS ==========="
echo -e "Remarks       : ${user}"
echo -e "Expired On    : $exp"
echo -e "Domain        : ${domain}"
echo -e "Port none TLS : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "Port TLS      : 443, 8443, 2087, 2096, 2053, 2083"
echo -e "Port gRPC     : 443"
echo -e "id            : ${uuid}"
echo -e "Encryption    : none"
echo -e "Network       : ws"
echo -e "Path          : /vless"
echo -e "ServiceName   : vless-grpc"
echo -e "=================================="
echo -e "Link TLS : "
echo -e "${vlesslink1}"
echo -e "=================================="
echo -e "Link none TLS : "
echo -e "${vlesslink2}"
echo -e "=================================="
echo -e "Link GRPC : "
echo -e "${vlesslink3}"
echo -e "=================================="
echo -e " Sc By Arya Blitar"
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
1) clear ; add-vless ;;
2) clear ; trialvless ;;
3) clear ; delws;;
4) clear ; renewws ;;
5) clear ; user-vless ;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back on menu" ; sleep 1 ; menu ;;
esac
