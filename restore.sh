#!/bin/bash
RED='\033[0;31m'
NC='\033[0;37m'
GREEN='\033[0;32m'
COLOR1='\033[0;37m'
clear
echo "Restore VPS - NON MULTIPATH - Arya Blitar"
echo "Fitur Ini Hanya Bisa Digunakan Sesuai Data Vps Dengan Autoscript Ini"
echo " "
read -rp "Link File: " -e url
wget -O backup.zip "$url"
unzip -o backup.zip
rm -f backup.zip
sleep 1
echo "Start Restore"

# === 1. STOP DISIK BEN GAK TABRAKAN ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Stopping Service..."
systemctl stop xray nginx 2>/dev/null
sleep 1

cd /root/backup
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring passwd data..."
cp /root/backup/passwd /etc/ &> /dev/null
cp /root/backup/group /etc/ &> /dev/null
cp /root/backup/shadow /etc/ &> /dev/null
cp /root/backup/gshadow /etc/ &> /dev/null
cp /root/backup/chap-secrets /etc/ppp/ &> /dev/null
cp -r /root/backup/scrz-prem/ /var/lib/ &> /dev/null
cp -r /root/backup/.acme.sh /root/ &> /dev/null

# === 2. RESTORE XRAY ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring Xray data (Non-Multipath)..."
rm -rf /etc/xray
cp -r /root/backup/xray /etc/ &> /dev/null

# === 3. KUNCI AUTO KONEK: RESTORE NGINX JUGA ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring Nginx..."
mkdir -p /etc/nginx/conf.d/
if [ -f /root/backup/nginx/xray.conf ]; then
  cp /root/backup/nginx/xray.conf /etc/nginx/conf.d/xray.conf
  echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Nginx lawas berhasil dibalekno, Port & Path wes podo"
else
  echo -e "$COLOR1│${NC}  [ ${RED}INFO${NC} ] • Nginx gak ketemu di backup, backup lawas!"
  echo -e "$COLOR1│${NC}  [ ${RED}INFO${NC} ] • Install ulang Xray disik baru restore user tok"
fi

# Restore domain nek ono
if [ -f /root/backup/nginx/domain ]; then
  cp /root/backup/nginx/domain /etc/xray/domain
fi

# === 4. BENERI PERMISSION & CERT ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Fixing Permission..."
chown -R www-data:www-data /etc/xray 2>/dev/null
chmod 644 /etc/xray/config.json 2>/dev/null
chmod 644 /etc/nginx/conf.d/xray.conf 2>/dev/null
# Nek cert ilang, gawe sementara ben nginx iso start
if [ ! -f /etc/xray/xray.crt ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -subj "/CN=localhost" 2>/dev/null
fi

# === 5. TEST & RESTART - IKI SING MARAI AUTO KONEK ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Testing Config..."
nginx -t
/usr/local/bin/xray run -test -config /etc/xray/config.json

echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restarting Service..."
systemctl daemon-reload
systemctl restart xray
sleep 2
systemctl restart nginx
sleep 1

rm -rf /root/backup &> /dev/null
rm -f /root/backup.zip &> /dev/null

echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Done... Successfully"
echo ""
echo -e "STATUS XRAY : $(systemctl is-active xray)"
echo -e "STATUS NGINX: $(systemctl is-active nginx)"
echo ""
echo -e "CEK PORT:"
echo "Xray : $(grep -o '\"port\": [0-9]*' /etc/xray/config.json | head -n 3 | tr '\n' ' ')"
echo "Nginx: $(grep -o '127.0.0.1:[0-9]*' /etc/nginx/conf.d/xray.conf | sort -u | tr '\n' ' ')"
echo ""
echo "Nek loro-lorone ACTIVE, berarti AUTO KONEK, tinggal tes neng HP"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu