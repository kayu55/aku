#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
COLOR1='\033[0;37m'
clear
echo "Fitur Ini Hanya Bisa Digunakan Sesuai Data Vps Dengan Autoscript Ini"
echo "Silakan masukkan tautan ke file cadangan data vps Anda"
echo ""
read -rp "Link File: " -e url
wget -O backup.zip "$url"
unzip -o backup.zip
rm -f backup.zip
sleep 1
echo "Start Restore"
cd /root/backup
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring passwd data..."
cp /root/backup/passwd /etc/ &> /dev/null
cp /root/backup/group /etc/ &> /dev/null
cp /root/backup/shadow /etc/ &> /dev/null
cp /root/backup/gshadow /etc/ &> /dev/null
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring admin data..."
cp -r /root/backup/scrz-prem/ /var/lib/ &> /dev/null
cp -r /root/backup/.acme.sh /root/ &> /dev/null
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring xray data (config + .BAIK)..."
cp -r /root/backup/xray /etc/ &> /dev/null
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring nginx data (PORT SYNC!)..."
cp -r /root/backup/nginx /etc/ &> /dev/null
rm -rf /root/backup &> /dev/null
rm -f /root/backup.zip
systemctl restart xray &> /dev/null
systemctl restart nginx &> /dev/null
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Done... Successfully"
echo "Done - Port Xray + Nginx sudah SINGKRON, user langsung konek!"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
