#!/bin/bash
NC='\033[0;37m'
green='\033[0;32m'

clear
echo ""
sleep 1
echo -e "[ ${green}INFO${NC} ] install backup... "

fi
echo -e "[ ${green}INFO${NC} ] Creating service... "
echo -e "[ ${green}INFO${NC} ] Downloading files... "
wget -q -O /usr/bin/backup "https://raw.githubusercontent.com/kayu55/aku/main/backup/backup.sh" && chmod +x /usr/bin/backup
wget -q -O /usr/bin/restore "https://raw.githubusercontent.com/kayu55/aku/main/backup/restore.sh" && chmod +x /usr/bin/restore
wget -q -O /usr/bin/cleaner "https://raw.githubusercontent.com/kayu55/aku/main/backup/cleaner.sh" && chmod +x /usr/bin/cleaner
wget -q -O /usr/bin/autobackup "https://raw.githubusercontent.com/kayu55/aku/main/backup/autobackup.sh" && chmod +x /usr/bin/autobackup

service cron restart > /dev/null 2>&1

rm -f /root/set-br2.sh
