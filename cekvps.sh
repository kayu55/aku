#!/bin/bash
UK="\033[0;34m"; WHITE="\033[1;37m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; RED="\033[0;31m"; NC='\033[0m'
clear
echo -e "${UK}┌──────────────────────────────────────────┐${NC}"
echo -e "  ${WHITE}      SALWA1 - STATUS VPS ${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
# IP + UPTIME
IP=$(curl -s ipv4.icanhazip.com)
UP=$(uptime -p | sed 's/up //')
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "IP VPS    : $IP"
echo -e "Uptime    : $UP"
echo -e "Load      : $LOAD"
echo ""
# CPU
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
CPU_INT=${CPU%.*}
if [ "$CPU_INT" -gt 80 ]; then CB="$RED"; elif [ "$CPU_INT" -gt 50 ]; then CB="$YELLOW"; else CB="$GREEN"; fi
echo -e "CPU       : ${CB}$CPU%${NC} ${WHITE}[$(nproc) Core]${NC}"
# RAM
RAM_T=$(free -m | awk 'NR==2{print $2}')
RAM_U=$(free -m | awk 'NR==2{print $3}')
RAM_P=$((RAM_U*100/RAM_T))
if [ "$RAM_P" -gt 80 ]; then RB="$RED"; elif [ "$RAM_P" -gt 50 ]; then RB="$YELLOW"; else RB="$GREEN"; fi
echo -e "RAM       : ${RB}$RAM_U MB / $RAM_T MB ($RAM_P%)${NC}"
# DISK
DISK_U=$(df -h / | awk 'NR==2{print $3}')
DISK_T=$(df -h / | awk 'NR==2{print $2}')
DISK_P=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK_P" -gt 80 ]; then DB="$RED"; elif [ "$DISK_P" -gt 50 ]; then DB="$YELLOW"; else DB="$GREEN"; fi
echo -e "DISK      : ${DB}$DISK_U / $DISK_T ($DISK_P%)${NC}"
echo ""
# PING - Kayak neng Web AkunSSH!
echo -e "${UK}┌──────────────────────────────────────────┐${NC}"
echo -e "  ${WHITE}        PING / KONEKSI ${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
PING_G=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
PING_CF=$(ping -c 1 -W 2 1.1.1.1 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
if [ -z "$PING_G" ]; then PING_G="TIMEOUT"; fi
if [ -z "$PING_CF" ]; then PING_CF="TIMEOUT"; fi
echo -e "Google (8.8.8.8) : $PING_G ms"
echo -e "Cloudflare (1.1.1.1): $PING_CF ms"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
echo ""
echo -e "Ketik ${GREEN}cekvps${NC} maneh gawe refresh!"
