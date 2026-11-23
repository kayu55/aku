#!/bin/bash
NC='\033[0;37m' 
PURPLE='\033[0;34m' 
GREEN='\033[0;32m' 
RED='\033[0;31m'
BIWhite='\033[1;97m'  
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
function del(){
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m               MEMBER SSH                 \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"      
echo "USERNAME          EXP DATE          STATUS"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "LOCKED${NORMAL}"
else
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "UNLOCKED${NORMAL}"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "\E[42;1;37m                DELETE USER               \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"  
echo ""
read -p "Username SSH to Delete : " Pengguna

if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna > /dev/null 2>&1
        echo -e "User $Pengguna was removed."
else
        echo -e "Failure: User $Pengguna Not Exist."
fi

read -n 1 -s -r -p "Press any key to back on menu"

menu-ssh
}

function ceklim(){
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m          CEK USER MULTILOGIN      \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -e "/root/log-limit.txt" ]; then
echo "User Who Violate The Maximum Limit";
echo "Time - Username - Number of Multilogin"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
cat /root/log-limit.txt
else
echo " No user has committed a violation"
echo " "
echo " or"
echo " "
echo " The user-limit script not been executed."
fi
echo " ";
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " ";
read -n 1 -s -r -p "Press any key to back on menu"
menu

}
function member(){
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m               MEMBER SSH                 \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"      
echo "USERNAME          EXP DATE          STATUS"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "LOCKED${NORMAL}"
else
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "UNLOCKED${NORMAL}"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Account number: $JUMLAH user"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
menu-ssh

}
function autokill(){
clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(grep -c -E "^# Autokill" /etc/cron.d/tendang)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\E[42;1;37m             AUTOKILL SSH          \E[0m"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Status Autokill : $sts        "
echo -e ""
echo -e "[1]  AutoKill After 1 Minutes  - 1 Akun 2 HP"
echo -e "[2]  AutoKill After 5 Minutes"
echo -e "[3]  AutoKill After 10 Minutes"
echo -e "[4]  AutoKill After 15 Minutes"
echo -e "[5]  Turn Off AutoKill/MultiLogin"
echo -e "[x]  Menu"
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -p "Select From Options [1-5 or x] :  " AutoKill
if [[ "$AutoKill" == "x" ]]; then
menu
return
fi
if [[ "$AutoKill" == "5" ]]; then
rm -f /etc/cron.d/tendang
service cron restart
echo -e "Autokill OFF"
sleep 2
menu
return
fi
read -p "Multilogin Maximum Number Of Allowed: " max
echo -e ""
# Tulis cron anyar
echo "# Autokill" > /etc/cron.d/tendang
case $AutoKill in
1) echo "*/1 * * * *  root /usr/bin/tendang $max" >> /etc/cron.d/tendang ;;
2) echo "*/5 * * * *  root /usr/bin/tendang $max" >> /etc/cron.d/tendang ;;
3) echo "*/10 * * * *  root /usr/bin/tendang $max" >> /etc/cron.d/tendang ;;
4) echo "*/15 * * * *  root /usr/bin/tendang $max" >> /etc/cron.d/tendang ;;
*) echo "Pilihan salah!" ; sleep 2 ; autokill ; return ;;
esac
chmod +x /etc/cron.d/tendang
service cron restart
echo -e "Autokill ON - Cek tiap $AutoKill menit - Max $max login"
cat /etc/cron.d/tendang
sleep 2
menu-ssh
}
clear
echo -e "${PURPLE}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE} \E[42;1;37m                     SSH MENU                    ${PURPLE}│$NC"
echo -e "${PURPLE}└─────────────────────────────────────────────────┘${NC}"
echo -e "${PURPLE}┌───────────────────────────────────────────────┐${NC}"
echo -e "     ${GREEN}[1]${NC}  Create Ssh Account "
echo -e "     ${GREEN}[2]${NC}  Trial Ssh Acoount  "
echo -e "     ${GREEN}[3]${NC}  Delete Ssh Acoount  "
echo -e "     ${GREEN}[4]${NC}  Perpanjang Ssh Account  "
echo -e "     ${GREEN}[5]${NC}  Cek User Login "
echo -e "     ${GREEN}[6]${NC}  Cek User Multi Log "
echo -e "     ${GREEN}[7]${NC}  Auto Del User Exp  "
echo -e "     ${GREEN}[8]${NC}  Auto Kill User Ssh "
echo -e "     ${GREEN}[9]${NC}  Cek All Member Ssh "
echo -e "     ${GREEN}[10]${NC} Tendang User Multi"
#echo -e "     ${GREEN}[11]${NC} Cek User Udp Login"
echo -e " "
echo -e "     ${GREEN}[0]${NC} Back To Menu      "
echo -e "${PURPLE}└───────────────────────────────────────────────┘${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; create_ssh ;;
2) clear ; trialssh ;;
3) clear ; del ;;
4) clear ; renewssh ;;
5) clear ; cekssh ;;
6) clear ; ceklim ;;
7) clear ; autodel ;;
8) clear ; autokill ;;
9) clear ; member ;;
10) clear ; tendang ;;
11) clear ; cekudp ;;
0) clear ; menu ;;
*) echo -e "" ; echo "Press any key to back on menu" ; sleep 1 ; menu ;;
esac
