#!/bin/bash
clear

# Ambil daftar username dari file konfigurasi
data=( $(cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq) )

name="${g} LIST NAME ${x}"
ipku="${g} IP-LOG   ${x}"

echo -e "\033[\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "         CEK ALLVRAY ACCOUNT            \e[0m"
echo -e "\033[\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;91m┌──────────────────────────────────────┐\033[0m"
for akun in "${data[@]}"
do
    if [[ -z "$akun" ]]; then
        akun="tidakada"
    fi


    # Mendapatkan daftar IP yang login untuk setiap akun
    echo -n > /tmp/ipvmess.txt
    data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`)
    for ip in "${data2[@]}"
    do
        jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
        if [[ "$jum" = "$ip" ]]; then
            echo "$jum" >> /tmp/ipvmess.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi
        jum2=$(cat /tmp/ipvmess.txt)
        sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
    done
    jum=$(cat /tmp/ipvmess.txt)
    if [[ -z "$jum" ]]; then
        echo > /dev/null
    else
        #IP=$(cat /etc/vmess/ip/${akun})
        LOGN=$(cat /tmp/ipvmess.txt | wc -l)
        #byte=$(cat /etc/vmess/usage/${akun})
        #LIMQ=$(con ${byte})
        #wey=$(cat /etc/limit/vmess/${akun})
        #USQU=$(con ${wey})
        lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 2 | tail -1)

    # Tampilan informasi akun
        printf "\033[97;1m│ %-11s │ %-10s  %-12s  %-12s \033[0m\n" "$akun" "$IP / $LOGN IP"

    fi
    rm -rf /tmp/ipvmess.txt
done
echo -e "\033[1;91m└──────────────────────────────────────┘\033[0m"
        
rm -rf /tmp/other.txt

echo ""
echo -e " "
echo -e "\033[0;32mSc Arya Blitar \033[0m "
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"

menu
echo -e "\033[0;32mSc Arya Blitar \033[0m "
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"

menu
exec bash