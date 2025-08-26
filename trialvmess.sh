#!/bin/bash

NC='\033[0;37m' 
domain=$(cat /etc/xray/domain)
clear
cd
echo -e "\033[0;34m┌──────────────────────────────────────────────┐${NC}"
echo -e "\033[0;34m│    \033[0;32m     • Trial Vmess Account •              \033[0;34m│ $NC"
echo -e "\033[0;34m└──────────────────────────────────────────────┘${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "Expired (Minutes): " timer
done
user=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=0
if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
#c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
#d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${user}
fi
echo "${iplim}" > /etc/vmess/${user}IP
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
cat> /etc/cron.d/trialvmess${user} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root /usr/bin/trial vmess $user $uuid $exp
EOF
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
echo -e "\033[0;34m═════════════\033[0;33mXRAY/VMESS\033[0;34m═════════════\033[0m"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Remarks       : ${user}"
echo -e "Expired On    : $timer Minutes" 
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
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link TLS       : ${vmesslink1}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link none TLS  : ${vmesslink2}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Link gRPC      : ${vmesslink3}"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e " SELAMAT MENIKMATI TRIAL DARI KAMI"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"

menu-vmess
