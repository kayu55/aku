#!/bin/bash

BIGreen='\033[0;32m'
NC='\033[0;37m'
BICyan='\033[0;34m' 
BIWhite='\033[1;97m'  
clear
echo -e "$BICyan┌─────────────────────────────────────────────────┐${NC}"
echo -e "$BICyan│$NC\033[42m                  MENU SETTINGS                  $BICyan│$NC"
echo -e "$BICyan└─────────────────────────────────────────────────┘${NC}"
echo -e " $BICyan┌───────────────────────────────────────────────┐${NC}"
echo -e " $BICyan│${BIGreen}[${BIWhite}1${BIGreen}]${NC}  • Renew Cert"
echo -e " $BICyan│${BIGreen}[${BIWhite}2${BIGreen}]${NC}  • Change Banner SSH "
echo -e " $BICyan│${BIGreen}[${BIWhite}3${BIGreen}]${NC}  • Restart Banner SSH "
echo -e " $BICyan│${BIGreen}[${BIWhite}4${BIGreen}]${NC}  • Info Bandwidth"
echo -e " $BICyan│${BIGreen}[${BIWhite}5${BIGreen}]${NC}  • Restart All Service "
echo -e " $BICyan│${BIGreen}[${BIWhite}6${BIGreen}]${NC}  • Set Auto Reboot"
echo -e " $BICyan│${BIGreen}[${BIWhite}7${BIGreen}]${NC}  • Set Jam Auto Reboot"
echo -e " $BICyan│${BIGreen}[${BIWhite}8${BIGreen}]${NC}  • Reboot Vps"
echo -e " $BICyan│${BIGreen}[${BIWhite}9${BIGreen}]${NC}  • Clear Log"
echo -e " $BICyan│${BIGreen}[${BIWhite}10${BIGreen}]${NC} • Upgrade Versi New Xray"
echo -e " $BICyan│${BIGreen}[${BIWhite}11${BIGreen}]${NC} • Batasi Limit Banwidth Di Vps"
echo -e " $BICyan│${BIGreen}[${BIWhite}0${BIGreen}]${NC}  • Balik Ke Menu"
echo -e " $BICyan└───────────────────────────────────────────────┘${NC}"
echo -e ""
read -p "  Select menu :  "  opt
echo -e   ""
case $opt in
1) clear ; certxray ;;
2) clear ; nano /etc/issue.net ;;
3) clear ; /etc/init.d/dropbear restart ;;
4) clear ; cek-bandwidth ;;
5) clear ; restart ;;
6) clear ; autoreboot ;;
7)clear ; jam ;;
8) clear ; reboot ;;
9) clear ; clearlog ;;
10) clear ; update-xray ;;
11) clear ; set-bw ;;
00 | 0) clear ; menu ;;
*) clear ; menu-set ;;
esac

