#!/bin/bash
clear

function con() {
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575)/1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}

# Direktori untuk penyimpanan limit
mkdir -p /etc/aryapro/limit
echo -n > /tmp/other.txt

red="\033[31m"
softex="\033[0m"
# Ambil daftar username dari file konfigurasi
data=( $(cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq) )

g="\033[92;1m"
w="\033[97;1m"
x="\033[0m"

name="${g} LIST NAME ${x}"
ipku="${g} IP-LOG   ${x}"
quta="${g} QUOTA/USAGE${x}"
expq="${g} EXPIRY IN ${x}"

# Header
        echo -e "\033[97;1m==========================================================\033[0m"
        echo -e "\033[97;1m                  VMESS MONITOR ACCESS                    \033[0m"
        echo -e "\033[97;1m==========================================================\033[0m"
    # Cetak garis atas tabel
        echo -e "\033[1;37m┌─────────────┬────────────┬──────────────┬──────────────┐\033[0m"
        echo -e "\033[97;1m│ $name │ $ipku │ $quta │ $expq  │\033[0m"
        echo -e "\033[1;37m└─────────────┴────────────┴──────────────┴──────────────┘\033[0m"        
# Memeriksa setiap akun dan menampilkan informasi
for akun in "${data[@]}"
do
    if [[ -z "$akun" ]]; then
        akun="tidakada"
    fi
    # Mendapatkan tanggal kedaluwarsa akun
    EXPIRY_DATE=$(grep "### $akun" /etc/aryapro/vmess/.vmess.db | cut -d ' ' -f 3 | sort | uniq)
    
    if [[ -n "$EXPIRY_DATE" ]]; then
        # Memeriksa apakah tanggal kedaluwarsa valid
        if date -d "$EXPIRY_DATE" &>/dev/null; then
            # Mengonversi tanggal kedaluwarsa menjadi sisa hari
            DAYS_LEFT=$(( ( $(date -d "$EXPIRY_DATE" +%s) - $(date +%s) ) / 86400 )) # Menghitung sisa hari
            
        else
            DAYS_LEFT="Invalid Date"
        fi
    else
        DAYS_LEFT="Expired"
    fi

    # Jika tanggal kedaluwarsa sudah habis atau tidak valid, tampilkan status yang sesuai
    if [[ "$DAYS_LEFT" == "Expired" || "$DAYS_LEFT" == "Invalid Date" ]]; then
        DAYS_LEFT="${red}Expired${softex}"
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
        IP=$(cat /etc/aryapro/vmess/ip/${akun})
        LOGN=$(cat /tmp/ipvmess.txt | wc -l)
        byte=$(cat /etc/aryapro/vmess/usage/${akun})
        LIMQ=$(con ${byte})
        wey=$(cat /etc/limit/vmess/${akun})
        USQU=$(con ${wey})
        lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 2 | tail -1)


    # Tampilan informasi akun
        printf "\033[97;1m│ %-11s │ %-10s │ %-12s │ %-12s │\033[0m\n" "$akun" "$IP/$LOGN IP" "$LIMQ/$USQU" "$DAYS_LEFT days"

    fi
    rm -rf /tmp/ipvmess.txt
done

        echo -e "\033[1;37m└─────────────┴────────────┴──────────────┴──────────────┘\033[0m"        
        
rm -rf /tmp/other.txt

echo -e "\033[0;33m┌──────────────────────────────────────────┐\033[0m"
echo -e "      Autoscript By Arya Blitar       "
echo -e "\033[0;33m└──────────────────────────────────────────┘\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
exec bash