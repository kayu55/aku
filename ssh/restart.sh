#!/bin/bash

NC='\e[0m'
green='\033[0;32m' 
clear
echo -e "${green}"
echo -e "======================================"
echo -e "${NC}"
echo -e "    [1] Restart All Services"
echo -e "    [2] Restart OpenSSH"
echo -e "    [3] Restart Dropbear"
echo -e "    [4] Restart Nginx"
echo -e "    [5] Restart Badvpn"
echo -e "    [x] Menu"
echo -e "${green}"
echo -e "======================================${NC}"
echo -e ""
read -p "    Select From Options [1-6 or x] :  " Restart
echo -e "${green}"
echo -e "======================================${NC}"
sleep 1
clear
case $Restart in
                1)
                clear
                systemctl restart ws-stunnel.service >/dev/null 2>&1
                systemctl restart xray.service >/dev/null 2>&1
                /etc/init.d/ssh restart
                /etc/init.d/dropbear restart
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
                ;;
                2)
                clear
                /etc/init.d/ssh restart
                echo -e ""
                echo -e "${green}======================================${NC}"
                echo -e ""
                echo -e "         SSH Service Restarted        "
                echo -e ""
                echo -e "${green}======================================${NC}"
                ;;
                3)
                clear
                /etc/init.d/dropbear restart
                echo -e ""
                echo -e "${green}======================================${NC}"
                echo -e ""
                echo -e "       Dropbear Service Restarted     "
                echo -e ""
                echo -e "${green}======================================${NC}"
                ;;
                4)
                clear
                /etc/init.d/nginx restart
                echo -e ""
                echo -e "${green}======================================${NC}"
                echo -e ""
                echo -e "         Nginx Service Restarted      "
                echo -e ""
                echo -e "${green}======================================${NC}"
                ;;
                5)
                clear
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
                systemctl restart rc-local.service >/dev/null 2>&1
                echo -e ""
                echo -e "${green}======================================${NC}"
                echo -e ""
                echo -e "    Badvpn  Badvpn Service Restarted  "
                echo -e ""
                echo -e "${green}======================================${NC}"
                ;;
                x)
                clear
                menu
                ;;
        esac
read -n 1 -s -r -p "Press any key to back on menu"

menu
