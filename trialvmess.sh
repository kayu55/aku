#!/bin/bash

Login="${1:-Trial}"        
masaaktif="${2:-1}"        
iplimit="${3:-1}"
Quota="${4:-1}"
pup=30
user="${Login}VM$(tr -dc 0-9 </dev/urandom | head -c3)"
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
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json

asu=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
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
      "add": "${domain}",
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



clear
if [ ! -e /etc/vmess ]; then
  mkdir -p /etc/vmess
fi

if [[ $iplimit -gt 0 ]]; then
mkdir -p /etc/kyt/limit/vmess/ip
echo -e "$iplimit" > /etc/kyt/limit/vmess/ip/$user
else
echo > /dev/null
fi

if [ -z ${Quota} ]; then
  Quota="0"
fi

c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/vmess/${user}
fi
DATADB=$(cat /etc/vmess/.vmess.db | grep "^###" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
	sed -i "/\b${user}\b/d" /etc/vmess/.vmess.db
	echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/vmess/.vmess.db
else
echo "### ${user} ${exp} ${uuid} ${Quota} ${iplimit}" >>/etc/vmess/.vmess.db
fi
    systemctl restart xray > /dev/null 2>&1
		echo sed -i \"/$user/d\" /etc/xray/config.json  | at now + $pup minutes

echo "systemctl restart xray" | at now + $pup minutes
clear
echo -e " VMESS XRAY "

echo -e " Remark       : ${user}"
echo -e " Domain        : ${domain}"
echo -e " Port TLS      : 400,8443"
echo -e " port WS       : 80,8880,8080,2082"
echo -e " Key           : ${uuid}"
echo -e " Localtions    : $CITY"
echo -e " ISP           : $ISP"
echo -e " AlterId       : 0"
echo -e " Security      : auto"
echo -e " Network       : ws"
echo -e " Path          : /vmess"
echo -e " ServiceName   : vmess-grpc"

echo -e " Link TLS      : ${vmesslink1}"
echo -e " Link WS       : ${vmesslink2}"
echo -e " Link GRPC     : ${vmesslink3}"

echo -e " Days in    : $masaaktif Day "
echo -e " Expiry in  : $pup Minutes "