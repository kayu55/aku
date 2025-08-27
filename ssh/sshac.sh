#!/bin/bash

clear

# Baca nama pengguna dari config.json, pisahkan username dan tanggal expired, lalu hilangkan duplikat
users=$(grep -E "^#ssh# " "" | sed -E 's/^#ssh# ([^ ]+).*/\1/' | awk '!seen[$0]++')
#useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login

echo -e "\e[97;1m ==================================== \e[0m"
echo -e "\e[97;1m       SHOW SSH USER ACCOUNT          \e[0m"
echo -e "\e[97;1m ==================================== \e[0m"
i=1
for user in $users; do
    echo "$i) $user"
    ((i++))
done

echo -e "\e[97;1m ==================================== \e[0m"
echo ""
# Minta pengguna memilih nomor
read -p " Just input Number: " number

# Dapatkan username berdasarkan nomor yang dipilih
selected_user=$(echo "$users" | sed -n "${number}p")

if [ -z "$selected_user" ]; then
    echo -e "\e[31;1m number is missing or incorrect\e[0m"
    exit 1
fi

# Tampilkan Detail Akun User
clear
cat /etc/scrz-prem/ssh/detail/$selected_user.txt
echo -e "\033[0;33m┌──────────────────────────────────────────┐\033[0m"
echo -e "      Autoscript By Arya Blitar       "
echo -e "\033[0;33m└──────────────────────────────────────────┘\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
exec bash