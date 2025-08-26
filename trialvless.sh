#!/bin/bash

NC='\033[0;37m' 
MYIP=$(curl -sS ipv4.icanhazip.com)

clear
user=trialvles`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
domain=$(cat /etc/xray/domain)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80$none?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${user}"
systemctl restart xray
clear
echo -e "\033[0;34m═════════════\033[0;33mXRAY/VLESS\033[0;34m═════════════${NC}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Port none TLS  : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "Port TLS       : 443, 8443, 2087, 2096, 2053, 2083 "
echo -e "Port gRPC      : 443"
echo -e "ID             : ${uuid}"
echo -e "Encryption     : none"
echo -e "Network        : ws"
echo -e "Path           : /vless"
echo -e "Path           : vless-grpc"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link TLS       : ${vlesslink1}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link none TLS  : ${vlesslink2}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link gRPC      : ${vlesslink3}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Expired On     : $exp"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-vless