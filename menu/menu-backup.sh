#!/bin/bash

NC='\e[0m'
BICyan='\033[0;34m'
Cok='\033[0;33m'

clear
echo -e "${BICyan}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan}│\E[42;1;37m                   BACKUP MENU                   ${BICyan}│$NC"
echo -e "${BICyan}└─────────────────────────────────────────────────┘${NC}"
echo -e " ${BICyan}┌───────────────────────────────────────────────┐${NC}"
echo -e " ${BICyan}│$NC   ${Cok}[1]${NC} • Backup"
echo -e " ${BICyan}│$NC   ${Cok}[2]${NC} • Restore"
echo -e " ${BICyan}│$NC   ${Cok}[3]${NC} • Auto-Backup"
echo -e " ${BICyan}│$NC   ${Cok}[4]${NC} • Clear Data "
echo -e " ${BICyan}│$NC   ${Cok}[0]${NC} • Back To Menu"
echo -e " ${BICyan}└───────────────────────────────────────────────┘${NC}"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; backup ;;
02 | 2) clear ; restore ;;
03 | 3) clear ; autobackup ;;
04 | 4) clear ; cleaner ;;
00 | 0) clear ; menu ;;
*) clear ; menu-backup ;;
esac
