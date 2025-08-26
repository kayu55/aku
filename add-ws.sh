#!/bin/bash

NC='\033[0;37m' 
clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
echo -e "\033[0;34m│\E[42;1;37m           Create Xray/Vmess Account            \033[0;34m│"
echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"

		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
            echo -e "\033[0;34m┌─────────────────────────────────────────────────┐\033[0m"
            echo -e "\033[0;34m│\E[42;1;37m           Create Xray/Vmess Account            \033[0;34m│"
            echo -e "\033[0;34m└─────────────────────────────────────────────────┘\033[0m"
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			echo ""
			echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
			read -n 1 -s -r -p "Press any key to back on menu"
menu
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
hariini=`date -d "0 days" +"%Y-%m-%d"`
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
asu=`cat<<EOF
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
ask=`cat<<EOF
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
grpc=`cat<<EOF
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
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"

systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1

clear
echo -e "\033[0;34m═══════════\033[0;33mXRAY/VMESS\033[0;34m═══════════${NC}"
echo -e "\033[0;34m════════════════════════════════${NC}"
echo -e "Remarks       : ${user}"
echo -e "Created       : $hariini"
echo -e "Expired On    : $exp" 
echo -e "Domain        : ${domain}" 
echo -e "Port none TLS : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "Port TLS      : 443, 8443, 2087, 2096, 2053, 2083 "
echo -e "Port gRPC     : 443"
echo -e "id            : ${uuid}" 
echo -e "alterId       : 0" 
echo -e "Security      : auto" 
echo -e "Network       : ws" 
echo -e "Path          : /vmess" 
echo -e "ServiceName   : vmess-grpc" 
echo -e "\033[0;34m════════════════════════════════${NC}" 
echo -e "Link TLS : "
echo -e "${vmesslink1}" 
echo -e "\033[0;34m════════════════════════════════${NC} "
echo -e "Link none TLS : "
echo -e "${vmesslink2}" 
echo -e "\033[0;34m════════════════════════════════${NC} "
echo -e "Link GRPC : "
echo -e "${vmesslink3}"
echo -e "\033[0;34m════════════════════════════════${NC}" 
echo -e "\033[0;32m Sc By Arya Blitar ${NC}" 
echo "" | tee -a /etc/log-create-user.log
rm /etc/xray/$user-tls.json > /dev/null 2>&1
rm /etc/xray/$user-none.json > /dev/null 2>&1
read -n 1 -s -r -p "Press any key to back on menu"
    

menu-vmess
