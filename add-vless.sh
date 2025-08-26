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
#tls="$(cat ~/log-install.txt | grep -w "Vless TLS" | cut -d: -f2|sed 's/ //g')"
#none="$(cat ~/log-install.txt | grep -w "Vless None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
echo -e "\033[0;34m│\E[42;1;37m            Create Xray/Vless Account            \033[0;34m│"
echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"

		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
		echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
		echo -e "\033[0;34m│\E[42;1;37m            Create Xray/Vless Account            \033[0;34m│"
		echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			echo ""
			read -n 1 -s -r -p "Press any key to back on menu"
			v2ray-menu
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${user}"
systemctl restart xray
clear
echo -e "\033[0;34m═══════════\033[0;33mXRAY/VLESS\033[0;34m═══════════${NC}"
echo -e "\033[0;34m════════════════════════════════${NC}"
echo -e "Remarks       : ${user}" 
echo -e "Created       : $hariini"
echo -e "Expired On    : $exp" 
echo -e "Domain        : ${domain}" 
echo -e "port none TLS : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "port TLS      : 443, 8443, 2087, 2096, 2053, 2083"
echo -e "port GRPC     : 443 "
echo -e "id            : ${uuid}"
echo -e "Encryption    : none" 
echo -e "Network       : ws" 
echo -e "Path          : /vless" 
echo -e "Path          : vless-grpc"  
echo -e "\033[0;34m════════════════════════════════${NC}"
echo -e "Link TLS :"
echo -e "${vlesslink1}" 
echo -e "\033[0;34m════════════════════════════════${NC}"   
echo -e "Link none TLS : "
echo -e "${vlesslink2}" 
echo -e "\033[0;34m════════════════════════════════${NC}"
echo -e "Link GRPC : "
echo -e "${vlesslink3}" 
echo -e "\033[0;34m════════════════════════════════${NC}" 
echo -e ""
echo -e "${GREEN} Sc By Arya Blitar ${NC}" 
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"

menu-vless
