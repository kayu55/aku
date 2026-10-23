#!/bin/bash
NC='\033[0;37m'
DEFBOLD='\e[39;0m'
RB='\033[0;36m'
GB='\033[0;37m'
YB='\e[33;1m'
BB='\033[0;34m'
MB='\033[0;33m'
CB='\e[35;1m'
WB='\e[37;0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

clear
clear

LOG_FILE="/var/log/xray/access.log"
CONFIG_FILE="/etc/xray/config.json"

data=( $(grep '###' "$CONFIG_FILE" 2>/dev/null | cut -d ' ' -f 2 | sort -u) )

echo -e "\033[0;34m┌──────────────────────────────────────────┐\033[0m"
echo -e "            ALLXRAY USER LOGIN             $NC"
echo -e "\033[0;34m└──────────────────────────────────────────┘\033[0m"
echo -e "\033[1;91m┌──────────────────────────────────────────┐\033[0m"

for akun in "${data[@]}"; do
    [[ -z "$akun" ]] && continue

    hasil=$(awk -v user="$akun" '
        index($0, "email: " user) {
            waktu = $1 " " $2
            if (match($0, /from [^ ]+/)) {
                ip = substr($0, RSTART + 5, RLENGTH - 5)
                sub(/:[0-9]+$/, "", ip)
                if (ip != "") {
                    if (!(ip in seen)) {
                        seen[ip] = 1
                        ips[++n] = ip
                    }
                    last = waktu
                }
            }
        }
        END {
            if (n > 0) {
                print last
                for (i = 1; i <= n; i++) print ips[i]
            }
        }
    ' "$LOG_FILE" 2>/dev/null)

    [[ -z "$hasil" ]] && continue
    lastlogin=$(printf '%s\n' "$hasil" | head -n 1)
    lastlogin=$(printf '%s\n' "$lastlogin" | awk '{split($2,t,"."); print t[1]}')
    mapfile -t ips < <(printf '%s\n' "$hasil" | tail -n +2)

    echo
    echo -e "${NC}user :${GREEN} ${akun} ${NC}"
    echo -e "${MB}Online Jam ${NC}: ${lastlogin} WIB"
    echo -e "${MB}IP Login   ${NC}:"
    i=1
    for ip in "${ips[@]}"; do
        echo -e "  ${NC}${i}. ${GREEN}${ip}${NC}"
        ((i++))
    done
done
echo -e "\033[1;91m└──────────────────────────────────────────┘\033[0m"
echo -e "${GREEN} "
echo -e " Sc Arya Blitar ${NC} "
echo -e " "
read -n 1 -s -r -p " Klik Enter Balik Ke menu"
menu
