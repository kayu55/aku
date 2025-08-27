#!/bin/bash

clear

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
i=1
for user in $users; do
    echo "$i) $AKUN"
    ((i++))
done

echo -e "\e[97;1m ==================================== \e[0m"
echo ""
# Minta pengguna memilih nomor
read -p " Just input Number: " number

# Dapatkan username berdasarkan nomor yang dipilih
selected_user=$(echo "$JUMLAH" | sed -n "${number}p")

if [ -z "$selected_user" ]; then
    echo -e "\e[31;1m number is missing or incorrect\e[0m"
    exit 1
fi

# Tampilkan Detail Akun User
clear
echo -e "\033[0;33m┌──────────────────────────────────────────┐\033[0m"
echo -e "      Autoscript By Arya Blitar       "
echo -e "\033[0;33m└──────────────────────────────────────────┘\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
exec bash