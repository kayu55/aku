#!/bin/bash

NC='\033[0;37m' 
Login="${1:-Trial}"        
masaaktif="${2:-1}"        
iplimit="${3:-1}"
pup=60
user="${Login}vm$(tr -dc 0-9 </dev/urandom | head -c3)"
IP=$(curl -sS ipv4.icanhazip.com)

domain=$(cat /etc/xray/domain)
nama=$(cat /etc/xray/username)
uuid=$(cat /proc/sys/kernel/random/uuid)
domain=$(cat /etc/xray/domain)
clear
cd
echo -e "\033[0;34m┌──────────────────────────────────────────────┐${NC}"
echo -e "\033[0;34m│    \033[0;32m     • Trial Vmess Account •              \033[0;34m│ $NC"
echo -e "\033[0;34m└──────────────────────────────────────────────┘${NC}"
echo -e ""

tgl=$(date -d "$masaaktif days" +"%d")
bln=$(date -d "$masaaktif days" +"%b")
thn=$(date -d "$masaaktif days" +"%Y")
expe="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2 $bln2, $thn2"
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json

cat> /etc/cron.d/trialvmess${user} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root /usr/bin/trialvmess $user $uuid $exp
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


echo sed -i \"/$user/d\" /etc/xray/config.json  | at now + $pup minutes
echo "systemctl restart xray" | at now + $pup minutes
service cron restart > /dev/null 2>&1

clear
echo -e "\033[0;34m═════════════\033[0;33mXRAY/VMESS\033[0;34m═════════════\033[0m"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo -e "Remarks       : ${user}"
echo -e "Expired On    : $pup Minutes" 
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
