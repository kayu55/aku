#!/bin/bash

NC='\033[0;37m' 
MYIP=$(curl -sS ipv4.icanhazip.com)
clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
#tr="$(cat ~/log-install.txt | grep -w "Trojan WS " | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
echo -e " \E[42;1;37m              CREATE TROJAN ACCOUNT              \E[0m"
echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"

		read -rp "User: " -e user
		user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
		
		if [[ ${user_EXISTS} == '1' ]]; then
clear
		echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
		echo -e " \E[42;1;37m               CREATE TROJAN ACCOUNT             \E[0m"
		echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			echo ""
			echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
			read -n 1 -s -r -p "Press any key to back on menu"
			menu-trojan
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

systemctl restart xray
trojanlink="trojan://${uuid}@bug.com:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"
clear
echo -e "\033[0;34m════════════\033[0;33mXRAY/TROJANWS\033[0;34m════════════${NC}"
echo -e "Remarks     : ${user}" 
echo -e "Created     : $hariini"
echo -e "Expired On  : $exp" 
echo -e "Host/IP     : ${domain}" 
echo -e "Port        : 443, 8443, 2087, 2096, 2053, 2083 "
echo -e "Key         : ${uuid}" 
echo -e "Path        : /trojan-ws"
echo -e "ServiceName : trojan-grpc" 
echo -e "\033[0;34m════════════════════════════════════${NC}"
echo -e "Link WS : "
echo -e "${trojanlink}" 
echo -e "\033[0;34m════════════════════════════════════${NC} "
echo -e "Link GRPC : "
echo -e "${trojanlink1}"
echo -e "\033[0;34m════════════════════════════════════${NC}" 
echo -e ""
echo -e " \033[0;32mSc By Arya Blitar${NC}" 
echo "" 
read -n 1 -s -r -p "Press any key to back on menu"

menu-trojan
