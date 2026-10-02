#!/bin/bash

NC='\033[0;37m' 
PURPLE='\033[0;34m' 
GREEN='\033[0;32m' 
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# // Export Align
export BOLD="\e[1m"
export WARNING="${red}\e[5m"
export UNDERLINE="\e[4m"

clear
clear
domen=`cat /etc/xray/domain`
#portsshws=`cat ~/log-install.txt | grep -w "SSH Websocket" | cut -d: -f2 | awk '{print $1}'`
#wsssl=`cat /root/log-install.txt | grep -w "SSH SSL Websocket" | cut -d: -f2 | awk '{print $1}'`
clear
#IP=$(curl -sS ifconfig.me);
#ossl=`cat /root/log-install.txt | grep -w "OpenVPN" | cut -f2 -d: | awk '{print $6}'`
opensh=`cat /root/log-install.txt | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1}'`
db=`cat /root/log-install.txt | grep -w "Dropbear" | cut -f2 -d: | awk '{print $1,$2}'`
ssl="$(cat ~/log-install.txt | grep -w "Stunnel5" | cut -d: -f2)"
#sqd="$(cat /root/log-install.txt | grep -w "Squid" | cut -d: -f2)"
#OhpSSH=`cat /root/log-install.txt | grep -w "OHP SSH" | cut -d: -f2 | awk '{print $1}'`

Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
echo -e "\033[0;34m________________\033[0m"
echo -e "Settings Triall   "
echo -e "\033[0;34m________________\033[0m"
echo -e ""
echo -e ""
echo -e "\033[0;34m________________\033[0m"
read -p " Menit : " pup
echo -e "\033[0;34m________________\033[0m"
hari="1"
Pass=1
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
clear

echo userdel -f "$Login" | at now + $pup minutes
echo "tunnel ssh ${Login}" | at now +$pup minutes &> /dev/null
clear
echo -e "${PURPLE}═════════════\033[0;33mSSH ACCOUNTS\033[0;34m═══════════${NC}"
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "Username   : $Login" 
echo -e "Password   : $Pass"
echo -e "Expired On : $pup menit" 
echo -e "${PURPLE}════════════════════════════════════${NC}"
#echo -e "IP         : $IP" 
echo -e "Host       : $domen" 
echo -e "OpenSSH    : $opensh"
echo -e "Dropbear   : $db" 
echo -e "SSH-WS     : 80, 8080, 8880, 2082, 2086, 2052, 2095" 
echo -e "SSH WS SSL : 443, 8443, 2087, 2096, 2053, 2083 " 
echo -e "SSL/TLS    :$ssl" 
echo -e "SSH HTTP   : $domen:80@$Login:$Pass"
#echo -e "Link Ovpn  : http://$domen:81"
echo -e "UDPGW      : 7100-7300" 
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "PAYLOD WS : GET / HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e ""
echo -e "PAYLOD WS/TLS : GET wss://[host_port]/ HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e " "
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "\033[0;32m Sc By Arya Blitar${NC}" 

#else
clear
echo -e "${PURPLE}═════════════\033[0;33mSSH ACCOUNTS\033[0;34m═══════════${NC}"
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "Username   : $Login" 
echo -e "Password   : $Pass"
echo -e "Expired On : $pup menit" 
echo -e "${PURPLE}════════════════════════════════════${NC}"
#echo -e "IP         : $IP" 
echo -e "Host       : $domen" 
echo -e "OpenSSH    : $opensh"
echo -e "Dropbear   : $db" 
echo -e "SSH-WS     : 80, 8080, 8880, 2082, 2086, 2052, 2095" 
echo -e "SSH WS SSL : 443, 8443, 2087, 2096, 2053, 2083 " 
echo -e "SSL/TLS    :$ssl" 
echo -e "SSH HTTP   : $domen:80@$Login:$Pass"
#echo -e "Link Ovpn  : http://$domen:81"
echo -e "UDPGW      : 7100-7300" 
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "PAYLOD WS : GET / HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e " "
echo -e "PAYLOD WS/TLS : GET wss://[host_port]/ HTTP/1.1[crlf]Host: [host_port][crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
echo -e " "
echo -e "${PURPLE}════════════════════════════════════${NC}"
echo -e "\033[0;32m Sc By Arya Blitar${NC}"
#fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
