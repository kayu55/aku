#!/bin/bash

clear

# Baca nama pengguna dari config.json, pisahkan username dan tanggal expired, lalu hilangkan duplikat
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
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
echo -e "\033[0;33m┌──────────────────────────────────────────┐\033[0m"
echo -e "      Autoscript By Arya Blitar       "
echo -e "\033[0;33m└──────────────────────────────────────────┘\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
exec bash