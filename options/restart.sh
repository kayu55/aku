#!/bin/bash

NC='\e[0m'
green='\033[0;32m' 
clear
clear
                systemctl restart ws.service >/dev/null 2>&1
                systemctl restart xray.service >/dev/null 2>&1
                /etc/init.d/ssh restart
                /etc/init.d/dropbear restart
                /etc/init.d/stunnel5 restart
                /etc/init.d/fail2ban restart
                /etc/init.d/cron restart
                /etc/init.d/nginx restart
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000
                systemctl restart rc-local.service
                echo -e ""
                echo -e "${green}======================================${NC}"
                echo -e ""
                echo -e "          Service/s Restarted         "
                echo -e ""
                echo -e "${green}======================================${NC}"
read -n 1 -s -r -p "Press any key to back on menu"

menu
