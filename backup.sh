#!/bin/bash
clear
IP=$(wget -qO- ipinfo.io/ip);
date=$(date +"%Y-%m-%d")
email=$(cat /home/email 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)

if [[ "$email" = "" ]]; then
echo "Masukkan Email Untuk Menerima Backup"
read -rp "Email : " -e email
echo "$email" > /home/email
fi

clear
echo "Mohon Menunggu, Proses Backup sedang berlangsung !!"
rm -rf /root/backup
mkdir -p /root/backup

# === DATA UTAMA ===
cp -r /root/.acme.sh /root/backup/ &> /dev/null
cp /etc/passwd /root/backup/ &> /dev/null
cp /etc/group /root/backup/ &> /dev/null
cp /etc/shadow /root/backup/ &> /dev/null
cp /etc/gshadow /root/backup/ &> /dev/null
cp -r /var/lib/scrz-prem/ /root/backup/scrz-prem &> /dev/null

# === XRAY - GAK MULTIPATH ===
cp -r /etc/xray /root/backup/xray &> /dev/null

# === TAMBAHAN PENTING BEN RESTORE AUTO KONEK ===
mkdir -p /root/backup/nginx
cp /etc/nginx/conf.d/xray.conf /root/backup/nginx/ &> /dev/null
cp /etc/xray/domain /root/backup/nginx/domain &> /dev/null
# Simpen info port & path sing aktif
grep -o '"port": [0-9]*' /etc/xray/config.json > /root/backup/xray/ports.txt 2>/dev/null
grep -o '"path": "[^"]*"' /etc/xray/config.json > /root/backup/xray/paths.txt 2>/dev/null

cd /root
zip -r $IP-$date.zip backup > /dev/null 2>&1
rclone copy /root/$IP-$date.zip dr:backup/
url=$(rclone link dr:backup/$IP-$date.zip)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"

echo -e "
Detail Backup Arya Blitar - NON MULTIPATH

IP VPS        : $IP
Domain        : $domain
Link Backup   : $link
Tanggal       : $date

" | mail -s "Backup Data" $email

rm -rf /root/backup
rm -rf /root/$IP-$date.zip
clear
echo -e "
Detail Backup Arya Blitar - NON MULTIPATH

IP VPS        : $IP
Domain        : $domain
Link Backup   : $link
Tanggal       : $date

"
echo "Silahkan copy Link dan restore di VPS baru"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu