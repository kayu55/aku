#!/bin/bash

NC='\033[0;37m' 
clear
cekray=`cat /root/log-install.txt | grep -ow "XRAY" | sort | uniq`
if [ "$cekray" = "XRAY" ]; then
domen=`cat /etc/xray/domain`
else
domen=`cat /etc/v2ray/domain`
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m        Create SSH Account         \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=$(curl -sS ifconfig.me);
opensh=`cat /root/log-install.txt | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1}'`
db=`cat /root/log-install.txt | grep -w "Dropbear" | cut -f2 -d: | awk '{print $1,$2}'`

clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`

if [[ ! -z "${PID}" ]]; then
echo -e "\033[0;34m════════════\033[0;33mSSH ACCOUNTS\033[0;34m══════════${NC}"
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e "Username   : $Login" 
echo -e "Password   : $Pass"
echo -e "Created    : $hariini"
echo -e "Expired On : $exp" 
echo -e "\033[0;34m══════════════════════════════════${NC}"
#echo -e "IP         : $IP" 
echo -e "Host       : $domen" 
echo -e "OpenSSH    : $opensh"
echo -e "Dropbear   : $db" 
echo -e "SSH-WS     : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "SSH WS SSL : 443, 8443, 2087, 2096, 2053, 2083 "
echo -e "SSL/TLS    : 444, 445, 447, 777" 
echo -e "SSH AC    : $domen:443@$Login:$Pass"
echo -e "UDPGW      : 7100-7300" 
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e " "
echo -e "PAYLOD WSOKET : GET / HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e ""
echo -e "PAYLOD WS : GET /cdn-cgi/trace HTTP/1.1[crlf]Host: bug.com[crlf]Connection: Keep-Alive[crlf][crlf]GET-RAY / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]"
echo -e ""
echo -e "PAYLOD WS/TLS : GET wss://[host_port]/ HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e " "
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e "\033[0;32m Sc By Arya Blitar ${NC}" 

else

echo -e "\033[0;34m════════════\033[0;33mSSH ACCOUNTS\033[0;34m══════════${NC}"
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e "Username   : $Login" 
echo -e "Password   : $Pass"
echo -e "Created    : $hariini"
echo -e "Expired On : $exp" 
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e "Host       : $domen" 
echo -e "OpenSSH    : $opensh"
echo -e "Dropbear   : $db" 
echo -e "SSH-WS     : 80, 8080, 8880, 2082, 2086, 2052, 2095"
echo -e "SSH-SSL-WS : 443, 8443, 2087, 2096, 2053, 2083 "
echo -e "SSL/TLS    : 444, 445, 447, 777" 
echo -e "SSH ACC    : $domen:443@$Login:$Pass"
echo -e "UDPGW      : 7100-7300" 
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e " "
echo -e "PAYLOD WSOKET : GET / HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e ""
echo -e "PAYLOD WS : GET /cdn-cgi/trace HTTP/1.1[crlf]Host: bug.com[crlf]Connection: Keep-Alive[crlf][crlf]GET-RAY / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]"
echo -e ""
echo -e "PAYLOD WS/TLS : GET wss://[host_port]/ HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e " "
echo -e "\033[0;34m══════════════════════════════════${NC}"
echo -e "\033[0;32m Sc By Arya Blitar${NC}"
fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
