#!/bin/bash
UK="\033[0;34m"; WHITE="\033[1;37m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; RED="\033[0;31m"; NC='\033[0m'
LOG=/var/log/cekvps-history.log
if [ "$1" == "cron" ]; then
  P=$(ping -c 1 -W 2 1.1.1.1 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
  if [ -z "$P" ]; then P="0"; fi
  echo "$(date +%s) $P" >> $LOG
  tail -n 40 $LOG > /tmp/cb.tmp && mv /tmp/cb.tmp $LOG
  exit 0
fi
clear
echo -e "${UK}┌──────────────────────────────────────────┐${NC}"
echo -e "  ${WHITE}  ARYA - CEK LATENSI ${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
IP=$(curl -s ipv4.icanhazip.com)
UP=$(uptime -p | sed 's/up //')
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "IP VPS    : $IP"
echo -e "Uptime    : $UP"
echo -e "Load      : $LOAD"
echo ""
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM_T=$(free -m | awk 'NR==2{print $2}'); RAM_U=$(free -m | awk 'NR==2{print $3}'); RAM_P=$((RAM_U*100/RAM_T))
DISK_U=$(df -h / | awk 'NR==2{print $3}'); DISK_T=$(df -h / | awk 'NR==2{print $2}'); DISK_P=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
echo -e "CPU       : $CPU% [$(nproc) Core]"
echo -e "RAM       : $RAM_U MB / $RAM_T MB ($RAM_P%)"
echo -e "DISK      : $DISK_U / $DISK_T ($DISK_P%)"
echo -e "${UK}┌──────────────────────────────────────────┐${NC}"
echo -e "          ${WHITE}PING / KONEKSI${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
PING_G=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
PING_C=$(ping -c 1 -W 2 1.1.1.1 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
if [ -z "$PING_G" ]; then PING_G="TIMEOUT"; else PING_G="$PING_G ms"; fi
if [ -z "$PING_C" ]; then PING_C="TIMEOUT"; else PING_C="$PING_C ms"; fi
echo -e "Google (8.8.8.8)      : ${GREEN}$PING_G${NC}"
echo -e "Cloudflare (1.1.1.1)  : ${GREEN}$PING_C${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
echo ""
echo -e "${UK}┌──────────────────────────────────────────┐${NC}"
echo -e "  ${WHITE}  Indonesia • Online ${GREEN}●${NC}"
echo -e "${UK}└──────────────────────────────────────────┘${NC}"
if [ -f "$LOG" ]; then
  TOTAL=$(wc -l < $LOG); UPCOUNT=$(awk '$2>0' $LOG | wc -l)
  if [ "$TOTAL" -gt 0 ]; then UPTIME_P=$((UPCOUNT*100/TOTAL)); else UPTIME_P=100; fi
  echo -n "Grafik 40 cek terakhir: "
  while read -r TS P; do if [ "$P" == "0" ]; then echo -n "🔴"; else echo -n "🟩"; fi; done < $LOG
  echo ""; echo ""
  CUR=$(tail -n 1 $LOG | awk '{print $2}')
  AVG=$(awk '$2>0{sum+=$2; c++} END{if(c>0) printf "%.1f", sum/c; else print "0"}' $LOG)
  MIN=$(awk '$2>0{if(min==""||$2<min) min=$2} END{print min+0}' $LOG)
  MAX=$(awk '$2>0{if($2>max) max=$2} END{print max+0}' $LOG)
  echo -e "LATENSI TERKINI : ${GREEN}$CUR ms - SANGAT CEPAT${NC}"
  echo -e "RATA-RATA       : $AVG ms"
  echo -e "MIN / MAX       : $MIN / $MAX ms"
  echo -e "UPTIME          : $UPTIME_P% ($UPCOUNT / $TOTAL cek)"
  echo -e "TERAKHIR DIPERIKSA: $(date '+%H:%M:%S') - 40 menit terakhir"
else
  echo "Durung ono data! Tunggu 1 menit, cron lagi ngumpulin data..."
fi
echo -e "${UK}└──────────────────────────────────────────┘${NC}"

echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu