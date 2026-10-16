#!/bin/bash

NC='\033[0;37m' 
MYIP=$(curl -sS ipv4.icanhazip.com)

clear
Login="${1:-Trial}"        
masaaktif="${2:-1}"        
iplimit="${3:-1}"
Quota="${4:-1}"
pup=60
user="${Login}VL$(tr -dc 0-9 </dev/urandom | head -c3)"
IP=$(curl -sS ipv4.icanhazip.com)

ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
nama=$(cat /etc/xray/username)
uuid=$(cat /proc/sys/kernel/random/uuid)
clear
tgl=$(date -d "$masaaktif days" +"%d")
bln=$(date -d "$masaaktif days" +"%b")
thn=$(date -d "$masaaktif days" +"%Y")
expe="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
tnggl="$tgl2 $bln2, $thn2"
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#vless$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

vlesslink1="vless://${uuid}@bug.com:443?path=/vless&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@bug.com:80?path=/vless&security=none&host=${domain}&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${user}"


if [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
fi

if [[ $iplimit -gt 0 ]]; then
mkdir -p /etc/kyt/limit/vless/ip
echo -e "$iplimit" > /etc/kyt/limit/vless/ip/$user
else
echo > /dev/null
fi

if [ -z ${Quota} ]; then
  Quota="0"
fi

c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/vless/${user}
fi
DATADB=$(cat /etc/vless/.vless.db | grep "^###" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/vless/.vless.db
  echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/vless/.vless.db
else
echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/vless/.vless.db
fi

    systemctl restart xray > /dev/null 2>&1
		echo sed -i \"/$user/d\" /etc/xray/config.json  | at now + $pup minutes

echo "systemctl restart xray" | at now + $pup minutes

notif_vl
clear

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
echo -e "Expired On     : $pup Minutes"
echo -e "\033[0;34m════════════════════════════════════\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-vless